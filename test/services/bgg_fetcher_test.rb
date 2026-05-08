require "test_helper"

class BggFetcherTest < ActiveSupport::TestCase
  BGG_XML = <<~XML
    <?xml version="1.0" encoding="utf-8"?>
    <items total="1">
      <item type="boardgame" id="13">
        <thumbnail>//cf.geekdo-images.com/thumb_hash/img/pic12345.jpg</thumbnail>
        <image>//cf.geekdo-images.com/sized_hash/img/pic12345.jpg</image>
        <name type="primary" sortindex="1" value="Catan"/>
        <name type="alternate" sortindex="1" value="Settlers of Catan"/>
      </item>
    </items>
  XML

  test "returns name and https image_url from valid BGG URL" do
    BggFetcher.any_instance.stubs(:fetch_xml).returns(BGG_XML)
    result = BggFetcher.call("https://boardgamegeek.com/boardgame/13/catan")
    assert_nil result.error
    assert_equal "Catan", result.name
    assert_equal "https://cf.geekdo-images.com/sized_hash/img/pic12345.jpg", result.image_url
  end

  test "prepends https: to protocol-relative image URL" do
    BggFetcher.any_instance.stubs(:fetch_xml).returns(BGG_XML)
    result = BggFetcher.call("https://boardgamegeek.com/boardgame/13/catan")
    assert result.image_url.start_with?("https://")
  end

  test "returns error when URL contains no game ID" do
    result = BggFetcher.call("https://boardgamegeek.com/")
    assert_equal "Could not parse a game ID from that URL", result.error
    assert_nil result.name
    assert_nil result.image_url
  end

  test "returns error when URL is blank" do
    result = BggFetcher.call("")
    assert_equal "Could not parse a game ID from that URL", result.error
  end

  test "returns error when API request fails" do
    BggFetcher.any_instance.stubs(:fetch_xml).returns(nil)
    result = BggFetcher.call("https://boardgamegeek.com/boardgame/13/catan")
    assert_equal "BGG API request failed", result.error
  end

  test "returns error on network exception" do
    BggFetcher.any_instance.stubs(:fetch_xml).raises(SocketError, "connection refused")
    result = BggFetcher.call("https://boardgamegeek.com/boardgame/13/catan")
    assert_match "connection refused", result.error
  end

  test "handles image_url that is nil when image element is missing" do
    xml_without_image = <<~XML
      <?xml version="1.0" encoding="utf-8"?>
      <items total="1">
        <item type="boardgame" id="13">
          <name type="primary" sortindex="1" value="Catan"/>
        </item>
      </items>
    XML
    BggFetcher.any_instance.stubs(:fetch_xml).returns(xml_without_image)
    result = BggFetcher.call("https://boardgamegeek.com/boardgame/13/catan")
    assert_nil result.error
    assert_equal "Catan", result.name
    assert_nil result.image_url
  end

  test "returns nil image_url for http scheme (non-https rejected)" do
    xml = BGG_XML.sub("<image>//cf.geekdo-images.com/", "<image>http://cf.geekdo-images.com/")
    BggFetcher.any_instance.stubs(:fetch_xml).returns(xml)
    Rails.logger.expects(:error).with(regexp_matches(/BggFetcher.*rejected image URL/))
    result = BggFetcher.call("https://boardgamegeek.com/boardgame/13/catan")
    assert_nil result.image_url
    assert_nil result.error
  end

  test "returns nil image_url for disallowed host" do
    xml = BGG_XML.sub("<image>//cf.geekdo-images.com/", "<image>//evil.example.com/")
    BggFetcher.any_instance.stubs(:fetch_xml).returns(xml)
    Rails.logger.expects(:error).with(regexp_matches(/BggFetcher.*rejected image URL/))
    result = BggFetcher.call("https://boardgamegeek.com/boardgame/13/catan")
    assert_nil result.image_url
    assert_nil result.error
  end

  test "returns nil image_url for malformed image URL" do
    xml = BGG_XML.sub("//cf.geekdo-images.com/sized_hash/img/pic12345.jpg", "not a url %%")
    BggFetcher.any_instance.stubs(:fetch_xml).returns(xml)
    Rails.logger.expects(:error).with(regexp_matches(/BggFetcher.*rejected image URL/))
    result = BggFetcher.call("https://boardgamegeek.com/boardgame/13/catan")
    assert_nil result.image_url
    assert_nil result.error
  end
end
