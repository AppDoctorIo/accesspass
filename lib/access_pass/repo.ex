defmodule AccessPass.Repo do
  @moduledoc false
  import AccessPass.Config
  if repo() == nil do
    use Ecto.Repo, otp_app: :access_pass
  end
end
