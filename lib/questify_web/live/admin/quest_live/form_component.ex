defmodule QuestifyWeb.QuestLive.FormComponent do
  use QuestifyWeb, :live_component

  alias Questify.Games

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage quest records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="quest-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:slug]} type="text" label="Slug" />
        <.input field={@form[:description]} type="text" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Quest</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{quest: quest} = assigns, socket) do
    changeset = Games.change_quest(quest)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"quest" => quest_params}, socket) do
    changeset =
      socket.assigns.quest
      |> Games.change_quest(quest_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"quest" => quest_params}, socket) do
    save_quest(socket, socket.assigns.action, quest_params)
  end

  defp save_quest(socket, :edit, quest_params) do
    current_user = socket.assigns.current_user

    #TODO check that user matches creator

    case Games.update_quest(socket.assigns.quest, quest_params) do
      {:ok, quest} ->
        notify_parent({:saved, quest})

        {:noreply,
         socket
         |> put_flash(:info, "Quest updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_quest(socket, :new, quest_params) do
    current_user = socket.assigns.current_user

    quest_params =
      quest_params
      |> Map.put("creator_id", current_user.id)

    case Games.create_quest(quest_params) do
      {:ok, quest} ->
        notify_parent({:saved, quest})

        {:noreply,
         socket
         |> put_flash(:info, "Quest created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
