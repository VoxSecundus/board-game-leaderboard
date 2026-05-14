require "test_helper"

class PlayersControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in
    @player = players(:alice)
  end

  test "GET /players returns 200" do
    get players_path
    assert_response :success
  end

  test "GET /players with valid sort params returns 200" do
    get players_path, params: { sort: "name", dir: "desc" }
    assert_response :success
  end

  test "GET /players sorts by name asc" do
    get players_path, params: { sort: "name", dir: "asc" }
    assert_operator response.body.index("Alice"), :<, response.body.index("Bob")
  end

  test "GET /players sorts by name desc" do
    get players_path, params: { sort: "name", dir: "desc" }
    assert_operator response.body.index("Bob"), :<, response.body.index("Alice")
  end

  test "GET /players with invalid sort param returns 200 without crashing" do
    get players_path, params: { sort: "injected; DROP TABLE players--", dir: "asc" }
    assert_response :success
  end

  test "GET /players/:id returns 200" do
    get player_path(@player)
    assert_response :success
  end

  test "GET /players/new returns 200" do
    get new_player_path
    assert_response :success
  end

  test "POST /players with valid params creates player and redirects" do
    assert_difference("Player.count", 1) do
      post players_path, params: { player: { name: "Charlie" } }
    end
    assert_redirected_to player_path(Player.last)
    assert_equal "Player created.", flash[:notice]
  end

  test "POST /players with blank name returns 422" do
    post players_path, params: { player: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "GET /players/:id/edit returns 200" do
    get edit_player_path(@player)
    assert_response :success
  end

  test "PATCH /players/:id with valid params updates and redirects" do
    patch player_path(@player), params: { player: { name: "Alicia" } }
    assert_redirected_to player_path(@player)
    assert_equal "Alicia", @player.reload.name
  end

  test "PATCH /players/:id with blank name returns 422" do
    patch player_path(@player), params: { player: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "DELETE /players/:id destroys player and redirects" do
    assert_difference("Player.count", -1) do
      delete player_path(@player)
    end
    assert_redirected_to players_path
    assert_equal "Player deleted.", flash[:notice]
  end

  test "unauthenticated access redirects to login" do
    delete logout_path
    get players_path
    assert_redirected_to login_path
  end

  test "GET /players/:id shows Play History section" do
    get player_path(@player)
    assert_response :success
    assert_select "h2", /Play History/
  end

  test "GET /players/:id shows game link in history table" do
    get player_path(@player)
    assert_select "tbody tr", minimum: 1
    assert_select "td a", /Chess/
  end

  test "GET /players/:id sorts plays by date desc" do
    # chess_night (1.week.ago, "Great game") is more recent than catan_rematch (2.weeks.ago, "...revenge")
    get player_path(@player), params: { sort: "date", dir: "desc" }
    assert_operator response.body.index("Great game"), :<, response.body.index("revenge")
  end

  test "GET /players/:id sorts plays by date asc" do
    # catan_rematch (2.weeks.ago) is oldest, so "revenge" appears before "Great game"
    get player_path(@player), params: { sort: "date", dir: "asc" }
    assert_operator response.body.index("revenge"), :<, response.body.index("Great game")
  end

  test "GET /players/:id with sort=location and dir=asc returns 200" do
    get player_path(@player), params: { sort: "location", dir: "asc" }
    assert_response :success
  end

  test "GET /players/:id with sort=location and dir=desc returns 200" do
    get player_path(@player), params: { sort: "location", dir: "desc" }
    assert_response :success
  end

  test "GET /players/:id with invalid sort dir defaults gracefully" do
    get player_path(@player), params: { sort: "date", dir: "invalid" }
    assert_response :success
  end

  test "GET /players/:id with invalid sort param returns 200 without crashing" do
    get player_path(@player), params: { sort: "injected; DROP TABLE plays--" }
    assert_response :success
  end

  test "GET /players/:id shows empty state when player has no plays" do
    get player_path(players(:newcomer))
    assert_response :success
    assert_select "p", /No plays recorded/
  end

  test "GET /players paginates: page 2 contains records beyond 25" do
    22.times { |i| Player.create!(name: "Extra #{"%.2d" % i}") }
    Player.create!(name: "Zzz Pagination")
    get players_path, params: { page: 2 }
    assert_response :success
    assert_includes response.body, "Zzz Pagination"
  end

  test "GET /players paginates: page 1 does not contain page 2 records" do
    22.times { |i| Player.create!(name: "Extra #{"%.2d" % i}") }
    Player.create!(name: "Zzz Pagination")
    get players_path
    assert_response :success
    refute_includes response.body, "Zzz Pagination"
  end

  test "GET /players filters by name" do
    get players_path, params: { q: "Ali" }
    assert_response :success
    assert_includes response.body, "Alice"
    refute_includes response.body, "Bob"
  end

  test "GET /players with blank q returns all records" do
    get players_path, params: { q: "" }
    assert_response :success
    assert_includes response.body, "Alice"
    assert_includes response.body, "Bob"
  end

  test "GET /players search is case-insensitive" do
    get players_path, params: { q: "ali" }
    assert_response :success
    assert_includes response.body, "Alice"
  end

  test "GET /players search with wildcard characters does not crash" do
    get players_path, params: { q: "100%" }
    assert_response :success
  end
end
