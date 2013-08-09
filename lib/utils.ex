defmodule Scribe.Utils do
  @moduledoc """
  This module contains utility functions used in Scribe
  """

  @doc false
  defmacro time(name, block) do
    quote do
      start_ms = timestamp_ms
      IO.puts "== Task: #{unquote(name)} started ==================================="
      unquote(block)
      IO.puts "== Task: #{unquote(name)} (#{(timestamp_ms - start_ms) / 1000}ms) finished =================================="
    end
  end

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

  @doc """
  Get timestamp from epoch in milliseconds
  """
  def timestamp_ms do
    {mega, second, micro} = :erlang.now
    (mega * 1000000 + second) * 1000000 + micro
  end
end
