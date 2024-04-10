# frozen_string_literal: true

class NewsUpdatesController < ApplicationController
  respond_to :html, :json

  def index
    @news_updates = authorize(NewsUpdate).includes(:creator).order("id desc").paginate(params[:page], limit: params[:limit])
    respond_with(@news_updates)
  end

  def edit
    @news_update = authorize(NewsUpdate.find(params[:id]))
    respond_with(@news_update)
  end

  def update
    @news_update = authorize(NewsUpdate.find(params[:id]))
    @news_update.update(news_update_params)
    respond_with(@news_update, location: news_updates_path)
  end

  def new
    @news_update = authorize(NewsUpdate.new)
    respond_with(@news_update)
  end

  def create
    @news_update = authorize(NewsUpdate.new(news_update_params))
    @news_update.save
    respond_with(@news_update, location: news_updates_path)
  end

  def destroy
    @news_update = authorize(NewsUpdate.find(params[:id]))
    @news_update.destroy
    respond_with(@news_update) do |format|
      format.js
    end
  end

  private

  def news_update_params
    params.require(:news_update).permit([:message])
  end
end
