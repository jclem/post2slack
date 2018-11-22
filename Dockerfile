FROM elixir:1.7-alpine as build

ARG ALPINE_VERSION=3.8

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force

ENV MIX_ENV=prod
COPY config mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY . .
RUN mix release --no-tar --verbose

FROM alpine:3.8
RUN apk add --update bash openssl

RUN mkdir /app && chown -R nobody: /app
WORKDIR /app

COPY --from=build /app/_build/prod/rel/post2slack .

ARG PORT=80
ENV PORT=$PORT
EXPOSE $PORT
CMD /app/bin/post2slack foreground
