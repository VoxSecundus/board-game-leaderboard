require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "valid with name" do
    assert Tag.new(name: "tournament").valid?
  end

  test "invalid without name" do
    tag = Tag.new(name: "")
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "normalizes name to lowercase on save" do
    tag = Tag.create!(name: "Tournament")
    assert_equal "tournament", tag.name
  end

  test "strips whitespace from name on save" do
    tag = Tag.create!(name: "  tournament  ")
    assert_equal "tournament", tag.name
  end

  test "name must be unique" do
    Tag.create!(name: "tournament")
    duplicate = Tag.new(name: "tournament")
    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "uniqueness is enforced case-insensitively" do
    Tag.create!(name: "tournament")
    duplicate = Tag.new(name: "TOURNAMENT")
    assert_not duplicate.valid?
  end
end
