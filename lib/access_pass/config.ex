defmodule AccessPass.Config do
  @moduledoc false
  def unquote(:repo)() do
    Application.get_env(:access_pass, unquote(:repo)) || AccessPass.Repo
  end

  def unquote(:confirmation_email)() do
    apl(
      Application.get_env(:access_pass, unquote(:confirmation_template)) ||
        {AccessPass.EmailTemplates, :confirmation_email, []}
    )
  end

  def unquote(:password_reset)() do
    apl(
      Application.get_env(:access_pass, unquote(:password_reset_template)) ||
        {AccessPass.EmailTemplates, :password_reset, []}
    )
  end

  def unquote(:forgot_username)() do
    apl(
      Application.get_env(:access_pass, unquote(:forgot_username_template)) ||
        {AccessPass.EmailTemplates, :forgot_username, []}
    )
  end

  def unquote(:custom_change)() do
    Application.get_env(:access_pass, unquote(:custom_change_mod)) || AccessPass.Users
  end

  def unquote(:after_insert)() do
    Application.get_env(:access_pass, unquote(:after_insert_mod)) || AccessPass.Users
  end

  def unquote(:insert_override)() do
    Application.get_env(:access_pass, unquote(:insert_override_mod)) || AccessPass.GateKeeper
  end

  def unquote(:id_gen)() do
    Application.get_env(:access_pass, unquote(:id_gen_mod)) || AccessPass.Users
  end

  def unquote(:refresh_expire_in)() do
    Application.get_env(:access_pass, unquote(:refresh_expire_in)) || 0
  end

  def unquote(:access_expire_in)() do
    Application.get_env(:access_pass, unquote(:access_expire_in)) || 300
  end

  def unquote(:id_len)() do
    Application.get_env(:access_pass, unquote(:id_len)) || 6
  end

  def unquote(:from)() do
    Application.get_env(:access_pass, unquote(:from))
  end

  def unquote(:confirmation_subject)() do
    Application.get_env(:access_pass, unquote(:confirmation_subject)) || "Confirmation email"
  end

  def unquote(:reset_password_subject)() do
    Application.get_env(:access_pass, unquote(:reset_password_subject)) || "Reset your password"
  end

  def unquote(:forgot_username_subject)() do
    Application.get_env(:access_pass, unquote(:forgot_username_subject)) || "Forgot Username"
  end

  def apl({mod, func, arg}) do
    apply(mod, func, arg)
  end
end
