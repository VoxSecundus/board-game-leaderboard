require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    log_in
    @game = games(:chess)
  end

  test "GET /games shows pending import banner for each in-progress import" do
    BggCollectionImport.create!(username: "alice")
    BggCollectionImport.create!(username: "bob")
    get games_path
    assert_includes response.body, "alice"
    assert_includes response.body, "bob"
  end

  test "GET /games returns 200" do
    get games_path
    assert_response :success
  end

  test "GET /games with valid sort params returns 200" do
    get games_path, params: { sort: "name", dir: "asc" }
    assert_response :success
  end

  test "GET /games sorts by name asc" do
    get games_path, params: { sort: "name", dir: "asc" }
    assert_operator response.body.index("Catan"), :<, response.body.index("Chess")
  end

  test "GET /games sorts by name desc" do
    get games_path, params: { sort: "name", dir: "desc" }
    assert_operator response.body.index("Chess"), :<, response.body.index("Catan")
  end

  test "GET /games with invalid sort param returns 200 without crashing" do
    get games_path, params: { sort: "1; DROP TABLE games--" }
    assert_response :success
  end

  test "GET /games/:id returns 200" do
    get game_path(@game)
    assert_response :success
  end

  test "GET /games/new returns 200" do
    get new_game_path
    assert_response :success
  end

  test "POST /games with valid params creates game and redirects" do
    assert_difference("Game.count", 1) do
      post games_path, params: { game: { name: "Pandemic" } }
    end
    assert_redirected_to game_path(Game.last)
    assert_equal "Game created.", flash[:notice]
  end

  test "POST /games with blank name returns 422" do
    post games_path, params: { game: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "GET /games/:id/edit returns 200" do
    get edit_game_path(@game)
    assert_response :success
  end

  test "PATCH /games/:id with valid params updates and redirects" do
    patch game_path(@game), params: { game: { name: "Chess Classic" } }
    assert_redirected_to game_path(@game)
    assert_equal "Chess Classic", @game.reload.name
  end

  test "PATCH /games/:id with blank name returns 422" do
    patch game_path(@game), params: { game: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "DELETE /games/:id destroys game and redirects" do
    assert_difference("Game.count", -1) do
      delete game_path(@game)
    end
    assert_redirected_to games_path
    assert_equal "Game deleted.", flash[:notice]
  end

  test "unauthenticated access redirects to login" do
    delete logout_path
    get games_path
    assert_redirected_to login_path
  end

  test "GET /games/:id shows BGG link when bgg_url is set" do
    get game_path(games(:chess))
    assert_select "a", /BoardGameGeek/
  end

  test "GET /games/:id shows Play History section" do
    get game_path(games(:chess))
    assert_response :success
    assert_select "h2", /Play History/
  end

  test "GET /games/:id shows play notes in history table" do
    get game_path(games(:chess))
    assert_select "tbody tr", minimum: 1
    assert_select "td", /Great game/
  end

  test "GET /games/:id sorts plays by date asc" do
    # chess_night is 1.week.ago ("Great game"); chess_night_2 is 2.days.ago ("Second chess game")
    get game_path(games(:chess)), params: { sort: "date", dir: "asc" }
    assert_operator response.body.index("Great game"), :<, response.body.index("Second chess game")
  end

  test "GET /games/:id sorts plays by date desc" do
    get game_path(games(:chess)), params: { sort: "date", dir: "desc" }
    assert_operator response.body.index("Second chess game"), :<, response.body.index("Great game")
  end

  test "GET /games/:id sorts plays by location asc" do
    # chess_night is in Living Room; chess_night_2 is in London; "Li" < "Lo" alphabetically
    get game_path(games(:chess)), params: { sort: "location", dir: "asc" }
    assert_operator response.body.index("Great game"), :<, response.body.index("Second chess game")
  end

  test "GET /games/:id sorts plays by location desc" do
    get game_path(games(:chess)), params: { sort: "location", dir: "desc" }
    assert_operator response.body.index("Second chess game"), :<, response.body.index("Great game")
  end

  test "GET /games/:id with invalid sort dir defaults gracefully" do
    get game_path(games(:chess)), params: { sort: "date", dir: "invalid" }
    assert_response :success
  end

  test "GET /games/:id with invalid sort param returns 200 without crashing" do
    get game_path(games(:chess)), params: { sort: "1; DROP TABLE plays--" }
    assert_response :success
  end

  test "GET /games/:id shows empty state when game has no plays" do
    get game_path(games(:monopoly))
    assert_response :success
    assert_select "p", /No plays recorded/
  end

  test "GET /games paginates: page 2 contains records beyond 25" do
    22.times { |i| Game.create!(name: "Extra #{"%.2d" % i}") }
    Game.create!(name: "Zzz Pagination")
    get games_path, params: { page: 2 }
    assert_response :success
    assert_includes response.body, "Zzz Pagination"
  end

  test "GET /games paginates: page 1 does not contain page 2 records" do
    22.times { |i| Game.create!(name: "Extra #{"%.2d" % i}") }
    Game.create!(name: "Zzz Pagination")
    get games_path
    assert_response :success
    refute_includes response.body, "Zzz Pagination"
  end

  # bgg_lookup

  test "GET /games/bgg_lookup returns turbo stream with name on success" do
    result = BggFetcher::Result.new(name: "Catan", image_url: "https://example.com/catan.jpg", error: nil)
    BggFetcher.stubs(:call).returns(result)
    get bgg_lookup_games_path, params: { bgg_url: "https://boardgamegeek.com/boardgame/13/catan" },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_includes response.body, "Catan"
  end

  test "GET /games/bgg_lookup returns turbo stream with error message on bad URL" do
    result = BggFetcher::Result.new(name: nil, image_url: nil, error: "Could not parse a game ID from that URL")
    BggFetcher.stubs(:call).returns(result)
    get bgg_lookup_games_path, params: { bgg_url: "https://example.com" },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_includes response.body, "Could not parse a game ID from that URL"
  end

  test "GET /games/bgg_lookup returns turbo stream with error on API failure" do
    result = BggFetcher::Result.new(name: nil, image_url: nil, error: "BGG API request failed")
    BggFetcher.stubs(:call).returns(result)
    get bgg_lookup_games_path, params: { bgg_url: "https://boardgamegeek.com/boardgame/13/catan" },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_includes response.body, "BGG API request failed"
  end

  # create with bgg_image_url

  test "POST /games with bgg_image_url attaches image when no file uploaded" do
    mock_response = mock()
    mock_response.stubs(:is_a?).with(Net::HTTPSuccess).returns(true)
    mock_response.stubs(:content_type).returns("image/jpeg")
    mock_response.stubs(:body).returns("fake-jpeg-bytes")
    GamesController.any_instance.stubs(:fetch_following_redirects).returns(mock_response)

    assert_difference("Game.count", 1) do
      post games_path, params: {
        game: { name: "Catan", bgg_url: "https://boardgamegeek.com/boardgame/13/catan" },
        bgg_image_url: "https://cf.geekdo-images.com/pics/pic12345.jpg"
      }
    end
    assert_redirected_to game_path(Game.last)
  end

  test "POST /games with bgg_image_url skips download when file also uploaded" do
    GamesController.any_instance.expects(:fetch_following_redirects).never
    fixture_file = fixture_file_upload("square.jpg", "image/jpeg")

    assert_difference("Game.count", 1) do
      post games_path, params: {
        game: { name: "Catan", box_art: fixture_file },
        bgg_image_url: "https://cf.geekdo-images.com/pics/pic12345.jpg"
      }
    end
  end

  # update with bgg_image_url

  test "PATCH /games/:id with bgg_image_url attaches image when no file uploaded" do
    mock_response = mock()
    mock_response.stubs(:is_a?).with(Net::HTTPSuccess).returns(true)
    mock_response.stubs(:content_type).returns("image/jpeg")
    mock_response.stubs(:body).returns("fake-jpeg-bytes")
    GamesController.any_instance.stubs(:fetch_following_redirects).returns(mock_response)

    patch game_path(@game), params: {
      game: { name: @game.name },
      bgg_image_url: "https://cf.geekdo-images.com/pics/pic12345.jpg"
    }
    assert_redirected_to game_path(@game)
  end

  # URL validation for bgg_image_url

  test "POST /games with http bgg_image_url skips download" do
    GamesController.any_instance.expects(:fetch_following_redirects).never
    Rails.logger.expects(:error).with(regexp_matches(/rejected unsafe URL/))
    assert_difference("Game.count", 1) do
      post games_path, params: {
        game: { name: "Catan" },
        bgg_image_url: "http://cf.geekdo-images.com/pic.jpg"
      }
    end
    assert_redirected_to game_path(Game.last)
  end

  test "POST /games with bgg_image_url from disallowed host skips download" do
    GamesController.any_instance.expects(:fetch_following_redirects).never
    Rails.logger.expects(:error).with(regexp_matches(/rejected unsafe URL/))
    assert_difference("Game.count", 1) do
      post games_path, params: {
        game: { name: "Catan" },
        bgg_image_url: "https://evil.example.com/pic.jpg"
      }
    end
    assert_redirected_to game_path(Game.last)
  end

  # bgg_import

  test "GET /games/bgg_import returns 200" do
    get bgg_import_games_path
    assert_response :success
  end

  test "POST /games/bgg_import with username renders preview with game names" do
    items = [
      BggCollectionFetcher::CollectionItem.new(bgg_id: 13, name: "Catan", image_url: nil, bgg_url: "https://boardgamegeek.com/boardgame/13"),
      BggCollectionFetcher::CollectionItem.new(bgg_id: 68448, name: "7 Wonders", image_url: nil, bgg_url: "https://boardgamegeek.com/boardgame/68448")
    ]
    BggCollectionFetcher.stubs(:call).returns(BggCollectionFetcher::Result.new(items: items, error: nil))
    post bgg_import_games_path, params: { username: "testuser" }
    assert_response :success
    assert_includes response.body, "Catan"
    assert_includes response.body, "7 Wonders"
  end

  test "POST /games/bgg_import marks game matching existing bgg_url as already in leaderboard" do
    items = [
      BggCollectionFetcher::CollectionItem.new(bgg_id: 171, name: "Chess", image_url: nil, bgg_url: "https://boardgamegeek.com/boardgame/171")
    ]
    BggCollectionFetcher.stubs(:call).returns(BggCollectionFetcher::Result.new(items: items, error: nil))
    post bgg_import_games_path, params: { username: "testuser" }
    assert_response :success
    assert_includes response.body, "already in leaderboard"
  end

  test "POST /games/bgg_import shows error when service fails" do
    BggCollectionFetcher.stubs(:call).returns(BggCollectionFetcher::Result.new(items: [], error: "User not found"))
    post bgg_import_games_path, params: { username: "nonexistent" }
    assert_response :success
    assert_includes response.body, "User not found"
  end

  test "POST /games/bgg_import with bgg_ids enqueues BggCollectionImportJob and redirects" do
    assert_enqueued_with(job: BggCollectionImportJob) do
      post bgg_import_games_path, params: {
        step: "import",
        username: "testuser",
        bgg_ids: [ "999" ],
        game_names: { "999" => "New Game" },
        game_image_urls: { "999" => "" }
      }
    end
    assert_redirected_to games_path
  end

  test "POST /games/bgg_import with bgg_ids creates a BggCollectionImport tracking record" do
    assert_difference("BggCollectionImport.count", 1) do
      post bgg_import_games_path, params: {
        step: "import",
        username: "testuser",
        bgg_ids: [ "999" ],
        game_names: { "999" => "New Game" },
        game_image_urls: { "999" => "" }
      }
    end
    assert_equal "testuser", BggCollectionImport.last.username
  end

  test "POST /games/bgg_import blocks a second import while one is already in progress" do
    BggCollectionImport.create!(username: "first")
    assert_no_enqueued_jobs do
      post bgg_import_games_path, params: {
        step: "import",
        username: "testuser",
        bgg_ids: [ "999" ],
        game_names: { "999" => "New Game" },
        game_image_urls: { "999" => "" }
      }
    end
    assert_redirected_to games_path
    assert flash[:alert].present?
  end

  test "POST /games/bgg_import with no bgg_ids selected redirects with alert" do
    assert_no_difference("BggCollectionImport.count") do
      assert_no_enqueued_jobs do
        post bgg_import_games_path, params: {
          step: "import",
          username: "testuser",
          game_names: { "999" => "New Game" },
          game_image_urls: { "999" => "" }
        }
      end
    end
    assert_redirected_to games_path
    assert flash[:alert].present?
  end

  # fetch_following_redirects

  test "fetch_following_redirects returns nil when redirect target is disallowed" do
    controller = GamesController.new
    redirect_response = mock()
    redirect_response.stubs(:is_a?).with(Net::HTTPRedirection).returns(true)
    redirect_response.stubs(:is_a?).with(Net::HTTPSuccess).returns(false)
    redirect_response.stubs(:[]).with("location").returns("https://169.254.169.254/secret")
    redirect_response.stubs(:code).returns("302")
    http = mock()
    http.stubs(:request).returns(redirect_response)
    # expects once: without the SSRF fix the code tries to follow the redirect
    # (calling start again for 169.254.169.254), which would violate the once expectation
    Net::HTTP.expects(:start).once.yields(http).returns(redirect_response)
    Rails.logger.expects(:error).with(regexp_matches(/rejected redirect to/))

    result = controller.send(:fetch_following_redirects, "https://cf.geekdo-images.com/pic.jpg")
    assert_nil result
  end

  test "GET /games filters by name" do
    get games_path, params: { q: "Che" }
    assert_response :success
    assert_includes response.body, "Chess"
    refute_includes response.body, "Catan"
    refute_includes response.body, "Monopoly"
  end

  test "GET /games with blank q returns all records" do
    get games_path, params: { q: "" }
    assert_response :success
    assert_includes response.body, "Chess"
    assert_includes response.body, "Catan"
  end

  test "GET /games search is case-insensitive" do
    get games_path, params: { q: "chess" }
    assert_response :success
    assert_includes response.body, "Chess"
  end

  test "GET /games search with wildcard characters does not crash" do
    Game.create!(name: "1000 Blank Cards")
    get games_path, params: { q: "100%" }
    assert_response :success
    refute_includes response.body, "1000 Blank Cards"
  end
end
