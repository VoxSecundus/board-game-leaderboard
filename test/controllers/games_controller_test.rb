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
end
