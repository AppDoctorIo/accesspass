# Email Templating
AccessPass sends 3 different type of emails for you. Confirmation email after a new user registration, password reset email and forgot username email. Out of the box is uses a very basic html for each.

AccessPass allows you to override each of those emails by using the AccessPassBehavior. Look at the AccessPassBehavior module docs for more details.

The html returned by your functions will go through EEx to swap for needed information. Below will show you the required EEx keys.

### confirmation template

<b>required:</b> <%= conf_key %>

<b>optional:</b> <%= base_url %>

example:

```elixir
defmodule Test.Temps
  use AccessPassBehavior
  def confirmation_email() do
  """
  <a href="https://<%= base_url %>?con_key=<%= conf_key %>"></a>
  """
  end
end
```

### password reset template

<b>required:</b> <%= password_key %>

<b>optional:</b> <%= base_url %>

example:

```elixir
defmodule Test.Temps
  use AccessPassBehavior
  def password_reset() do
  """
  <a href="https://<%= base_url %>/reset?con_key=<%= password_key %>"></a>
  """
  end
end
```

### forgot username template

<b>required:</b> <%= user_name %>

example:

```elixir
defmodule Test.Temps
  use AccessPassBehavior
  def forgot_username() do
  """
  <h1> Your username is <%= user_name %>!</h1>
  """
  end
end
```
