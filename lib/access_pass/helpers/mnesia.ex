defmodule AccessPass.Mnesia do
  alias :mnesia, as: Mnesia
	def insert(name, obj) do
		create = fn -> Mnesia.write(smoosh(name,obj)) end
    case Mnesia.transaction(create) do
      {:atomic, :ok} -> :ok
      _ -> IO.inspect("Something went wrong creating account in Mnesia cache")
    end
	end
	def match_object(name,obj) do
		Mnesia.match_object(smoosh(name,obj))
	end

	def match_delete(name,obj) do
		# need to match and then loop delete, ez
	end
	def match(name,obj) do
		# need to match and then delete access keys
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
	def smoosh(val, tup) do
		[val | Tuple.to_list(tup)] |> List.to_tuple()
	end
end