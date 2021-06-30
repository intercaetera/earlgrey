defmodule Earlgrey.ConsumerSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [Earlgrey.Consumer]

    IO.puts("Supervisor initialized")
    Supervisor.init(children, strategy: :one_for_one)
  end
end
