defmodule AccessPass.EtsDistributed do
  def insert(name, obj) do
    AccessPass.Ets.insert(name, obj)
    replicate(:insert, name, obj)
  end

  def insert_with_revoke(name, obj, tup) do
    AccessPass.Ets.insert_with_revoke(name, obj, tup)
    replicate(:insert_with_revoke, name, obj, tup)
  end

  def delete(name, key) do
    AccessPass.Ets.delete(name, key)
    replicate(:delete, name, key)
  end

  defdelegate match_object(name, object), to: AccessPass.Ets
  defdelegate match_delete(name, obj), to: AccessPass.Ets
  defdelegate match(name, obj), to: AccessPass.Ets
  defdelegate new(name, opts), to: AccessPass.Ets

  defp replicate(:insert_with_revoke, name, obj, tup) do
    Task.start(fn ->
      Node.list() |> :rpc.multicall(AccessPass.Ets, :insert_with_revoke, [name, obj, tup])
    end)
  end

  defp replicate(:insert, name, obj) do
    Task.start(fn ->
      Node.list() |> :rpc.multicall(AccessPass.Ets, :insert, [name, obj])
    end)
  end

  defp replicate(:delete, name, obj) do
    Task.start(fn ->
      Node.list() |> :rpc.multicall(AccessPass.Ets, :delete, [name, obj])
    end)
  end
end
