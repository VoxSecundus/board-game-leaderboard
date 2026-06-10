class AppSetting < ApplicationRecord
  serialize :default_player_ids, coder: JSON

  def self.instance
    first_or_create!
  end

  def default_player_ids=(ids)
    super(Array(ids).map(&:to_i).reject(&:zero?))
  end
end
