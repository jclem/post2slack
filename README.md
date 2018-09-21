# Post2Slack [![Build Status](https://travis-ci.com/jclem/post2slack.svg?branch=master)](https://travis-ci.com/jclem/post2slack) [![Coverage Status](https://coveralls.io/repos/github/jclem/post2slack/badge.svg?branch=master)](https://coveralls.io/github/jclem/post2slack?branch=master)

Post2Slack posts to a Slack channel as the authorized user.

## Running

For your .env file:

1. Set a `PORT`.
2. Set `SLACK_CLIENT_ID` to your Slack client ID.
3. Set `SLACK_CLIENT_SECRET` to your Slack client secret.
4. Set `POST_SIGNING_SECRET` to a base64-encoded 32-byte value After compiling this app (which is possible without the secrets), use `mix post2_slack.gen.secret`.
5. Set `STATE_SIGNING_SECRET` to another base64-encoded 32-byte value.

To start:

`foreman start`

## Deploying

This can easily be deployed to Heroku via docker. First, set the above env vars, as well as `MIX_ENV=prod`, and excepting `PORT`.

1. `heroku apps:create`
2. `heroku container:login`
3. `heroku container:push web`
4. `heroku container:release web`

## How it Works

Post2Slack uses Slack OAuth to get a token with `chat:write:user` scope, which is returned inside of an expiring, encrypted [JWE token][jwe] (this means that the token is not readable, and despite the fact that typical Slack access tokens don't expire, it expires in 1 week). Then, a normal Slack API `chat.postMessage` request can be sent to Post2Slack, along with a `Authorization: Bearer $token` header for authentication.

[jwe]: https://tools.ietf.org/html/rfc7516
