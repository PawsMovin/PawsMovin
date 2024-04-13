module AvoidPostings
  class VersionsController < ApplicationController
    respond_to :html, :json

    def index
      @avoid_posting_versions = authorize(AvoidPostingVersion).search(search_params(AvoidPostingVersion)).paginate(params[:page], limit: params[:limit], search_count: params[:search])
      respond_with(@avoid_posting_versions)
    end
  end
end
