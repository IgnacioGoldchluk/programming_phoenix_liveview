defmodule PentoWeb.Admin.DashboardLive do
  use PentoWeb, :live_view
  alias PentoWeb.Admin.SurveyResultsLive
  alias PentoWeb.Endpoint
  alias PentoWeb.Admin.UserActivityLive

  @survey_results_topic "survey_results"
  @user_activity_topic "user_activity"
  @survey_activity_topic "survey_activity"
  def mount(_params, _session, socket) do
    if connected?(socket) do
      [@survey_results_topic, @user_activity_topic, @survey_activity_topic]
      |> Enum.each(&Endpoint.subscribe/1)
    end

    {
      :ok,
      socket
      |> assign(:survey_results_component_id, "survey-results")
      |> assign(:user_activity_component_id, "user-activity")
    }
  end

  def handle_info(%{event: "rating_created"}, socket) do
    send_update(
      SurveyResultsLive,
      id: socket.assigns.survey_results_component_id
    )

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    send_update(
      UserActivityLive,
      id: socket.assigns.user_activity_component_id
    )

    {:noreply, socket}
  end
end
