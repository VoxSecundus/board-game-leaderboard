require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup { log_in }

  test "GET /settings returns 200" do
    get settings_path
    assert_response :success
  end

  test "PATCH /settings persists default player IDs and redirects" do
    patch settings_path, params: {
      app_setting: { default_player_ids: [ players(:alice).id.to_s, players(:bob).id.to_s ] }
    }
    assert_redirected_to settings_path
    assert_equal "Settings saved.", flash[:notice]
    assert_equal [ players(:alice).id, players(:bob).id ], AppSetting.instance.default_player_ids
  end

  test "PATCH /settings with no players resets to empty array" do
    AppSetting.instance.update!(default_player_ids: [ players(:alice).id ])
    patch settings_path, params: { app_setting: { default_player_ids: [ "" ] } }
    assert_redirected_to settings_path
    assert_equal [], AppSetting.instance.default_player_ids
  end
end
