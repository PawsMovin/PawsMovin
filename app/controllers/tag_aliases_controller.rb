class TagAliasesController < ApplicationController
  before_action :member_only, except: %i[index show]
  before_action :admin_only, only: %i[edit update approve]
  respond_to :html, :json

  def index
    @tag_aliases = TagAlias.includes(:antecedent_tag, :consequent_tag, :approver).search(search_params).paginate(params[:page], limit: params[:limit])
    respond_with(@tag_aliases)
  end

  def show
    @tag_alias = TagAlias.find(params[:id])
    respond_with(@tag_alias)
  end

  def new
  end

  def edit
    @tag_alias = TagAlias.find(params[:id])
  end

  def create
    @tag_alias_request = TagAliasRequest.create(tag_alias_params(:create))

    if @tag_alias_request.invalid?
      render action: "new"
    elsif @tag_alias_request.forum_topic
      redirect_to forum_topic_path(@tag_alias_request.forum_topic)
    else
      redirect_to tag_alias_path(@tag_alias_request.tag_relationship)
    end
  end

  def update
    @tag_alias = TagAlias.find(params[:id])

    if @tag_alias.editable_by?(CurrentUser.user)
      update_params = tag_alias_params
      unless @tag_alias.is_pending?
        update_params = update_params.except(:antecedent_name, :consequent_name)
      end
      @tag_alias.update(update_params)
    end

    respond_with(@tag_alias)
  end

  def destroy
    @tag_alias = TagAlias.find(params[:id])
    if @tag_alias.deletable_by?(CurrentUser.user)
      @tag_alias.reject!
      respond_with(@tag_alias, location: tag_aliases_path)
    else
      access_denied
    end
  end

  def approve
    @tag_alias = TagAlias.find(params[:id])
    @tag_alias.approve!(approver: CurrentUser.user)
    respond_with(@tag_alias, location: tag_alias_path(@tag_alias))
  end

  private

  def tag_alias_params(context = nil)
    permitted_params = %i[antecedent_name consequent_name forum_topic_id]
    permitted_params += %i[reason skip_forum] if context == :create
    params.require(:tag_alias).permit(permitted_params)
  end
end
