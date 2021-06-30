defmodule Earlgrey.Utils do
  def discard_command(command) do
    command
    |> String.split
    |> (fn [_ | tail] -> tail end).()
    |> Enum.join(" ")
  end

  def is_character_already_linked(character_name) do
    case :dets.match_object(:characters, {:_, character_name}) do
      [] -> {:ok}
      _ -> {:error, "This character is already linked to someone."}
    end
  end
end
