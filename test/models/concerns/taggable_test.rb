require "test_helper"

class TaggableTest < ActiveSupport::TestCase
  test "location has tags via taggings" do
    assert_includes locations(:living_room).tags.map(&:name), "home"
  end

  test "tag_list returns comma-separated sorted tag names" do
    assert_equal "home", locations(:living_room).tag_list
  end

  test "tag_list= assigns tags from comma-separated string" do
    location = locations(:living_room)
    location.tag_list = "café, tournament"
    location.save!
    assert_equal [ "café", "tournament" ], location.tags.order(:name).pluck(:name)
  end

  test "tag_list= strips whitespace and downcases" do
    location = Location.create!(name: "Test")
    location.tag_list = "  Home , CAFÉ  "
    location.save!
    assert_equal [ "café", "home" ], location.tags.order(:name).pluck(:name)
  end

  test "tag_list= with empty string removes all tags" do
    location = locations(:living_room)
    location.tag_list = ""
    location.save!
    assert_equal [], location.tags.pluck(:name)
  end

  test "tag_list= reuses existing Tag records rather than duplicating" do
    existing = tags(:home)
    location = locations(:london)
    location.tag_list = "home"
    location.save!
    assert_equal 1, Tag.where(name: "home").count
    assert_includes location.tags, existing
  end

  test "tagged_with scope returns locations with that tag" do
    assert_includes Location.tagged_with("home"), locations(:living_room)
    refute_includes Location.tagged_with("home"), locations(:london)
  end

  test "tagged_with scope is case-insensitive" do
    assert_includes Location.tagged_with("Home"), locations(:living_room)
  end

  test "destroying a location also destroys its taggings" do
    location = locations(:living_room)
    count = location.taggings.count
    assert_difference("Tagging.count", -count) do
      location.destroy
    end
  end

  test "destroying a tagging does not destroy the tag" do
    tag = tags(:home)
    assert_no_difference("Tag.count") do
      taggings(:one).destroy
    end
    assert tag.reload.persisted?
  end

  test "tag_list virtual attribute is preserved on failed save" do
    location = Location.new(name: "", tag_list: "home")
    location.valid?
    assert_equal "home", location.tag_list
  end
end
