module Admin
  class AuditLogsController < ApplicationController
    before_action :moderator_only
    respond_to :html, :json

    def index
      @audit_logs = StaffAuditLog.search(search_params).paginate(params[:page], limit: params[:limit])
      respond_with(@audit_logs)
    end

    private

    def search_params
      permit_search_params(%i[user_id user_name action])
    end
  end
end
