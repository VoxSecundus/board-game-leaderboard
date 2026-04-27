require "application_system_test_case"

class GamesTest < ApplicationSystemTestCase
  setup do
    SessionsController.any_instance.stubs(:valid_password?).returns(true)
    visit login_url
    fill_in "Password", with: "anything"
    click_button "Sign in"
  end

  test "viewing games index" do
    visit games_url
    assert_text "Games"
    assert_text games(:chess).name
    assert_text games(:catan).name
  end

  test "creating a game" do
    visit new_game_url
    fill_in "Name", with: "Pandemic"
    click_button "Create Game"
    assert_current_path(%r{^/games/\d+$})
    assert_text "Game created."
    assert_text "Pandemic"
  end

  test "creating a game with blank name shows error" do
    visit new_game_url
    fill_in "Name", with: ""
    click_button "Create Game"
    assert_text "can't be blank"
  end

  test "editing a game" do
    visit edit_game_url(games(:chess))
    fill_in "Name", with: "Chess Classic"
    click_button "Update Game"
    assert_text "Game updated."
    assert_text "Chess Classic"
  end

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

  test "BGG link shown on show page" do
    visit game_url(games(:chess))
    assert_link "View on BoardGameGeek"
  end

  test "toggling to table view" do
    visit games_url
    find("button[aria-label='Table view']").click
    assert_selector "[data-view-toggle-target='tableView']", visible: true
    assert_selector "[data-view-toggle-target='gridView']", visible: :hidden
  end
end
