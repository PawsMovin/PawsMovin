# frozen_string_literal: true

class ApiKeysController < ApplicationController
  before_action :requires_reauthentication
  before_action :member_only
  before_action :load_api_key, except: %i[index new create]
  respond_to :html, :json

  def index
    params[:search][:user_id] ||= params[:user_id]
    @api_keys = authorize(ApiKey).visible(CurrentUser.user).search(search_params(ApiKey)).paginate(params[:page], limit: params[:limit], search_count: params[:search])
    respond_with(@api_keys)
  end

  def new
    @api_key = authorize(ApiKey.new(user: CurrentUser.user))
    respond_with(@api_key)
  end

  def edit
    authorize(@api_key)
    respond_with(@api_key)
  end

  def create
    @api_key = authorize(ApiKey.new(user: CurrentUser.user, **permitted_attributes(ApiKey)))
    @api_key.save
    notice(@api_key.valid? ? "API key created" : @api_key.errors.full_messages.join("; "))
    respond_with(@api_key, location: user_api_keys_path(CurrentUser.user))
  end

  def update
    authorize(@api_key)
    @api_key.update(permitted_attributes(@api_key))
    notice("API key updated")
    respond_with(@api_key, location: user_api_keys_path(CurrentUser.user))
  end

  def destroy
    authorize(@api_key)
    @api_key.destroy
    notice("API key deleted")
    respond_with(@api_key, location: user_api_keys_path(CurrentUser.user))
  end

  private

  def load_api_key
    @api_key = ApiKey.visible(CurrentUser.user).find(params[:id])
  end
end
