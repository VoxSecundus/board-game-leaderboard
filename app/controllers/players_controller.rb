class PlayersController < ApplicationController
  include HistorySortable

  before_action :set_player, only: %i[show edit update destroy]

  def index
    scope = Player.order(sort_column => sort_direction)
    scope = scope.where("name LIKE ?", "%#{Player.sanitize_sql_like(params[:q].strip)}%") if params[:q].present?
    @pagy, @players = pagy(scope)
  end

  def show
    @plays = history_sorted(
      Play.where(id: @player.play_participants.select(:play_id))
          .includes(:game, :location, play_participants: :player)
    )
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      redirect_to @player, notice: "Player created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @player.update(player_params)
      redirect_to @player, notice: "Player updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @player.destroy
    redirect_to players_path, notice: "Player deleted."
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:name, :profile_picture)
  end

  SORTABLE_COLUMNS = %w[name created_at].freeze

  def sort_column
    SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:dir]) ? params[:dir] : "asc"
  end
end
