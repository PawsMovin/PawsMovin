# frozen_string_literal: true

class ForumPostsController < ApplicationController
  before_action :load_post, only: %i[edit show update destroy hide unhide warning]
  respond_to :html, :json
  skip_before_action :api_check

  def index
    @query = authorize(ForumPost).visible(CurrentUser.user).search(search_params(ForumPost))
    @forum_posts = @query.includes(:topic).paginate(params[:page], limit: params[:limit], search_count: params[:search])
    respond_with(@forum_posts)
  end

  def show
    authorize(@forum_post)
    if request.format.html? && @forum_post.id == @forum_post.topic.original_post.id
      redirect_to(forum_topic_path(@forum_post.topic, page: params[:page]))
    else
      respond_with(@forum_post)
    end
  end

  def new
    @forum_post = authorize(ForumPost.new(permitted_attributes(ForumPost)))
    respond_with(@forum_post)
  end

  def edit
    authorize(@forum_post)
    respond_with(@forum_post)
  end

  def search
    authorize(ForumPost)
  end

  def create
    @forum_post = authorize(ForumPost.new(permitted_attributes(ForumPost)))
    if @forum_post.valid?
      @forum_post.save
      respond_with(@forum_post, location: forum_topic_path(@forum_post.topic, page: @forum_post.forum_topic_page, anchor: "forum_post_#{@forum_post.id}"))
    else
      respond_with(@forum_post)
    end
  end

  def update
    authorize(@forum_post)
    @forum_post.update(permitted_attributes(ForumPost))
    respond_with(@forum_post, location: forum_topic_path(@forum_post.topic, page: @forum_post.forum_topic_page, anchor: "forum_post_#{@forum_post.id}"))
  end

  def destroy
    authorize(@forum_post)
    @forum_post.destroy
    respond_with(@forum_post)
  end

  def hide
    authorize(@forum_post)
    @forum_post.hide!
    respond_with(@forum_post)
  end

  def unhide
    authorize(@forum_post)
    @forum_post.unhide!
    respond_with(@forum_post)
  end

  def warning
    authorize(@forum_post)
    if params[:record_type] == "unmark"
      @forum_post.remove_user_warning!
    else
      @forum_post.user_warned!(params[:record_type], CurrentUser.user)
    end
    html = render_to_string(partial: "forum_posts/forum_post", locals: { forum_post: @forum_post, original_forum_post_id: @forum_post.topic.original_post.id }, formats: [:html])
    render(json: { html: html, posts: deferred_posts })
  end

  private

  def load_post
    @forum_post = ForumPost.includes(topic: %i[category]).find(params[:id])
  end
end
