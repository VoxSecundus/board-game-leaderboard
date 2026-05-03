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
