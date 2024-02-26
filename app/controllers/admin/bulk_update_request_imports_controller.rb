# frozen_string_literal: true

module Admin
  class BulkUpdateRequestImportsController < ApplicationController
    before_action :owner_only

    def new
    end

    def create
      @importer = BulkUpdateRequestImporter.new(params[:batch][:text], params[:batch][:forum_id])
      @importer.process!
      flash[:notice] = "Import queued"
      redirect_to new_admin_bulk_update_request_import_path
    rescue StandardError => e
      flash[:notice] = e.to_s
      redirect_to new_admin_bulk_update_request_import_path
    end
  end
end
