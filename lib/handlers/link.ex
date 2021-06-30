defmodule Earlgrey.Link do
  alias Nostrum.Api

  def generate_code() do
    Enum.random(100_000..999_999)
  end

  def get_confirmation_thread() do
    Application.get_env(:earlgrey, :confirmation_thread)
  end

  def get_account_name(content) do
    case Earlgrey.Utils.discard_command(content) do
      "" -> {:error, "Please provide a character name."}
      name -> {:ok, name}
    end
  end

  defp persist_code(name, code, author_id) do
    :dets.insert(:confirm_codes, {name, code})
    :dets.insert(:confirm_ids, {name, author_id })
  end

  def handle(msg) do
    with {:ok, account_name} <- get_account_name(msg.content),
         {:ok} <- Earlgrey.Utils.is_character_already_linked(account_name) do
      code = generate_code()
      persist_code(account_name, code, msg.author.id)

      Api.create_message(msg.channel_id, """
      Your account name is **#{account_name}**. Your confirmation code is `#{code}`.

      1. Create a post in the below thread with just the confirmation code as the account you are trying to link.
      2. Click the `#n` at the top right of the post that you have just created and copy the URL.
      3. Type `confirm Url`.

      #{get_confirmation_thread()}
      """)
    else
      {:error, error} -> Api.create_message(msg.channel_id, error)
    end
  end
end
