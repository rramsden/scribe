defmodule Scribe.Adapters.MockAdapter do
  def start_link(_config), do: :ok
  def close(_conn), do: :ok
  def execute(_sql, _conn), do: :ok
  def select(_sql, _conn), do: {:ok, "123"}
  def drop_database(_config), do: :ok
  def create_database(_config), do: :ok
end

defmodule ScribeTest do
  use ExUnit.Case

  alias Scribe.Config, as: Config
  import Scribe.TestHelpers

  @_config_path Path.join(Path.dirname(__FILE__), "fixtures/scribe.conf")

  setup meta do
    setup_project(meta)
  end

  teardown meta do
    teardown_project(meta)
  end

  test "create database" do
    Scribe.create_database(@_config_path)
  end

  test "drop database" do
    Scribe.drop_database(@_config_path)
  end

  test "creates a migration", meta do
    assert length(Path.wildcard(Path.join(meta[:project_dir], "db/migrations/*"))) == 0
    Scribe.create_migration("users", meta[:project_dir])
    assert length(Path.wildcard(Path.join(meta[:project_dir], "db/migrations/*"))) == 1
  end

  test "runs a migration", meta do
    Scribe.create_migration("users", meta[:project_dir])
    Scribe.migrate(meta[:project_dir], @_config_path)
  end

  test "initializes a project directory", meta do
    assert File.exists?(Path.join(meta[:project_dir], "db/migrations"))
    assert File.exists?(Path.join(meta[:project_dir], "db/scribe.conf"))
    assert File.exists?(Path.join(meta[:project_dir], "lib/my_project/tasks/db.ex"))
  end
end
