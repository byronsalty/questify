defmodule QuestifyWeb.LocationLive.FormComponent do
  use QuestifyWeb, :live_component

  alias Questify.Games

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %> for Quest: <%= @quest.name %>
      </.header>

      <.simple_form
        for={@form}
        id="location-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:quest_id]} type="hidden" value={@quest.id} />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:is_terminal]} type="checkbox" label="Terminal" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Location</.button>
        </:actions>
      </.simple_form>

    </div>
    """
  end

  @impl true
  def update(%{location: location} = assigns, socket) do
    changeset = Games.change_location(location)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"location" => location_params}, socket) do
    changeset =
      socket.assigns.location
      |> Games.change_location(location_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"location" => location_params}, socket) do
    IO.inspect(location_params, label: "location params")

    # location_params = Map.put(location_params, "quest_id", quest_id)
    save_location(socket, socket.assigns.action, location_params)
  end

  defp save_location(socket, :edit, location_params) do
    case Games.update_location(socket.assigns.location, location_params) do
      {:ok, location} ->
        notify_parent({:saved, location})

        {:noreply,
         socket
         |> put_flash(:info, "Location updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_location(socket, :new, location_params) do
    case Games.create_location(location_params) do
      {:ok, location} ->
        notify_parent({:saved, location})

        {:noreply,
         socket
         |> put_flash(:info, "Location created successfully")
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
