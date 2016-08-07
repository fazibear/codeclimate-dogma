defmodule CodeclimateDogma.Reporter do
  @moduledoc """
  Dogma formatter for Code Climate.
  """

  @delimiter "\0"

  use GenEvent

  def handle_event({:finished, scripts}, _) do
    IO.write finish(scripts)
    {:ok, []}
  end
  def handle_event(_, _), do: {:ok, []}

  def finish(scripts) do
    scripts
    |> Enum.map(&format/1)
    |> Enum.join(@delimiter)
  end

  defp format(script) do
    script.errors
    |> Enum.map(fn(error) ->
         error
         |> format_error(script)
       end)
    |> Enum.join(@delimiter)
  end

  defp format_error(error, script) do
    %{
      type: "Issue",
      check_name: check_name(error.rule),
      description: error.message,
      categories: ["Style"],
      location: %{
        path: path(script.path),
        lines: %{
          begin: error.line,
          end: error.line
        }
      }
    } |> Poison.encode!
  end

  defp path(path) do
    path
    |> String.replace(~r/^\/code\//, "")
  end

  defp check_name(rule) do
    rule
    |> to_string
    |> String.replace("Elixir.Dogma.Rule.", "")
  end
end
