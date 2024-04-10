# frozen_string_literal: true

module Artists
  class UrlsController < ApplicationController
    respond_to :json, :html

    def index
      @artist_urls = authorize(ArtistUrl).includes(:artist).search(search_params(ArtistUrl)).paginate(params[:page], limit: params[:limit], search_count: params[:search])
      respond_with(@artist_urls) do |format|
        format.json { render(json: @artist_urls.to_json(include: :artist)) }
      end
    end
  end
end
