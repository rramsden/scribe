defmodule Scribe do
  defrecord Config, host: nil, database: nil, user: nil, password: nil
  import Scribe.Utils

  @doc """
  Initializes scribe files directory
  db/migrations
  """
  def init(directory) do
    File.mkdir_p Path.join(directory, "db/migrations")
    IO.puts "CREATE db/migrations"

    # copy scribe database configuration
    source = Path.join(Path.dirname(__FILE__), "scribe/generators/config.exs")
    destination = Path.join( System.cwd, "db/config.exs" )

    :ok = File.cp(source, destination)
    IO.puts "CREATE db/config.exs"
  end

  @doc """
  Drop the database
  """
  def drop_database do
    config = Scribe.Utils.load_config
    time "Dropping Database: #{config[:database]}" do
      System.cmd("dropdb #{config[:database]}")
    end
  end

  @doc """
  Create the database
  """
  def create_database do
    config = Scribe.Utils.load_config
    time "Creating Database: #{config[:database]}" do
      System.cmd("createdb #{config[:database]}")
    end
  end

  @doc """
  Looks in db/migrations and executes a migration
  """
  def migrate do
    config = Scribe.Utils.load_config
    {:ok, _pid} = :pgsql_connection_sup.start_link()
    connection = :pgsql_connection.open(config[:database], config[:user], config[:password])

    create_version_table_if_needed(connection)
    latest_version = case :pgsql_connection.sql_query("SELECT MAX(version) FROM schema_versions", connection) do
      {:selected, [{version}]} when is_integer(version) ->
        version
      output ->
        0
    end

    # fetch and execute latest migrations
    migrations = load_migrations(latest_version)
    execute(migrations, connection)
  end

  defp execute([], conn), do: :ok
  defp execute([migration|rest], conn) do
    [file: path] = Regex.captures(%r/\d+_(?<file>.*)\.exs/g, migration[:path])
    Code.require_file migration[:path]

    module = Mix.Utils.camelize(path)

    time "Migrating: #{module}" do
      {migration_sql, _} = Code.eval_string "#{module}.up"
      case :pgsql_connection.sql_query(migration_sql, conn) do
        {:error, reason} -> exit(reason)
        _ -> :ok
      end
      {:updated, 1} = :pgsql_connection.sql_query("INSERT INTO schema_versions VALUES ('#{migration[:version]}')", conn)
    end
    execute(rest, conn)
  end

  defp load_migrations(latest_version) do
    files = Path.wildcard(Path.join(System.cwd, "db/migrations/*"))
    migrations = Enum.map files, fn(path) ->
      version = Enum.first(String.split(Path.basename(path), "_")) |> String.to_integer |> tuple_to_list |> Enum.first
      [version: version, path: path]
    end
    Enum.filter(migrations, fn(keyword_list) -> keyword_list[:version] > latest_version end)
  end

  defp create_version_table_if_needed(connection) do
    create_table_sql = """
    CREATE TABLE schema_versions (
      version integer NOT NULL
    );
    """
    :pgsql_connection.sql_query(create_table_sql, connection)
  end
end
