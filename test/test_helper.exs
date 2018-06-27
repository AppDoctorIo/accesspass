ExUnit.start()

defmodule AccessPass.TestHelpers do
  def clear() do
    :mnesia.delete_table(:access_token_ets)
    :mnesia.delete_table(:refresh_token_ets)
    SyncM.add_table(:refresh_token_ets, [:uniq, :refresh, :access, :meta])
    SyncM.add_table(:access_token_ets, [:access, :refresh, :meta])
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
