require "application_system_test_case"

class GameHistoryTest < ApplicationSystemTestCase
  setup { log_in_via_browser }

  test "game show page displays Play History section" do
    visit game_url(games(:chess))
    assert_text "Play History"
  end

  test "game show page lists notes in history table" do
    visit game_url(games(:chess))
    assert_selector "tbody tr", minimum: 1
    assert_text "Great game"
  end

  test "game show page links to play from date cell" do
    visit game_url(games(:chess))
    within "tbody" do
      assert_selector "a[href*='/plays/']"
    end
  end

  test "game show page shows winner name in history table" do
    visit game_url(games(:chess))
    within "tbody" do
      assert_text players(:alice).name
    end
  end

  test "game with no plays shows empty state message" do
    visit game_url(games(:monopoly))
    assert_text "No plays recorded"
  end

  test "history table is sortable by date" do
    visit game_url(games(:chess))
    click_link "Date"
    assert_current_path(game_path(games(:chess)), ignore_query: true)
    assert_text "Play History"
  end
end
