# frozen_string_literal: true

class DtextPreviewsController < ApplicationController
  skip_forgery_protection only: :create

  def create
    body = params[:body] || ""
    dtext = helpers.format_text(body, allow_color: !(params[:color].present? && params[:color].falsy?) && CurrentUser.user.is_trusted?)
    render(json: { html: dtext, posts: deferred_posts })
  end
end
