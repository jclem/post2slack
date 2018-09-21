# Post2Slack

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

Post2Slack uses Slack OAuth to get a token with `chat:write:user` scope, which is returned inside of an expiring, encrypted [JWE token][JWE] (this means that the token is not readable, and despite the fact that typical Slack access tokens don't expire, it expires in 1 week). This is then sent with an `Authorization: Bearer $token` header back to post2slack, along with a normal Slack API request for `chat.postMessage`.

[JWE]: https://tools.ietf.org/html/rfc7516
