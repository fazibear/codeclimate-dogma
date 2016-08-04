defmodule CodeclimateDogma.Mixfile do
  use Mix.Project

  def project do
    [app: :codeclimate_dogma,
     version: "0.0.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:dogma, "~> 0.1.0"},
      {:poison, "~> 2.2.0"}
    ]
  end
end
