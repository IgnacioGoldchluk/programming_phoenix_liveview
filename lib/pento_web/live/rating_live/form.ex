defmodule PentoWeb.RatingLive.Form do
  use PentoWeb, :live_component

  alias Pento.Survey
  alias Pento.Survey.Rating

  def update(
        %{current_user: user, product: product} = assigns,
        socket
      ) do
    changeset =
      %Rating{user_id: user.id, product_id: product.id}
      |> Survey.change_rating()

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_form(changeset)
    }
  end

  def handle_event("save", %{"rating" => rating_params}, socket) do
    {:noreply, save_rating(socket, rating_params)}
  end

  def save_rating(
        %{assigns: %{product_index: product_index, product: product}} = socket,
        rating_params
      ) do
    case Survey.create_rating(rating_params) do
      {:ok, rating} ->
        product = %{product | ratings: [rating]}
        send(self(), {:created_rating, product, product_index})
        socket

      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, changeset |> to_form())
  end
end
