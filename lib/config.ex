defmodule Config do
  @moduledoc """
  Resolves a configuration value
  """

  @doc """
  Fetch a config value from application env.
  """
  @spec fetch!(atom, atom) :: String.t()
  def fetch!(app, key), do: Application.fetch_env!(app, key) |> resolve

  @spec fetch!(atom, atom, [atom]) :: String.t()
  def fetch!(app, key, keys), do: Application.fetch_env!(app, key) |> get_in(keys) |> resolve

  defp resolve({:system, key}), do: System.get_env(key)
  defp resolve(value), do: value
end
