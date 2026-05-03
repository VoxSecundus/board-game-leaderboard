require "application_system_test_case"

class GamesTest < ApplicationSystemTestCase
  setup { log_in_via_browser }

  test "deleting a game from show page" do
    game = games(:catan)
    visit game_url(game)
    accept_confirm do
      click_button "Delete"
    end
    assert_current_path games_path
    assert_text "Game deleted."
    assert_no_text game.name
  end

  test "toggling to table view" do
    visit games_url
    find("button[aria-label='Table view']").click
    assert_selector "[data-view-toggle-target='tableView']", visible: true
    assert_selector "[data-view-toggle-target='gridView']", visible: :hidden
  end
end
