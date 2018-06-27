defmodule AccessPass.Routes do
  @moduledoc """
     Routes provides a drop in macro to generate routes for a phoenix
     route file to handle the following endpoints:

     GET /check

     GET /refresh

     POST /register

     POST /confirm

     POST /login

     POST /reset_password

     POST /logout

     POST /change_password

     usage:
     ```elixir
    defmodule TestWeb.Router do
      use TestWeb, :router
      use AccessPass.Routes 

      scope "/" do
        get "/", PageController, :index
        access_pass :routes
      end

    end
    ```
  """
  defmacro __using__(_) do
    quote do
      import AccessPass.Routes
      alias AccessPass.Auth
      alias AccessPass.AuthExtended
    end
  end

  defmacro access_pass(:routes) do
    routes = [
      {:get, :check},
      {:get, :refresh},
      {:post, :register},
      {:post, :confirm},
      {:post, :login},
      {:post, :reset_password},
      {:post, :forgot_username},
      {:post, :logout},
      {:post, :change_password}
    ]

    for {method, route} <- routes do
      quote do
        unquote(method)(unquote_splicing([route_path(route), AccessPass.Controller, route]))
      end
    end
  end

  defp route_path(route) do
    "/#{to_string(route)}"
  end
end
