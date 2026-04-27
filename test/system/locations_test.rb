require "application_system_test_case"

class LocationsTest < ApplicationSystemTestCase
  setup do
    SessionsController.any_instance.stubs(:valid_password?).returns(true)
    visit login_url
    fill_in "Password", with: "anything"
    click_button "Sign in"
  end

  test "viewing locations index" do
    visit locations_url
    assert_text "Locations"
    assert_text locations(:living_room).name
    assert_text locations(:london).name
  end

  test "creating a location without coordinates" do
    visit new_location_url
    fill_in "Name", with: "Office"
    click_button "Create Location"
    assert_current_path(%r{^/locations/\d+$})
    assert_text "Location created."
    assert_text "Office"
  end

  test "creating a location with coordinates" do
    visit new_location_url
    fill_in "Name", with: "Paris"
    fill_in "Latitude", with: "48.8566"
    fill_in "Longitude", with: "2.3522"
    click_button "Create Location"
    assert_text "Location created."
  end

  test "creating a location with blank name shows error" do
    visit new_location_url
    fill_in "Name", with: ""
    click_button "Create Location"
    assert_text "can't be blank"
  end

  test "editing a location" do
    visit edit_location_url(locations(:living_room))
    fill_in "Name", with: "Lounge"
    click_button "Update Location"
    assert_text "Location updated."
    assert_text "Lounge"
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

  test "map link shown for location with coordinates" do
    visit location_url(locations(:london))
    assert_link "View on map"
  end

  test "toggling to table view" do
    visit locations_url
    find("button[aria-label='Table view']").click
    assert_selector "[data-view-toggle-target='tableView']", visible: true
    assert_selector "[data-view-toggle-target='gridView']", visible: :hidden
  end
end
