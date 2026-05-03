require "application_system_test_case"

class LocationsTest < ApplicationSystemTestCase
  setup { log_in_via_browser }

  test "deleting a location from show page" do
    location = locations(:living_room)
    visit location_url(location)
    accept_confirm do
      click_button "Delete"
    end
    assert_current_path locations_path
    assert_text "Location deleted."
    assert_no_text location.name
  end

  test "toggling to table view" do
    visit locations_url
    find("button[aria-label='Table view']").click
    assert_selector "[data-view-toggle-target='tableView']", visible: true
    assert_selector "[data-view-toggle-target='gridView']", visible: :hidden
  end
end
