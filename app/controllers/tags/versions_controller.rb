# frozen_string_literal: true

module Tags
  class VersionsController < ApplicationController
    respond_to :html, :json

    def index
      @tag_versions = authorize(TagTypeVersion).search(search_params(TagTypeVersion)).paginate(params[:page], limit: params[:limit])

      respond_with(@tag_versions)
    end
  end
end
