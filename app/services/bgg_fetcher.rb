require "net/http"

class BggFetcher
  BGG_API = "https://boardgamegeek.com/xmlapi2/thing"
  ALLOWED_IMAGE_HOSTS = %w[cf.geekdo-images.com].freeze

  Result = Data.define(:name, :image_url, :error)

  def self.call(bgg_url) = new(bgg_url).call

  def initialize(bgg_url)
    @bgg_url = bgg_url.to_s
  end

  def call
    game_id = extract_id
    return Result.new(name: nil, image_url: nil, error: "Could not parse a game ID from that URL") unless game_id

    xml = fetch_xml(game_id)
    unless xml
      Rails.logger.error("BggFetcher: API request failed for game ID #{game_id} (url=#{@bgg_url})")
      return Result.new(name: nil, image_url: nil, error: "BGG API request failed")
    end

    doc = Nokogiri::XML(xml)
    name = doc.at_xpath("//item/name[@type='primary']")&.[]("value")
    raw = doc.at_xpath("//item/image")&.text&.strip
    normalized = raw&.then { |u| u.start_with?("//") ? "https:#{u}" : u }
    uri = normalized && (URI.parse(normalized) rescue nil)
    image_url = normalized if uri&.scheme == "https" && ALLOWED_IMAGE_HOSTS.include?(uri.host)
    unless image_url || raw.nil?
      Rails.logger.error("BggFetcher: rejected image URL #{raw} (not https on allowed host)")
    end

    Result.new(name: name, image_url: image_url, error: nil)
  rescue => e
    Rails.logger.error("BggFetcher: unexpected error for #{@bgg_url}: #{e.class}: #{e.message}")
    Result.new(name: nil, image_url: nil, error: e.message)
  end

  private

  def extract_id
    URI.parse(@bgg_url).path.match(%r{/boardgame/(\d+)}i)&.captures&.first
  rescue URI::InvalidURIError
    nil
  end

  def fetch_xml(id)
    uri = URI("#{BGG_API}?id=#{id}&type=boardgame")
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{ENV.fetch('BGG_API_TOKEN', '')}"
      res = http.request(req)
      res.body if res.is_a?(Net::HTTPSuccess)
    end
  end
end
