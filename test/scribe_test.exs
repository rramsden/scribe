defmodule Scribe.Adapters.MockAdapter do
  def start_link, do: :ok
  def close(_conn), do: :ok
  def execute(_sql, _conn), do: :ok
  def select(_sql, _conn), do: {:ok, "123"}
  def drop_database(_config), do: :ok
  def create_database(_config), do: :ok
end

defmodule ScribeTest do
  use ExUnit.Case
  alias Scribe.Config, as: Config

  @_config_path Path.join(Path.dirname(__FILE__), "fixtures/scribe.conf")

  setup do
    # setup a temporary directory for a project
    tmp_dir = Path.join(System.tmp_dir, "my_project")
    File.mkdir_p(tmp_dir)
    {:ok, tmp_dir: tmp_dir}
  end

  teardown meta do
    # remove temporary project directory
    File.rm_rf(meta[:tmp_dir])
  end

  test "create database" do
    Scribe.create_database([{:config_path, @_config_path}])
  end

  test "drop database" do
    Scribe.drop_database([{:config_path, @_config_path}])
  end

  test "initializes a project directory", meta do
    Scribe.init(meta[:tmp_dir])
    assert File.exists?(Path.join(meta[:tmp_dir], "db/migrations"))
    assert File.exists?(Path.join(meta[:tmp_dir], "db/scribe.conf"))
    assert File.exists?(Path.join(meta[:tmp_dir], "lib/my_project/tasks/db.ex"))
  end
end
