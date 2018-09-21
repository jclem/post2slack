defmodule Slack do
  @spec exchange_code(String.t()) :: {:ok, String.t()} | {:error, any}
  def exchange_code(code) do
    with {:ok, %{body: body}} <-
           HTTPoison.post(
             Slack.API.process_url("oauth.access"),
             exchange_code_form(code),
             [{"content-type", "application/x-www-form-urlencoded"}]
           ),
         %{"ok" => true, "access_token" => access_token} <- Poison.decode!(body) do
      {:ok, access_token}
    end
  end

  @spec post_message(String.t(), Map.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def post_message(oauth_token, params) do
    Slack.API.post(
      "chat.postMessage",
      Map.merge(params, %{as_user: true}),
      [{"authorization", "Bearer #{oauth_token}"}]
    )
  end

  @spec client_id :: String.t() | nil
  def client_id, do: Config.fetch!(:post2slack, Slack, [:client_id])

  @spec client_secret :: String.t() | nil
  def client_secret, do: Config.fetch!(:post2slack, Slack, [:client_secret])

  @spec scope :: String.t()
  def scope, do: "chat:write:user"

  defp exchange_code_form(code) do
    {:form,
     [
       client_id: Slack.client_id(),
       client_secret: Slack.client_secret(),
       code: code,
       redirect_uri: Post2Slack.Router.redirect_uri()
     ]}
  end
end
