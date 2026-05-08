class Expansion < ApplicationRecord
  belongs_to :game
  has_many :play_expansions, dependent: :destroy
  has_many :plays, through: :play_expansions
  has_one_attached :box_art

  ALLOWED_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_BYTES = 5.megabytes

  validates :name, presence: true
  validate :box_art_acceptable

  before_destroy :prevent_bgg_expansion_destroy

  private

  def box_art_acceptable
    return unless box_art.attached?

    unless box_art.content_type.in?(ALLOWED_TYPES)
      errors.add(:box_art, "must be a JPEG, PNG, or WebP")
    end

    if box_art.byte_size > MAX_BYTES
      errors.add(:box_art, "must be less than 5 MB")
    end
  end

  def prevent_bgg_expansion_destroy
    # Allow cascade deletion when the parent game is being destroyed
    throw(:abort) if bgg_sourced? && destroyed_by_association.nil?
  end
end
