defmodule Fooer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      fooer: [
        strategy: Cluster.Strategy.Epmd,
        config: [hosts: [:"fooer1@127.0.0.1", :"fooer2@127.0.0.1", :"fooer3@127.0.0.1"]]
      ]
    ]

    children = [
      FooerWeb.Telemetry,
      # Fooer.Repo,
      # {DNSCluster, query: Application.get_env(:fooer, :dns_cluster_query) || :ignore},
      {Cluster.Supervisor, [topologies, [name: Daedal.ClusterSupervisor]]},
      {Phoenix.PubSub, name: Fooer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Fooer.Finch},
      # Start a worker by calling: Fooer.Worker.start_link(arg)
      DaedalRemote.child_spec(
        pinger_opts: [
          beacon_cookie: System.get_env("BEACON_COOKIE") |> String.to_atom(),
          beacon_node: System.get_env("BEACON_NODE") |> String.to_atom()
        ]
      ),
      # Start to serve requests, typically the last entry
      FooerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fooer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FooerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
