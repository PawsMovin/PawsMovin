# frozen_string_literal: true

module Users
  class EmailChangesController < ApplicationController
    def new
    end

    def create
      email_change = UserEmailChange.new(CurrentUser.user, params[:email_change][:email], params[:email_change][:password])
      email_change.process
      if CurrentUser.user.errors.any?
        flash[:notice] = CurrentUser.user.errors.full_messages.join("; ")
        redirect_to(new_users_email_change_path)
      else
        redirect_to(home_users_path, notice: "Email was updated")
      end
    end
  end
end
