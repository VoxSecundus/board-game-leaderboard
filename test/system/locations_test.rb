require "application_system_test_case"

class LocationsTest < ApplicationSystemTestCase
  setup do
    SessionsController.any_instance.stubs(:valid_password?).returns(true)
    visit login_url
    fill_in "Password", with: "anything"
    click_button "Sign in"
  end

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
