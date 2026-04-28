class Player < ApplicationRecord
  has_one_attached :profile_picture
  has_many :play_participants, dependent: :destroy

  ALLOWED_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_BYTES = 5.megabytes

  validates :name, presence: true
  validates :profile_picture,
            content_type: { in: ALLOWED_TYPES, message: "must be a JPEG, PNG, or WebP" },
            size: { less_than: MAX_BYTES, message: "must be less than 5 MB" },
            square_image: true
end
