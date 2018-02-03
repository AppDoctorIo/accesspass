defmodule AccessPass.AccessTokenServer do
  @moduledoc false
  use GenServer
  @name :access_token
  @ets :access_token_ets
  alias AccessPass.{GateKeeper,RefreshToken}
  import AccessPass.Config

  def start_link() do
    GenServer.start_link(__MODULE__, {%{}, %{}}, name: @name)
  end

  def init(state) do
    :ets.new(@ets, [:set, :protected, :named_table])
    {:ok, state}
  end

  def handle_call({:add, refresh_token, meta},_,_) do
    access_token = GateKeeper.genToken()
    Process.send_after(@name, {:revoke, access_token}, access_expire_in() * 1000)
    :ets.insert(@ets, {access_token,refresh_token,meta}) 
    {:reply, access_token,%{}}
  end

  def handle_info({:revoke, access_token}, _) do
    case :ets.match(@ets,{access_token,:"$1",:"_"}) do
      [[val]] -> RefreshToken.revoke_self_only(val)
      _ -> :ok
    end
    :ets.delete(@ets, access_token)
    {:noreply,%{}}
  end

  def handle_call({:revoke, access_token},_,_) do
    case :ets.match(@ets,{access_token,:"$1",:"_"}) do
      [[val]] -> RefreshToken.revoke_self_only(val)
      _ -> :ok
    end
    :ets.delete(@ets, access_token)
    {:reply, {:ok},%{}}
  end

  def handle_cast({:revoke, access_token}, %{}) do
    :ets.delete(@ets, access_token)
    {:noreply,%{}}
  end

  def check(access_token) do
    case :ets.match(@ets, {access_token,:"_",:"$1"}) do
      [[val]] -> {:ok, val}
      _       -> return_expire_error()
    end
  end

  defp return_expire_error() do
    {:error, "access token expired"}
  end

end
