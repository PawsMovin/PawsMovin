# frozen_string_literal: true

module Notes
  class VersionsController < ApplicationController
    respond_to :html, :json

    def index
      @note_versions = authorize(NoteVersion).search(search_params(NoteVersion)).paginate(params[:page], limit: params[:limit])
      respond_with(@note_versions) do |format|
        format.html { @note_versions = @note_versions.includes(:updater) }
      end
    end
  end
end
