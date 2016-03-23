class LocationsController < ApplicationController
  def index
    render :index, locals: { locations: locations }
  end

  def show
    render :show, locals: { location: location }
  end

  private

  def locations
    @locations ||= Location.all
  end

  def location
    @location ||= Location.find_by!(handle: params[:handle])
  end
end