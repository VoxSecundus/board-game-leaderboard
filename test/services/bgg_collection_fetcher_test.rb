require "test_helper"

class BggCollectionFetcherTest < ActiveSupport::TestCase
  COLLECTION_XML = <<~XML
    <?xml version="1.0" encoding="utf-8" standalone="yes"?>
    <items totalitems="2" termsofuse="https://boardgamegeek.com/xmlapi/termsofuse">
      <item objecttype="thing" objectid="13" subtype="boardgame" collid="111">
        <name sortindex="1">Catan</name>
        <image>//cf.geekdo-images.com/sized_hash/img/catan.jpg</image>
        <thumbnail>//cf.geekdo-images.com/thumb_hash/img/catan.jpg</thumbnail>
        <status own="1" lastmodified="2023-01-01 00:00:00"/>
        <numplays>5</numplays>
      </item>
      <item objecttype="thing" objectid="68448" subtype="boardgame" collid="222">
        <name sortindex="1">7 Wonders</name>
        <image>//cf.geekdo-images.com/sized_hash/img/wonders.jpg</image>
        <thumbnail>//cf.geekdo-images.com/thumb_hash/img/wonders.jpg</thumbnail>
        <status own="1" lastmodified="2023-01-01 00:00:00"/>
        <numplays>3</numplays>
      </item>
    </items>
  XML

  def success_response(body = COLLECTION_XML)
    r = mock()
    r.stubs(:code).returns("200")
    r.stubs(:body).returns(body)
    r
  end

  def error_response(code)
    r = mock()
    r.stubs(:code).returns(code)
    r
  end

  test "returns items on 200 with valid XML" do
    BggCollectionFetcher.any_instance.stubs(:do_request).returns(success_response)
    result = BggCollectionFetcher.call("testuser")
    assert_nil result.error
    assert_equal 2, result.items.length
    assert_equal "Catan", result.items.first.name
    assert_equal 13, result.items.first.bgg_id
    assert_equal "https://boardgamegeek.com/boardgame/13", result.items.first.bgg_url
  end

  test "normalises protocol-relative image URL to https" do
    BggCollectionFetcher.any_instance.stubs(:do_request).returns(success_response)
    result = BggCollectionFetcher.call("testuser")
    assert result.items.first.image_url.start_with?("https://")
  end

  test "retries on 202 and returns items when subsequent request succeeds" do
    fetcher = BggCollectionFetcher.new("testuser")
    fetcher.stubs(:wait_for_retry)
    fetcher.stubs(:do_request).returns(error_response("202"), success_response)
    result = fetcher.call
    assert_nil result.error
    assert_equal 2, result.items.length
  end

  test "returns error after all retries return 202" do
    BggCollectionFetcher.any_instance.stubs(:do_request).returns(error_response("202"))
    BggCollectionFetcher.any_instance.stubs(:wait_for_retry)
    result = BggCollectionFetcher.call("testuser")
    assert_match(/try again/, result.error)
    assert_equal [], result.items
  end

  test "returns error on non-200 non-202 response" do
    BggCollectionFetcher.any_instance.stubs(:do_request).returns(error_response("404"))
    result = BggCollectionFetcher.call("testuser")
    assert_match(/404/, result.error)
    assert_equal [], result.items
  end

  test "returns error for blank username" do
    result = BggCollectionFetcher.call("")
    assert_equal "Username is required", result.error
    assert_equal [], result.items
  end

  test "returns error on network exception" do
    BggCollectionFetcher.any_instance.stubs(:do_request).raises(SocketError, "connection refused")
    result = BggCollectionFetcher.call("testuser")
    assert_match(/connection refused/, result.error)
  end

  test "returns nil image_url for images on disallowed host" do
    xml = COLLECTION_XML.gsub("cf.geekdo-images.com", "evil.example.com")
    BggCollectionFetcher.any_instance.stubs(:do_request).returns(success_response(xml))
    Rails.logger.stubs(:error)
    result = BggCollectionFetcher.call("testuser")
    assert result.items.all? { |item| item.image_url.nil? }
  end

  test "returns nil image_url for http scheme image URL" do
    xml = COLLECTION_XML.sub("//cf.geekdo-images.com/sized_hash/img/catan.jpg",
                              "http://cf.geekdo-images.com/catan.jpg")
    BggCollectionFetcher.any_instance.stubs(:do_request).returns(success_response(xml))
    Rails.logger.stubs(:error)
    result = BggCollectionFetcher.call("testuser")
    assert_nil result.items.first.image_url
  end

  test "returns error when BGG returns an error XML response" do
    error_xml = <<~XML
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <errors><error><message>Invalid username specified</message></error></errors>
    XML
    BggCollectionFetcher.any_instance.stubs(:do_request).returns(success_response(error_xml))
    result = BggCollectionFetcher.call("nobody")
    assert_equal "Invalid username specified", result.error
    assert_equal [], result.items
  end

  test "returns empty items array for empty collection" do
    xml = <<~XML
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <items totalitems="0" termsofuse="https://boardgamegeek.com/xmlapi/termsofuse"></items>
    XML
    BggCollectionFetcher.any_instance.stubs(:do_request).returns(success_response(xml))
    result = BggCollectionFetcher.call("testuser")
    assert_nil result.error
    assert_equal [], result.items
  end
end
