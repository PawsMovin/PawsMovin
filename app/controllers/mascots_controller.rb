# frozen_string_literal: true

class MascotsController < ApplicationController
  respond_to :html, :json
  before_action :admin_only, except: [:index]

  def index
    @mascots = Mascot.search(search_params).paginate(params[:page], limit: 75)
    respond_with(@mascots)
  end

  def new
    @mascot = Mascot.new
  end

  def create
    @mascot = Mascot.create(mascot_params.merge(creator: CurrentUser.user))
    respond_with(@mascot, location: mascots_path)
  end

  def edit
    @mascot = Mascot.find(params[:id])
  end

  def update
    @mascot = Mascot.find(params[:id])
    @mascot.update(mascot_params)
    respond_with(@mascot, location: mascots_path)
  end

  def destroy
    @mascot = Mascot.find(params[:id])
    @mascot.destroy
    respond_with(@mascot)
  end

  private

  def mascot_params
    params.fetch(:mascot, {}).permit(%i[mascot_file display_name background_color artist_url artist_name available_on_string active hide_anonymous])
  end
end
