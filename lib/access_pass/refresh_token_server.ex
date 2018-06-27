defmodule AccessPass.RefreshTokenServer do
  @moduledoc false
  use GenServer

  import AccessPass.Importer

  @name :refresh_token
  @ets :refresh_token_ets
  alias AccessPass.{GateKeeper, AccessToken}

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def init(state) do
    new(@ets, [:set, :public, :named_table])
    {:ok, state}
  end

  def handle_call({:refresh, refresh_token}, _from, %{}) do
    case match_object(@ets, {:_, refresh_token, :_, :_}) do
      [] ->
        {:reply, {:error, "refresh token expired"}, %{}}

      [{uniq, refresh, _, meta}] ->
        access = AccessPass.AccessToken.add(refresh, meta)
        insert(@ets, {uniq, refresh, access, meta})
        {:reply, {:ok, access}, %{}}

      _ ->
        {:reply, {:error, "error getting token data"}, %{}}
    end
  end

  def handle_call({:add, uniq, meta, 0}, _from, %{}) do
    refresh = GateKeeper.genToken()
    new_access_token = AccessPass.AccessToken.add(refresh, meta)
    insert(@ets, {uniq, refresh, new_access_token, meta})
    {:reply, GateKeeper.formatTokens(refresh, new_access_token, 0), %{}}
  end

  def handle_call({:add, uniq, meta, revokeAt}, _from, %{}) when is_integer(revokeAt) do
    refresh = GateKeeper.genToken()
    new_access_token = AccessPass.AccessToken.add(refresh, meta)

    insert_with_revoke(
      @ets,
      {uniq, refresh, new_access_token, meta},
      {@name, {:revoke, refresh}, revokeAt * 1000}
    )

    {:reply, GateKeeper.formatTokens(refresh, new_access_token, revokeAt), %{}}
  end

  def handle_call({:add, _, _, _}, _from, %{}) do
    {:reply, {:error, "invalid type for revokeAt"}, %{}}
  end

  def handle_call({:revoke, refresh_token}, _from, %{}) do
    case match(@ets, {:_, refresh_token, :"$1", :_}) do
      [[_]] -> AccessToken.revoke_self_only(refresh_token)
      _ -> :ok
    end

    match_delete(@ets, {:_, refresh_token, :_, :_})
    {:reply, {:ok}, %{}}
  end

  def handle_info({:revoke, refresh_token}, %{}) do
    case match(@ets, {:_, refresh_token, :"$1", :_}) do
      [[_]] -> AccessToken.revoke_self_only(refresh_token)
      _ -> :ok
    end

    match_delete(@ets, {:_, refresh_token, :_, :_})
    {:noreply, %{}}
  end

  def handle_cast({:revoke, refresh_token}, %{}) do
    match_delete(@ets, {:_, refresh_token, :_, :_})
    {:noreply, %{}}
  end

  # Below is only for testing
  def showAllTokens() do
    match_object(@ets, {:_, :_, :_, :_})
  end
end
