defmodule AccessPass.Auth do
  @moduledoc """
   Plug that checks for access_token in header and then checks if its expired or revoked.
   If it's not expired/revoked it adds the stored data from the token in meta.
   If it is then it returns 401 unauthorized and halts the plug. 
   You can pass confirmed: true on the plug to only auth if the users email has been confirmed.
  """
  import Plug.Conn

  def init(opts \\ %{}) do
    opts
  end

  def call(conn, confirmed: true) do
    token = conn |> getHeaderValue("access_token")

    case AccessPass.logged?(token) do
      {:ok, data} -> email_confirmation_check(conn, data)
      {:error, _} -> conn |> send_resp(401, "unauthorized") |> halt()
    end
  end

  def call(conn, _) do
    token = conn |> getHeaderValue("access_token")

    case AccessPass.logged?(token) do
      {:ok, data} -> conn |> assign(:data, data)
      {:error, _} -> conn |> send_resp(401, "unauthorized") |> halt()
    end
  end

  defp email_confirmation_check(conn, %{email_confirmed: false}) do
    conn |> send_resp(401, "email address not confirmed") |> halt()
  end

  defp email_confirmation_check(conn, %{email_confirmed: true} = data) do
    conn |> assign(:data, data)
  end

  defp email_confirmation_check(conn, _), do: conn |> send_resp(401, "unauthorized") |> halt()

  defp getHeaderValue(conn, val) do
    case conn |> get_req_header(val) do
      [val] -> val
      _ -> nil
    end
  end
end

defmodule AccessPass.AuthExtended do
  @moduledoc """
   Plug that checks for access_token in header and then checks if its expired or revoked.
   If it's not expired/revoked it adds the stored data from the token in meta.
   If it is then it returns 401 unauthorized and halts the plug. 
   You can pass any number of arguments in keyword list format to match against the users
   meta obj that is stored on registration. An example use case is for role based auth.
  """
  import Plug.Conn

  def init(opts \\ %{}) do
    opts
  end

  def call(conn, keyword_list) do
    token = conn |> getHeaderValue("access_token")

    case AccessPass.logged?(token) do
      {:ok, data} -> extended_auth(conn, data, keyword_list)
      {:error, _} -> conn |> send_resp(401, "unauthorized") |> halt()
    end
  end

  defp extended_auth(conn, data, keyword_list) do
    case Enum.all?(keyword_list, fn {key, val} ->
           get_in(data, [:meta, Atom.to_string(key)]) == val
         end) do
      true -> conn |> assign(:data, data)
      false -> conn |> send_resp(401, "unauthorized") |> halt()
    end
  end

  defp getHeaderValue(conn, val) do
    case conn |> get_req_header(val) do
      [val] -> val
      _ -> nil
    end
  end
end
