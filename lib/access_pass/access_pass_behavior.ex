defmodule AccessPassBehavior do
  import AccessPass.Config
  @moduledoc """
    This Module provides you the ability to override AccessPass behavior
    Create a new module in your application and impliment any of the callbacks below to override default behavior.
    EX. 
    ```
    defmodule MyApplication do
        use AccessPassBehavior
        # all of your overrides here
    end
    # in your config file
    config :access_pass, overrides_module: MyApplication
    ```
  """

  @doc """
  This function is called after_login and should return a map that will be stored in the users token

  Returns `{:ok,%{custom: true}}`

  """  
  @callback after_login(%AccessPass.Users{}) :: {:ok, map}
  @doc """
  This function is called before registration insert, you can add additional data to the changeset and must return the altered changeset

  Returns `altered %Ecto.Changeset{} struct`

  """  
  @callback custom_user_changes(%Ecto.Changeset{}) :: %Ecto.Changeset{}
  @doc """
  This function is called after a user registration insert happens and must return the same object that is passed in.

  Returns `%AccessPass.Users{} that was passed in`

  """  
  @callback after_insert(%AccessPass.Users{}) :: %AccessPass.Users{}
  @doc """
  This function is called as a replacement to Repo.insert and must run the insert op for the given changeset.
  It also passes the origional register params unaltered in case you want to add additional fields.
  It should return the return of Repo.insert

  Returns `{:ok, %AccessPass.Users{}} | {:error, %AccessPass.Users{}}`

  """  
  @callback insert_override(%Ecto.Changeset{},map) :: {:ok, %AccessPass.Users{}} | {:error, %AccessPass.Users{}}
  @doc """
  This function is called after a user has confirmed their email address and must return {:ok}

  Returns `{:ok}`.

  """  
  @callback after_confirm(%AccessPass.Users{}) :: {:ok}
  @doc """
  This function is used to change the default user_id generation. It must return the passed in changeset and a string used for user id in a tuple.

  Returns `{%Ecto.Changeset{}, String.t()}`.

  """  
  @callback gen_user_id(%Ecto.Changeset{}) :: {%Ecto.Changeset{}, String.t()}
  @doc """
  This function should return text:html for the password reset email, look at Email Templating section in Crash Course section of the docs for more info.

  Returns `<p>Email text is returned</p>`.

  """  
  @callback password_reset() :: String.t()
  @doc """
  This function should return text:html for the forgot_username email, look at Email Templating section in Crash Course section of the docs for more info.

  Returns `<p>Email text is returned</p>`.

  """  
  @callback forgot_username() :: String.t()
  @doc """
  This function should return text:html for the confirmation_email email, look at Email Templating section in Crash Course section of the docs for more info.

  Returns `<p>Email text is returned</p>`.

  """  
  @callback confirmation_email() :: String.t()
  @doc """
  This function is passed a map of tokens and the user struct. What is returned will be forwarded along and returned by register/login

  Returns `%{
        "type": "basic",
        "refresh_token": "OTc1Nzk5MTQtN2Y4Ny00MDI1LTk1YjgtNzA3OWNmN2Q3M2Iy",
        "refresh_expire_in": 0,
        "access_token": "ZDU1YjM2NGQtNTgyMi00OTRmLTgxYzItNTc5M2JiODNiYzAz",
        "access_expire_in": 300,
        "extra_param": "this is extra"
    }`.

  """  
  @callback login_return(map,%AccessPass.Users{}) :: term

  defmacro __using__(_) do
    quote do
      @behaviour AccessPassBehavior

      def after_login(user) do
        {:ok,
         %{
           user_id: user.user_id,
           email_confirmed: user.confirmed,
           email: user.email,
           username: user.username,
           meta: user.meta
         }}
      end
      def login_return(token,user) do
        token 
      end

      def custom_user_changes(changeset) do
        changeset
      end

      def after_insert(changeset) do
        changeset
      end

      def insert_override(changeset,params) do
        repo().insert(changeset)
      end

      def after_confirm(_), do: {:ok}

      def gen_user_id(changeset) do
        user_id = AccessPass.Users.string_of_length(id_len())

        case repo().get(AccessPass.Users, user_id) do
          %AccessPass.Users{} -> gen_user_id(changeset)
          _ -> {changeset, user_id}
        end
      end

      def confirmation_email() do
        """
        <p>Hi,</p>
        <p> Please go to the link below to activate your account</p>
        <a href="<%= base_url %>/confirm/<%= conf_key %>">Confirm email</a>
        <p>If you did not sign up for an account please disregard this email.</p>
        <p>Thanks,</p> 
        <p>EXAMPLE COMPANY NAME</p>
        """
      end

      def password_reset() do
        """
        <p>Hi,</p>
        <p> No need to worry, you can reset your password by clicking the link below:</p>
        <a href="<%= base_url %>/password-reset/<%= password_key %>">Reset password</a>

        <p>Thanks,</p>
        <p>EXAMPLE COMPANY NAME</p>
        </p>
        """
      end

      def forgot_username() do
        """
        <p>Hi,</p>
        <p>Your username is <%= user_name %><p>
        <p>Thanks,</p>
        <p>EXAMPLE COMPANY NAME</p>
        """
      end

      defoverridable AccessPassBehavior

    end
  end
end

defmodule AccessPass.Overrides do
    @moduledoc false
  use AccessPassBehavior
end