defmodule Scribe.Migration do
  import Scribe.Utils

  @doc """
  Run migrations
  """
  def up(project_dir, config) do
    conn = config.adapter.start_link(config)
    create_version_table(config.adapter, conn)
    schema_vsn = read_schema_version(config.adapter, conn)
    migrations = Enum.filter read_migrations(project_dir), fn(m) -> m[:version] > schema_vsn end
    execute(:up, migrations, config.adapter, conn)
    config.adapter.close(conn)
  end

  @doc """
  Rollback a migration
  """
  def down(project_dir, config) do
    conn = config.adapter.start_link(config)
    create_version_table(config.adapter, conn)
    schema_vsn = read_schema_version(config.adapter, conn)
    migrations = Enum.filter read_migrations(project_dir), fn(m) -> m[:version] < schema_vsn end
    sorted_list = Enum.sort migrations, fn(a, b) -> a[:version] > b[:version] end
    last_migration = case Enum.first(sorted_list) do
      nil -> []
      migration -> [migration]
    end
    execute(:down, last_migration, config.adapter, conn)
    config.adapter.close(conn)
  end

  defp execute(_, [], _, _), do: :ok
  defp execute(direction, [migration|rest], adapter, conn) do
    [file: path] = Regex.captures(%r/\/\d+_(?<file>.*)\.exs$/g, migration[:path])
    Code.require_file migration[:path]

    module = Mix.Utils.camelize(path)

    time "Migrating: #{module}" do
      {migration_sql, _} = Code.eval_string "#{module}.#{direction}"
      case adapter.execute(migration_sql, conn) do
        {:error, reason} -> exit(reason)
        _ -> :ok
      end

      case direction do
        :up -> adapter.execute("INSERT INTO schema_versions VALUES ('#{migration[:version]}')", conn)
        :down -> adapter.execute("DELETE FROM schema_versions WHERE version = #{migration[:version]}", conn)
      end
    end
    execute(direction, rest, adapter, conn)
  end

  defp read_migrations(project_dir) do
    migration_files = Path.wildcard(Path.join(project_dir, "db/migrations/*"))
    Enum.map migration_files, fn(path) ->
      [version: migration_vsn] = Regex.captures(%r/\/(?<version>\d+)_.*\.exs$/g, path)
      {vsn, _} = String.to_integer(migration_vsn)
      [path: path, version: vsn]
    end
  end

  defp read_schema_version(adapter, conn) do
    case adapter.select("SELECT MAX(version) FROM schema_versions", conn) do
      {:ok, version} when is_integer(version) ->
        {:ok, version}
      _ ->
        0
    end
  end

  defp create_version_table(adapter, conn) do
    create_query = """
    CREATE TABLE schema_versions (
      version integer NOT NULL
    );
    """
    adapter.execute(create_query, conn)
  end
end
