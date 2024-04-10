# frozen_string_literal: true

module Posts
  class ReplacementsController < ApplicationController
    before_action :ensure_uploads_enabled, only: %i[new create]
    respond_to :html, :json

    content_security_policy only: %i[new] do |p|
      p.img_src(:self, :data, :blob, "*")
      p.media_src(:self, :data, :blob, "*")
    end

    def index
      params[:search][:post_id] = params.delete(:post_id) if params.key?(:post_id)
      @post_replacements = authorize(PostReplacement).includes(:post).visible(CurrentUser.user).search(search_params).paginate(params[:page], limit: params[:limit])

      respond_with(@post_replacements)
    end

    def new
      @post = Post.find(params[:post_id])
      @post_replacement = authorize(@post.replacements.new(permitted_attributes(PostReplacement)))
      respond_with(@post_replacement)
    end

    def create
      @post = Post.find(params[:post_id])
      @post_replacement = authorize(@post.replacements.new(permitted_attributes(PostReplacement).merge(creator_id: CurrentUser.id, creator_ip_addr: CurrentUser.ip_addr)))
      @post_replacement.save
      if @post_replacement.errors.none?
        flash.now[:notice] = "Post replacement submitted"
      end
      respond_to do |format|
        format.json do
          return render(json: { success: false, message: @post_replacement.errors.full_messages.join("; ") }, status: 412) if @post_replacement.errors.any?

          render(json: { success: true, location: post_path(@post) })
        end
      end
    end

    def approve
      @post_replacement = authorize(PostReplacement.find(params[:id]))
      @post_replacement.approve!(penalize_current_uploader: params[:penalize_current_uploader])

      respond_with(@post_replacement, location: post_path(@post_replacement.post))
    end

    def toggle_penalize
      @post_replacement = authorize(PostReplacement.find(params[:id]))
      @post_replacement.toggle_penalize!

      respond_with(@post_replacement)
    end

    def reject
      @post_replacement = authorize(PostReplacement.find(params[:id]))
      @post_replacement.reject!

      respond_with(@post_replacement, location: post_path(@post_replacement.post))
    end

    def destroy
      @post_replacement = authorize(PostReplacement.find(params[:id]))
      @post_replacement.destroy

      respond_with(@post_replacement, location: post_path(@post_replacement.post))
    end

    def promote
      @post_replacement = authorize(PostReplacement.find(params[:id]))
      @upload = @post_replacement.promote!
      if @post_replacement.errors.any?
        respond_with(@post_replacement)
      elsif @upload.errors.any?
        respond_with(@upload)
      else
        respond_with(@upload.post)
      end
    end

    private

    def check_allow_create
      return if CurrentUser.can_replace?

      raise(User::PrivilegeError, "You cannot create replacements")
    end

    def ensure_uploads_enabled
      if DangerZone.uploads_disabled?(CurrentUser.user)
        access_denied("Uploads are disabled")
      end
    end
  end
end
