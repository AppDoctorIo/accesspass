defmodule AccessPass.EmailTemplates do
  @moduledoc false
  def confirmation_email() do
    """
    <p>Hi,</p>
    <p> Please go to the link below to activate your account</p>
    <a href="https://api.example.com/confirm/<%= conf_key %>">Confirm email</a>
    <p>If you did not sign up for an account please disregard this email.</p>
    <p>Thanks,</p> 
    <p>EXAMPLE COMPANY NAME</p>
    """
  end

  def password_reset() do
    """
    <p>Hi,</p>
    <p> No need to worry, you can reset your password by clicking the link below:</p>
    <a href="https://api.example.com/password-reset/<%= password_key %>">Reset password</a>

    <p>Thanks,</p>
    <p>EXAMPLE COMPANY NAME</p>
    </p>
    """
  end

  def forgot_username() do
    """
    <p>Hi,</p>
    <p>Your username is <%= user_name %><p>
    <p>Thanks,</p>
    <p>EXAMPLE COMPANY NAME</p>
    """
  end
end
