defmodule AccessPass.AccessToken do
  @moduledoc """
    AccessToken communicated internally with a GenServer implementation of your
    applications valid access tokens.
  """
  @server_name :access_token
  @doc """
  will add a new access_token with meta based on refresh_token

  Returns `"access_token"`.

  ## Examples

      iex> AccessPass.AccessToken.add("ODhhMDgzYwfefdfeC00YjgyLWFiZGMtZTJjOWZiMzJjODhi",${})
      "ODhhMDgzYwfefdfeC00YjgyLWFiZGMtZTJjOWZiMzJjODhi"

  """
  def add(refresh_token, meta) do
    GenServer.call(@server_name, {:add, refresh_token, meta})
  end
  @doc """
  calling will revoke a given access token

  Returns `{:ok}`.

  ## Examples

      iex> AccessPass.AccessToken.revoke("ODhhMDgzYwfefdfeC00YjgyLWFiZGMtZTJjOWZiMzJjODhi")
      {:ok}

  """
  def revoke(access_token) do
    GenServer.call(@server_name, {:revoke, access_token})
  end

  @doc """
  calling will check if an access token is still valid

  Returns `{:ok, val}`.

  ## Examples

      iex> AccessPass.AccessToken.check("ODhhMDgzYwfefdfeC00YjgyLWFiZGMtZTJjOWZiMzJjODhi")
      {ok: {metadata: "hi"}}

  """
  def check(access_token) do
    AccessPass.AccessTokenServer.check(access_token)
  end

  def revoke_self_only(access_token) do
    GenServer.cast(@server_name, {:revoke, access_token})
  end
end
