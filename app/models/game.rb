class Game < ApplicationRecord
  has_one_attached :box_art
  has_many :plays, dependent: :destroy
  has_many :expansions, dependent: :destroy

  accepts_nested_attributes_for :expansions, allow_destroy: true

  def expansions_attributes=(attrs)
    attrs.each_value do |expansion_attrs|
      next unless expansion_attrs["_destroy"].in?([ "1", true ])
      id = expansion_attrs["id"]&.to_i
      next unless id&.positive? && expansions.find_by(id: id, bgg_sourced: true)
      expansion_attrs.delete("_destroy")
    end
    super(attrs)
  end

  ALLOWED_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_BYTES = 5.megabytes

  validates :name, presence: true
  validates :bgg_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validate :box_art_acceptable

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
end
