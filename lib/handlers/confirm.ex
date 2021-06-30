defmodule Earlgrey.Confirm do
  alias Nostrum.Api

  def handle(msg) do
    with {:ok, url} <- get_url(msg.content),
         {:ok, character, code} <- get_confirmation_data(url),
         {:ok} <- verify_code(character, code, msg.author.id),
         {:ok} <- Earlgrey.Utils.is_character_already_linked(character) do
      confirm_code(msg.author.id, character)

      Api.create_message(
        msg.channel_id,
        "Character **#{character}** confirmed. Check `list` to get your character id, then post with `post Id Post Content`"
      )
    else
      {:error, error} -> Api.create_message(msg.channel_id, error)
      _ -> Api.create_message(msg.channel_id, "Something went wrong.")
    end
  end

  def get_confirmation_data(url) do
    post_id = url |> String.split("#pid") |> Enum.take(-1)
    result = HTTPoison.get("#{get_confirmation_thread()}&pid=#{post_id}#pid#{post_id}")

    case result do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        get_code_and_author_from_html(body, post_id)

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, status_code}

      {:error, %HTTPoison.Error{reason: :nxdomain}} ->
        {:error, "This doesn't seem to be a URL."}

      _ ->
        {:error, "Unknown error"}
    end
  end

  def get_code_and_author_from_html(body, post_id) do
    case Floki.parse_document(body) do
      {:ok, document} ->
        {:ok, confirmation_code} =
          document
          |> Floki.find("div#pid_#{post_id}")
          |> get_first_child
          |> get_confirmation_code

        post_author =
          document
          |> Floki.find("table#post_#{post_id} .postcat a:not([title=\"Online\"])")
          |> get_first_child
          |> Floki.text()

        {:ok, post_author, confirmation_code}

      _ ->
        {:error, "Couldn't parse body."}
    end
  end

  def verify_code(character, code, author_id) do
    case :dets.lookup(:confirm_codes, character) do
      [{_character, stored_code}] when stored_code === code ->
        case :dets.lookup(:confirm_ids, character) do
          [{_character, id}] when author_id === id ->
            {:ok}

          _ ->
            {:error,
             "You don't seem to be the same person that initiated the link. Try editing the post with a new code obtained from `link`."}
        end

      [{_character, _stored_code}] ->
        {:error, "Character code is invalid. Check if the code in the forum post is correct."}

      [] ->
        {:error,
         "Character code for **#{character}** has not been generated yet. Generate one with `link`."}

      _ ->
        {:error, "Unknown error"}
    end
  end

  def get_confirmation_code(nil), do: {:error, "Post not found."}

  def get_confirmation_code(raw) do
    case Regex.run(~r/\d{6}/, raw) do
      [confirmation_code] -> {:ok, String.to_integer(confirmation_code)}
      _ -> {:error, "The post does not seem to contain a code."}
    end
  end

  def get_url(content) do
    case Earlgrey.Utils.discard_command(content) do
      "" -> {:error, "Please provide a post URL (or see `link` for details)."}
      name -> {:ok, name}
    end
  end

  def get_first_child(floki_response) do
    {_node, _attrs, children} = floki_response |> List.first()
    children |> List.first()
  end

  def confirm_code(author_id, character) do
    :dets.insert(:characters, {author_id, character})
  end

  def get_confirmation_thread() do
    Application.get_env(:earlgrey, :confirmation_thread)
  end
end
