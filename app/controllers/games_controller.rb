class GamesController < ApplicationController
  include HistorySortable

  before_action :set_game, only: %i[show edit update destroy]

  def index
    @pagy, @games = pagy(Game.order(sort_column => sort_direction))
  end

  def show
    @plays = history_sorted(
      @game.plays.includes(:location, play_participants: :player)
    )
  end

  def new
    @game = Game.new
  end

  def bgg_lookup
    result = BggFetcher.call(params[:bgg_url])
    @name      = result.name
    @image_url = result.image_url
    @error     = result.error
    respond_to { |f| f.turbo_stream }
  end

  def create
    @game = Game.new(game_params)
    attach_image_from_url(@game, params[:bgg_image_url]) if use_bgg_image?
    if @game.save
      redirect_to @game, notice: "Game created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    attach_image_from_url(@game, params[:bgg_image_url]) if use_bgg_image?
    if @game.update(game_params)
      redirect_to @game, notice: "Game updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game.destroy
    redirect_to games_path, notice: "Game deleted."
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:name, :bgg_url, :box_art)
  end

  def use_bgg_image?
    return false unless params[:bgg_image_url].present?

    box_art = game_params[:box_art]
    !box_art.is_a?(ActionDispatch::Http::UploadedFile) || box_art.original_filename.blank?
  end

  ALLOWED_IMAGE_HOSTS = %w[cf.geekdo-images.com].freeze

  def safe_bgg_url?(url)
    uri = URI.parse(url)
    uri.scheme == "https" && ALLOWED_IMAGE_HOSTS.include?(uri.host)
  rescue URI::InvalidURIError
    false
  end

  def attach_image_from_url(game, url)
    unless safe_bgg_url?(url)
      Rails.logger.error("GamesController#attach_image_from_url: rejected unsafe URL #{url}")
      return
    end
    Rails.logger.info("GamesController#attach_image_from_url: downloading #{url}")
    response = fetch_following_redirects(url)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("GamesController#attach_image_from_url: got #{response&.code} for #{url}")
      return
    end

    content_type = response.content_type
    unless content_type.in?(Game::ALLOWED_TYPES)
      Rails.logger.error("GamesController#attach_image_from_url: rejected content-type #{content_type} for #{url}")
      return
    end

    if response.body.bytesize > Game::MAX_BYTES
      Rails.logger.error("GamesController#attach_image_from_url: image too large (#{response.body.bytesize} bytes) for #{url}")
      return
    end

    filename = File.basename(URI.parse(url).path).presence || "box_art"
    game.box_art.attach(io: StringIO.new(response.body), filename: filename, content_type: content_type)
    Rails.logger.info("GamesController#attach_image_from_url: attached #{filename} (#{response.body.bytesize} bytes)")
  rescue URI::InvalidURIError, SocketError, Net::HTTPError => e
    Rails.logger.error("GamesController#attach_image_from_url: exception for #{url}: #{e.class}: #{e.message}")
    nil
  end

  def fetch_following_redirects(url, limit = 5)
    return nil if limit == 0

    uri = URI.parse(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(Net::HTTP::Get.new(uri))
    end

    if response.is_a?(Net::HTTPRedirection)
      location = URI.join(url, response["location"]).to_s
      unless safe_bgg_url?(location)
        Rails.logger.error("GamesController#fetch_following_redirects: rejected redirect to #{location}")
        return nil
      end
      Rails.logger.info("GamesController#fetch_following_redirects: #{response.code} → #{location}")
      fetch_following_redirects(location, limit - 1)
    else
      response
    end
  end

  SORTABLE_COLUMNS = %w[name created_at].freeze

  def sort_column
    SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:dir]) ? params[:dir] : "asc"
  end
end
