# frozen_string_literal: true

module Users
  class PasswordsController < ApplicationController
    def edit
      @user = CurrentUser.user
    end
  end
end
