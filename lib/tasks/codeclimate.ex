defmodule Mix.Tasks.Codeclimate do
  @moduledoc """
  Task to analyze files
  """
  use Mix.Task

  alias Dogma.Config
  alias CodeclimateDogma.Reporter

  #@code_dir "/Users/fazibear/dev/sprint-poker/lib"
  @code_dir "/code/lib"

  def run(_argv) do
    {:ok, dispatcher} = GenEvent.start_link([])
    GenEvent.add_handler(dispatcher, Reporter, [])

    @code_dir
    |> Dogma.run(Config.build, dispatcher)
  end
end
