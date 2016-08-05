defmodule Mix.Tasks.Codeclimate do
  @moduledoc """
  Task to analyze files
  """
  use Mix.Task

  alias Dogma.Config
  alias CodeclimateDogma.Reporter
  alias Dogma.Rule

  @code_dir "/code"
  @config_file "/config.json"

  @default_exclude [
    ~r(\A#{@code_dir}/_build/),
    ~r(\A#{@code_dir}/deps/)
  ]

  def run(_argv) do
    {:ok, dispatcher} = GenEvent.start_link([])
    GenEvent.add_handler(dispatcher, Reporter, [])

    config = config_file

    Application.put_env(:dogma, :exclude, @default_exclude ++ exclude(config))
    Application.put_env(:dogma, :override, override(config))

    @code_dir
    |> Dogma.run(Config.build, dispatcher)
  end

  defp exclude(config) when is_list(config) do
    config
    |> Map.get(:exclude, [])
    |> Enum.map(fn (exclude) ->
      ~r(\A#{@code_dir}#{exclude})
    end)
  end
  defp exclude(_), do: []

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
      {:ok, config} ->
        config
        |> Poison.decode!(keys: :atoms)
        |> Map.get(:config, %{})
      {:error, _} ->
        %{}
    end
  end
end
