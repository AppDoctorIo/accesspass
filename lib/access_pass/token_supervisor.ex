defmodule AccessPass.TokenSupervisor do
  @moduledoc false
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(AccessPass.RefreshTokenServer, []),
      worker(AccessPass.AccessTokenServer, [])
    ]

    opts = [strategy: :rest_for_one, name: AccessPass.SubSupervisor]
    supervise(children, opts)
  end
end
