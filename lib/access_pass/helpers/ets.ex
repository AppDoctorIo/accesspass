defmodule AccessPass.Ets do
	def insert(name, obj) do
		:ets.insert(name, obj)
	end
	def delete(name,key) do
		:ets.delete(name, key)
	end
	def match_object(name,object) do
		:ets.match_object(name, object)
	end
	def match_delete(name,obj) do
		:ets.match_delete(name, obj)
	end
	def match(name,obj) do
		:ets.match(name, obj)
	end
	def new(name,opts) do
		IO.inspect({name,opts})
		:ets.new(name, opts)
	end
end