require "test_helper"

class ExpansionTest < ActiveSupport::TestCase
  test "valid with game and name" do
    assert Expansion.new(game: games(:chess), name: "Test Expansion").valid?
  end

  test "invalid without name" do
    expansion = Expansion.new(game: games(:chess), name: "")
    assert_not expansion.valid?
    assert_includes expansion.errors[:name], "can't be blank"
  end

  test "invalid without game" do
    assert_not Expansion.new(name: "Test Expansion").valid?
  end

  test "owned defaults to true" do
    expansion = Expansion.new(game: games(:chess), name: "Test Expansion")
    assert_equal true, expansion.owned
  end

  test "bgg_sourced defaults to false" do
    expansion = Expansion.new(game: games(:chess), name: "Test Expansion")
    assert_equal false, expansion.bgg_sourced
  end

  test "bgg_sourced expansion cannot be destroyed" do
    expansion = expansions(:chess_kings_gambit)
    assert_no_difference("Expansion.count") { expansion.destroy }
  end

  test "non-bgg_sourced expansion can be destroyed" do
    expansion = expansions(:catan_custom)
    assert_difference("Expansion.count", -1) { expansion.destroy }
  end
end
