module NameSearchable
  extend ActiveSupport::Concern

  private

  def apply_name_search(scope)
    @query = params[:q].to_s.strip
    return scope if @query.blank?
    scope.where("name LIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%")
  end
end
