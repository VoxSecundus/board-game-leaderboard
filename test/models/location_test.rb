require "test_helper"

class LocationTest < ActiveSupport::TestCase
  test "valid with name only" do
    assert Location.new(name: "Home").valid?
  end

  test "invalid without name" do
    location = Location.new(name: "")
    assert_not location.valid?
    assert_includes location.errors[:name], "can't be blank"
  end

  test "valid without coordinates" do
    assert Location.new(name: "Somewhere").valid?
  end

  test "valid with coordinates" do
    assert Location.new(name: "London", latitude: 51.5074, longitude: -0.1278).valid?
  end

  test "valid at boundary latitude" do
    assert Location.new(name: "North Pole", latitude: 90.0, longitude: 0.0).valid?
    assert Location.new(name: "South Pole", latitude: -90.0, longitude: 0.0).valid?
  end

  test "valid at boundary longitude" do
    assert Location.new(name: "Antimeridian", latitude: 0.0, longitude: 180.0).valid?
    assert Location.new(name: "Antimeridian West", latitude: 0.0, longitude: -180.0).valid?
  end

  test "invalid with latitude out of range" do
    location = Location.new(name: "Bad", latitude: 91.0)
    assert_not location.valid?
    assert location.errors[:latitude].any?
  end

  test "invalid with longitude out of range" do
    location = Location.new(name: "Bad", longitude: 181.0)
    assert_not location.valid?
    assert location.errors[:longitude].any?
  end
end
