class PlayParticipant < ApplicationRecord
  belongs_to :play
  belongs_to :player

  validates :player, presence: true
end
