require "application_system_test_case"

class PlaysTest < ApplicationSystemTestCase
  setup { log_in_via_browser }

  test "creating a play with a participant" do
    visit new_play_url
    select games(:chess).name, from: "Game"
    fill_in "Date", with: Date.today.iso8601
    click_button "+ Add Participant"
    within all("[data-play-form-target='row']").last do
      find("select").select players(:alice).name
      find("input[type='number']").fill_in with: "7"
      find("input[type='checkbox']").check
    end
    click_button "Record Play"
    assert_current_path(%r{^/plays/\d+$})
    assert_text "Play recorded."
    assert_text games(:chess).name
    assert_text players(:alice).name
    assert_text "★"
  end

  test "creating a play with no game shows error" do
    visit new_play_url
    click_button "Record Play"
    assert_text "must exist"
  end

  test "deleting a play from show page" do
    play = plays(:catan_night)
    visit play_url(play)
    accept_confirm do
      click_button "Delete"
    end
    assert_current_path plays_path
    assert_text "Play deleted."
  end

  test "sort link changes URL" do
    visit plays_url
    click_link "Date"
    assert_current_path(%r{sort=date})
  end

  test "editing a play updates a participant score, shows it on the show page" do
    play = plays(:chess_night)

    visit edit_play_url(play)
    within all("[data-play-form-target='row']").first do
      find("input[type='number']").set("42")
    end
    click_button "Update Play"

    assert_text "Play updated."
    within "table tbody" do
      assert_text "42"
    end
  end

  test "editing a play toggles winner status, shows it on the show page" do
    play = plays(:catan_night)

    visit edit_play_url(play)
    within all("[data-play-form-target='row']").first do
      find("input[type='checkbox']").check
    end
    click_button "Update Play"

    assert_text "Play updated."
    assert_text "★"
  end

  test "editing a play removes a participant, shows the removal on the show page" do
    play = plays(:chess_night)

    visit edit_play_url(play)
    within all("[data-play-form-target='row']").last do
      find("button[title='Remove']").click
    end
    click_button "Update Play"

    assert_text "Play updated."
    assert_no_text players(:bob).name
  end
end
