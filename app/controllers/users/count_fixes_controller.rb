# frozen_string_literal: true

module Users
  class CountFixesController < ApplicationController
    def new
      authorize(:count_fixes)
    end

    def create
      authorize(:count_fixes)
      CurrentUser.user.refresh_counts!
      notice("Counts have been refreshed")
      respond_to do |format|
        format.html { redirect_to(user_path(CurrentUser.id)) }
        format.json { head(204) }
      end
    end
  end
end
