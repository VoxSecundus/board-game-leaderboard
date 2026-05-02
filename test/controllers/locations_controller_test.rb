require "test_helper"

class LocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in
    @location = locations(:living_room)
  end

  test "GET /locations returns 200" do
    get locations_path
    assert_response :success
  end

  test "GET /locations with valid sort params returns 200" do
    get locations_path, params: { sort: "latitude", dir: "asc" }
    assert_response :success
  end

  test "GET /locations sorts by name asc" do
    get locations_path, params: { sort: "name", dir: "asc" }
    # "Living Room" < "London" alphabetically (Li < Lo)
    assert_operator response.body.index("Living Room"), :<, response.body.index("London")
  end

  test "GET /locations sorts by name desc" do
    get locations_path, params: { sort: "name", dir: "desc" }
    assert_operator response.body.index("London"), :<, response.body.index("Living Room")
  end

  test "GET /locations with invalid sort param returns 200 without crashing" do
    get locations_path, params: { sort: "1; DROP TABLE locations--" }
    assert_response :success
  end

  test "GET /locations/:id returns 200" do
    get location_path(@location)
    assert_response :success
  end

  test "GET /locations/new returns 200" do
    get new_location_path
    assert_response :success
  end

  test "POST /locations with valid params creates location and redirects" do
    assert_difference("Location.count", 1) do
      post locations_path, params: { location: { name: "Office" } }
    end
    assert_redirected_to location_path(Location.last)
    assert_equal "Location created.", flash[:notice]
  end

  test "POST /locations with coordinates creates location" do
    post locations_path, params: { location: { name: "London", latitude: "51.5074", longitude: "-0.1278" } }
    assert_redirected_to location_path(Location.last)
    location = Location.last
    assert_in_delta 51.5074, location.latitude, 0.0001
    assert_in_delta(-0.1278, location.longitude, 0.0001)
  end

  test "POST /locations with blank name returns 422" do
    post locations_path, params: { location: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "POST /locations with invalid latitude returns 422" do
    post locations_path, params: { location: { name: "Bad", latitude: "95" } }
    assert_response :unprocessable_entity
  end

  test "GET /locations/:id/edit returns 200" do
    get edit_location_path(@location)
    assert_response :success
  end

  test "PATCH /locations/:id with valid params updates and redirects" do
    patch location_path(@location), params: { location: { name: "Garage" } }
    assert_redirected_to location_path(@location)
    assert_equal "Garage", @location.reload.name
  end

  test "PATCH /locations/:id with blank name returns 422" do
    patch location_path(@location), params: { location: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "DELETE /locations/:id destroys location and redirects" do
    assert_difference("Location.count", -1) do
      delete location_path(@location)
    end
    assert_redirected_to locations_path
    assert_equal "Location deleted.", flash[:notice]
  end

  test "unauthenticated access redirects to login" do
    delete logout_path
    get locations_path
    assert_redirected_to login_path
  end

  test "GET /locations/:id shows map link when coordinates are present" do
    get location_path(locations(:london))
    assert_select "a", "View on map"
  end
end
