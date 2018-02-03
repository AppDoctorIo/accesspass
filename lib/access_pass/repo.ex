defmodule AccessPass.Repo do
	@moduledoc false
  if Application.get_env(:access_pass, :repo) == nil do
    use Ecto.Repo, otp_app: :access_pass
  end
end
