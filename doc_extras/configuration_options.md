# Configuration Options

<b>overrides_module</b>: Module that impliments AccessPassBehavior to offer customization of email templates and many other hooks.

<b>repo</b>: used to point to an already existing repo for ecto

<b>distributed</b>: a boolean that will decide on if data should be replicated to other connected nodes.

<b>refresh\_expire\_in</b>: time in seconds to expire each refresh token

<b>access\_expire\_in</b>: time in seconds to expire access token

<b>id\_len</b>: number of characters in default id generation

<b>from</b>: email address mailgun will be using to send emails.

<b>confirmation\_subject</b>: string to override confirmation subject line of email.

<b>reset\_password\_subject</b>: string to override reset password subject line of email.

<b>forgot\_username_subject</b>: string to override forgot username subject line of email.

<b>bamboo email configs</b>: look [here](https://hexdocs.pm/bamboo/readme.html) for the configs needed. These configs go under config :access_pass, AccessPass.Mailer

<b>ecto configurations</b>: If you want AccessPass to house your instance of Ecto as compared to providing repo: above then check out the getting started section for an example config.

```elixir
#Example configuration with every option
config :access_pass, AccessPass.Mailer,
  adapter: Bamboo.PICKANDADAPTER,
 #Please look at the configs from bamboo hex page for what the required configs are. 

config :access_pass, 
        repo: Test.Repo,
        distributed: true,
        sync: true,                                         #Required if already using ecto
        mailgun_domain: "https://api.mailgun.net/v3/YOURDOMAIN", #Required
        mailgun_key:    "key-YOURKEY",                           #Required
        from: YOUREMAIL@example.com,                             #Required
        confirmation_template: {Test.Temps, :conf_template, []},         #check Email Templating
        password_reset_template: {Test.Temps, :reset_template, []},      #check Email Templating
        forgot_username_template: {Test.Temp, :forgot_user_template, []},#check Email Templating
        id_gen_mod: Test.Gen, #Needs to have gen_user_id(changeset) and return {changeset, ID}
        custom_change_mod: Test.Gen, #Needs to have custom(changeset) and return changeset
        insert_override_mod: Test.Gen, #Needs to have insert_override(changeset) and return {:ok, changeset} or {:error, changeset}
        after_insert_mod: Test.Gen, #Needs to have after_insert({:error,cs} OR {:ok,cs}) and return changeset
        refresh_expire_in: 3600, #(1hour) defaults to 0(no expire)
        access_expire_in: 600, #(10 minutes) defaults to 300(5 minutes)
        id_len: 12, # defaults to 6 
        confirmation_subject: "welcome to my site", # default: "Confirmation email"
        reset_password_subject: "please reset password", # default: "Reset your password"
        forgot_username_subject: "woops you forgot this", # default: "Forgot Username"
        base_url: "https://mydomain.example.com", # default: "https://api.example.com", used in email templates
```


