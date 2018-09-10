# Phoenix routes
AccessPass comes with a helper module to generate authentication routes for you like the following.

```elixir
defmodule TestWeb.Router do
  use TestWeb, :router
  use AccessPass.Routes #helper module

  scope "/" do
    access_pass :routes #macro to generate routes
  end

end
```

This will generate the following routes

### GET /check

This endpoint is used to check if an access token is expired or as a quick way to get the json stored for the token

<b>Required Params</b>

<b>headers</b>: access_token

### GET /refresh

This endpoint is used to get a new access\_token with a given refresh\_token(this is not expired or revoked)

<b>Required Params</b>

<b>headers</b>: refresh_token

### POST /register

This endpoint is used to register a new user

<b>Required Params</b>

<b>body</b>: 

```json
{ 
  "username": "username",
  "password": "password",
  "password_confirm": "password"
  "email"   : "email",
  "meta"    : {}  
}       
```
<b>Returns:</b>

```json
	{"ok": 
	{"type":"basic",
	"refresh_token":"MzU0NjgxM2MtMzE3ZC00YmJmLWJiMDQtZmFhM2Q3Y2RhMzQ4",
	"refresh_expire_in"0,
	"access_token":"Y2ZkNjZlMDQtYWY1MS00YzhiLTgwNDgtYmRmYjg1ODcyZTFh",
	"access_expire_in":300}
	}
```
username,password and email are required. Meta is an optional object to store any data for the user. This object will be what is stored with a users access\_token

### POST /confirm

This endpoint is used to mark a user account confirmed. Will be linked to in the confirmation email sent out so you can think of this as the callback to that email.

<b>Required Params</b>

<b>body</b>: 

```json
{ 
  "confirm_id": "ID that ties this confirmation to the account",
}       
```

### POST /login
This endpoint handles user login.

<b>Required Params</b>

<b>body</b>: 

```json
{ 
  "username": "username or email case insensitive",
  "password": "password"
}       
```

<b>Returns:</b>

```json
	{"ok": 
	{"type":"basic",
	"refresh_token":"MzU0NjgxM2MtMzE3ZC00YmJmLWJiMDQtZmFhM2Q3Y2RhMzQ4",
	"refresh_expire_in"0,
	"access_token":"Y2ZkNjZlMDQtYWY1MS00YzhiLTgwNDgtYmRmYjg1ODcyZTFh",
	"access_expire_in":300}
	}
```

### POST /reset_password
This endpoint will send a password reset email to an email linked to a username. If no account is found it still returns ok so people can not use this endpoint to fish usernames.

<b>Required Params</b>

<b>body</b>: 

```json
{ 
  "username": "username"
}       
```

### POST /logout
This endpoint is used to revoke both access and refresh token for this session. In effect logging the user out.

<b>Required Params</b>

<b>headers</b>: access_token

### POST /change_password
This endpoint is used as the callback to a password reset. The flow is as follows.

Request password reset 

|> Email to form to make new password(link contains password_id

|> On form submit send password_id and new password to this endpoint.

password resets expire 2 hours after sent.

<b>Required Params</b>

<b>body</b>: 

```json
{ 
  "password_id": "passwordid",
  "password_confirm":"the new password to be set for a user"
  "new_password": "the new password to be set for a user"
}       
```

### POST /forgot_username

This endpoint is used to have a user's forgotten username emailed to them.

<b>Required Params</b>

<b>body</b>: 

```json
{ 
  "email"   : "email",
}       
```
<b>Returns:</b>

```json
	{"ok": "An email has been sent to you with your username"}
```
