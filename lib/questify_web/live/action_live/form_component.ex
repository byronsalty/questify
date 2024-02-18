defmodule QuestifyWeb.ActionLive.FormComponent do
  use QuestifyWeb, :live_component

  alias Questify.Games

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage action records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="action-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:command]} type="text" label="Command" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:is_terminal]} type="checkbox" label="Is terminal" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Action</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{action: action} = assigns, socket) do
    changeset = Games.change_action(action)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"action" => action_params}, socket) do
    changeset =
      socket.assigns.action
      |> Games.change_action(action_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"action" => action_params}, socket) do
    save_action(socket, socket.assigns.action, action_params)
  end

  defp save_action(socket, :edit, action_params) do
    case Games.update_action(socket.assigns.action, action_params) do
      {:ok, action} ->
        notify_parent({:saved, action})

        {:noreply,
         socket
         |> put_flash(:info, "Action updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_action(socket, :new, action_params) do
    case Games.create_action(action_params) do
      {:ok, action} ->
        notify_parent({:saved, action})

        {:noreply,
         socket
         |> put_flash(:info, "Action created successfully")
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
