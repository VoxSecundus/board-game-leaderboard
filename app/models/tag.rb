class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  before_validation { self.name = name.strip.downcase if name.present? }
end
