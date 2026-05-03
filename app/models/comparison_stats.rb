class ComparisonStats
  Result = Data.define(:wins_p1, :losses_p1, :draws, :per_game)

  def initialize(player1, player2, game_ids = nil)
    @player1  = player1
    @player2  = player2
    @game_ids = game_ids
  end

  def result
    @result ||= compute
  end

  private

  def compute
    wins_p1 = losses_p1 = draws = 0
    per_game = {}

    shared_plays.each do |play|
      pps = play.play_participants.to_a
      pp1 = pps.find { |pp| pp.player_id == @player1.id }
      pp2 = pps.find { |pp| pp.player_id == @player2.id }
      next unless pp1 && pp2

      entry = per_game[play.game_id] ||= { game: play.game, wins_p1: 0, losses_p1: 0, draws: 0 }

      if pp1.winner? == pp2.winner?
        draws += 1
        entry[:draws] += 1
      elsif pp1.winner?
        wins_p1 += 1
        entry[:wins_p1] += 1
      else
        losses_p1 += 1
        entry[:losses_p1] += 1
      end
    end

    Result.new(
      wins_p1:   wins_p1,
      losses_p1: losses_p1,
      draws:     draws,
      per_game:  per_game.values.sort_by { |r| r[:game].name }
    )
  end

  def shared_plays
    p1_ids = PlayParticipant.where(player_id: @player1.id).select(:play_id)
    p2_ids = PlayParticipant.where(player_id: @player2.id).select(:play_id)
    scope  = Play.where(id: p1_ids).where(id: p2_ids)
                 .includes(:game, play_participants: :player)
                 .order(date: :desc)
    @game_ids.present? ? scope.where(game_id: @game_ids) : scope
  end
end
