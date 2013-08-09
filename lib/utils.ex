defmodule Scribe.Utils do
  @doc """
  Load Scribe configuration file located in db/config.exs
  """
  def load_config(config_path // Path.join(System.cwd, "db/config.exs")) do
    {:ok, config} = File.read(config_path)
    {result, _} = Code.eval_string(config)
    result
  end

  @doc """
  Generate a timestamp using system command date +%s
  """
  def timestamp do
    System.cmd("date +%s") |> String.strip
  end
end
