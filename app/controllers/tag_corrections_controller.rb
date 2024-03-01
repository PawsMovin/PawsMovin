# frozen_string_literal: true

class TagCorrectionsController < ApplicationController
  respond_to :html, :json
  before_action :janitor_only, only: %i[create]

  def show
    @correction = TagCorrection.new(params[:tag_id])
    respond_with(@correction)
  end

  def create
    @correction = TagCorrection.new(params[:tag_id])
    @correction.fix!

    respond_to do |format|
      format.html { redirect_back(fallback_location: tags_path(search: { name_matches: @correction.tag.name, hide_empty: "no" }), notice: "Tag will be fixed in a few seconds") }
      format.json
    end
  end
end
