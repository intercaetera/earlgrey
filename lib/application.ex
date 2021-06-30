defmodule Earlgrey.Application do
  use Application

  def start(_type, _args) do
    children = [Earlgrey.ConsumerSupervisor]

    options = [strategy: :one_for_one, name: Earlgrey.Supervisor]

    :dets.open_file(:confirm_codes, [type: :set])
    :dets.open_file(:confirm_ids, [type: :set])
    :dets.open_file(:characters, [type: :bag])

    Supervisor.start_link(children, options)
  end
end
