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
end
