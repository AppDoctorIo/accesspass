defmodule AccessPass.Controller do
  @moduledoc false
  import Plug.Conn
  def init(options), do: options

  def call(conn, opts) do
    apply(AccessPass.Controller, opts, [conn, nil])
  end

  def check(%{method: "GET"} = conn, _) do
    case AccessPass.logged?(getHeaderValue(conn, "access_token")) do
      {:ok, meta} -> conn |> json(200, %{ok: meta})
      {:error, errorMessage} -> conn |> json(400, %{error: errorMessage})
    end
  end

  def refresh(%{method: "GET"} = conn, _) do
    case AccessPass.refresh(getHeaderValue(conn, "refresh_token")) do
      {:ok, meta} -> conn |> json(200, %{ok: meta})
      {:error, err} -> conn |> json(400, %{error: err})
    end
  end

  def register(%{method: "POST"} = conn, _) do
    case AccessPass.register(conn.body_params) do
      {:ok, data} -> conn |> json(200, %{ok: data})
      {:error, err} -> conn |> json(400, %{error: err})
    end
  end

  def confirm(%{method: "POST"} = conn, _) do
    case AccessPass.confirm(getBodyValue(conn, "confirm_id")) do
      {:ok, data} -> conn |> json(200, %{ok: data})
      {:error, err} -> conn |> json(400, %{error: err})
    end
  end

  def login(%{method: "POST"} = conn, _) do
    case AccessPass.login(getBodyValue(conn, "username"), getBodyValue(conn, "password")) do
      {:ok, data} -> conn |> json(200, %{ok: data})
      {:error, err} -> conn |> json(400, %{error: err})
    end
  end

  def reset_password(%{method: "POST"} = conn, _) do
    case AccessPass.reset_password(getBodyValue(conn, "username")) do
      {:ok, data} ->
        conn |> json(200, %{ok: data})

      {:error, _} ->
        conn |> json(200, %{ok: "password reset sent to accounts email"})
    end
  end

  def forgot_username(%{method: "POST"} = conn, _) do
    case AccessPass.forgot_username(getBodyValue(conn, "email")) do
      {:ok, data} -> conn |> json(200, %{ok: data})
      {:error, _} -> conn |> json(200, %{ok: "sent email with related username"})
    end
  end

  def logout(%{method: "POST"} = conn, _) do
    case AccessPass.logout(getHeaderValue(conn, "access_token")) do
      {:ok} -> conn |> json(200, %{ok: "logged out"})
      {:error, err} -> conn |> json(400, %{error: err})
    end
  end

  def change_password(%{method: "POST"} = conn, _) do
    case AccessPass.change_password(
           getBodyValue(conn, "password_id"),
           getBodyValue(conn, "new_password")
         ) do
      {:ok} -> conn |> json(200, %{ok: "password changed"})
      {:error, err} -> conn |> json(400, %{error: err})
    end
  end

  defp json(conn, status, obj) do
    put_resp_content_type(conn, "application/json")
    |> send_resp(status, Poison.encode!(obj))
    |> halt()
  end

  defp getBodyValue(conn, val) do
    case conn.body_params[val] do
      nil -> ""
      val -> val
    end
  end

  defp getHeaderValue(conn, val) do
    case conn |> get_req_header(val) do
      [val] -> val
      _ -> nil
    end
  end
end
