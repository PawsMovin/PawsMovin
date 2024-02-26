# frozen_string_literal: true

class PostDisapprovalsController < ApplicationController
  before_action :approver_only
  skip_before_action :api_check
  respond_to :html, :json

  def index
    @post_disapprovals = PostDisapproval.includes(:user).search(search_params).paginate(params[:page], limit: params[:limit])
    respond_with(@post_disapprovals)
  end

  def create
    pd_params = post_disapproval_params
    @post_disapproval = PostDisapproval.create_with(post_disapproval_params).find_or_create_by(user_id: CurrentUser.id, post_id: pd_params[:post_id])
    @post_disapproval.reason = pd_params[:reason]
    @post_disapproval.message = pd_params[:message]
    @post_disapproval.save
    respond_to do |format|
      format.html { redirect_to(post_path(id: pd_params[:post_id])) }
      format.json { render(json: @post_disapproval) }
    end
  end

  private

  def post_disapproval_params
    params.require(:post_disapproval).permit(%i[post_id reason message])
  end
end
