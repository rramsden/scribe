defmodule Mix.Tasks.Db do
  use Mix.Task

  defmodule Drop do
    def run(_) do
      config = Scribe.Utils.load_config
      IO.puts("== Dropping database #{config[:database]} =====================")
      System.cmd("dropdb #{config[:database]}")
      IO.puts("== Dropped #{config[:database]} ===============================")
    end
  end

  defmodule Create do
    def run(_) do
      config = Scribe.Utils.load_config
      IO.puts("== Creating database #{config[:database]} =====================")
      System.cmd("createdb #{config[:database]}")
      IO.puts("== Created #{config[:database]} ===============================")
    end
  end

  defmodule Migrate do
    def run([name]) do
      # generate tempalte
      template_path = Path.join(Path.dirname(__FILE__), "../generators/migration.eex")
      compiled_template = EEx.eval_file(template_path, [name: Mix.Utils.camelize(name)])

      # write template to file
      rel_path = "db/migrations/#{Scribe.Utils.timestamp}_#{name}.exs"
      write_path = Path.join(System.cwd, rel_path)
      File.write(write_path, compiled_template)

      IO.puts "CREATE #{rel_path}"
    end

    @doc """
    Run migrations
    """
    def run([]) do
      Scribe.migrate
    end
  end

  defmodule Init do
    def run(_) do
      Scribe.init System.cwd
    end
  end
end
