require "test_helper"

class ComparisonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in
    @alice = players(:alice)
    @bob   = players(:bob)
  end

  test "GET /compare with no params returns 200 and shows selector form" do
    get compare_path
    assert_response :success
    assert_select "select[name='player1_id']"
    assert_select "select[name='player2_id']"
  end

  test "GET /compare with two different players returns 200" do
    get compare_path, params: { player1_id: @alice.id, player2_id: @bob.id }
    assert_response :success
  end

  test "GET /compare shows both player names in results frame" do
    get compare_path, params: { player1_id: @alice.id, player2_id: @bob.id }
    assert_select "turbo-frame[id='results']" do
      assert_select "*", text: /#{@alice.name}/
      assert_select "*", text: /#{@bob.name}/
    end
  end

  test "GET /compare shows results turbo frame" do
    get compare_path, params: { player1_id: @alice.id, player2_id: @bob.id }
    assert_response :success
    assert_select "turbo-frame[id='results']"
  end

  test "GET /compare with same player twice returns 422 with error in results frame" do
    get compare_path, params: { player1_id: @alice.id, player2_id: @alice.id }
    assert_response :unprocessable_entity
    assert_select "turbo-frame[id='results']" do
      assert_select "*", text: /two different players/
    end
  end

  test "GET /compare with chess filter shows only chess in results" do
    get compare_path, params: {
      player1_id: @alice.id,
      player2_id: @bob.id,
      game_ids: [ games(:chess).id ]
    }
    assert_response :success
    assert_select "turbo-frame[id='results'] td", text: games(:chess).name
    assert_select "turbo-frame[id='results'] td", text: games(:catan).name, count: 0
  end

  test "GET /compare with catan filter shows only catan in results" do
    get compare_path, params: {
      player1_id: @alice.id,
      player2_id: @bob.id,
      game_ids: [ games(:catan).id ]
    }
    assert_response :success
    assert_select "turbo-frame[id='results'] td", text: games(:catan).name
    assert_select "turbo-frame[id='results'] td", text: games(:chess).name, count: 0
  end

  test "GET /compare with players who share no plays shows no per-game table" do
    get compare_path, params: { player1_id: players(:newcomer).id, player2_id: @alice.id }
    assert_response :success
    assert_select "turbo-frame[id='results']" do
      assert_select "table", count: 0
    end
  end

  test "GET /compare with nonexistent player redirects with alert" do
    get compare_path, params: { player1_id: 999999, player2_id: @bob.id }
    assert_redirected_to compare_path
    assert_equal "Player not found.", flash[:alert]
  end

  test "unauthenticated access redirects to login" do
    delete logout_path
    get compare_path
    assert_redirected_to login_path
  end
end
