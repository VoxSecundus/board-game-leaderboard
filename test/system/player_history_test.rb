require "application_system_test_case"

class PlayerHistoryTest < ApplicationSystemTestCase
  test "player show page displays Play History section" do
    visit player_url(players(:alice))
    assert_text "Play History"
  end

  test "player show page lists plays with game column" do
    visit player_url(players(:alice))
    assert_selector "tbody tr", minimum: 1
    assert_text games(:chess).name
  end

  test "player show page shows green row for a win" do
    visit player_url(players(:alice))
    # alice won chess_night — that row should have the green win class
    assert_selector "tr[class*='bg-green-50']"
  end

  test "player show page shows red row for a loss" do
    visit player_url(players(:alice))
    # alice lost catan_rematch — that row should have the red loss class
    assert_selector "tr[class*='bg-red-50']"
  end

  test "player show page shows exactly one neutral row when no winner declared" do
    visit player_url(players(:alice))
    # alice has 3 plays: 1 win (chess_night), 1 loss (catan_rematch), 1 no-winner (catan_night)
    rows = all("tbody tr")
    assert_equal 3, rows.count
    neutral_rows = rows.select { |row| !row[:class].to_s.include?("bg-green") && !row[:class].to_s.include?("bg-red") }
    assert_equal 1, neutral_rows.count
  end

  test "player show page links to plays from date cell" do
    visit player_url(players(:alice))
    within "tbody" do
      assert_selector "a[href*='/plays/']"
    end
  end

  test "player with no plays shows empty state message" do
    visit player_url(players(:newcomer))
    assert_text "No plays recorded"
  end

  test "history table is sortable by date" do
    visit player_url(players(:alice))
    click_link "Date"
    assert_current_path(player_path(players(:alice)), ignore_query: true)
    assert_text "Play History"
  end
end
