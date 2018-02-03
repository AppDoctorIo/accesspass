# Plugs
AccessPass provides a plug to use in your router pipelines or elsewhere to authenticate users. If authenticated it will set a meta object on the connection for you to use downstream that includes the object gathered on user registration. If the access_token is expired it will return a 401 unauthorized

Example:

```elixir
defmodule TestWeb.Router do
  use TestWeb, :router
  use AccessPass.Routes 
  
  pipeline :auth do
  	plug Auth #Auth is an AccessPass plug to require auth on routes
  end	

  scope "/admin" do
  pipe_through :auth #will run auth on every route in this block
    get "/", PageController, :index
  end
end
```
In the previous if you went to yourdomain.com/admin/ it would check your header for an access_token and if found make sure its not revoked and valid. If it is it will set meta on the connection. If not it will return 401 and halt the connection.