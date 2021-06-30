defmodule Earlgrey.Help do
  alias Nostrum.Api

  def handle(msg) do
    Api.create_message(msg.channel_id, """
      Hello!
      I am a bot to help you post anonymously in the Discovery Freelancer _Alt Lounge_ server.
      Type "`link Forum Account Name`" to start the process of linking your forum alt account.

      Available commands: `help`, `link`, `confirm`, `list`, `post`.
    """)
  end
end
