# Configuration Options

<b>repo</b>: used to point to an already existing repo for ecto

<b>confirmation\_template</b>: a mfa tuple that returns html to use when sending confirmation emails.

<b>distributed</b>: a boolean that will decide on if data should be replicated to other connected nodes.

<b>password\_reset\_template</b>: a mfa tuple that returns html to use when sending password reset email

<b>forgot\_username\_template</b>: a mfa tuple that returns html to use when sending forgot username email

<b>id\_gen\_mod</b>: Points to a Module that contains an gen\_user\_id(changeset) function

<b>custom\_change\_mod</b>: Points to a Module that contains an custom(changeset) function. This function runs at the very end of the changeset pipeline on user registration giving you the option to change anything in the changeset before db insert. Must return a changeset.

<b> insert\_override\_mod </b>: Points to a Module that contains an insert_override(changeset) function. This can be used to wrap the insert of a user in a transaction with some other inserts. You should at some point attempt to insert the user changeset in this function and return the results of that insert. Expects the same type of results from a normal Repo.insert(cs)...ie {:ok, cs} or {:error, cs} returned

<b>after\_insert\_mod </b>: Points to a Module that contains an after_insert(insert_result) function. This can be used for stuff like logging or adding the user to an internal cache. it is passed a standard Repo.insert return and should pass a result that matches what it was passed. Make sure to handle both a Repo.failed insert({:error, cs}) and a Repo.passed insert({:ok,cs})

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
```


