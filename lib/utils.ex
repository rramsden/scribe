defmodule Scribe.Utils do
  alias Scribe.Config, as: Config

  @moduledoc """
  This module contains utility functions used in Scribe
  """

  @doc false
  defmacro time(name, block) do
    quote do
      start_ms = timestamp_ms
      puts "== Task: #{unquote(name)} started ==================================="
      unquote(block)
      puts "== Task: #{unquote(name)} (#{(timestamp_ms - start_ms) / 1000}ms) finished =================================="
    end
  end

  @doc """
  Load Scribe configuration file located in db/config.exs
  """
  def load_config(config_path) do
    {:ok, config} = File.read(config_path)
    {config, _} = Code.eval_string(config)

    camelized = Mix.Utils.camelize(config[:adapter])
    config = Enum.map(config, fn({key, value}) -> {key, binary_to_list(value)} end)
    {adapter, _} = Code.eval_string("Scribe.Adapters.#{camelized}")
    config = Config.new(config)
    config.adapter(adapter)
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

  def puts(output) do
    if Mix.env == :test do
      # output nothing
    else
      IO.puts(output)
    end
  end
end
