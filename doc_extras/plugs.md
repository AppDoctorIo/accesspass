# Plugs
AccessPass provides a plugs to use in your router pipelines or elsewhere to authenticate users. If authenticated it will set a data object(user_id, username, email, email_confirmed,meta) on the connection for you to use downstream. If the access_token is expired it will return a 401 unauthorized

# Auth
Auth plug is provided by use AccessPass.Routes and provides basic auth for routes. You can pass confirmed: true in order to also require a users email to be confirmed for a route.

Example:

```elixir
defmodule TestWeb.Router do
  use TestWeb, :router
  use AccessPass.Routes 
  
  pipeline :auth do
  	plug Auth #just does token check
  	or
  	plug Auth, confirmed: true #also requires email confirmation
  end	

  scope "/admin" do
  pipe_through :auth #will run auth on every route in this block
    get "/", PageController, :index
  end
end
```
In the previous if you went to yourdomain.com/admin/ it would check your header for an access_token and if found make sure its not revoked and valid. If it is it will set data object on the connection. If not it will return 401 and halt the connection.

# AuthExtended
AuthExtended plug is provided by use AccessPass.Routes and provides extended auth capabilities. You can pass a keyword list of any length to validate stuff set in the users meta object on registration. An example is to provide role based authentication.

Example:

```elixir
defmodule TestWeb.Router do
  use TestWeb, :router
  use AccessPass.Routes 
  
  pipeline :auth do
  	plug AuthExtended, role: "admin" # validate that role of admin set in meta object.
  	plug Auth, confirmed: true # you can also combine with basic auth for email confirmation validation.
  end	

  scope "/admin" do
  pipe_through :auth #will run auth on every route in this block
    get "/", PageController, :index
  end
end
```
In the previous if you went to yourdomain.com/admin/ it would check your header for an access_token. If the token is found then it will validate that the users meta object currently stored has a key of role and a value of "admin". If this is true then it will run basic auth for email confirmation. If this is all correct then it will store the user info in data object for use downstream.