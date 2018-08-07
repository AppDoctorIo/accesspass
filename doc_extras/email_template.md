# Email Templating
AccessPass sends 3 different type of emails for you. Confirmation email after a new user registration, password reset email and forgot username email. Out of the box is uses a very basic html for each.

AccessPass allows you to override each of those emails by using the AccessPassBehavior. Look at the AccessPassBehavior module docs for more details.

The html returned by your functions will go through EEx to swap for needed information. Below will show you the required EEx keys.

### confirmation template

<b>required:</b> <%= conf_key %>

example:

```elixir
defmodule Test.Temps
	def conf_template() do
	"""
	<a href="https://mysite.com?con_key=<%= conf_key %>"></a>
	"""
	end
end
```

### password reset template

<b>required:</b> <%= password_key %>

example:

```elixir
defmodule Test.Temps
	def reset_template() do
	"""
	<a href="https://mysite.com/reset?con_key=<%= password_key %>"></a>
	"""
	end
end
```

### password reset template

<b>required:</b> <%= user_name %>

example:

```elixir
defmodule Test.Temps
	def forgot_user_template() do
	"""
	<h1> Your username is <%= user_name %>!</h1>
	"""
	end
end
```