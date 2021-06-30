defmodule Earlgrey.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api

  alias Earlgrey.{
    Help,
    Link,
    Confirm,
    ListChars,
    Post
  }

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  @spec handle_event(Nostrum.Consumer.event()) :: any()
  def handle_event({:MESSAGE_CREATE, msg = %{ guild_id: nil }, _ws_state}) do
    command = msg.content |> String.split |> List.first

    case command do
      "ping" ->
        Api.create_message(msg.channel_id, "Pong!")

      m when m in ["hello", "hi", "help"] ->
        Help.handle(msg)

      "link" ->
        Link.handle(msg)

      "confirm" ->
        Confirm.handle(msg)

      "list" ->
        ListChars.handle(msg)

      "post" ->
        Post.handle(msg)

      _ ->
        :ignore
    end
  end

  def handle_event({:READY, _data, _ws_state}) do
    Api.update_status(:online, "PM with 'hi'", 0)
  end

  def handle_event(_event) do
    :noop
  end
end
