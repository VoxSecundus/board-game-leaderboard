require "application_system_test_case"

class BulkPlaysTest < ApplicationSystemTestCase
  setup { log_in_via_browser }

  test "bulk record link is present on plays index" do
    visit plays_url
    assert_link "Bulk Record"
  end

  test "navigating to bulk entry page from plays index" do
    visit plays_url
    assert_current_path plays_path
    click_link "Bulk Record"
    assert_current_path bulk_new_plays_path
  end

  test "adding a play with no meta set shows all fields editable" do
    visit bulk_new_plays_url
    click_button "+ Add Play"
    within all("[data-bulk-play-form-target='play']").last do
      assert_selector "[data-editable='game']", visible: true
      assert_selector "[data-locked='game']", visible: :hidden
      assert_selector "[data-editable='date']", visible: true
      assert_selector "[data-locked='date']", visible: :hidden
      assert_selector "[data-editable='location']", visible: true
      assert_selector "[data-locked='location']", visible: :hidden
    end
  end

  test "setting meta game locks the game field in added play entries" do
    visit bulk_new_plays_url
    find("[data-bulk-play-form-target='metaGame']").find("option[value='#{games(:chess).id}']").select_option
    click_button "+ Add Play"
    within all("[data-bulk-play-form-target='play']").last do
      assert_selector "[data-locked='game']", visible: true
      assert_selector "[data-editable='game']", visible: :hidden
      assert_text games(:chess).name
    end
  end

  test "setting meta participants locks players but leaves score and winner editable per play" do
    visit bulk_new_plays_url
    within "[data-meta-participants-section]" do
      click_button "+ Add Participant"
      find("[data-bulk-play-form-target='metaParticipants']").find("select").find("option[value='#{players(:alice).id}']").select_option
    end
    click_button "+ Add Play"
    within all("[data-bulk-play-form-target='play']").last do
      assert_selector "[data-field='extra-participants']", visible: :hidden
      within "[data-field='meta-participants']" do
        assert_text players(:alice).name
        assert_selector "input[type='number']"
        assert_selector "input[type='checkbox']"
        assert_no_selector "select"
      end
    end
  end

  test "adding a play entry appends it to the list" do
    visit bulk_new_plays_url
    assert_selector "[data-bulk-play-form-target='play']", count: 0
    click_button "+ Add Play"
    assert_selector "[data-bulk-play-form-target='play']", count: 1
    click_button "+ Add Play"
    assert_selector "[data-bulk-play-form-target='play']", count: 2
  end

  test "removing a play entry removes it from the list" do
    visit bulk_new_plays_url
    click_button "+ Add Play"
    click_button "+ Add Play"
    assert_selector "[data-bulk-play-form-target='play']", count: 2
    all("[data-bulk-play-form-target='play']").first.click_button "Remove"
    assert_selector "[data-bulk-play-form-target='play']", count: 1
  end

  test "changing the meta game updates already-added play entries" do
    visit bulk_new_plays_url
    click_button "+ Add Play"
    find("[data-bulk-play-form-target='metaGame']").find("option[value='#{games(:chess).id}']").select_option
    within all("[data-bulk-play-form-target='play']").last do
      assert_selector "[data-locked='game']", visible: true
      assert_selector "[data-editable='game']", visible: :hidden
      assert_text games(:chess).name
    end
  end

  test "clearing meta game restores the editable game select in play entries" do
    visit bulk_new_plays_url
    find("[data-bulk-play-form-target='metaGame']").find("option[value='#{games(:chess).id}']").select_option
    click_button "+ Add Play"
    find("[data-bulk-play-form-target='metaGame']").find("option[value='']").select_option
    within all("[data-bulk-play-form-target='play']").last do
      assert_selector "[data-editable='game']", visible: true
      assert_selector "[data-locked='game']", visible: :hidden
    end
  end

  test "submitting two plays creates both and redirects to plays index" do
    visit bulk_new_plays_url
    assert_current_path bulk_new_plays_path
    find("[data-bulk-play-form-target='metaGame']").find("option[value='#{games(:chess).id}']").select_option
    click_button "+ Add Play"
    click_button "+ Add Play"
    assert_selector "[data-bulk-play-form-target='play']", count: 2
    initial_count = Play.count
    click_button "Record Plays"
    assert_current_path plays_path
    assert_text "2 plays recorded."
    assert_equal initial_count + 2, Play.count
  end

  test "submitting a play with per-play game selection creates it" do
    visit bulk_new_plays_url
    click_button "+ Add Play"
    within all("[data-bulk-play-form-target='play']").last do
      find("[data-editable='game'] select").find("option[value='#{games(:chess).id}']").select_option
      find("[data-editable='date'] input").set(Date.today.to_s)
    end
    initial_count = Play.count
    click_button "Record Plays"
    assert_current_path plays_path
    assert_text "1 play recorded."
    assert_equal initial_count + 1, Play.count
  end
end
