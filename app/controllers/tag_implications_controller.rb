# frozen_string_literal: true

class TagImplicationsController < ApplicationController
  before_action :member_only, except: %i[index show]
  before_action :admin_only, only: %i[edit update approve]
  respond_to :html, :json

  def index
    @tag_implications = TagImplication.includes(:antecedent_tag, :consequent_tag, :approver).search(search_params).paginate(params[:page], limit: params[:limit])
    respond_with(@tag_implications)
  end

  def show
    @tag_implication = TagImplication.find(params[:id])
    respond_with(@tag_implication)
  end

  def new
    @tag_implication = TagImplication.new
  end

  def edit
    @tag_implication = TagImplication.find(params[:id])
  end

  def create
    @tag_implication_request = TagImplicationRequest.create(tag_implication_params(:create))

    if @tag_implication_request.invalid?
      respond_with(@tag_implication_request) do |format|
        format.html { redirect_back(fallback_location: new_tag_implication_path, notice: @tag_implication_request.errors.full_messages.join("; ")) }
      end
    elsif @tag_implication_request.forum_topic
      redirect_to forum_topic_path(@tag_implication_request.forum_topic)
    else
      redirect_to tag_implication_path(@tag_implication_request.tag_relationship)
    end
  end

  def update
    @tag_implication = TagImplication.find(params[:id])

    if @tag_implication.is_pending? && @tag_implication.editable_by?(CurrentUser.user)
      @tag_implication.update(tag_implication_params)
    end

    respond_with(@tag_implication)
  end

  def destroy
    @tag_implication = TagImplication.find(params[:id])
    if @tag_implication.deletable_by?(CurrentUser.user)
      @tag_implication.reject!
      if @tag_implication.errors.any?
        flash[:notice] = @tag_implication.errors.full_messages.join("; ")
        redirect_to(tag_implications_path)
        return
      end
      respond_with(@tag_implication) do |format|
        format.html do
          flash[:notice] = "Tag implication was deleted"
          redirect_to(tag_implications_path)
        end
      end
    else
      access_denied
    end
  end

  def approve
    @tag_implication = TagImplication.find(params[:id])
    @tag_implication.approve!(approver: CurrentUser.user)
    respond_with(@tag_implication, location: tag_implication_path(@tag_implication))
  end

  private

  def tag_implication_params(context = nil)
    permitted_params = %i[antecedent_name consequent_name]
    permitted_params += %i[reason forum_topic_id] if context == :create
    permitted_params += %i[skip_forum] if context == :create && CurrentUser.is_admin?
    params.require(:tag_implication).permit(permitted_params)
  end
end
