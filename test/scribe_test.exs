defmodule Scribe.MockAdapter do
  def execute(sql) do
    :ok
  end
end

defmodule ScribeTest do
  use ExUnit.Case
end
