ExUnit.start

defmodule Scribe.TestHelpers do
  def setup_project(meta) do
    # setup a temporary directory for a project
    pathify = Regex.replace(%r/[^a-zA-Z]/, atom_to_list(meta[:test].name), "_", [:global])
    tmp_dir = Path.join(System.tmp_dir, pathify) |> Path.join("my_project")
    File.mkdir_p(tmp_dir)
    Scribe.init(tmp_dir)
    {:ok, project_dir: tmp_dir}
  end

  def teardown_project(meta) do
    # remove temporary project directory
    {:ok, _} = File.rm_rf(meta[:project_dir])
  end
end
