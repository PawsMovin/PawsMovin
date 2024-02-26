# frozen_string_literal: true

module Users
  class EmailNotificationsController < ApplicationController
    class VerificationError < StandardError; end

    before_action :validate_sig, only: [:destroy]
    rescue_from VerificationError, with: :access_denied

    def show
    end

    def destroy
      @user = ::User.find(params[:user_id])
      @user.receive_email_notifications = false
      @user.save
    end

    private

    def validate_sig
      message = EmailLinkValidator.validate(params[:sig], :unsubscribe)
      if message.blank? || !message || message != params[:user_id].to_s
        raise(VerificationError)
      end
    end
  end
end
