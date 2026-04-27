require "test_helper"

class GameTest < ActiveSupport::TestCase
  test "valid with name only" do
    assert Game.new(name: "Chess").valid?
  end

  test "invalid without name" do
    game = Game.new(name: "")
    assert_not game.valid?
    assert_includes game.errors[:name], "can't be blank"
  end

  test "valid with blank bgg_url" do
    assert Game.new(name: "Chess", bgg_url: "").valid?
  end

  test "valid with http bgg_url" do
    assert Game.new(name: "Chess", bgg_url: "https://boardgamegeek.com/boardgame/171/chess").valid?
  end

  test "invalid with non-url bgg_url" do
    game = Game.new(name: "Chess", bgg_url: "not-a-url")
    assert_not game.valid?
    assert game.errors[:bgg_url].any?
  end
end
