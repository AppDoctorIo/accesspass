defmodule AccessPass.RefreshToken do
  @moduledoc """
    RefreshToken communicated internally with a GenServer implementation of your
    applications valid refresh tokens.
  """
  @server_name :refresh_token
    @doc """
    will add a new refresh token and return a token object
    
  Returns `{
      refresh_token: refresh_token,
      access_token: access_token,
      type: "basic",
      access_expire_in: access_expire_in(),
      refresh_expire_in: expire_in
    }`.

  ## Examples

      iex> AccessPass.RefreshToken.add("ODhhMDgzYwfefdfeC00YjgyLWFiZGMtZTJjOWZiMzJjODhi",${},0)
      {
        "type":"basic",
        "refresh_token":"MjNmYzgzNGMtMGM3MS00YTA4LTkxMWMtNDEyODU3Yzk2ZTgy",
        "refresh_expire_in":1200,
        "access_token":"ODhhMDgzYjctZTE3OC00YjgyLWFiZGMtZTJjOWZiMzJjODhi",
        "access_expire_in":600
      }

  """
  def add(unq_id, meta, revokeAt) do
    GenServer.call(@server_name, {:add, unq_id, meta, revokeAt})
  end
@doc """
  calling will revoke a given refresh token

  Returns `{:ok}`.

  ## Examples

      iex> AccessPass.RefreshToken.revoke("ODhhMDgzYwfefdfeC00YjgyLWFiZGMtZTJjOWZiMzJjODhi")
      {:ok}

  """
  def revoke(refresh_token) do
    GenServer.call(@server_name, {:revoke, refresh_token})
  end
  @doc """
  calling will refresh for a new access token

  Returns `{ok: token}`.

  ## Examples

      iex> AccessPass.RefreshToken.refresh("ODhhMDgzYwfefdfeC00YjgyLWFiZGMtZTJjOWZiMzJjODhi")
      {ok: "ODhhMDgzYwfefdfeC00YjgyLWFiZGMtZTJjOWZiMzJjODhi"}

  """

  def refresh(refresh_token) do
    GenServer.call(@server_name, {:refresh, refresh_token})
  end
  def revoke_self_only(access_token) do
    GenServer.cast(@server_name, {:revoke, access_token})
  end
end
