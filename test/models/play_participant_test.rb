require "test_helper"

class PlayParticipantTest < ActiveSupport::TestCase
  test "valid with play and player" do
    pp = PlayParticipant.new(play: plays(:chess_night), player: players(:alice))
    assert pp.valid?
  end

  test "invalid without player" do
    pp = PlayParticipant.new(play: plays(:chess_night))
    assert_not pp.valid?
    assert_includes pp.errors[:player], "must exist"
  end

  test "winner defaults to false" do
    pp = play_participants(:alice_catan)
    assert_equal false, pp.winner
  end
end
