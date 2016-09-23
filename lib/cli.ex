defmodule Codeclimate.CLI do
  @moduledoc """
  Task to analyze files
  """
  alias Dogma.Config
  alias CodeclimateDogma.Reporter
  alias Dogma.Rule
  alias Dogma.ScriptSources
  alias Dogma.Script
  alias Dogma.Runner

  @config_file "/config.json"

  def main(_argv) do
    try do
      config = config_file
      Application.put_env(:dogma, :override, override(config))
      run_dogma(config)
    rescue
      error -> log_error(error)
    end
  end

  defp run_dogma(config) do
    {:ok, dispatcher} = GenEvent.start_link([])
    GenEvent.add_handler(dispatcher, Reporter, [])

    config
    |> get_dirs
    |> Enum.each(fn(dir) ->
      dir |> run(Config.build, dispatcher)
      IO.write("\0")
    end)
  end

  def get_dirs(%{"include_paths" => paths}) do
    paths
  end
  def get_dirs(_), do: ["."]

  def run(dir_or_file, config, dispatcher) do
    dir_or_file
    |> ScriptSources.find(config.exclude)
    |> ScriptSources.to_scripts
    |> notify_start(dispatcher)
    |> test(config.rules, dispatcher)
    |> notify_finish(dispatcher)
  end

  def test(scripts, rules, dispatcher) do
    scripts
    |> Enum.map(&Task.async(fn -> test_script(&1, dispatcher, rules) end))
    |> Enum.map(&Task.await/1)
  end

  defp test_script(script, dispatcher, rules) do
    errors = try do
      script |> Runner.run_tests( rules )
    rescue
      error ->
        log_error(error)
        []
    end

    script = %Script{ script | errors: errors }
    GenEvent.sync_notify( dispatcher, {:script_tested, script} )
    script
  end

  defp notify_start(scripts, dispatcher) do
    GenEvent.sync_notify(dispatcher, {:start, scripts})
    scripts
  end

  defp notify_finish(scripts, dispatcher) do
    GenEvent.sync_notify(dispatcher, {:finished, scripts})
    scripts
  end

  defp override(config) when is_map(config) do
    config
    |> Map.get(:override, [])
    |> Enum.map(&map_rules/1)
    |> Enum.reject(&!&1)
  end
  defp override(_), do: []

  defp map_rules({key, opts = %{}}) do
    rule_name = key
                |> Atom.to_string
                |> Macro.camelize

    Rule
    |> Module.concat(rule_name)
    |> struct(Keyword.new(opts))
  end
  defp map_rules(_), do: nil

  defp config_file do
    case File.read(@config_file) do
      {:ok, config} -> config |> Poison.decode!
      _ -> %{}
    end
  end

  defp log_error(error) do
    IO.inspect(:stderr, error, [])
  end
end
