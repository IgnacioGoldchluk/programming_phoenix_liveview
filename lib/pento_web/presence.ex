defmodule PentoWeb.Presence do
  use Phoenix.Presence, otp_app: :pento, pubsub_server: Pento.PubSub

  alias PentoWeb.Presence
  @user_activity_topic "user_activity"
  @survey_activity_topic "survey_activity"
  @survey_activity_key "survey"

  def track_user(pid, product, user_email) do
    Presence.track(
      pid,
      @user_activity_topic,
      product.name,
      %{users: [%{email: user_email}]}
    )
  end

  def list_products_and_users() do
    Presence.list(@user_activity_topic)
    |> Enum.map(&extract_product_with_users/1)
  end

  defp extract_product_with_users({product_name, %{metas: metas}}) do
    {product_name, users_from_metas_list(metas)}
  end

  defp users_from_metas_list(metas_list) do
    Enum.map(metas_list, &users_from_meta_map/1)
    |> List.flatten()
    |> Enum.uniq()
  end

  defp users_from_meta_map(meta_map), do: get_in(meta_map, [:users])

  def track_user_taking_survey(pid, user_email) do
    Presence.track(
      pid,
      @survey_activity_topic,
      @survey_activity_key,
      %{email: user_email}
    )
  end

  def number_of_users_taking_a_survey() do
    Presence.list(@survey_activity_topic)
    |> extract_user_emails_for_survey()
    |> Enum.uniq()
    |> Enum.count()
  end

  def extract_user_emails_for_survey(%{"survey" => %{metas: users_list}}) do
    users_list |> Enum.map(&Map.get(&1, :email))
  end

  def extract_user_emails_for_survey(%{}), do: []
end
