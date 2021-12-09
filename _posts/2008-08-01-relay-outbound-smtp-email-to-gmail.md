---
title: Relay outbound SMTP email to Gmail
layout: post
date:   2008-08-01 14:46:34 -0800
categories: ruby
---

Sending emails with Rails via Gmail is a snap with Marc Chung's excellent plugin
[action_mailer_tls](http://code.openrain.com/rails/action_mailer_tls). However
sometimes our production environment isn't using Gmail as a mail server and/or
we just need an easy way to send email from our development environment for
testing or demonstrating purposes. <!--more-->

Instead of installing the action_mailer_tls plugin and configuring each of our
Rails apps, we can do a one-time setup of our local Postfix client to relay all
SMTP outbound emails to our Gmail account. If your running a Mac OS Leopard or
Linux, Postfix should already be installed. With a little configuration, we
should be up and running in a couple minutes.

First create /etc/postfix/relay_password file with the server name, email account name and password as shown below. This configuration works with Gmail accounts as well as with Google Apps email accounts. I'm personally using my company's Google Apps with a special email account setup for outbound emails only.

    smtp.gmail.com    example@yourdomain.com:yourpassword

Then tell Postfix about our google accounts information so it knows how and where to relay the email to. This can be done with the postmap command:

    $ postmap /etc/postfix/relay_password

Since Gmail requires a TLS (Transport Layer Security) connection for certificate-based authentication, we'll need to download a free root certificate from Verisign <a href="https://www.verisign.com/support/roots.html" rel="external">https://www.verisign.com/support/roots.html</a> to authenticate our remote SMTP client.

    $ mkdir /etc/postfix/certs
    $ cd /etc/postfix/certs
    $ sudo cp roots.zip /etc/postfix/certs
    $ sudo unzip -j roots.zip
    $ sudo openssl x509 -inform der -in ThawtePremiumServerCA.cer -out  ThawtePremiumServerCA.pem
    $ sudo c_rehash /etc/postfix/certs

Now we are ready to configure Postfix. Postfix needs to know what host to relay the email to, the username and password to authenticate the Gmail account, and the path to our certificates for the encrypted session.  Add these lines to the bottom of /etc/postfix/main.cf

    relayhost = smtp.gmail.com:587
    # auth
    smtp_sasl_auth_enable = yes
    smtp_sasl_password_maps = hash:/etc/postfix/relay_password
    smtp_sasl_security_options = noanonymous

    # tls
    smtp_tls_security_level = may
    smtp_tls_CApath = /etc/postfix/certs
    smtp_tls_session_cache_database = btree:/etc/postfix/smtp_scache
    smtp_tls_session_cache_timeout = 3600s
    smtp_tls_loglevel = 1
    tls_random_source = dev:/dev/urandom

Restart (or start) Postfix to pick up our new changes.

    $ sudo postfix stop
    $ sudo postfix start

That's it! Now we don't have to do any special installation or configuration to send email via Gmail for our Rails apps. We just need to set the delivery method to :smtp and we're ready to go.
