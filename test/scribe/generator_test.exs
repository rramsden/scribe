defmodule ScribeGeneratorTest do
  use ExUnit.Case, async: true
  import Scribe.TestHelpers
  import Scribe.Generator

  setup meta do
    setup_project(meta)
  end

  teardown meta do
    teardown_project(meta)
  end

  test "creates a file from a template", meta do
    destination = Path.join(meta[:project_dir], "file")
    create_file(destination, "config")
    assert File.exists?(destination)
  end
end
