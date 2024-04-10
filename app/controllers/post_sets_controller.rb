# frozen_string_literal: true

class PostSetsController < ApplicationController
  respond_to :html, :json

  def index
    authorize(PostSet)
    if params[:post_id].present?
      @post_sets = PostSet.visible(CurrentUser.user).where_has_post(params[:post_id].to_i).paginate(params[:page], limit: params[:limit] || 50)
    elsif params[:maintainer_id].present?
      if CurrentUser.is_moderator?
        @post_sets = PostSet.where_has_maintainer(params[:maintainer_id].to_i).paginate(params[:page], limit: params[:limit] || 50)
      else
        @post_sets = PostSet.visible(CurrentUser.user).where_has_maintainer(CurrentUser.id).paginate(params[:page], limit: params[:limit] || 50)
      end
    else
      @post_sets = PostSet.visible(CurrentUser.user).search(search_params).paginate(params[:page], limit: params[:limit])
    end

    respond_with(@post_sets)
  end

  def new
    @post_set = authorize(PostSet.new(permitted_attributes(@post_set)))
  end

  def create
    @post_set = authorize(PostSet.new(permitted_attributes(@post_set)))
    @post_set.save
    notice(@post_set.valid? ? "Set created" : @post_set.errors.full_messages.join("; "))
    respond_with(@post_set)
  end

  def show
    @post_set = authorize(PostSet.find(params[:id]))

    respond_with(@post_set)
  end

  def edit
    @post_set = authorize(PostSet.find(params[:id]))
    check_post_edit_access(@post_set)
    respond_with(@post_set)
  end

  def update
    @post_set = authorize(PostSet.find(params[:id]))
    @post_set.update(permitted_attributes(@post_set))
    notice(@post_set.valid? ? "Set updated" : @post_set.errors.full_messages.join("; "))
    respond_with(@post_set)
  end

  def maintainers
    @post_set = authorize(PostSet.find(params[:id]))
  end

  def post_list
    @post_set = authorize(PostSet.find(params[:id]))
    respond_with(@post_set)
  end

  def update_posts
    @post_set = authorize(PostSet.find(params[:id]))
    @post_set.update(permitted_attributes(@post_set))
    notice(@post_set.valid? ? "Set posts updated." : @post_set.errors.full_messages.join("; "))
    redirect_back(fallback_location: post_list_post_set_path(@post_set))
  end

  def destroy
    @post_set = authorize(PostSet.find(params[:id]))
    @post_set.destroy
    respond_with(@post_set)
  end

  def for_select
    owned = authorize(PostSet).owned(CurrentUser.user).order(:name)
    maintained = PostSet.active_maintainer(CurrentUser.user).order(:name)

    @for_select = {
        "Owned"      => owned.map {|x| [x.name.tr("_", " ").truncate(35), x.id]},
        "Maintained" => maintained.map {|x| [x.name.tr("_", " ").truncate(35), x.id]}
    }

    render(json: @for_select)
  end

  def add_posts
    @post_set = authorize(PostSet.find(params[:id]))
    @post_set.add(add_remove_posts_params.map(&:to_i))
    @post_set.save
    respond_with(@post_set)
  end

  def remove_posts
    @post_set = authorize(PostSet.find(params[:id]))
    @post_set.remove(add_remove_posts_params.map(&:to_i))
    @post_set.save
    respond_with(@post_set)
  end

  private

  def add_remove_posts_params
    params.extract!(:post_ids).permit(post_ids: []).require(:post_ids)
  end
end
