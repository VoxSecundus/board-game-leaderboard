require "application_system_test_case"

class PlayersTest < ApplicationSystemTestCase
  setup do
    SessionsController.any_instance.stubs(:valid_password?).returns(true)
    visit login_url
    fill_in "Password", with: "anything"
    click_button "Sign in"
  end

  test "viewing players index" do
    visit players_url
    assert_text "Players"
    assert_text players(:alice).name
    assert_text players(:bob).name
  end

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

  test "creating a player" do
    visit new_player_url
    fill_in "Name", with: "Dave"
    click_button "Create Player"
    assert_current_path(%r{^/players/\d+$})
    assert_text "Player created."
    assert_text "Dave"
  end

  test "creating a player with blank name shows error" do
    visit new_player_url
    fill_in "Name", with: ""
    click_button "Create Player"
    assert_text "can't be blank"
  end

  test "editing a player" do
    visit edit_player_url(players(:alice))
    fill_in "Name", with: "Alicia"
    click_button "Update Player"
    assert_text "Player updated."
    assert_text "Alicia"
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

  test "sort link changes URL query params" do
    visit players_url
    find("button[aria-label='Table view']").click
    click_link "Name"
    assert_current_path(%r{sort=name})
  end

  test "nav link to players is active" do
    visit players_url
    assert_selector "nav a[href='#{players_path}']"
  end
end
