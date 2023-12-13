module Moderator
  class UserTextVersionsController < ApplicationController
    respond_to :html
    before_action :moderator_only

    def index
      @text_versions = UserTextVersion.includes(:user).order(id: :desc).search(search_params).paginate(params[:page], limit: params[:limit] || 20)
      respond_with(@text_versions)
    end

    def for_user
      @user = User.find(params[:user_id])
      @text_versions = @user.text_versions.includes(:user).order(id: :desc).search(search_params).paginate(params[:page], limit: params[:limit] || 20)
      render :index
    end

    def show
      @text_version = UserTextVersion.find(params[:id])
      respond_with(@text_version)
    end

    def diff
      if params[:otherversion].blank? || params[:thisversion].blank?
        redirect_back fallback_location: { action: :index }, notice: "You must select two versions to diff"
        return
      end

      @otherversion = UserTextVersion.find(params[:otherversion])
      @thisversion = UserTextVersion.find(params[:thisversion])
      @user = @thisversion.user
      redirect_back fallback_location: { action: :index }, notice: "You cannot diff two different users" if @otherversion.user_id != @thisversion.user_id
    end

    def search_params
      permitted_params = %i[changes updater_id updater_name user_id user_name about_matches artinfo_matches]
      permitted_params += %i[ip_addr blacklist_matches] if CurrentUser.is_admin?
      permit_search_params permitted_params
    end
  end
end
