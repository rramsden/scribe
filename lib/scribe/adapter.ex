defmodule Scribe.Adapter do
  @moduedoc """
  Database adapters need to implement this interface
  """

  use Behaviour

  @doc """
  Start database connection
  """
  defcallback start_link(config :: Scribe.Config) :: :ok

  @doc """
  Select SQL query
  """
  defcallback select(sql :: String.t(), config :: Scribe.Config) :: { :ok, result :: term } | { :error, reason :: String.t() }

  @doc """
  Execute SQL query
  """
  defcallback execute(sql :: String.t(), config :: Scribe.Config) :: :ok | { :error, reason :: String.t() }

  @doc """
  Close a database connection
  """
  defcallback close(conn :: term) :: :ok

  @doc """
  Opens a new connection and drops the database defined in scribe configuration
  """
  defcallback drop_database(config :: Scribe.Config) :: :ok

  @doc """
  Opens a new connection and creates the database defiend in scribe configuration
  """
  defcallback create_database(config :: Scribe.Config) :: :ok
end
