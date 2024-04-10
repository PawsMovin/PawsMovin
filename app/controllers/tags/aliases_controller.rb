# frozen_string_literal: true

module Tags
  class AliasesController < ApplicationController
    respond_to :html, :json

    def index
      @tag_aliases = authorize(TagAlias).includes(:antecedent_tag, :consequent_tag, :approver).search(search_params).paginate(params[:page], limit: params[:limit])
      respond_with(@tag_aliases)
    end

    def show
      @tag_alias = authorize(TagAlias.find(params[:id]))
      respond_with(@tag_alias)
    end

    def new
      @tag_alias = authorize(TagAlias.new)
    end

    def edit
      @tag_alias = authorize(TagAlias.find(params[:id]))
    end

    def create
      @tag_alias_request = authorize(TagAliasRequest.new(permitted_attributes(TagAlias)), policy_class: TagAliasPolicy)
      @tag_alias_request.create

      if @tag_alias_request.invalid?
        respond_with(@tag_alias_request) do |format|
          format.html { redirect_back(fallback_location: new_tag_alias_path, notice: @tag_alias_request.errors.full_messages.join("; ")) }
        end
      elsif @tag_alias_request.forum_topic
        redirect_to(forum_topic_path(@tag_alias_request.forum_topic))
      else
        redirect_to(tag_alias_path(@tag_alias_request.tag_relationship))
      end
    end

    def update
      @tag_alias = authorize(TagAlias.find(params[:id]))

      if @tag_alias.is_pending? && @tag_alias.editable_by?(CurrentUser.user)
        @tag_alias.update(permitted_attributes(TagAlias))
      end

      respond_with(@tag_alias)
    end

    def destroy
      @tag_alias = authorize(TagAlias.find(params[:id]))
      if @tag_alias.rejectable_by?(CurrentUser.user)
        @tag_alias.reject!
        respond_with(@tag_alias, location: tag_aliases_path)
      else
        access_denied
      end
    end

    def approve
      @tag_alias = authorize(TagAlias.find(params[:id]))
      @tag_alias.approve!(approver: CurrentUser.user)
      respond_with(@tag_alias, location: tag_alias_path(@tag_alias))
    end
  end
end
