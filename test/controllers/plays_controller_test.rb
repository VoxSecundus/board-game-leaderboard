require "test_helper"

class PlaysControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in
    @play = plays(:chess_night)
  end

  test "GET /plays returns 200" do
    get plays_path
    assert_response :success
  end

  test "GET /plays with date sort returns 200" do
    get plays_path, params: { sort: "date", dir: "asc" }
    assert_response :success
  end

  test "GET /plays with game sort returns 200" do
    get plays_path, params: { sort: "game", dir: "asc" }
    assert_response :success
  end

  test "GET /plays with SQL injection sort param returns 200 without crashing" do
    get plays_path, params: { sort: "1; DROP TABLE plays--" }
    assert_response :success
  end

  test "GET /plays/:id returns 200" do
    get play_path(@play)
    assert_response :success
  end

  test "GET /plays/new returns 200" do
    get new_play_path
    assert_response :success
  end

  test "POST /plays with valid params creates play and redirects" do
    assert_difference([ "Play.count", "PlayParticipant.count" ], 1) do
      post plays_path, params: {
        play: {
          game_id: games(:chess).id,
          date: Date.today,
          play_participants_attributes: {
            "0" => { player_id: players(:alice).id, score: 5, winner: "1" }
          }
        }
      }
    end
    assert_redirected_to play_path(Play.last)
    assert_equal "Play recorded.", flash[:notice]
  end

  test "POST /plays without game_id returns 422" do
    post plays_path, params: { play: { notes: "no game" } }
    assert_response :unprocessable_entity
  end

  test "GET /plays/:id/edit returns 200" do
    get edit_play_path(@play)
    assert_response :success
  end

  test "PATCH /plays/:id with valid params updates and redirects" do
    patch play_path(@play), params: { play: { notes: "updated notes" } }
    assert_redirected_to play_path(@play)
    assert_equal "updated notes", @play.reload.notes
  end

  test "PATCH /plays/:id updates a participant's score" do
    participant = play_participants(:alice_chess)
    patch play_path(@play), params: {
      play: {
        play_participants_attributes: {
          "0" => { id: participant.id, player_id: participant.player_id, score: 42, winner: "1" }
        }
      }
    }
    assert_redirected_to play_path(@play)
    assert_equal 42, participant.reload.score
  end

  test "PATCH /plays/:id sets a participant as winner" do
    participant = play_participants(:bob_chess)
    assert_not participant.winner
    patch play_path(@play), params: {
      play: {
        play_participants_attributes: {
          "0" => { id: participant.id, player_id: participant.player_id, winner: "1" }
        }
      }
    }
    assert_redirected_to play_path(@play)
    assert participant.reload.winner
  end

  test "PATCH /plays/:id clears a participant's winner status" do
    participant = play_participants(:alice_chess)
    assert participant.winner
    patch play_path(@play), params: {
      play: {
        play_participants_attributes: {
          "0" => { id: participant.id, player_id: participant.player_id, winner: "0" }
        }
      }
    }
    assert_redirected_to play_path(@play)
    assert_not participant.reload.winner
  end

  test "PATCH /plays/:id removes a participant via _destroy" do
    participant = play_participants(:bob_chess)
    assert_difference("PlayParticipant.count", -1) do
      patch play_path(@play), params: {
        play: {
          play_participants_attributes: {
            "0" => { id: participant.id, _destroy: "1" }
          }
        }
      }
    end
    assert_redirected_to play_path(@play)
    assert_raises(ActiveRecord::RecordNotFound) { participant.reload }
  end

  test "PATCH /plays/:id adds a new participant to an existing play" do
    play = plays(:catan_night)
    assert_difference("PlayParticipant.count", 1) do
      patch play_path(play), params: {
        play: {
          play_participants_attributes: {
            "0" => { player_id: players(:bob).id, score: 8, winner: "0" }
          }
        }
      }
    end
    assert_redirected_to play_path(play)
    new_pp = PlayParticipant.last
    assert_equal players(:bob), new_pp.player
    assert_equal 8, new_pp.score
  end

  test "PATCH /plays/:id with blank game_id returns 422" do
    patch play_path(@play), params: { play: { game_id: nil } }
    assert_response :unprocessable_entity
  end

  test "DELETE /plays/:id destroys play and redirects" do
    assert_difference("Play.count", -1) do
      delete play_path(@play)
    end
    assert_redirected_to plays_path
    assert_equal "Play deleted.", flash[:notice]
  end

  test "unauthenticated access redirects to login" do
    delete logout_path
    get plays_path
    assert_redirected_to login_path
  end
end
