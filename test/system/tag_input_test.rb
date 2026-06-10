require "application_system_test_case"

class TagInputTest < ApplicationSystemTestCase
  setup { log_in_via_browser }

  test "can add tags via keyboard on new location form" do
    visit new_location_url
    fill_in "Name", with: "My Place"

    find('[data-tag-input-target="input"]').fill_in with: "work"
    find('[data-tag-input-target="input"]').send_keys :return
    find('[data-tag-input-target="input"]').fill_in with: "meeting"
    find('[data-tag-input-target="input"]').send_keys ","

    assert_selector "[data-chip='work']"
    assert_selector "[data-chip='meeting']"

    click_button "Create Location"
    assert_text "Location created."

    location = Location.find_by!(name: "My Place")
    assert_equal %w[meeting work], location.tags.order(:name).pluck(:name)
  end

  test "existing tags appear as selectable buttons and toggle chips" do
    location = locations(:living_room)
    visit edit_location_url(location)

    assert_selector "[data-tag-input-target='existing']"

    existing_btn = find("[data-tag-input-target='existing'][data-tag='home']")
    assert_selector "[data-chip='home']"

    existing_btn.click
    assert_no_selector "[data-chip='home']"

    existing_btn.click
    assert_selector "[data-chip='home']"
  end

  test "removing a chip via × button" do
    location = locations(:living_room)
    visit edit_location_url(location)

    assert_selector "[data-chip='home']"
    find("[data-chip='home'] button").click
    assert_no_selector "[data-chip='home']"
  end

  test "tag filter link on index filters results" do
    visit locations_url
    assert_text "Living Room"

    click_link "home"
    assert_current_path locations_path(tag: "home")
    assert_text "Living Room"
    assert_no_text "London"
    assert_text "Filtered by tag"
    click_link "Clear filter"
    assert_current_path locations_path
  end
end
