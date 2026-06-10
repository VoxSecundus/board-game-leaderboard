require "test_helper"

class AppSettingTest < ActiveSupport::TestCase
  test ".instance returns the singleton record" do
    setting = AppSetting.instance
    assert setting.persisted?
    assert_equal setting, AppSetting.instance
    assert_equal 1, AppSetting.count
  end

  test "default_player_ids defaults to empty array" do
    assert_equal [], AppSetting.instance.default_player_ids
  end

  test "default_player_ids= coerces string IDs to integers" do
    setting = AppSetting.instance
    setting.default_player_ids = %w[1 2 3]
    assert_equal [1, 2, 3], setting.default_player_ids
  end

  test "default_player_ids= drops blank values" do
    setting = AppSetting.instance
    setting.default_player_ids = ["", "1", "", "2"]
    assert_equal [1, 2], setting.default_player_ids
  end
end
