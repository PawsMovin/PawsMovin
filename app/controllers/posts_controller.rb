# frozen_string_literal: true

class PostsController < ApplicationController
  skip_before_action :api_check, only: %i[delete destroy undelete move_favorites expunge approve unapprove]
  respond_to :html, :json

  def index
    if params[:md5].present?
      @post = authorize(Post.find_by!(md5: params[:md5]))
      respond_with(@post) do |format|
        format.html { redirect_to(@post) }
      end
    else
      authorize(Post)
      @post_set = PostSets::Post.new(tag_query, params[:page], limit: params[:limit], random: params[:random])
      @posts = PostsDecorator.decorate_collection(@post_set.posts)
      respond_with(@posts) do |format|
        format.json do
          render(json: @post_set.api_posts)
        end
        format.atom
      end
    end
  end

  def show
    @post = authorize(Post.find(params[:id]))

    include_deleted = @post.is_deleted? || (@post.parent_id.present? && @post.parent.is_deleted?) || CurrentUser.is_approver?
    @parent_post_set = PostSets::PostRelationship.new(@post.parent_id, include_deleted: include_deleted, want_parent: true)
    @children_post_set = PostSets::PostRelationship.new(@post.id, include_deleted: include_deleted, want_parent: false)
    @comment_votes = {}
    @comment_votes = CommentVote.for_comments_and_user(@post.comments.visible(CurrentUser.user).map(&:id), CurrentUser.id) if request.format.html?

    respond_with(@post)
  end

  def show_seq
    authorize(Post)
    @post = PostSearchContext.new(params).post
    include_deleted = @post.is_deleted? || (@post.parent_id.present? && @post.parent.is_deleted?) || CurrentUser.is_approver?
    @parent_post_set = PostSets::PostRelationship.new(@post.parent_id, include_deleted: include_deleted, want_parent: true)
    @children_post_set = PostSets::PostRelationship.new(@post.id, include_deleted: include_deleted, want_parent: false)
    @comment_votes = {}
    @comment_votes = CommentVote.for_comments_and_user(@post.comments.visible(CurrentUser.user).map(&:id), CurrentUser.id) if request.format.html?
    @fixup_post_url = true

    respond_with(@post) do |fmt|
      fmt.html { render("posts/show")}
    end
  end

  def update
    @post = authorize(Post.find(params[:id]))
    ensure_can_edit(@post)

    pparams = permitted_attributes(@post)
    pparams.delete(:tag_string) if pparams[:tag_string_diff].present?
    pparams.delete(:source) if pparams[:source_diff].present?
    @post.update(pparams)
    respond_with_post_after_update(@post)
  end

  def revert
    @post = authorize(Post.find(params[:id]))
    ensure_can_edit(@post)
    @version = @post.versions.find(params[:version_id])

    @post.revert_to!(@version)

    respond_with(@post) do |format|
      format.js
    end
  end

  def copy_notes
    @post = authorize(Post.find(params[:id]))
    ensure_can_edit(@post)
    @other_post = Post.find(params[:other_post_id].to_i)
    @post.copy_notes_to(@other_post)

    if @post.errors.any?
      @error_message = @post.errors.full_messages.join("; ")
      render(json: {success: false, reason: @error_message}.to_json, status: 400)
    else
      head(:no_content)
    end
  end

  def random
    authorize(Post)
    tags = params[:tags] || ""
    @post = Post.tag_match(tags + " order:random").limit(1).first
    raise(ActiveRecord::RecordNotFound) if @post.nil?
    respond_with(@post) do |format|
      format.html { redirect_to(post_path(@post, tags: params[:tags])) }
    end
  end

  def mark_as_translated
    @post = authorize(Post.find(params[:id]))
    ensure_can_edit(@post)
    @post.mark_as_translated(params[:post])
    respond_with_post_after_update(@post)
  end

  def update_iqdb
    @post = authorize(Post.find(params[:id]))
    @post.update_iqdb_async
    respond_with_post_after_update(@post)
  end

  def delete
    @post = authorize(Post.find(params[:id]))
    @reason = @post.pending_flag&.reason || ""
    @reason = "Inferior version/duplicate of post ##{@post.parent_id}" if @post.parent_id && @reason == ""
    @reason = "" if @reason =~ /uploading_guidelines/
  end

  def destroy
    @post = authorize(Post.find(params[:id]))
    @post.delete!(params[:reason], move_favorites: params[:move_favorites].present?)
    @post.copy_sources_to_parent if params[:copy_sources].present?
    @post.copy_tags_to_parent if params[:copy_tags].present?
    @post.parent.save if params[:copy_tags].present? || params[:copy_sources].present?
    respond_with(@post) do |format|
      format.html { redirect_to(post_path(@post)) }
    end
  end

  def undelete
    @post = authorize(Post.find(params[:id]))
    @post.undelete!
    respond_with(@post)
  end

  def confirm_move_favorites
    @post = authorize(Post.find(params[:id]))
  end

  def move_favorites
    @post = authorize(Post.find(params[:id]))
    @post.give_favorites_to_parent
    @post.give_votes_to_parent
    redirect_to(post_path(@post))
  end

  def expunge
    @post = authorize(Post.find(params[:id]))
    @post.expunge!
    respond_with(@post)
  end

  def regenerate_thumbnails
    @post = authorize(Post.find(params[:id]))
    raise(User::PrivilegeError, "Cannot regenerate thumbnails on deleted images") if @post.is_deleted?
    @post.regenerate_image_samples!
    respond_with(@post)
  end

  def regenerate_videos
    @post = authorize(Post.find(params[:id]))
    raise(User::PrivilegeError, "Cannot regenerate thumbnails on deleted images") if @post.is_deleted?
    @post.regenerate_video_samples!
    respond_with(@post)
  end

  def approve
    @post = authorize(Post.find(params[:id]))
    if @post.is_approvable?
      @post.approve!
      respond_with do |format|
        format.json do
          render(json: {}, status: 201)
        end
      end
    elsif @post.approver.present?
      flash[:notice] = "Post is already approved"
    else
      flash[:notice] = "You can't approve this post"
    end
  end

  def unapprove
    @post = authorize(Post.find(params[:id]))
    if @post.is_unapprovable?(CurrentUser.user)
      @post.unapprove!
      respond_with(nil)
    else
      flash[:notice] = "You can't unapprove this post"
    end
  end

  def uploaders
    @relation = authorize(Post).where(is_pending: true).search_uploaders(search_params(Post)).group(:uploader_id).order("COUNT(uploader_id) DESC").paginate(params[:page], limit: params[:limit] || 20)
    @counts = @relation.count
    @users = User.where(id: @counts.keys)
  end

  def add_to_pool
    @post = authorize(Post.find(params[:id]))
    if params[:pool_id].present?
      @pool = Pool.find(params[:pool_id])
    else
      @pool = Pool.find_by!(name: params[:pool_name])
    end

    @pool.with_lock do
      @pool.add(@post.id)
      @pool.save
    end
    append_pool_to_session(@pool)
    respond_with(@pool, location: post_path(@post))
  end

  def remove_from_pool
    @post = authorize(Post.find(params[:id]))
    if params[:pool_id].present?
      @pool = Pool.find(params[:pool_id])
    else
      @pool = Pool.find_by!(name: params[:pool_name])
    end

    @pool.with_lock do
      @pool.remove!(@post)
      @pool.save
    end
    respond_with(@pool, location: post_path(@post))
  end

  def favorites
    @post = authorize(Post.find(params[:id]))
    query = User.joins(:favorites)
    unless CurrentUser.is_moderator?
      query = query.where("bit_prefs & :value != :value", { value: User.flag_value_for("enable_privacy_mode") }).or(query.where(favorites: { user_id: CurrentUser.id }))
    end
    query = query.where(favorites: { post_id: @post.id })
    query = query.order("users.name asc")
    @users = query.paginate(params[:page], limit: params[:limit])
  end

  private

  def tag_query
    params[:tags] || (params[:post] && params[:post][:tags])
  end

  def respond_with_post_after_update(post)
    respond_with(post) do |format|
      format.html do
        if post.warnings.any?
          warnings = post.warnings.full_messages.join(".\n \n")
          if warnings.length > 45_000
            Dmail.create_automated({
               to_id: CurrentUser.id,
               title: "Post update notices for post ##{post.id}",
               body:  "While editing post ##{post.id} some notices were generated. Please review them below:\n\n#{warnings[0..45_000]}"
           })
            flash[:notice] = "What the heck did you even do to this poor post? That generated way too many warnings. But you get a dmail with most of them anyways"
          elsif warnings.length > 1500
            Dmail.create_automated({
                 to_id: CurrentUser.id,
                 title: "Post update notices for post ##{post.id}",
                 body:  "While editing post ##{post.id} some notices were generated. Please review them below:\n\n#{warnings}"
             })
            flash[:notice] = "This edit created a LOT of notices. They have been dmailed to you. Please review them"
          else
            flash[:notice] = warnings
          end
        end

        if post.errors.any?
          @message = post.errors.full_messages.join("; ")
          render(template: "static/error", status: 500)
        else
          response_params = {q: params[:tags_query], pool_id: params[:pool_id], post_set_id: params[:post_set_id]}
          response_params.reject!{|key, value| value.blank?}
          redirect_to(post_path(post, response_params))
        end
      end

      format.json do
        render(json: post)
      end
    end
  end

  def ensure_can_edit(post)
    can_edit = CurrentUser.can_post_edit_with_reason
    raise(User::PrivilegeError.new("Updater #{User.throttle_reason(can_edit)}")) unless can_edit == true
  end

  def append_pool_to_session(pool)
    recent_pool_ids = session[:recent_pool_ids].to_s.scan(/\d+/)
    recent_pool_ids << pool.id.to_s
    recent_pool_ids = recent_pool_ids.slice(1, 5) if recent_pool_ids.size > 5
    session[:recent_pool_ids] = recent_pool_ids.uniq.join(",")
  end
end
