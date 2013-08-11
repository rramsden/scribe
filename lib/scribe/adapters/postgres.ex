defmodule Scribe.Adapters.Postgres do
  @moduledoc false
  @behaviour Scribe.Adapter

  def start_link(config) do
    :pgsql_connection_sup.start_link
    :pgsql_connection.open(
      host: config.host,
      database: config.database,
      user: config.user,
      password: config.password
    )
  end

  def close(conn) do
    :pgsql_connection.close(conn)
  end

  def execute(sql, conn) do
    case :pgsql_connection.sql_query(sql, conn) do
      {:error, reason} -> {:error, reason}
      _ -> :ok
    end
  end

  def select(sql, conn) do
   case :pgsql_connection.sql_query(sql, conn) do
      {:selected, [{result}]} -> {:ok, result}
      {:error, reason} -> {:error, reason}
    end
  end

  def drop_database(config) do
    :pgsql_connection_sup.start_link

    # establish master connection
    conn = :pgsql_connection.open(host: config.host, user: config.user, password: config.password, database: "postgres")
    execute("DROP DATABASE #{config.database}", conn)
    close(conn)
  end

  def create_database(config) do
    :pgsql_connection_sup.start_link

    # establish master connection
    conn = :pgsql_connection.open(host: config.host, user: config.user, password: config.password, database: "postgres")
    execute("CREATE DATABASE #{config.database}", conn)
    close(conn)
  end
end
