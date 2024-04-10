# frozen_string_literal: true

module Users
  class DeletionsController < ApplicationController
    def show
      authorize(UserDeletion.new(CurrentUser.user, nil))
    end

    def destroy
      deletion = authorize(UserDeletion.new(CurrentUser.user, params[:password]))
      deletion.delete!
      cookies.delete(:remember)
      session.delete(:user_id)
      redirect_to(posts_path, notice: "You are now logged out")
    rescue UserDeletion::ValidationError => e
      render_expected_error(400, e)
    end
  end
end
