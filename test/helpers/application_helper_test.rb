require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "player avatar initials have the player's name as a title" do
    avatar = Nokogiri::HTML.fragment(player_avatar(players(:alice)).to_s)

    assert_equal "Alice", avatar.at_css("a > span")[:title]
  end

  test "uploaded player avatar has the player's name as a title" do
    player = players(:alice)
    player.profile_picture.attach(
      Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures/files/square.jpg"), "image/jpeg")
    )

    avatar = Nokogiri::HTML.fragment(player_avatar(player).to_s)

    assert_equal "Alice", avatar.at_css("a > img")[:title]
  end
end
