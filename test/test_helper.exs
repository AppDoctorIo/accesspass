ExUnit.start()

defmodule AccessPass.TestHelpers do
  def clear() do
    Supervisor.terminate_child(AccessPass.Supervisor, AccessPass.TokenSupervisor)
    Supervisor.restart_child(AccessPass.Supervisor, AccessPass.TokenSupervisor)
    {:ok}
  end

  def isMap(map) when is_map(map), do: true
  def isMap(_), do: false
  def isErrorTup({:error, _}), do: true
  def isErrorTup(_), do: false
  def isOkTup({:ok, _}), do: true
  def isOkTup(_), do: false
end
