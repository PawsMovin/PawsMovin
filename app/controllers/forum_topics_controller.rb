# frozen_string_literal: true

class ForumTopicsController < ApplicationController
  respond_to :html, :json
  before_action :load_topic, except: %i[index new create mark_all_as_read]
  skip_before_action :api_check

  def index
    params[:search] ||= {}
    params[:search][:order] ||= "sticky" if request.format.html?

    @query = authorize(ForumTopic).visible(CurrentUser.user).search(search_params(ForumTopic))
    @forum_topics = @query.paginate(params[:page], limit: params[:limit] || 50, search_count: params[:search])

    respond_with(@forum_topics) do |format|
      format.html do
        @forum_topics = @forum_topics.includes(:creator, :updater).load
      end
      format.json do
        render(json: @forum_topics.to_json)
      end
    end
  end

  def show
    authorize(@forum_topic)
    if request.format.html?
      @forum_topic.mark_as_read!(CurrentUser.user)
    end
    @forum_posts = ForumPost.includes(topic: [:category]).search(topic_id: @forum_topic.id).reorder("forum_posts.id").paginate(params[:page])
    @original_forum_post_id = @forum_topic.original_post.id
    respond_with(@forum_topic)
  end

  def new
    @forum_topic = authorize(ForumTopic.new(permitted_attributes(ForumTopic)))
    @forum_topic.original_post = ForumPost.new(permitted_attributes(ForumTopic)[:original_post_attributes])
    respond_with(@forum_topic)
  end

  def edit
    authorize(@forum_topic)
    respond_with(@forum_topic)
  end

  def create
    @forum_topic = authorize(ForumTopic.new(permitted_attributes(ForumTopic)))
    @forum_topic.save
    respond_with(@forum_topic)
  end

  def update
    authorize(@forum_topic)
    @forum_topic.assign_attributes(permitted_attributes(ForumTopic))
    @forum_topic.save(touch: false)
    respond_with(@forum_topic)
  end

  def destroy
    authorize(@forum_topic)
    @forum_topic.destroy
    notice("Topic deleted")
    respond_with(@forum_topic, location: forum_topics_path)
  end

  def hide
    authorize(@forum_topic)
    @forum_topic.hide!
    if @forum_topic.errors.any?
      respond_with(@forum_topic) do |format|
        format.html do
          redirect_back(fallback_location: forum_topic_path(@forum_topic), notice: "Failed to hide topic: #{@forum_topic.errors.full_messages.join('; ')}")
        end
      end
    else
      notice("Topic hidden")
      respond_with(@forum_topic)
    end
  end

  def unhide
    authorize(@forum_topic)
    @forum_topic.unhide!
    notice("Topic unhidden")
    respond_with(@forum_topic)
  end

  def lock
    authorize(@forum_topic)
    @forum_topic.update(is_locked: true)
    notice("Topic locked")
    respond_with(@forum_topic)
  end

  def unlock
    authorize(@forum_topic)
    @forum_topic.update(is_locked: false)
    notice("Topic unlocked")
    respond_with(@forum_topic)
  end

  def sticky
    authorize(@forum_topic)
    @forum_topic.update(is_sticky: true)
    notice("Topic stickied")
    respond_with(@forum_topic)
  end

  def unsticky
    authorize(@forum_topic)
    @forum_topic.update(is_sticky: false)
    notice("Topic unstickied")
    respond_with(@forum_topic)
  end

  def mark_all_as_read
    authorize(ForumTopic)
    CurrentUser.user.update_attribute(:last_forum_read_at, Time.now)
    ForumTopicVisit.prune!(CurrentUser.user)
    respond_to do |format|
      format.html { redirect_to(forum_topics_path, notice: "All topics marked as read") }
      format.json
    end
  end

  def subscribe
    authorize(@forum_topic)
    status = ForumTopicStatus.where(forum_topic_id: @forum_topic, user_id: CurrentUser.user.id).first
    if status
      status.update(subscription: true, subscription_last_read_at: @forum_topic.updated_at, mute: false)
    else
      ForumTopicStatus.create(forum_topic_id: @forum_topic.id, user_id: CurrentUser.user.id, subscription_last_read_at: @forum_topic.updated_at, subscription: true)
    end
    respond_with(@forum_topic)
  end

  def unsubscribe
    authorize(@forum_topic)
    status = ForumTopicStatus.where(forum_topic_id: @forum_topic.id, user_id: CurrentUser.user.id, subscription: true).first
    status&.destroy
    respond_with(@forum_topic)
  end

  def mute
    authorize(@forum_topic)
    status = ForumTopicStatus.where(forum_topic_id: @forum_topic.id, user_id: CurrentUser.user.id).first
    if status
      status.update(mute: true, subscription: false, subscription_last_read_at: nil)
    else
      ForumTopicStatus.create(forum_topic_id: @forum_topic.id, user_id: CurrentUser.user.id, mute: true)
    end
    respond_with(@forum_topic)
  end

  def unmute
    authorize(@forum_topic)
    status = ForumTopicStatus.where(forum_topic_id: @forum_topic.id, user_id: CurrentUser.user.id, mute: true).first
    status&.destroy
    respond_with(@forum_topic)
  end

  def confirm_move
    authorize(@forum_topic)
    @categories = ForumCategory.visible.select { |cat| cat != @forum_topic.category && cat.can_create_within?(CurrentUser.user) && cat.can_create_within?(@forum_topic.creator) }
  end

  def move
    authorize(@forum_topic)
    @category = ForumCategory.find(params.dig(:forum_topic, :category_id))
    return render_expected_error(403, "You cannot move topics into categories you cannot create within.") unless @category.can_create_within?(CurrentUser.user)
    return render_expected_error(403, "You cannot move topics into categories the topic creator cannot create within.") unless @category.can_create_within?(@forum_topic.creator)
    @forum_topic.update(category: @category)
    notice("Forum topic moved")
    respond_with(@forum_topic)
  end

  private

  def load_topic
    @forum_topic = ForumTopic.includes(:category).find(params[:id])
  end
end
