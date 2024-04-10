# frozen_string_literal: true

class PoolsController < ApplicationController
  respond_to :html, :json
  before_action :member_only, except: %i[index show gallery]
  before_action :janitor_only, only: [:destroy]

  def new
    @pool = Pool.new
    respond_with(@pool)
  end

  def edit
    @pool = Pool.find(params[:id])
    respond_with(@pool)
  end

  def index
    @pools = Pool.search(search_params).paginate(params[:page], limit: params[:limit], search_count: params[:search])
    respond_with(@pools) do |format|
      format.json do
        render(json: @pools.to_json)
        expires_in(params[:expiry].to_i.days) if params[:expiry]
      end
    end
  end

  def gallery
    @pools = authorize(Pool).search(search_params(Pool)).paginate_posts(params[:page], limit: params[:limit], search_count: params[:search])
  end

  def show
    @pool = authorize(Pool.find(params[:id]))
    respond_with(@pool) do |format|
      format.html do
        @posts = @pool.posts.paginate_posts(params[:page], limit: params[:limit], total_count: @pool.post_ids.count)
      end
    end
  end

  def create
    @pool = authorize(Pool.new(permitted_attributes(Pool)))
    @pool.save
    notice(@pool.valid? ? "Pool created" : @pool.errors.full_messages.join("; "))
    respond_with(@pool)
  end

  def update
    @pool = authorize(Pool.find(params[:id]))
    @pool.update(permitted_attributes(@pool)) # TODO: make sure this doesn't break anything
    notice(@pool.valid? ? "Pool updated" : @pool.errors.full_messages.join("; "))
    respond_with(@pool)
  end

  def destroy
    @pool = authorize(Pool.find(params[:id]))
    raise(User::PrivilegeError) unless @pool.deletable_by?(CurrentUser.user)
    @pool.destroy
    notice("Pool deleted")
    respond_with(@pool)
  end

  def revert
    @pool = authorize(Pool.find(params[:id]))
    @version = @pool.versions.find(params[:version_id])
    @pool.revert_to!(@version)
    flash[:notice] = "Pool reverted"
    respond_with(@pool) do |format|
      format.js
    end
  end
end
