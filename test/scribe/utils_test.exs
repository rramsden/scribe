defmodule ScribeUtilsTest do
  use ExUnit.Case, async: true
  import Scribe.Utils

  test "loads scribe config" do
    config = load_config( Path.join(Path.dirname(__FILE__), "../../lib/scribe/generators/config.exs") )
    assert is_record(config, Scribe.Config)
  end

  test "generates timestamp" do
    assert is_binary(timestamp)
  end
end

