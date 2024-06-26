defmodule MakerstudioAssignment.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :ets.new(:users, [:set, :public, :named_table])
    :ets.new(:usernames, [:set, :public, :named_table])
    children = [
      MakerstudioAssignmentWeb.Telemetry,
      MakerstudioAssignment.Repo,
      {DNSCluster,
       query: Application.get_env(:makerstudioAssignment, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MakerstudioAssignment.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MakerstudioAssignment.Finch},
      # Start a worker by calling: MakerstudioAssignment.Worker.start_link(arg)
      # {MakerstudioAssignment.Worker, arg},
      # Start to serve requests, typically the last entry
      MakerstudioAssignmentWeb.Endpoint
    ]


    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MakerstudioAssignment.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MakerstudioAssignmentWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
