defmodule Earlgrey.Post do
  alias Nostrum.Api

  def get_channel_id() do
    Application.get_env(:earlgrey, :posting_channel_id)
  end

  def get_char(author_id, char_id) do
    :dets.lookup(:characters, author_id)
    |> Enum.fetch(char_id - 1)
  end

  def compose(character_name, post) do
    "**#{character_name}:** #{post}"
  end

  def get_id_and_post(content) do
    case Earlgrey.Utils.discard_command(content) do
      "" -> {:error, "No character id or post content found. Usage: `post id content`"}
      rest -> 
        [character_id | post_array] = rest |> String.split()
        post = post_array |> Enum.join(" ")
        {:ok, {character_id, post}}
    end
  end

  def handle(msg) do
    with {:ok, {character_id, post}} <- get_id_and_post(msg.content),
         {:ok, {_id, character_name}} <-
           get_char(msg.author.id, String.to_integer(character_id)) do
      composed_post = compose(character_name, post)
      Api.create_message(get_channel_id(), composed_post)
    else
      :error -> Api.create_message(msg.channel_id, "The character id you provided is incorrect.")
      {:error, error} -> Api.create_message(msg.channel_id, error)
      _ -> Api.create_message(msg.channel_id, "Something went wrong.")
    end
  end
end
