defmodule AccessPass.Auth do
  @moduledoc """
   Plug that checks for access-token in header and then checks if its expired or revoked.
   If it's not expired/revoked it adds the stored data from the token in meta.
   If it is then it returns 401 unauthorized and halts the plug by default. Can be changed. 
   You can pass confirmed: true on the plug to only auth if the users email has been confirmed.
  """
  import Plug.Conn
  import AccessPass.Config

  def init(opts \\ %{}) do
    opts
  end

  def call(conn, confirmed: true) do
    token = conn |> getHeaderValue("access-token")

    case AccessPass.logged?(token) do
      {:ok, data} -> email_confirmation_check(conn, data)
      {:error, _} -> conn |> overrides_mod().auth_error()
    end
  end

  def call(conn, _) do
    token = conn |> getHeaderValue("access-token")

    case AccessPass.logged?(token) do
      {:ok, data} -> conn |> assign(:data, data)
      {:error, _} -> conn |> overrides_mod().auth_error()
    end
  end

  defp email_confirmation_check(conn, %{email_confirmed: false}) do
    conn |> overrides_mod().email_auth_error()
    
  end

  defp email_confirmation_check(conn, %{email_confirmed: true} = data) do
    conn |> assign(:data, data)
  end

  defp email_confirmation_check(conn, _), do: conn |> overrides_mod().auth_error()

  defp getHeaderValue(conn, val) do
    case conn |> get_req_header(val) do
      [val] -> val
      _ -> nil
    end
  end
end

defmodule AccessPass.AuthExtended do
  @moduledoc """
   Plug that checks for access-token in header and then checks if its expired or revoked.
   If it's not expired/revoked it adds the stored data from the token in meta.
   If it is then it returns 401 unauthorized and halts the plug by default. Can be changed. 
   You can pass any number of arguments in keyword list format to match against the users
   meta obj that is stored on registration. An example use case is for role based auth.
  """
  import Plug.Conn
  import AccessPass.Config

  def init(opts \\ %{}) do
    opts
  end

  def call(conn, keyword_list) do
    token = conn |> getHeaderValue("access-token")

    case AccessPass.logged?(token) do
      {:ok, data} -> extended_auth(conn, data, keyword_list)
      {:error, _} -> conn |> overrides_mod().auth_error()
    end
  end

  defp extended_auth(conn, data, keyword_list) do
    case Enum.all?(keyword_list, fn {key, val} ->
           get_in(data, [:meta, Atom.to_string(key)]) == val
         end) do
      true -> conn |> assign(:data, data)
      false -> conn |> overrides_mod().auth_error()
    end
  end

  defp getHeaderValue(conn, val) do
    case conn |> get_req_header(val) do
      [val] -> val
      _ -> nil
    end
  end
end
