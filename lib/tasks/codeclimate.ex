defmodule Mix.Tasks.Codeclimate do
  @moduledoc """
  Task to analyze files
  """
  use Mix.Task

  alias Dogma.Config
  alias CodeclimateDogma.Reporter

  @code_dir "/code"

  @default_exclude [
    ~r(\A#{@code_dir}/_build/),
    ~r(\A#{@code_dir}/deps/)
  ]

  def run(_argv) do
    {:ok, dispatcher} = GenEvent.start_link([])
    GenEvent.add_handler(dispatcher, Reporter, [])

    @code_dir
    |> Dogma.run(config, dispatcher)
  end

  def config do
    %Config{Config.build | exclude: @default_exclude}
  end
end
