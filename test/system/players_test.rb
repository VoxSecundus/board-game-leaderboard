require "application_system_test_case"

class PlayersTest < ApplicationSystemTestCase
  setup { log_in_via_browser }

  test "toggling to table view persists" do
    visit players_url
    find("button[aria-label='Table view']").click
    assert_selector "[data-view-toggle-target='tableView']", visible: true
    assert_selector "[data-view-toggle-target='gridView']", visible: :hidden

    visit players_url
    assert_selector "[data-view-toggle-target='tableView']", visible: true
  end

  test "toggling back to grid view" do
    visit players_url
    find("button[aria-label='Table view']").click
    find("button[aria-label='Grid view']").click
    assert_selector "[data-view-toggle-target='gridView']", visible: true
    assert_selector "[data-view-toggle-target='tableView']", visible: :hidden
  end

  test "clicking a player card navigates to the player" do
    player = players(:alice)
    visit players_url
    within find("div[data-navigate-url-value='#{player_path(player)}']") do
      find("p", text: /Added/).click
    end
    assert_current_path player_path(player)
  end

  test "clicking a player table row navigates to the player" do
    player = players(:alice)
    visit players_url
    find("button[aria-label='Table view']").click
    within "tr[data-navigate-url-value='#{player_path(player)}']" do
      find("td", text: player.created_at.to_date.to_s).click
    end
    assert_current_path player_path(player)
  end

  test "deleting a player from show page" do
    player = players(:bob)
    visit player_url(player)
    accept_confirm do
      click_button "Delete"
    end
    assert_current_path players_path
    assert_text "Player deleted."
    assert_no_text player.name
  end
end
