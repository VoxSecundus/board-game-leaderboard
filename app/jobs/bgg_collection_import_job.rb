require "net/http"

class BggCollectionImportJob < ApplicationJob
  queue_as :default

  ALLOWED_IMAGE_HOSTS = %w[cf.geekdo-images.com].freeze

  def perform(items, import_id)
    existing = Game.where.not(bgg_url: [ nil, "" ])
                   .pluck(:bgg_url)
                   .filter_map { |u| u.match(%r{/boardgame/(\d+)})&.captures&.first&.to_i }
                   .to_set

    items.each do |item|
      next if existing.include?(item["bgg_id"].to_i)
      game = Game.new(name: item["name"], bgg_url: item["bgg_url"])
      attach_image(game, item["image_url"]) if item["image_url"].present?
      game.save
    end
  ensure
    BggCollectionImport.where(id: import_id).delete_all
  end

  private

  def attach_image(game, url)
    return unless safe_url?(url)
    response = fetch_with_redirects(url)
    return unless response.is_a?(Net::HTTPSuccess)
    return unless response.content_type.in?(Game::ALLOWED_TYPES)
    return if response.body.bytesize > Game::MAX_BYTES
    filename = File.basename(URI.parse(url).path).presence || "box_art"
    game.box_art.attach(io: StringIO.new(response.body), filename: filename, content_type: response.content_type)
  rescue URI::InvalidURIError, SocketError, Net::HTTPError => e
    Rails.logger.error("BggCollectionImportJob: image error for #{url}: #{e.class}: #{e.message}")
  end

  def fetch_with_redirects(url, limit = 5)
    return nil if limit.zero?
    uri = URI.parse(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(Net::HTTP::Get.new(uri)) }
    if response.is_a?(Net::HTTPRedirection)
      location = URI.join(url, response["location"]).to_s
      return nil unless safe_url?(location)
      fetch_with_redirects(location, limit - 1)
    else
      response
    end
  end

  def safe_url?(url)
    uri = URI.parse(url)
    uri.scheme == "https" && ALLOWED_IMAGE_HOSTS.include?(uri.host)
  rescue URI::InvalidURIError
    false
  end
end
