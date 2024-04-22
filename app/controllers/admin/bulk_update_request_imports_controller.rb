# frozen_string_literal: true

module Admin
  class BulkUpdateRequestImportsController < ApplicationController
    def new
      authorize(BulkUpdateRequestImporter)
    end

    def create
      bparams = params[:batch].presence || params
      @importer = authorize(BulkUpdateRequestImporter.new(bparams[:script], bparams[:forum_id]))
      @importer.process!
      notice("Import queued")
      respond_to do |format|
        format.html { redirect_to(new_admin_bulk_update_request_import_path) }
        format.json
      end
    end
  end
end
