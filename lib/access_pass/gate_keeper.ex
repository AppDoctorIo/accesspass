defmodule AccessPass.Gettext do
  @moduledoc false
  use Gettext, otp_app: :access_pass
end

defmodule AccessPass.GateKeeper do
  @moduledoc false
  alias AccessPass.{Mail, Users, AccessToken, RefreshToken}
  import AccessPass.Config
  import Ecto.Query

  def genToken() do
    Ecto.UUID.generate() |> Base.encode64(padding: false)
  end

  defdelegate check(access_token), to: AccessToken
  defdelegate refresh(refresh_token), to: RefreshToken

  def register(user_obj) do
    with {:ok, user} <- create_and_insert(user_obj),
         _ <- Mail.send_confirmation_email(user.email, user.confirm_id),
         {:ok, token_body} <- overrides_mod().after_login(user) do
      {:ok,
       RefreshToken.add(
         user.user_id,
         token_body,
         refresh_expire_in()
       ) |> overrides_mod().login_return(user)} 
    else
      {:error, changeset} ->
        {:error, changeset |> Ecto.Changeset.traverse_errors(&translate_error/1)}

      _ ->
        {:error, "error registering account"}
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

  def change_password(password_id, new_password,password_confirm) do
    with %Users{} = user <- repo().get_by(Users, password_reset_key: password_id),
         {:ok, %AccessPass.Users{}} <-
           AccessPass.Users.update_password(user, %{password: new_password, password_confirm: password_confirm}) |> repo().update() do
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
    with {:ok, user} <- login(username, password),
         {:ok, token_body} <- overrides_mod().after_login(user) do
      {:ok,
       RefreshToken.add(
         user.user_id,
         token_body,
         refresh_expire_in()
       ) |> overrides_mod().login_return(user)}
    else
      {:error} -> {:error, "username or password is incorrect"}
      _ -> {:error, "error with login endpoint"}
    end
  end

  def bypass_log_in(username) do
    with {:ok, user} <- bypass_login(username),
         {:ok, token_body} <- overrides_mod().after_login(user) do
      {:ok,
       RefreshToken.add(
         user.user_id,
         token_body,
         refresh_expire_in()
       )
       |> overrides_mod().login_return(user)}
    else
      {:error} -> {:error, "username incorrect"}
      _ -> {:error, "error with bypass login endpoint"}
    end
  end

  def confirm(confirm_id) do
    with %AccessPass.Users{} = user <- repo().get_by(Users, confirm_id: confirm_id),
         {:ok, _} <- Users.update_key(user, :confirmed, true) |> repo().update(),
         {:ok} <- overrides_mod().after_confirm(user) do
      {:ok, "email confirmed"}
    else
      _ -> {:error, "email confirmation failed"}
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
  defp create_and_insert(user_obj) do
    Users.create_user_changeset(user_obj)
    |> overrides_mod().insert_override(user_obj)
    |> overrides_mod().after_insert()
  end

  defp login_query(username) do
    from(
      u in Users,
      where: fragment("lower(?)", u.username) == fragment("lower(?)", ^username) or fragment("lower(?)", u.email) == fragment("lower(?)", ^username)
    ) |> repo().one
  end

  defp login(username, password) do
    with %Users{} = user <- login_query(username),
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

  defp bypass_login(username) do
    with %Users{} = user <- login_query(username),
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
