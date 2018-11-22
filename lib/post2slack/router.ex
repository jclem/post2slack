require Logger

defmodule Post2Slack.Router do
  use Plug.Router

  if Mix.env() != :test, do: plug(Plug.Logger)
  if Mix.env() == :prod, do: plug(Plug.SSL, hsts: true, rewrite_on: [:x_forwarded_proto])

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  get "/login" do
    url = "https://slack.com/oauth/authorize?#{oauth_authorize_query()}"
    html = Plug.HTML.html_escape(url)
    body = "<html><body>You are being <a href=\"#{html}\">redirected</a>.</body></html>"

    conn
    |> put_resp_header("location", url)
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> send_resp(302, body)
  end

  get "/ping" do
    conn
    |> put_resp_header("content-type", "text/plain; charset=utf-8")
    |> send_resp(200, "OK")
  end

  get "/oauth/slack/callback" do
    with :ok <- Post2Slack.StateToken.verify_token(conn.params["state"]),
         {:ok, access_token} <- Slack.exchange_code(conn.params["code"]),
         access_token = Post2Slack.PostToken.create_token(access_token) do
      html = """
      <html>
        <body>
          <p><a href="#">Click here</a> to copy your access token.</a></p>
          <script>
            document.querySelector('a').addEventListener('click', evt => {
              evt.preventDefault();
              const element = document.createElement('textarea');
              element.value = '#{Plug.HTML.html_escape(access_token)}';
              document.body.appendChild(element);
              element.select();
              document.execCommand('copy');
              document.body.removeChild(element);
            });
          </script>
        </body>
      </html>
      """

      conn
      |> put_resp_header("content-type", "text/html; charset=utf-8")
      |> send_resp(200, html)
    else
      {:error, :invalid_token} ->
        send_resp(conn, 403, "Forbidden")

      err ->
        err |> inspect |> Logger.warn()
        send_resp(conn, 500, "Unexpected error")
    end
  end

  post "/post" do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, oauth_token} <- Post2Slack.PostToken.verify_token(token),
         {:ok, %{body: %{"ok" => true}}} <- Slack.post_message(oauth_token, conn.body_params) do
      send_resp(conn, 200, "OK")
    else
      err ->
        err |> inspect |> Logger.warn()
        send_resp(conn, 500, "Unexpected error")
    end
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  @spec redirect_uri :: String.t()
  def redirect_uri, do: Config.fetch!(:post2slack, __MODULE__, [:redirect_uri])

  defp oauth_authorize_query do
    Plug.Conn.Query.encode(
      client_id: Slack.client_id(),
      scope: Slack.scope(),
      redirect_uri: redirect_uri(),
      state: Post2Slack.StateToken.create_token()
    )
  end
end
