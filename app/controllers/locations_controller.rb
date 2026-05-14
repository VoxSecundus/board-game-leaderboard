class LocationsController < ApplicationController
  before_action :set_location, only: %i[show edit update destroy]

  def index
    scope = Location.order(sort_column => sort_direction)
    scope = scope.where("name LIKE ?", "%#{Location.sanitize_sql_like(params[:q].strip)}%") if params[:q].present?
    @pagy, @locations = pagy(scope)
  end

  def show; end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)
    if @location.save
      redirect_to @location, notice: "Location created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @location.update(location_params)
      redirect_to @location, notice: "Location updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy
    redirect_to locations_path, notice: "Location deleted."
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :latitude, :longitude)
  end

  SORTABLE_COLUMNS = %w[name latitude longitude created_at].freeze

  def sort_column
    SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:dir]) ? params[:dir] : "asc"
  end
end
