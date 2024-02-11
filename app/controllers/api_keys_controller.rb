class ApiKeysController < ApplicationController
  before_action :requires_reauthentication
  before_action :member_only
  before_action :load_apikey, except: %i[index new create]
  respond_to :html, :json

  def index
    params[:search][:user_id] ||= params[:user_id]
    @api_keys = ApiKey.visible(CurrentUser.user).search(search_params).paginate(params[:page], limit: params[:limit], search_count: params[:search])
    respond_with(@api_keys)
  end

  def new
    @api_key = ApiKey.new(user: CurrentUser.user)
    respond_with(@api_key)
  end

  def edit
    respond_with(@api_key)
  end

  def create
    @api_key = ApiKey.create(user: CurrentUser.user, **api_key_params)
    if @api_key.valid?
      respond_with(@api_key, location: user_api_keys_path(CurrentUser.user), notice: "API key created")
    else
      respond_with(@api_key, location: user_api_keys_path(CurrentUser.user), notice: @api_key.errors.full_messages.join("; "))
    end
  end

  def update
    @api_key.update(api_key_params)
    respond_with(@api_key, location: user_api_keys_path(CurrentUser.user), notice: "API key updated")
  end

  def destroy
    @api_key.destroy
    respond_with(@api_key, location: user_api_keys_path(CurrentUser.user), notice: "API key deleted")
  end

  private

  def load_apikey
    @api_key = ApiKey.visible(CurrentUser.user).find(params[:id])
  end

  def api_key_params
    params.fetch(:api_key, {}).permit(:name, :permitted_ip_addresses, permissions: [])
  end

  def search_params
    permit_search_params(%i[user_id user_name])
  end
end
