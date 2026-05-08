require "test_helper"

class PlayExpansionTest < ActiveSupport::TestCase
  test "valid with play and expansion" do
    pe = PlayExpansion.new(play: plays(:chess_night), expansion: expansions(:chess_kings_gambit))
    assert pe.valid?
  end

  test "invalid without play" do
    pe = PlayExpansion.new(expansion: expansions(:chess_kings_gambit))
    assert_not pe.valid?
  end

  test "invalid without expansion" do
    pe = PlayExpansion.new(play: plays(:chess_night))
    assert_not pe.valid?
  end
end
