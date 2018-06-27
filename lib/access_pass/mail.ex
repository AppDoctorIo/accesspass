defmodule AccessPass.Mail do
  @moduledoc false
  import Bamboo.Email
  alias AccessPass.Mailer

  import AccessPass.Config

  def send_confirmation_email(to, conf_key) do
    body = confirmation_email()

    templated_body = EEx.eval_string(body, conf_key: conf_key)
    send_mail(to, from(), confirmation_subject(), templated_body)
  end

  def send_password_reset_email(to, password_key) do
    body = password_reset()
    templated_body = EEx.eval_string(body, password_key: password_key)
    send_mail(to, from(), reset_password_subject(), templated_body)
  end

  def send_forgot_username_email(to, user_name) do
    body = forgot_username()
    templated_body = EEx.eval_string(body, user_name: user_name)
    send_mail(to, from(), forgot_username_subject(), templated_body)
  end

  def send_mail(_, nil, _, _) do
    IO.inspect("please set from in config in order to send any emails")
  end

  def send_mail(to, from, subject, content) do
    new_email(
      to: to,
      from: from,
      subject: subject,
      html_body: content
    )
    |> Mailer.deliver_now()
  end
end
