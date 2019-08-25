defmodule AccessPass.Repo do
  @moduledoc false
  IO.inspect(Application.get_env(:access_pass, :repo))
  if Application.get_env(:access_pass, :repo) == nil do
    use Ecto.Repo, otp_app: :access_pass
  end
end
