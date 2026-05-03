require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in
    @game = games(:chess)
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
    assert_match "Zzz Pagination", response.body
  end

  test "GET /games paginates: page 1 does not contain page 2 records" do
    22.times { |i| Game.create!(name: "Extra #{"%.2d" % i}") }
    Game.create!(name: "Zzz Pagination")
    get games_path
    assert_response :success
    assert_no_match "Zzz Pagination", response.body
  end
end
