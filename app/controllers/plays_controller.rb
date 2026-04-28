class PlaysController < ApplicationController
  before_action :set_play, only: %i[show edit update destroy]

  def index
    @plays = sorted_plays
  end

  def show; end

  def new
    @play = Play.new
    @play.play_participants.build
  end

  def create
    @play = Play.new(play_params)
    if @play.save
      redirect_to @play, notice: "Play recorded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @play.update(play_params)
      redirect_to @play, notice: "Play updated."
    else
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
    if params[:sort] == "game"
      dir = %w[asc desc].include?(params[:dir]) ? params[:dir] : "asc"
      Play.joins(:game).order("games.name #{dir}")
    else
      Play.order(sort_column => sort_direction)
    end
  end

  def sort_column
    SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "date"
  end

  def sort_direction
    %w[asc desc].include?(params[:dir]) ? params[:dir] : "desc"
  end
end
