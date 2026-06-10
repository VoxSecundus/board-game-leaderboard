module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings

    after_save :sync_tags
  end

  class_methods do
    def tagged_with(name)
      joins(:tags).where(tags: { name: name.to_s.strip.downcase })
    end
  end

  def tag_list
    return @tag_list unless @tag_list.nil?
    tags.order(:name).pluck(:name).join(", ")
  end

  def tag_list=(value)
    @tag_list = value
  end

  private

  def sync_tags
    return if @tag_list.nil?
    names = @tag_list.to_s.split(",").map { |s| s.strip.downcase }.uniq.reject(&:empty?)
    self.tags = names.map { |name| Tag.find_or_create_by!(name: name) }
    @tag_list = nil
  end
end
