defmodule Scribe do
  import Scribe.Utils
  import Scribe.Generator
  defrecord Config, adapter: nil, host: nil, database: nil, user: nil, password: nil

  @doc """
  Initializes scribe files directory
  db/migrations
  """
  def init(directory) do
    File.mkdir_p Path.join(directory, "db/migrations")
    Scribe.Utils.puts "%{white}CREATE db/migrations"

    # copy scribe database configuration
    destination = Path.join( directory, "db/scribe.conf" )
    create_file destination, "config"

    # copy database tasks into project
    project_name = Path.basename(directory)
    destination = Path.join( directory, "lib/#{project_name}/tasks/db.ex" )
    create_file destination, "tasks"
  end

  def create_migration(name, directory) do
    # generate tempalte
    rel_path = "db/migrations/#{Scribe.Utils.timestamp}_#{name}.exs"
    destination = Path.join(directory, rel_path)
    create_file destination, "migration", [name: Mix.Utils.camelize(name)]
  end

  @doc """
  Drop the database
  """
  def drop_database(config_path) do
    config = Scribe.Utils.load_config(config_path)

    time "Dropping Database: #{config.database}" do
      config.adapter.drop_database(config)
    end
  end

  @doc """
  Create the database
  """
  def create_database(config_path) do
    config = Scribe.Utils.load_config(config_path)

    time "Creating Database: #{config.database}" do
      config.adapter.create_database(config)
    end
  end

  @doc """
  Looks in db/migrations and executes a migration
  """
  def migrate(project_dir, config_path) do
    config = Scribe.Utils.load_config(config_path)

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
    migrations = load_migrations(latest_version, project_dir)
    execute(migrations, config.adapter, conn)

    # close database connection
    config.adapter.close(conn)
  end

  defp execute([], _adapter, _conn), do: :ok
  defp execute([migration|rest], adapter, conn) do
    [file: path] = Regex.captures(%r/\/\d+_(?<file>.*)\.exs$/g, migration[:path])
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

  defp load_migrations(latest_version, project_dir) do
    files = Path.wildcard(Path.join(project_dir, "db/migrations/*"))
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
