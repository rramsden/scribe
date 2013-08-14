defmodule ScribeMigrationTest do
  use ExUnit.Case, async: true
  import Scribe.Migration
  import Scribe.TestHelpers

  setup meta do
    setup_project(meta)
  end

  teardown meta do
    teardown_project(meta)
  end

  test "runs migration", meta do
    config = Scribe.Config.new(adapter: Scribe.Adapters.MockAdapter)
    Scribe.create_migration("my_migration", meta[:project_dir])
    assert up(meta[:project_dir], config)
  end

  test "rolls a migration back", meta do
    config = Scribe.Config.new(adapter: Scribe.Adapters.MockAdapter)
    Scribe.create_migration("my_migration", meta[:project_dir])
    assert up(meta[:project_dir], config)
    assert down(meta[:project_dir], config)
  end
end
