defmodule AccessPass do
  @moduledoc """
  This is the main Public api and out of the box all you will use.
  Includes everything you need for all your authentication needs.
  """
  alias AccessPass.GateKeeper
  # maybe validate password === password confirm
  @doc """
  Checks if the given access token is not revoked or expired and returns the data stored for it

  Returns `{:ok,{user: "data"}}`.

  ## Examples

      AccessPass.logged?("ODhhMDgzYjctZTE3OC00YjgyLWFiZGMtZTJjOWZiMzJjODhi")
      {:ok, {username: "jordiee"}}

  """
  defdelegate logged?(token), to: GateKeeper, as: :check

  @doc """
  Refresh for a new access_token given a refresh_token

  Returns `{:ok,"access_token"}`.

  ## Examples

      AccessPass.refresh("ODhhMDgzYwfefdfeC00YjgyLWFiZGMtZTJjOWZiMzJjODhi")
      {:ok, "ODhhMDgzYjctZTE3OC00YjgyLWFiZGMtZTJjOWZiMzJjODhi"}

  """
  defdelegate refresh(refresh_token), to: GateKeeper, as: :refresh

  @doc """
    Register a new user

  Returns `{"ok":
            {
              "type":"TYPE",
              "refresh_token":"refresh token",
              "refresh_expire_in": seconds,
              "access_token":"access_token",
              "access_expire_in": seconds
            }
          }`

  ## Examples

      AccessPass.register(%{
        username: "example",
        password: "otherexample",
        email: "example@email.com",
        meta: {
          coolInfo: "stored in here"
        }
      })
      {"ok":
      {
        "type":"basic",
        "refresh_token":"MjNmYzgzNGMtMGM3MS00YTA4LTkxMWMtNDEyODU3Yzk2ZTgy",
        "refresh_expire_in":1200,
        "access_token":"ODhhMDgzYjctZTE3OC00YjgyLWFiZGMtZTJjOWZiMzJjODhi",
        "access_expire_in":600
      }
      }
  """
  defdelegate register(user_obj), to: GateKeeper, as: :register

  @doc """
  Marks a user email confirmed based on the given confirm_id

  Returns `{:ok, "email confirmed"}`.

  ## Examples

      AccessPass.confirm("ODhhMDgzYwfefdfeC00YjgyLWFiZGMtZTJjOWZiMzJjODhi")
      {:ok, "email confirmed"}
  """
  defdelegate confirm(confirm_id), to: GateKeeper, as: :confirm

  @doc """
    Register a new user

  Returns `{"ok":
            {
              "type":"TYPE",
              "refresh_token":"refresh token",
              "refresh_expire_in": seconds,
              "access_token":"access_token",
              "access_expire_in": seconds
            }
          }`

  ## Examples

      AccessPass.login(%{
        username: "example",
        password: "otherexample",
      })
      {"ok":
      {
        "type":"basic",
        "refresh_token":"MjNmYzgzNGMtMGM3MS00YTA4LTkxMWMtNDEyODU3Yzk2ZTgy",
        "refresh_expire_in":1200,
        "access_token":"ODhhMDgzYjctZTE3OC00YjgyLWFiZGMtZTJjOWZiMzJjODhi",
        "access_expire_in":600
      }
      }
  """

  defdelegate login(username, password), to: GateKeeper, as: :log_in

  @doc """
  calling will set a reset password email to the linked email account of the username

  Returns `{ok: "password reset sent to accounts email"}`.

  ## Examples

      AccessPass.reset_password("jordiee")
      {ok: "password reset sent to accounts email"}

  """
  defdelegate reset_password(username), to: GateKeeper, as: :reset_password

  @doc """
  calling will send a forgot_username email to the email(if it exists in system)

  Returns `{ok: "sent email with related username"}`.

  ## Examples

      AccessPass.forgot_username("myemail@gmail.com")
      {ok: "sent email with related username"}

  """
  defdelegate forgot_username(email), to: GateKeeper, as: :forgot_username

  @doc """
  calling logout will revoke both access_token and refresh_token for the given access_token

  Returns `{:ok}`.

  ## Examples

      AccessPass.logout("ODhhMDgzYwfefdfeC00YjgyLWFiZGMtZTJjOWZiMzJjODhi")
      {:ok}

  """
  defdelegate logout(access_token), to: GateKeeper, as: :log_out

  @doc """
  Calling will update user password for related password_id

  Returns `{:ok}`.

  ## Examples

      AccessPass.change_password("ODhhMDgzYwfefdfeC00YjgyLWFiZGMtZTJjOWZiMzJjODhi","myNewPassword")
      {:ok}

  """
  defdelegate change_password(password_id, new_password), to: GateKeeper, as: :change_password
end
