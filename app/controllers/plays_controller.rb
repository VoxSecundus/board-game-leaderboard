class PlaysController < ApplicationController
  before_action :set_play, only: %i[show edit update destroy]

  def index
    @plays = sorted_plays
  end

  def show; end

  def new
    @play = Play.new
    @play.play_participants.build
    @players = Player.order(:name)
  end

  def create
    @play = Play.new(play_params)
    if @play.save
      redirect_to @play, notice: "Play recorded."
    else
      @players = Player.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @players = Player.order(:name)
  end

  def update
    if @play.update(play_params)
      redirect_to @play, notice: "Play updated."
    else
      @players = Player.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @play.destroy
    redirect_to plays_path, notice: "Play deleted."
  end

  private

  def set_play
    @play = Play.find(params[:id])
  end

  def play_params
    params.require(:play).permit(:game_id, :location_id, :date, :notes,
      play_participants_attributes: [ :id, :player_id, :score, :winner, :_destroy ])
  end

  SORTABLE_COLUMNS = %w[date created_at].freeze

  def sorted_plays
    scope = Play.includes(:game, :location, play_participants: :player)
    if params[:sort] == "game"
      dir = %w[asc desc].include?(params[:dir]) ? params[:dir] : "asc"
      scope.joins(:game).order("games.name #{dir}")
    else
      scope.order(sort_column => sort_direction)
    end
  end

  def sort_column
    SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "date"
  end

  def sort_direction
    %w[asc desc].include?(params[:dir]) ? params[:dir] : "desc"
  end
end
