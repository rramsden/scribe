defmodule Scribe.Generator do
  @doc """
  Creates a new file from a template
  """
  def create_file(destination, template_name, bindings // []) do
    template_path = Path.join(Path.dirname(__FILE__), "templates/#{template_name}.eex")
    contents = EEx.eval_file(template_path, bindings)
    Scribe.Utils.puts "%{white}CREATE #{destination}"
    File.mkdir_p(Path.dirname(destination))
    :ok = File.write(destination, contents)
  end
end
