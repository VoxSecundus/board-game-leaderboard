require "test_helper"

class BggCollectionImportJobTest < ActiveJob::TestCase
  def item(bgg_id:, name:, image_url: nil)
    { "bgg_id" => bgg_id, "name" => name, "image_url" => image_url,
      "bgg_url" => "https://boardgamegeek.com/boardgame/#{bgg_id}" }
  end

  test "creates a game for each item" do
    assert_difference("Game.count", 1) do
      BggCollectionImportJob.new.perform([ item(bgg_id: 999, name: "Pandemic") ], nil)
    end
    assert_equal "Pandemic", Game.last.name
    assert_equal "https://boardgamegeek.com/boardgame/999", Game.last.bgg_url
  end

  test "skips item whose bgg_id matches an existing game bgg_url" do
    # games(:chess) fixture has bgg_url containing /boardgame/171
    assert_no_difference("Game.count") do
      BggCollectionImportJob.new.perform([ item(bgg_id: 171, name: "Chess") ], nil)
    end
  end

  test "imports new items and skips existing ones in the same batch" do
    assert_difference("Game.count", 1) do
      BggCollectionImportJob.new.perform([
        item(bgg_id: 171, name: "Chess"),
        item(bgg_id: 999, name: "Pandemic")
      ], nil)
    end
  end

  test "attaches image when image_url is present" do
    mock_response = mock()
    mock_response.stubs(:is_a?).with(Net::HTTPSuccess).returns(true)
    mock_response.stubs(:content_type).returns("image/jpeg")
    mock_response.stubs(:body).returns("fake-jpeg-bytes")
    BggCollectionImportJob.any_instance.stubs(:fetch_with_redirects).returns(mock_response)

    BggCollectionImportJob.new.perform([
      item(bgg_id: 999, name: "Pandemic", image_url: "https://cf.geekdo-images.com/pic.jpg")
    ], nil)
    assert Game.last.box_art.attached?
  end

  test "saves game without image when image_url is nil" do
    BggCollectionImportJob.new.perform([ item(bgg_id: 999, name: "Pandemic") ], nil)
    assert_not Game.last.box_art.attached?
  end

  test "does nothing with an empty items array" do
    assert_no_difference("Game.count") { BggCollectionImportJob.new.perform([], nil) }
  end

  test "deletes the BggCollectionImport tracking record when done" do
    import = BggCollectionImport.create!(username: "testuser")
    BggCollectionImportJob.new.perform([], import.id)
    assert_not BggCollectionImport.exists?(import.id)
  end
end
