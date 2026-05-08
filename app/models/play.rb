class Play < ApplicationRecord
  belongs_to :game
  belongs_to :location, optional: true
  has_many :play_participants, dependent: :destroy
  has_many :players, through: :play_participants
  has_many :play_expansions, dependent: :destroy
  has_many :expansions, through: :play_expansions

  accepts_nested_attributes_for :play_participants, allow_destroy: true,
                                reject_if: ->(attrs) { attrs["player_id"].blank? }

  validates :game, presence: true
end
