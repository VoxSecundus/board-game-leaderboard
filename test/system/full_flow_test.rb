require "application_system_test_case"

class FullFlowTest < ApplicationSystemTestCase
  setup { log_in_via_browser }

  test "complete user journey" do
    # Create Player 1
    visit new_player_url
    assert_current_path new_player_path
    fill_in "Name", with: "Journey Alice"
    click_button "Create Player"
    assert_text "Player created."

    # Create Player 2
    visit new_player_url
    fill_in "Name", with: "Journey Bob"
    click_button "Create Player"
    assert_text "Player created."

    # Create a Game
    visit new_game_url
    fill_in "Name", with: "Journey Chess"
    click_button "Create Game"
    assert_text "Game created."

    # Create a Location
    visit new_location_url
    fill_in "Name", with: "Journey Location"
    click_button "Create Location"
    assert_text "Location created."

    # Record a Play
    visit new_play_url
    select "Journey Chess", from: "Game"
    fill_in "Date", with: Date.today.iso8601
    select "Journey Location", from: "Location"
    fill_in "Notes", with: "End-to-end test notes"

    click_button "+ Add Participant"
    within all("[data-play-form-target='row']").last do
      find("select").select "Journey Alice"
      find("input[type='number']").fill_in with: "10"
      find("input[type='checkbox']").check
    end

    click_button "+ Add Participant"
    within all("[data-play-form-target='row']").last do
      find("select").select "Journey Bob"
      find("input[type='number']").fill_in with: "5"
    end

    click_button "Record Play"
    assert_text "Play recorded."
    assert_text "Journey Chess"
    assert_text "End-to-end test notes"
    assert_text "Journey Alice"
    assert_text "★"

    # Verify game history
    click_link "Journey Chess"
    assert_text "Play History"
    assert_text "Journey Alice"

    # Verify player history colours
    visit players_url
    click_link "Journey Alice"
    assert_text "Play History"
    assert_selector "tr[class*='bg-green']"

    visit players_url
    click_link "Journey Bob"
    assert_text "Play History"
    assert_selector "tr[class*='bg-red']"

    # Compare players
    visit compare_url
    select "Journey Alice", from: "player1_id"
    select "Journey Bob", from: "player2_id"
    click_button "Compare"
    within "turbo-frame#results" do
      assert_text "Journey Alice"
      assert_text "Journey Bob"
    end

    # Logout
    click_button "Logout"
    assert_current_path login_path
  end
end
