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

  test "Fetch from BGG button fills in name and shows image preview" do
    result = BggFetcher::Result.new(
      name: "Catan",
      image_url: "https://cf.geekdo-images.com/sized_hash/img/pic12345.jpg",
      expansions: [],
      error: nil
    )
    BggFetcher.stubs(:call).returns(result)

    visit new_game_url
    fill_in "game[bgg_url]", with: "https://boardgamegeek.com/boardgame/13/catan"
    click_button "Fetch from BGG"

    assert_field "game[name]", with: "Catan"
    assert_selector "img[src='https://cf.geekdo-images.com/sized_hash/img/pic12345.jpg']"
  end

  test "Fetch from BGG button shows error for invalid URL" do
    result = BggFetcher::Result.new(name: nil, image_url: nil, expansions: [], error: "Could not parse a game ID from that URL")
    BggFetcher.stubs(:call).returns(result)

    visit new_game_url
    fill_in "game[bgg_url]", with: "https://example.com"
    click_button "Fetch from BGG"

    assert_text "Could not parse a game ID from that URL"
  end

  test "selecting a file after BGG fetch clears the bgg_image_url hidden field" do
    result = BggFetcher::Result.new(
      name: "Catan",
      image_url: "https://cf.geekdo-images.com/sized_hash/img/pic12345.jpg",
      expansions: [],
      error: nil
    )
    BggFetcher.stubs(:call).returns(result)

    visit new_game_url
    fill_in "game[bgg_url]", with: "https://boardgamegeek.com/boardgame/13/catan"
    click_button "Fetch from BGG"
    assert_field "game[name]", with: "Catan"

    hidden = find("input[name='bgg_image_url']", visible: :all)
    assert_equal "https://cf.geekdo-images.com/sized_hash/img/pic12345.jpg", hidden.value

    attach_file "game[box_art]", Rails.root.join("test/fixtures/files/square.jpg")

    assert_equal "", hidden.value
  end
end
