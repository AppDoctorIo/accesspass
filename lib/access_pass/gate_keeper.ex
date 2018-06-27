defmodule AccessPass.GateKeeper do
  @moduledoc false
  alias AccessPass.{Mail, Users, AccessToken, RefreshToken}
  import AccessPass.Config

  def genToken() do
    Ecto.UUID.generate() |> Base.encode64(padding: false)
  end

  defdelegate check(access_token), to: AccessToken
  defdelegate refresh(refresh_token), to: RefreshToken

  def register(user_obj) do
    case create_and_insert(user_obj) do
      {:ok, user} ->
        Mail.send_confirmation_email(user.email, user.confirm_id)

        {:ok,
         RefreshToken.add(
           user.user_id,
           %{
             user_id: user.user_id,
             email_confirmed: user.confirmed,
             email: user.email,
             username: user.username,
             meta: user.meta
           },
           refresh_expire_in()
         )}

      {:error, changeset} ->
        {:error, changeset |> Ecto.Changeset.traverse_errors(&translate_error/1)}
    end
  end

  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(AccessPass.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(AccessPass.Gettext, "errors", msg, opts)
    end
  end

  def forgot_username(email) do
    case repo().get_by(Users, email: email) do
      nil ->
        {:error, "failed to find user"}

      %AccessPass.Users{} = user ->
        case Mail.send_forgot_username_email(user.email, user.username) do
          %Bamboo.Email{} -> {:ok, "sent email with related username"}
          {:error, _} -> {:error, "error sending email"}
        end
    end
  end

  def log_out(access_token) do
    AccessToken.revoke(access_token)
  end

  def change_password(password_id, new_password) do
    with %Users{} = user <- repo().get_by(Users, password_reset_key: password_id),
         {:ok, %AccessPass.Users{}} <-
           AccessPass.Users.update_password(user, %{password: new_password}) |> repo().update() do
      {:ok}
    else
      {:error, changeset} ->
        {:error, changeset |> Ecto.Changeset.traverse_errors(&translate_error/1)}

      nil ->
        {:error, "reset for account does not exist"}
    end
  end

  def reset_password(username) do
    password_key = genToken()

    case repo().get_by(Users, username: username) do
      nil ->
        {:error, "failed to request reset password"}

      %AccessPass.Users{} = user ->
        with usr <-
               Users.update_key(user, :password_reset_key, password_key)
               |> Users.update_key(:password_reset_expire, timeNowInUnix() + 2 * 60 * 60),
             {:ok, _} <- repo().update(usr),
             %Bamboo.Email{} <- Mail.send_password_reset_email(user.email, password_key) do
          {:ok, "password reset sent to accounts email"}
        else
          _ -> {:error, "failed to request reset password"}
        end
    end
  end

  def log_in(username, password) do
    case login(username, password) do
      {:ok, user} ->
        {:ok,
         RefreshToken.add(
           user.user_id,
           %{
             user_id: user.user_id,
             email_confirmed: user.confirmed,
             email: user.email,
             username: user.username,
             meta: user.meta
           },
           refresh_expire_in()
         )}

      {:error} ->
        {:error, "username or password is incorrect"}
    end
  end

  def confirm(confirm_id) do
    case repo().get_by(Users, confirm_id: confirm_id) do
      nil ->
        {:error, "User confirmation failed"}

      %AccessPass.Users{} = user ->
        Users.update_key(user, :confirmed, true) |> repo().update() |> return_from_conf
    end
  end

  def timeNowInUnix() do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  def isExpired(unix) do
    timeNowInUnix() >= unix
  end

  def formatTokens(refresh_token, access_token, expire_in) do
    %{
      refresh_token: refresh_token,
      access_token: access_token,
      type: "basic",
      access_expire_in: access_expire_in(),
      refresh_expire_in: expire_in
    }
  end

  # Private functions
  # ===================================================== 
  def insert_override(changeset) do
    repo().insert(changeset)
  end

  defp create_and_insert(user_obj) do
    Users.create_user_changeset(user_obj)
    |> insert_override().insert_override()
    |> after_insert().after_insert()
  end

  defp return_from_conf({:ok, _}) do
    {:ok, "email confirmed"}
  end

  defp return_from_conf(_) do
    {:error, "email confirmation failed"}
  end

  defp login(username, password) do
    with %Users{} = user <- repo().get_by(Users, username: username),
         true <- Comeonin.Bcrypt.checkpw(password, user.password_hash),
         {:ok, user} <-
           user
           |> Users.inc(:successful_login_attempts, user.successful_login_attempts)
           |> repo().update() do
      {:ok, user}
    else
      _ -> {:error}
    end
  end
end
