defmodule PentoWeb.DemographicLive.Form do
  use PentoWeb, :live_component

  alias Pento.Survey
  alias Pento.Survey.Demographic

  def update(%{current_user: current_user} = assigns, socket) do
    changeset = Survey.change_demographic(%Demographic{user_id: current_user.id})

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_form(changeset)
    }
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, changeset |> to_form)
  end

  def handle_event("save", %{"demographic" => demographic_params}, socket) do
    {:noreply, save_demographic(socket, demographic_params)}
  end

  defp save_demographic(socket, demographic_params) do
    case Survey.create_demographic(demographic_params) do
      {:ok, demographic} ->
        send(self(), {:created_demographic, demographic})
        socket

      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end
end
