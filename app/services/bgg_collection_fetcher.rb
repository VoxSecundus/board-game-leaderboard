require "net/http"

class BggCollectionFetcher
  BGG_API = "https://boardgamegeek.com/xmlapi2/collection"
  ALLOWED_IMAGE_HOSTS = %w[cf.geekdo-images.com].freeze
  MAX_RETRIES = 5
  RETRY_DELAY = 2

  Result = Data.define(:items, :error)
  CollectionItem = Data.define(:bgg_id, :name, :image_url, :bgg_url)

  def self.call(username) = new(username).call

  def initialize(username)
    @username = username.to_s.strip
  end

  def call
    return Result.new(items: [], error: "Username is required") if @username.blank?

    xml_result = fetch_xml
    return Result.new(items: [], error: xml_result[:error]) if xml_result[:error]

    doc = Nokogiri::XML(xml_result[:body])

    error_msg = doc.at("errors error message")&.text
    return Result.new(items: [], error: error_msg) if error_msg

    items = doc.xpath("//item").filter_map do |item|
      bgg_id = item["objectid"]&.to_i
      next unless bgg_id&.positive?

      name = item.at("name")&.text&.strip
      next if name.blank?

      image_url = normalize_image_url(item.at("image")&.text&.strip)

      CollectionItem.new(
        bgg_id: bgg_id,
        name: name,
        image_url: image_url,
        bgg_url: "https://boardgamegeek.com/boardgame/#{bgg_id}"
      )
    end

    Result.new(items: items, error: nil)
  rescue => e
    Rails.logger.error("BggCollectionFetcher: unexpected error for #{@username}: #{e.class}: #{e.message}")
    Result.new(items: [], error: e.message)
  end

  private

  def fetch_xml
    MAX_RETRIES.times do |attempt|
      response = do_request
      return { body: response.body } if response.code == "200"
      return { error: "BGG API returned #{response.code}" } unless response.code == "202"
      wait_for_retry unless attempt == MAX_RETRIES - 1
    end
    { error: "BGG is still processing the request, please try again shortly" }
  end

  def do_request
    uri = URI("#{BGG_API}?username=#{URI.encode_www_form_component(@username)}&own=1&subtype=boardgame&excludesubtype=boardgameexpansion")
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{ENV.fetch('BGG_API_TOKEN', '')}"
      http.request(req)
    end
  end

  def wait_for_retry
    sleep RETRY_DELAY
  end

  def normalize_image_url(raw)
    return nil if raw.nil? || raw.empty?
    url = raw.start_with?("//") ? "https:#{raw}" : raw
    uri = URI.parse(url)
    return url if uri.scheme == "https" && ALLOWED_IMAGE_HOSTS.include?(uri.host)
    Rails.logger.error("BggCollectionFetcher: rejected image URL #{raw}")
    nil
  rescue URI::InvalidURIError
    Rails.logger.error("BggCollectionFetcher: rejected image URL #{raw}")
    nil
  end
end
