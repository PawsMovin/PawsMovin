# frozen_string_literal: true

class TagsController < ApplicationController
  respond_to :html, :json

  def index
    @tags = authorize(Tag).search(search_params(Tag)).paginate(params[:page], limit: params[:limit], search_count: params[:search])

    respond_with(@tags)
  end

  def preview
    authorize(Tag)
    @preview = TagsPreview.new(tags: params[:tags] || "")
    respond_to do |format|
      format.json do
        render(json: @preview.serializable_hash)
      end
    end
  end

  def show
    if params[:id] =~ /\A\d+\z/
      @tag = Tag.find(params[:id])
    else
      @tag = Tag.find_by!(name: params[:id])
    end
    authorize(@tag)
    respond_with(@tag)
  end

  def edit
    @tag = authorize(Tag.find(params[:id]))
    respond_with(@tag)
  end

  def update
    @tag = authorize(Tag.find(params[:id]))
    @tag.update(permitted_attributes(@tag))
    respond_with(@tag)
  end

  def correct
    authorize(Tag)
    @correction = TagCorrection.new(params[:id])
    @correction.fix!

    respond_to do |format|
      format.html { redirect_back(fallback_location: tags_path(search: { name_matches: @correction.tag.name, hide_empty: "no" }), notice: "Tag will be fixed in a few seconds") }
      format.json
    end
  end

  def meta_search
    authorize(Tag)
    @meta_search = MetaSearches::Tag.new(params)
    @meta_search.load_all
    respond_with(@meta_search)
  end
end
