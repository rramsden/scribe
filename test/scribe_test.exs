defmodule Scribe.Adapters.MockAdapter do
  def start_link, do: :ok
  def close(_conn), do: :ok
  def execute(_sql, _conn), do: :ok
  def select(_sql, _conn), do: :ok
  def drop_database(_config), do: :ok
  def create_database(_config), do: :ok
end

defmodule ScribeTest do
  use ExUnit.Case
  alias Scribe.Config, as: Config

  @_config_path Path.join(Path.dirname(__FILE__), "fixtures/scribe.conf")

  test "create database" do
    Scribe.create_database([{:config_path, @_config_path}])
  end

  test "drop database" do
    Scribe.drop_database([{:config_path, @_config_path}])
  end
end
