require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  SQUARE_IMAGE    = Rails.root.join("test/fixtures/files/square.jpg")
  NONSQUARE_IMAGE = Rails.root.join("test/fixtures/files/nonsquare.jpg")
  GIF_IMAGE       = Rails.root.join("test/fixtures/files/square.gif")

  test "valid with name only" do
    assert Player.new(name: "Alice").valid?
  end

  test "invalid without name" do
    player = Player.new(name: "")
    assert_not player.valid?
    assert_includes player.errors[:name], "can't be blank"
  end

  test "valid with square jpeg attached" do
    player = players(:alice)
    player.profile_picture.attach(io: File.open(SQUARE_IMAGE), filename: "square.jpg", content_type: "image/jpeg")
    assert player.valid?, player.errors.full_messages.inspect
  end

  test "invalid with non-square image" do
    player = players(:alice)
    player.profile_picture.attach(io: File.open(NONSQUARE_IMAGE), filename: "nonsquare.jpg", content_type: "image/jpeg")
    assert_not player.valid?
    assert player.errors[:profile_picture].any? { |e| e.include?("square") }
  end

  test "invalid with unsupported content type" do
    player = players(:alice)
    player.profile_picture.attach(
      io: File.open(GIF_IMAGE),
      filename: "avatar.gif",
      content_type: "image/gif"
    )
    assert_not player.valid?
    assert player.errors[:profile_picture].any?
  end
end
