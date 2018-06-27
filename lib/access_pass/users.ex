defmodule AccessPass.Users do
  @moduledoc false
  @chars "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz123456789"
         |> String.split("", trim: true)
  use Ecto.Schema
  import Ecto.Changeset
  alias AccessPass.GateKeeper
  import AccessPass.Config
  @primary_key {:user_id, :string, autogenerate: false}
  schema "users" do
    field(:username, :string)
    field(:meta, :map, default: %{})
    field(:email, :string)
    field(:password_hash, :string)
    field(:successful_login_attempts, :integer, default: 1)
    field(:password, :string, virtual: true)
    field(:confirmed, :boolean, default: false)
    field(:confirm_id, :string)
    field(:password_reset_key, :string)
    field(:password_reset_expire, :integer)

    timestamps()
  end

  @required_fields ~w(username email password)
  @optional_fields ~w(confirm_id meta password_reset_key password_reset_expire)
  def genId() do
    Ecto.UUID.generate() |> Base.encode64(padding: false)
  end

  def changeset(schema, params \\ :empty) do
    schema
    |> cast(params, @required_fields ++ @optional_fields)
  end

  def create_user_changeset(params) do
    changeset(%AccessPass.Users{}, params)
    |> id_gen().gen_user_id()
    |> put_user_id
    |> gen_confirmed_id
    |> validate_email
    |> validate_required([:username, :email, :password])
    |> validate_length(:username, min: 3, max: 36)
    |> validate_length(:email, min: 3, max: 256)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:email)
    |> unique_constraint(:user_id)
    |> unique_constraint(:username)
    |> add_hash
    |> custom_change().custom()
  end

  def update_password(changeset, params) do
    changeset(changeset, params)
    |> not_expired
    |> validate_length(:password, min: 6)
    |> add_hash
    |> null_password_fields
  end

  def not_expired(changeset) do
    cond do
      changeset
      |> get_field(:password_reset_expire)
      |> GateKeeper.isExpired() ->
        add_error(changeset, :password_reset_expire, "Password reset expired.")

      true ->
        changeset
    end
  end

  def null_password_fields(changeset) do
    changeset
    |> change(%{password_reset_key: nil})
    |> change(%{password_reset_expire: nil})
  end

  def inc(changeset, key, num) do
    changeset
    |> change(%{key => num + 1})
  end

  def update_key(changeset, key, val) do
    changeset
    |> change(%{key => val})
  end

  def validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/@/)
  end

  def add_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))

      _ ->
        changeset
    end
  end

  def gen_confirmed_id(changeset) do
    changeset |> put_change(:confirm_id, genId())
  end

  def custom(changeset) do
    changeset
  end

  def after_insert(changeset) do
    changeset
  end

  def put_user_id({changeset, user_id}) do
    changeset |> put_change(:user_id, user_id)
  end

  def gen_user_id(changeset) do
    user_id = string_of_length(id_len())

    case repo().get(AccessPass.Users, user_id) do
      %AccessPass.Users{} -> gen_user_id(changeset)
      _ -> {changeset, user_id}
    end
  end

  defp string_of_length(len) do
    Enum.reduce(1..len, [], fn _i, acc ->
      [Enum.random(@chars) | acc]
    end)
    |> Enum.join("")
  end
end
