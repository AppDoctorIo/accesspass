defmodule AccessPass.EtsDistributed do
	def insert(name, obj,true) do
		:ets.insert(name, obj)
	end
	def insert(name, obj) do
		:ets.insert(name, obj)
		replicate(name,obj)	
	end
	defdelegate delete(name,key), to: AccessPass.Ets
	defdelegate match_object(name,object), to: AccessPass.Ets
	defdelegate match_delete(name,obj), to: AccessPass.Ets
	defdelegate match(name,obj), to: AccessPass.Ets
	defdelegate new(name,opts), to: AccessPass.Ets
	defp replicate(name,obj) do
		Task.start(fn ->
			Node.list() |> :rpc.multicall(AccessPass.Ets, :insert, [name,obj])
		end)
	end
end