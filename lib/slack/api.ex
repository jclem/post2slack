defmodule Slack.API do
  use HTTPoison.Base

  def process_url(url) do
    "https://slack.com/api/#{url}"
  end

  def process_request_body(body), do: Poison.encode!(body)
  def process_response_body(body), do: Poison.decode!(body)

  def process_request_headers(headers),
    do: [{"accept", "application/json"}, {"content-type", "application/json"}] ++ headers
end
