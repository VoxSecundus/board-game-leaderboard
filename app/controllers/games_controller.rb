class GamesController < ApplicationController
  include HistorySortable
  include NameSearchable

  before_action :set_game, only: %i[show edit update destroy]

  def index
    scope = apply_name_search(Game.order(sort_column => sort_direction))
    @pagy, @games = pagy(scope)
    @pending_imports = BggCollectionImport.order(:created_at)
  end

  def show
    @plays = history_sorted(
      @game.plays.includes(:location, play_participants: :player)
    )
  end

  def new
    @game = Game.new
  end

  def bgg_import
    if request.post? && params[:step] == "import"
      if BggCollectionImport.exists?
        redirect_to games_path, alert: "An import is already in progress. Please wait for it to finish before starting another."
        return
      end
      items = Array(params[:bgg_ids]).filter_map do |id|
        name = (params[:game_names] || {})[id].to_s.strip
        next if name.blank?
        { "bgg_id" => id.to_i, "name" => name,
          "image_url" => (params[:game_image_urls] || {})[id].to_s.presence,
          "bgg_url" => "https://boardgamegeek.com/boardgame/#{id}" }
      end
      if items.empty?
        redirect_to games_path, alert: "No games were selected for import."
        return
      end
      import = BggCollectionImport.create!(username: params[:username].to_s.strip)
      BggCollectionImportJob.perform_later(items, import.id)
      redirect_to games_path, notice: "Importing #{items.length} game(s) in the background. They will appear shortly."
    elsif request.post?
      fetch_and_preview_collection
    end
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

  def fetch_and_preview_collection
    username = params[:username].to_s.strip
    result = BggCollectionFetcher.call(username)
    if result.error
      flash.now[:alert] = result.error
      render :bgg_import
      return
    end
    existing = Game.where.not(bgg_url: [ nil, "" ])
                   .pluck(:bgg_url)
                   .filter_map { |u| u.match(%r{/boardgame/(\d+)})&.captures&.first&.to_i }
                   .to_set
    @username = username
    @items_with_status = result.items.map { |item| { item: item, exists: existing.include?(item.bgg_id) } }
    render :bgg_import
  end

  SORTABLE_COLUMNS = %w[name created_at].freeze

  def sort_column
    SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:dir]) ? params[:dir] : "asc"
  end
end
