class ComparisonsController < ApplicationController
  def show
    @all_players = Player.order(:name)
    @all_games   = Game.order(:name)

    return unless params[:player1_id].present? && params[:player2_id].present?

    if params[:player1_id] == params[:player2_id]
      @same_player_error = "Select two different players to compare."
      render :show, status: :unprocessable_entity
      return
    end

    @player1 = Player.find(params[:player1_id])
    @player2 = Player.find(params[:player2_id])

    game_id = params[:game_id].presence&.to_i
    @selected_game_id = game_id&.positive? ? game_id : nil
    @stats = ComparisonStats.new(@player1, @player2, @selected_game_id && [ @selected_game_id ]).result
  rescue ActiveRecord::RecordNotFound
    redirect_to compare_path, alert: "Player not found."
  end
end
