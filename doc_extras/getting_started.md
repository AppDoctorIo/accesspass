# Getting Started
The idea behind AccessPass was to have a very quick setup and have a full implementation of authorization.(2 lines of code minus configs)

### Installation

add the following to your deps:
```elixir
{:access_pass, "~> 0.6.1"}
```

Before running mix deps.get please add the configuration below.
### Configuration

Through the rest of the documentation I will be showing examples for using AccessPass with phoenix but that is NOT required. AccessPass can be used with plain plug and does not have a phoenix dependency.

First we need to make sure you have the basic configs required. At minimum you need to have a bamboo email adaptor set and an ecto repo configured like follows. Go [here](https://hexdocs.pm/bamboo/readme.html) for more information on bamboo adapters.

```elixir
config :access_pass, AccessPass.Mailer,
  adapter: Bamboo.SendgridAdapter,
  api_key: "SG.yoursendgridkey"

config :access_pass, 
        repo: Test.Repo,
        from: "SENDINGEMAIL@whatever.com"
```
The above configuration is assuming your application already has a ecto repo.

if not use the following:

```elixir
config :access_pass, AccessPass.Mailer,
  adapter: Bamboo.SendgridAdapter,
  api_key: "SG.yoursendgridkey"

config :access_pass, 
       from: "SENDINGEMAIL@whatever.com"
                 		 
config :access_pass, :ecto_repos, [AccessPass.Repo]
config :access_pass, AccessPass.Repo,[
  adapter: Ecto.Adapters.Postgres,
  username: "YOURUSERNAME",
  password: "YOURPASSWORD",
  database: "YOURDATABASE",
  hostname: "YOURHOST",
  pool_size: 10
]
```
by using the above config AccessPass will start and supervise a Ecto.Repo for you. In most cases you will use the first option as you will probably be using phoenix that already has Ecto. For more info on configurations for ecto go [here](https://hexdocs.pm/ecto/Ecto.html)

There are far more configuration options. You can see all options in the configuration portion of crash course

### Database migration

AccessPass requires a user table set up exactly as the migration below. Look at the link above if you need help with migrations.

```elixir
defmodule YourApplication do
  use Ecto.Migration

  def change do
  	create table(:users) do
  		add :user_id, :string
  		add :username, :string, size: 20
  		add :meta, :map
  		add :email, :string
  		add :password_hash, :string
  	    add :successful_login_attempts, :integer
        add :confirm_id, :string
        add :password_reset_key, :string
        add :password_reset_expire, :integer
        add :confirmed, :boolean
  		timestamps
  	end
    create unique_index(:users, [:email])
    create unique_index(:users, [:user_id])
    create unique_index(:users, [:username])
  end
end
```

### Phoenix Routes
AccessPass was created to be very easy to use in a new or existing project after the initial configuration/db changes.

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
IMPORTANT: access_pass :routes needs to be called in global scope to work:

```elixir
  scope "/" do
    access_pass :routes
  end
```
NOT

```elixir
  scope "/", TestWeb do
    access_pass :routes
  end
```

The above will add endpoints for:

 GET /check

 GET /refresh

 POST /register

 POST /confirm

 POST /login

 POST /reset_password

 POST /logout

 POST /change_password

 POST /forgot_username
     
 For more information on the above routes jump ahead to Phoenix routes section of crash course.    
 
 An example of how to add authentication to an existing route is as follows:
 
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
The above will authorize all routes in the /admin block by access-token in header. To learn more jump ahead to plugs section of crash course.
 





