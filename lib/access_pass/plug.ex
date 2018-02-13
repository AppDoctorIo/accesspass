defmodule AccessPass.Auth do
  @moduledoc """
   Plug that checks for access_token in header and then checks if its expired or revoked.
   If it's not it adds the stored data from the token in meta.
   If it is then it returns 401 unauthorized and halts the plug. 
  """
  import Plug.Conn

  def init(opts \\ %{}) do
    opts
  end

  def call(conn, _opts) do
    token = conn |> getHeaderValue("access_token")

    case AccessPass.logged?(token) do
      {:ok, data} -> conn |> assign(:data, data)
      {:error, _} -> conn |> send_resp(401, "unauthorized") |> halt()
    end
  end

  defp getHeaderValue(conn, val) do
    case conn |> get_req_header(val) do
      [val] -> val
      _ -> nil
    end
  end
end
