# frozen_string_literal: true

module Artists
  class VersionsController < ApplicationController
    respond_to :html, :json

    def index
      @artist_versions = authorize(ArtistVersion).search(search_params(ArtistVersion)).paginate(params[:page], limit: params[:limit], search_count: params[:search])
      respond_with(@artist_versions)
    end
  end
end
