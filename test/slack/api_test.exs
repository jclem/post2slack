defmodule Slack.APITest do
  use ExUnit.Case

  alias Slack.API

  test ".process_url/1" do
    assert API.process_url("chat.post") == "https://slack.com/api/chat.post"
  end

  test ".process_request_body/1" do
    assert API.process_request_body(%{foo: "bar"}) == ~s({"foo":"bar"})
  end

  test ".process_response_body/1" do
    assert API.process_response_body(~s({"foo":"bar"})) == %{"foo" => "bar"}
  end

  test ".process_request_headers/1" do
    assert API.process_request_headers([{"authorization", "Bearer token"}]) == [
             {"accept", "application/json"},
             {"content-type", "application/json"},
             {"authorization", "Bearer token"}
           ]
  end
end
