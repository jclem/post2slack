defmodule ConfigTest do
  use ExUnit.Case, async: false

  describe ".fetch!/2" do
    test "fetches a config value from the environment" do
      System.put_env("FOO", "bar")
      Application.put_env(:post2slack, :foo, {:system, "FOO"})
      assert Config.fetch!(:post2slack, :foo) == "bar"
    end

    test "fetches a config value from a pure value" do
      Application.put_env(:post2slack, :foo, "bar")
      assert Config.fetch!(:post2slack, :foo) == "bar"
    end
  end

  describe ".fetch!/3" do
    test "fetches from a nested config value" do
      Application.put_env(:post2slack, :foo, %{bar: %{baz: :qux}})
      assert Config.fetch!(:post2slack, :foo, [:bar, :baz]) == :qux
    end
  end
end
