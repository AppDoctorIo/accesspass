defmodule AccessPass.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children =
      if Application.get_env(:access_pass, :repo) == nil do
        [
          supervisor(AccessPass.Repo, []),
          supervisor(AccessPass.TokenSupervisor, [])
        ]
      else
        [
          supervisor(AccessPass.TokenSupervisor, [])
        ]
      end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :rest_for_one, name: AccessPass.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
