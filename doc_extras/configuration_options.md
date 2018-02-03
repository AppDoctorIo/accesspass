# Configuration Options

<b>repo</b>: used to point to an already existing repo for ecto

<b>confirmation\_template</b>: a mfa tuple that returns html to use when sending confirmation emails.

<b>password\_reset\_template</b>: a mfa tuple that returns html to use when sending password reset email

<b>forgot\_username\_template</b>: a mfa tuple that returns html to use when sending forgot username email

<b>id\_gen\_mod</b>: Points to a Module that contains an gen\_user\_id(changeset) function

<b>refresh\_expire\_in</b>: time in seconds to expire each refresh token

<b>access\_expire\_in</b>: time in seconds to expire access token

<b>id\_len</b>: number of characters in default id generation

<b>from</b>: email address mailgun will be using to send emails.

<b>confirmation\_subject</b>: string to override confirmation subject line of email.

<b>reset\_password\_subject</b>: string to override reset password subject line of email.

<b>forgot\_username_subject</b>: string to override forgot username subject line of email.

<b>mailgun\_domain</b>: string domain for mailgun account.

<b>mailgun_key</b>: string for mailgun account key.

<b>ecto configurations</b> If you want AccessPass to house your instance of Ecto as compared to providing repo: above then check out the getting started section for an example config.

```elixir
#Example configuration with every option
config :access_pass, 
        repo: Test.Repo,                                         #Required if already using ecto
        mailgun_domain: "https://api.mailgun.net/v3/YOURDOMAIN", #Required
        mailgun_key:    "key-YOURKEY",                           #Required
        from: YOUREMAIL@example.com,                             #Required
        confirmation_template: {Test.Temps, :conf_template, []},         #check Email Templating
        password_reset_template: {Test.Temps, :reset_template, []},      #check Email Templating
        forgot_username_template: {Test.Temp, :forgot_user_template, []},#check Email Templating
        id_gen_mod: Test.Gen, #Needs to have gen_user_id(changeset) and return {changeset, ID}
        refresh_expire_in: 3600, #(1hour) defaults to 0(no expire)
        access_expire_in: 600, #(10 minutes) defaults to 300(5 minutes)
        id_len: 12, # defaults to 6 
        confirmation_subject: "welcome to my site", # default: "Confirmation email"
        reset_password_subject: "please reset password", # default: "Reset your password"
        forgot_username_subject: "woops you forgot this", # default: "Forgot Username"
```


