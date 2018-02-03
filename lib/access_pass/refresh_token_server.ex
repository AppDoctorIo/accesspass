defmodule AccessPass.RefreshTokenServer do
  @moduledoc false
  use GenServer
  @name :refresh_token
  @ets :refresh_token_ets
  alias AccessPass.{GateKeeper, AccessToken}

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def init(state) do
    :ets.new(@ets, [:set, :protected, :named_table])
    {:ok, state}
  end

  def handle_call({:refresh, refresh_token}, _from, %{}) do
    case :ets.match_object(@ets, {:_, refresh_token, :_, :_}) do
      [] ->
        {:reply, {:error, "refresh token expired"}, %{}}

      [{uniq, refresh, _, meta}] ->
        access = AccessPass.AccessToken.add(refresh, meta)
        :ets.insert(@ets, {uniq, refresh, access, meta})
        {:reply, {:ok, access}, %{}}

      obj ->
        {:reply, {:error, "error getting token data"}, %{}}
    end
  end

  def handle_call({:add, uniq, meta, 0}, _from, %{}) do
    refresh = GateKeeper.genToken()
    new_access_token = AccessPass.AccessToken.add(refresh, meta)
    :ets.insert(@ets, {uniq, refresh, new_access_token, meta})
    {:reply, GateKeeper.formatTokens(refresh, new_access_token, 0), %{}}
  end

  def handle_call({:add, uniq, meta, revokeAt}, _from, %{}) when is_integer(revokeAt) do
    refresh = GateKeeper.genToken()
    new_access_token = AccessPass.AccessToken.add(refresh, meta)
    :ets.insert(@ets, {uniq, refresh, new_access_token, meta})
    Process.send_after(@name, {:revoke, refresh}, revokeAt * 1000)
    {:reply, GateKeeper.formatTokens(refresh, new_access_token, revokeAt), %{}}
  end
  def handle_call({:add, uniq, meta, revokeAt}, _from, %{}) do
    {:reply, {:error, "invalid type for revokeAt"}, %{}}
  end

  def handle_call({:revoke, refresh_token}, _from, %{}) do
    case :ets.match(@ets, {:_, refresh_token, :"$1", :_}) do
      [[val]] -> AccessToken.revoke_self_only(refresh_token)
      _ -> :ok
    end

    :ets.match_delete(@ets, {:_, refresh_token, :_, :_})
    {:reply, {:ok}, %{}}
  end

  def handle_info({:revoke, refresh_token}, %{}) do
    case :ets.match(@ets, {:_, refresh_token, :"$1", :_}) do
      [[val]] -> AccessToken.revoke_self_only(refresh_token)
      _ -> :ok
    end

    :ets.match_delete(@ets, {:_, refresh_token, :_, :_})
    {:noreply, %{}}
  end

  def handle_cast({:revoke, refresh_token}, %{}) do
    IO.inspect(refresh_token)
    :ets.match_delete(@ets, {:_, refresh_token, :_, :_})
    {:noreply, %{}}
  end

  # Below is only for testing
  def showAllTokens() do
    :ets.match_object(@ets, {:_, :_, :_, :_})
  end
end
