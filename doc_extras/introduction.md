# Introduction
AccessPass is an out of the box solution to api authentication. While AccessPass is quite opinionated in how everything works it still offers configuration options such as email templating. AccessPass in a way was inspired by elixir's addict but to be more focused on api authentication. AccessPass does NOT provide any UI views so when using it AccessPass will handle the api calls for login/logout/register ect but the form sending that data is separated from AccessPass

### What is the authentication type?
AccessPass uses the idea of access tokens and refresh tokens. Access tokens out of the box last 5 minutes while refresh tokens last forever(both configurable). AccessPass handles internally expiring tokens and provides for the ability to refresh for new tokens.

AccessPass access/refresh tokens are not actually tokens but merely ids used to look up a authorization. Unlike normal token based authentication you can revoke tokens at any time to prevent access while the implementation remains fast by hitting a GenServer and not a database. 

### Can it work across servers?
AccessPass Supports distributed enviroments via the distributed and flag. Read more about them in the config section. By default access pass uses ETS for token tracking but if distributed flag is true it will start replicating all inserts/delete calls to connected nodes. This is a for on "weak distribution" in the sense that newly joined nodes do not copy the current ets state from another node and if net split happens data may be lost on rejoin causing users to have to relog. Each node is responsible on token insert for revoking the token after the set expiration period, that way if network goes down after token is replicated the token will still get revoked at the correct time. Replicated ETS was choses over mnesia because mnesia is very hard to make a general solution to just "work" for all node structures.

### What does it do?
When using AccessPass you get the following done for you:

You get implementations for logging a user in and out, user registration including the sending of confirmation emails,forgot password and forgot username. It includes a plug implementation that will check if a user is authorized based on header values. It also includes a macro to generate all the routes for you if you are using phoenix.


### Requirements

AccessPass requires the use of postgres and a users table that matches the following migration:

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