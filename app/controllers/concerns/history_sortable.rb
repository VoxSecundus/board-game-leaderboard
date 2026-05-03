module HistorySortable
  extend ActiveSupport::Concern
  HISTORY_SORT_COLUMNS = %w[date location].freeze

  private

  def history_sorted(scope)
    col = HISTORY_SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "date"
    dir = %w[asc desc].include?(params[:dir]) ? params[:dir] : "desc"
    if col == "location"
      scope.left_joins(:location).order(Arel.sql("locations.name #{dir} NULLS LAST"))
    else
      scope.order(col => dir)
    end
  end
end
