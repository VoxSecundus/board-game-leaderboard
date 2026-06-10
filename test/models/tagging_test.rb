require "test_helper"

class TaggingTest < ActiveSupport::TestCase
  test "belongs to tag and polymorphic taggable" do
    tagging = taggings(:one)
    assert_instance_of Tag, tagging.tag
    assert_instance_of Location, tagging.taggable
  end

  test "cannot duplicate tag on same taggable" do
    existing = taggings(:one)
    duplicate = Tagging.new(tag: existing.tag, taggable: existing.taggable)
    assert_not duplicate.valid?
    assert duplicate.errors[:tag_id].any?
  end

  test "same tag can appear on different taggables" do
    location = Location.create!(name: "New Place")
    tagging = Tagging.new(tag: tags(:home), taggable: location)
    assert tagging.valid?
  end
end
