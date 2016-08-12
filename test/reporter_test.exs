defmodule Test.Reporter do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias Dogma.Script
  alias Dogma.Error
  alias CodeclimateDogma.Reporter

  test "return JSON of files with no errors" do
    scripts = [
      %Script{ path: "foo.ex", errors: [] },
      %Script{ path: "bar.ex", errors: [] }
    ]

    for script <- scripts do
      _ = capture_io(fn ->
        {:ok, []} = Reporter.handle_event({:script_tested,  script}, [])
      end)
    end

    result = capture_io(fn ->
      {:ok, []} = Reporter.handle_event({:finished,  scripts}, [])
    end)

    assert result == "\0"
  end

  test "return JSON of files with some errors" do
    errors = [
      %Error{
        line: 1,
        rule: Dogma.Rule.ModuleDoc,
        message: "Module without a @moduledoc detected"
      },
      %Error{
        line: 14,
        rule: Dogma.Rule.ComparisonToBoolean,
        message: "Comparison to a boolean is pointless"
      }
    ]

    scripts = [
      %Script{ path: "foo.ex", errors: [] },
      %Script{ path: "bar.ex", errors: errors }
    ]

    result = capture_io(fn -> Reporter.handle_event({:finished, scripts}, []) end)

    assert result == ~s(\0{"type":"Issue","location":{"path":"bar.ex","lines":{"end":1,"begin":1}},"description":"Module without a @moduledoc detected","check_name":"ModuleDoc","categories":["Style"]}\0{"type":"Issue","location":{"path":"bar.ex","lines":{"end":14,"begin":14}},"description":"Comparison to a boolean is pointless","check_name":"ComparisonToBoolean","categories":["Style"]})
  end
end
