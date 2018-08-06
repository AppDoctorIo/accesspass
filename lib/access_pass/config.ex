defmodule AccessPass.Config do
  @moduledoc false
  def unquote(:repo)() do
    Application.get_env(:access_pass, unquote(:repo)) || AccessPass.Repo
  end

  def unquote(:overrides_mod)() do
    Application.get_env(:access_pass, unquote(:overrides_module)) || AccessPass.Overrides
  end

  def unquote(:base_url)() do
    Application.get_env(:access_pass, unquote(:base_url)) || "https://api.example.com"
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

end