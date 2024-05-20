# frozen_string_literal: true

class EmailsController < ApplicationController
  respond_to :html
  skip_before_action :verify_authenticity_token, only: %i[bounce]

  def resend_confirmation
    if IpBan.is_banned?(CurrentUser.ip_addr)
      redirect_to(home_users_path, notice: "An error occurred trying to send an activation email")
      return
    end

    raise(User::PrivilegeError.new("Must be logged in to resend verification email.")) if CurrentUser.is_anonymous?
    raise(User::PrivilegeError.new("Account already active.")) if CurrentUser.is_verified?
    raise(User::PrivilegeError.new("Cannot send confirmation because the email is not allowed.")) if EmailBlacklist.is_banned?(CurrentUser.user.email)
    # if RateLimiter.check_limit("emailconfirm:#{CurrentUser.id}", 1, 12.hours)
    #  raise User::PrivilegeError.new("Confirmation email sent too recently. Please wait at least 12 hours between sends.")
    # end
    RateLimiter.hit("emailconfirm:#{CurrentUser.id}", 12.hours)

    Users::EmailConfirmationMailer.confirmation(CurrentUser.user).deliver_now
    redirect_to(home_users_path, notice: "Activation email resent")
  end

  def activate_user
    if IpBan.is_banned?(CurrentUser.ip_addr)
      redirect_to(home_users_path, notice: "An error occurred trying to activate your account")
      return
    end

    user = verify_get_user(:activate)
    raise(User::PrivilegeError.new("Account cannot be activated because the email is not allowed.")) if EmailBlacklist.is_banned?(user.email)
    raise(User::PrivilegeError.new("Account already activated.")) if user.is_verified?

    user.mark_verified!

    redirect_to(home_users_path, notice: "Account activated")
  end

  def bounce
    @body = JSON.parse(request.body.read)
    @message = JSON.parse(@body["Message"])
    return head(403) unless sns_valid?
    if @message["eventType"] == "Bounce"
      address = @message.dig("bounce", "bouncedRecipients", 0, "emailAddress")
      user = User.find_by(email: address)
      user&.update!(receive_email_notifications: false)
    end
    head(204)
  end

  private

  def sns_valid?
    @body["SignatureVersion"] == "1" && verify_sns!
  end

  def verify_sns!
    parts = %w[Message MessageId Subject Timestamp TopicArn Type]
    sign = ""
    parts.each do |key|
      sign += "#{key}\n"
      sign += "#{@body[key]}\n"
    end
    signature = Base64.decode64(@body["Signature"])
    pubkey = fetch_public_key(@body["SigningCertURL"])
    pubkey&.verify(OpenSSL::Digest::SHA1.new, signature, sign) || false
  end

  def fetch_public_key(url)
    response = Faraday.new(PawsMovin.config.faraday_options).get(url)
    return nil unless response.success?
    OpenSSL::X509::Certificate.new(response.body).public_key
  end

  def verify_get_user(purpose)
    message = EmailLinkValidator.validate(params[:sig], purpose)
    raise(User::PrivilegeError.new("Invalid activation link.")) if message.blank? || !message
    User.find(message.to_i)
  end
end
