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

  test "clicking a location card navigates to the location" do
    location = locations(:living_room)
    visit locations_url
    within find("div[data-navigate-url-value='#{location_path(location)}']") do
      find("p", text: /Added/).click
    end
    assert_current_path location_path(location)
  end

  test "clicking a location table row navigates to the location" do
    location = locations(:living_room)
    visit locations_url
    find("button[aria-label='Table view']").click
    within "tr[data-navigate-url-value='#{location_path(location)}']" do
      find("td", text: location.created_at.to_date.to_s).click
    end
    assert_current_path location_path(location)
  end

  test "searching locations by name filters results" do
    visit locations_url
    fill_in placeholder: "Search by name…", with: "Lon"
    assert_text "London"
    assert_no_text "Living Room"
  end

  test "clearing the search restores all locations" do
    visit locations_url(q: "Lon")
    assert_no_text "Living Room"
    fill_in placeholder: "Search by name…", with: ""
    assert_text "London"
    assert_text "Living Room"
  end

  test "no-match search shows empty state message" do
    visit locations_url
    fill_in placeholder: "Search by name…", with: "zzznomatch"
    assert_text 'No locations match "zzznomatch"'
  end
end
