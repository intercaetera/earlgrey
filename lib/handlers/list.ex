defmodule Earlgrey.ListChars do
  @offset 1

  alias Nostrum.Api

  def get_chars(id) do
    case :dets.lookup(:characters, id) do
      [] ->
        "You have no linked characters."

      chars ->
        chars
        |> Enum.map(fn {_id, character} -> character end)
        |> Enum.with_index(@offset)
        |> Enum.map(fn {name, index} -> "#{index}. #{name}" end)
        |> Enum.join("\n")
    end
  end

  def handle(msg) do
    Api.create_message(msg.channel_id, get_chars(msg.author.id))
  end
end
