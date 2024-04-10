# frozen_string_literal: true

module Users
  class NameChangeRequestsController < ApplicationController
    respond_to :html, :json

    def index
      @change_requests = authorize(UserNameChangeRequest).search(search_params).paginate(params[:page], limit: params[:limit])
      respond_with(@change_requests)
    end

    def show
      @change_request = authorize(UserNameChangeRequest.find(params[:id]))
      respond_with(@change_request)
    end

    def new
      @change_request = authorize(UserNameChangeRequest.new(permitted_attributes(UserNameChangeRequest)))
      respond_with(@change_request)
    end

    def create
      @change_request = authorize(UserNameChangeRequest.new(permitted_attributes(UserNameChangeRequest)))
      @change_request.save

      if @change_request.errors.any?
        render(action: "new")
      else
        @change_request.approve!
        redirect_to(user_name_change_request_path(@change_request), notice: "Your name has been changed")
      end
    end
  end
end
