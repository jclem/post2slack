defmodule Post2Slack.RouterTest do
  use ExUnit.Case, async: false
  use Plug.Test

  import Mock

  alias Post2Slack.{Router, PostToken, StateToken}

  @opts Post2Slack.Router.init([])

  test "GET /login" do
    conn = conn(:get, "/login") |> Router.call(@opts)
    assert conn.status == 302
    assert get_resp_header(conn, "content-type") == ["text/html; charset=utf-8"]
    ["https://slack.com/oauth/authorize?" <> query] = get_resp_header(conn, "location")
    query = Plug.Conn.Query.decode(query)
    assert query["client_id"] == "SLACK_CLIENT_ID"
    assert query["redirect_uri"] == "https://localhost"
    assert query["scope"] == "chat:write:user"
    assert StateToken.verify_token(query["state"]) == :ok
  end

  describe "GET /oauth/slack/callback" do
    test_with_mock "returns a token with a valid state", HTTPoison, post: &HTTPoisonMock.post/3 do
      state = StateToken.create_token()
      query = Plug.Conn.Query.encode(state: state, code: "code")
      conn = conn(:get, "/oauth/slack/callback?#{query}") |> Router.call(@opts)
      assert conn.status == 200
      assert get_resp_header(conn, "content-type") == ["text/html; charset=utf-8"]
      assert conn.resp_body =~ "element.value = 'access_token';"
    end

    test "returns a 403 with an invalid state" do
      state = "Invalid Token"
      query = Plug.Conn.Query.encode(state: state, code: "code")
      conn = conn(:get, "/oauth/slack/callback?#{query}") |> Router.call(@opts)
      assert conn.status == 403
      assert conn.resp_body == "Forbidden"
    end

    test_with_mock "returns a 500 with non-200", HTTPoison, post: &HTTPoisonMock.post/3 do
      state = StateToken.create_token()
      query = Plug.Conn.Query.encode(state: state, code: "invalid_code")
      conn = conn(:get, "/oauth/slack/callback?#{query}") |> Router.call(@opts)
      assert conn.status == 500
      assert conn.resp_body == "Unexpected error"
    end
  end

  describe "POST /post" do
    test_with_mock "Posts a message with a valid token", Slack.API, post: &HTTPoisonMock.post/3 do
      token = PostToken.create_token("valid_token")

      conn =
        conn(:post, "/post", %{"text" => "Hello, world"})
        |> put_req_header("authorization", "Bearer #{token}")
        |> Router.call(@opts)

      assert conn.status == 200
      assert conn.resp_body == "OK"
    end

    test_with_mock "Returns a 500 from an upstream error", Slack.API, post: &HTTPoisonMock.post/3 do
      token = PostToken.create_token("valid_token")

      conn =
        conn(:post, "/post", %{"text" => "Hello, world", "fail" => true})
        |> put_req_header("authorization", "Bearer #{token}")
        |> Router.call(@opts)

      assert conn.status == 500
      assert conn.resp_body == "Unexpected error"
    end
  end

  test "404" do
    conn = conn(:get, "/foo") |> Router.call(@opts)
    assert conn.status == 404
    assert conn.resp_body == "Not found"
  end
end

defmodule HTTPoisonMock do
  def post("https://slack.com/api/oauth.access", {:form, form}, _headers) do
    case Keyword.get(form, :code) do
      "code" ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Poison.encode!(%{ok: true, access_token: "access_token"})
         }}

      "invalid_code" ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Poison.encode!(%{ok: false})
         }}
    end
  end

  def post(
        "chat.postMessage",
        %{"text" => "Hello, world", "fail" => true, as_user: true},
        _headers
      ) do
    {:ok,
     %HTTPoison.Response{
       status_code: 200,
       body: %{"ok" => false}
     }}
  end

  def post("chat.postMessage", %{"text" => "Hello, world", as_user: true}, _headers) do
    {:ok,
     %HTTPoison.Response{
       status_code: 200,
       body: %{"ok" => true}
     }}
  end
end
