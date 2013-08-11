defmodule Mix.Tasks.Scribe do
  defmodule Init do
    def run(_), do: Scribe.init(System.cwd)
  end
end
