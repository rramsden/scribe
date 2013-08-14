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
end
