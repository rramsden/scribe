defmodule Scribe do
  import Scribe.Utils
  defrecord Config, adapter: nil, host: nil, database: nil, user: nil, password: nil

  @doc """
  Initializes scribe files directory
  db/migrations
  """
  def init(directory) do
    File.mkdir_p Path.join(directory, "db/migrations")
    IO.puts "CREATE db/migrations"

    # copy scribe database configuration
    source = Path.join(Path.dirname(__FILE__), "scribe/generators/config.exs")
    destination = Path.join( System.cwd, "db/scribe.conf" )

    :ok = File.cp(source, destination)
    IO.puts "CREATE #{Path.relative_to(destination, System.cwd)}"
  end

  @doc """
  Drop the database
  """
  def drop_database do
    config = Scribe.Utils.load_config

    time "Dropping Database: #{config.database}" do
      config.adapter.drop_database(config)
    end
  end

  @doc """
  Create the database
  """
  def create_database do
    config = Scribe.Utils.load_config

    time "Creating Database: #{config.database}" do
      config.adapter.create_database(config)
    end
  end

  @doc """
  Looks in db/migrations and executes a migration
  """
  def migrate do
    config = Scribe.Utils.load_config

    # open persistent database connection
    conn = config.adapter.start_link(config)

    # create version table
    config.adapter.execute(create_version_table_if_needed, conn)

    # fetch latest version
    latest_version = case config.adapter.select("SELECT MAX(version) FROM schema_versions", conn) do
      {:ok, version} when is_integer(version) ->
        version
      _ ->
        0
    end

    # fetch and execute latest migrations
    migrations = load_migrations(latest_version)
    execute(migrations, config.adapter, conn)

    # close database connection
    config.adapter.close(conn)
  end

  defp execute([], _adapter, _conn), do: :ok
  defp execute([migration|rest], adapter, conn) do
    [file: path] = Regex.captures(%r/\d+_(?<file>.*)\.exs/g, migration[:path])
    Code.require_file migration[:path]

    module = Mix.Utils.camelize(path)

    time "Migrating: #{module}" do
      {migration_sql, _} = Code.eval_string "#{module}.up"
      case adapter.execute(migration_sql, conn) do
        {:error, reason} -> exit(reason)
        _ -> :ok
      end
      :ok = adapter.execute("INSERT INTO schema_versions VALUES ('#{migration[:version]}')", conn)
    end
    execute(rest, adapter, conn)
  end

  defp load_migrations(latest_version) do
    files = Path.wildcard(Path.join(System.cwd, "db/migrations/*"))
    migrations = Enum.map files, fn(path) ->
      version = Enum.first(String.split(Path.basename(path), "_")) |> String.to_integer |> tuple_to_list |> Enum.first
      [version: version, path: path]
    end
    Enum.filter(migrations, fn(keyword_list) -> keyword_list[:version] > latest_version end)
  end

  defp create_version_table_if_needed do
    """
    CREATE TABLE schema_versions (
      version integer NOT NULL
    );
    """
  end
end
