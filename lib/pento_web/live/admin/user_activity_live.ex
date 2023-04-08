defmodule PentoWeb.Admin.UserActivityLive do
  use PentoWeb, :live_component

  alias PentoWeb.Presence

  def update(_assigns, socket) do
    {
      :ok,
      socket
      |> assign_user_activity()
      |> assign_number_of_users_taking_survey()
    }
  end

  def assign_user_activity(socket) do
    assign(socket, :user_activity, Presence.list_products_and_users())
  end

  def assign_number_of_users_taking_survey(socket) do
    assign(socket, :number_of_users_taking_survey, Presence.number_of_users_taking_a_survey())
  end
end
