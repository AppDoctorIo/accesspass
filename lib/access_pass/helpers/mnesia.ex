defmodule AccessPass.Mnesia do
  alias :mnesia, as: Mnesia
	def insert(name, obj) do
		val = smoosh(name,obj)
   	(:ok == run_trans(fn -> Mnesia.write(val) end))
	end
	def match_object(name,obj) do
		val = smoosh(name,obj)
		run_trans(fn -> Mnesia.match_object(val) end) |> Enum.map(&strip_name/1)
	end
	def delete(name,key) do
		val = smoosh(name,key)
		run_trans(fn -> Mnesia.delete(val) end)
	end
	def match_delete(name,obj) do
		val = smoosh(name,obj)
		run_trans(fn -> Mnesia.match_object(val) end)
			|> delete_by_key
	end
	def match(name,{_, :"$1", :_} = pat) do
		match_object(name,pat) 
		|> Enum.map(fn({_,refresh,_}) -> [refresh] end) 
	end

	def match(name,{_, :_, :"$1"} = pat) do
		match_object(name,pat) 
		|> Enum.map(fn({_,_,meta}) -> [meta] end)
	end
	def match(name,{:_, _, :"$1", :_} = pat) do
		match_object(name,pat) 
		|> Enum.map(fn({_,_,three,_}) -> [three] end)
	end

	def new(:refresh_token_ets = name,_) do
		case Enum.member?(:mnesia.system_info(:tables),:jordan1) do
			true ->	nil	
			false -> 	SyncM.add_table(name,[:uniq, :refresh, :access, :meta])
		end	
	end
	def new(:access_token_ets = name,_) do
		case Enum.member?(:mnesia.system_info(:tables),:jordan1) do
			true ->	nil	
			false -> 	SyncM.add_table(name,[:access, :refresh, :meta])
		end
	end
	defp delete_by_key([h|t]) do
		local_list = Tuple.to_list(h)
		var = smoosh(Enum.at(local_list,0),{Enum.at(local_list,1)})
		run_trans(fn -> 
			Mnesia.delete(var)
			end)
		delete_by_key(t)
	end
	defp delete_by_key([]) do
		:ok	
	end
	def strip_name(tup) do
			[_|t] = Tuple.to_list(tup)
			List.to_tuple(t)
	end
	def smoosh(val, tup) when is_tuple(tup) do
		[val | Tuple.to_list(tup)] |> List.to_tuple()
	end
	def smoosh(val, tup) do
		[val | Tuple.to_list({tup})] |> List.to_tuple()
	end
	defp run_trans(fnc) do
		case Mnesia.transaction(fnc) do
      {:atomic, val} -> val 
      _ -> :error
    end
	end
end