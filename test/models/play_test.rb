require "test_helper"

class PlayTest < ActiveSupport::TestCase
  test "valid with game only" do
    play = Play.new(game: games(:chess))
    assert play.valid?
  end

  test "invalid without game" do
    play = Play.new
    assert_not play.valid?
    assert_includes play.errors[:game], "must exist"
  end

  test "valid without location" do
    play = Play.new(game: games(:catan))
    assert play.valid?
  end

  test "has players through play_participants" do
    play = plays(:chess_night)
    assert_includes play.players, players(:alice)
    assert_includes play.players, players(:bob)
  end
end
