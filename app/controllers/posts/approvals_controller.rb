# frozen_string_literal: true

module Posts
  class ApprovalsController < ApplicationController
    before_action :approver_only, except: %i[index]
    skip_before_action :api_check, except: %i[index]
    respond_to :html, :json

    def index
      @post_approvals = authorize(PostApproval).includes(:post, :user).search(search_params).paginate(params[:page], limit: params[:limit])
      respond_with(@post_approvals)
    end

    def create
      post = authorize(Post.find(params[:post_id]), policy_class: PostApprovalPolicy)
      if post.is_approvable?
        post.approve!
        respond_with do |format|
          format.json do
            render(json: {}, status: 201)
          end
        end
      elsif post.approver.present?
        flash[:notice] = "Post is already approved"
      else
        flash[:notice] = "You can't approve this post"
      end
    end

    def destroy
      post = authorize(Post.find(params[:post_id]), policy: PostApprovalPolicy)
      if post.is_unapprovable?(CurrentUser.user)
        post.unapprove!
        respond_with(nil)
      else
        flash[:notice] = "You can't unapprove this post"
      end
    end
  end
end
