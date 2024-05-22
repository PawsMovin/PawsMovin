# frozen_string_literal: true

class BansController < ApplicationController
  respond_to :html
  respond_to :json, except: %i[new create edit update destroy]

  def index
    @bans = authorize(Ban).search(search_params(Ban)).paginate(params[:page], limit: params[:limit])
    respond_with(@bans) do |format|
      format.html { @bans = @bans.includes(:user, :banner) }
    end
  end

  def show
    @ban = authorize(Ban.find(params[:id]))
    respond_with(@ban)
  end

  def new
    @ban = authorize(Ban.new(permitted_attributes(Ban)))
  end

  def edit
    @ban = authorize(Ban.find(params[:id]))
  end

  def create
    @ban = authorize(Ban.new(permitted_attributes(Ban)))
    @ban.save

    notice("Ban created") if @ban.valid?
    respond_with(@ban)
  end

  def update
    @ban = authorize(Ban.find(params[:id]))
    @ban.update(permitted_attributes(@ban))

    notice("Ban updated") if @ban.valid?
    respond_with(@ban)
  end

  def destroy
    @ban = authorize(Ban.find(params[:id]))
    @ban.destroy

    notice("Ban destroyed")
    respond_with(@ban)
  end
end
