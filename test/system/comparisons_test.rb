require "application_system_test_case"

class ComparisonsTest < ApplicationSystemTestCase
  setup { log_in_via_browser }

  test "Compare nav link leads to player selector" do
    visit root_url
    click_link "Compare"
    assert_current_path compare_path
    assert_selector "select[name='player1_id']"
    assert_selector "select[name='player2_id']"
  end

  test "selecting two players and submitting shows head-to-head stats" do
    visit compare_url
    select players(:alice).name, from: "player1_id"
    select players(:bob).name, from: "player2_id"
    click_button "Compare"
    within "turbo-frame#results" do
      assert_text players(:alice).name
      assert_text players(:bob).name
    end
  end

  test "selecting same player twice redirects with alert" do
    visit compare_url
    select players(:alice).name, from: "player1_id"
    select players(:alice).name, from: "player2_id"
    click_button "Compare"
    assert_text "two different players"
  end

  test "game filter checkbox updates results without showing other game" do
    visit compare_url(player1_id: players(:alice).id, player2_id: players(:bob).id)
    within "turbo-frame#results" do
      assert_text players(:alice).name
    end
    check games(:chess).name
    click_button "Compare"
    within "turbo-frame#results" do
      assert_text games(:chess).name
      assert_no_text games(:catan).name
    end
  end

  test "per-game breakdown table shows both shared games" do
    visit compare_url(player1_id: players(:alice).id, player2_id: players(:bob).id)
    within "turbo-frame#results" do
      assert_text games(:chess).name
      assert_text games(:catan).name
    end
  end
end
