# frozen_string_literal: true

class StaticController < ApplicationController
  respond_to :text, only: %i[robots]

  def privacy
    @page = WikiPage.find_by(title: "help:privacy_policy")
  end

  def terms_of_service
    @page = WikiPage.find_by(title: "help:terms_of_service")
  end

  def contact
    @page = WikiPage.find_by(title: "help:contact")
  end

  def takedown
    @page = WikiPage.find_by(title: "help:takedown")
  end

  def not_found
    render("static/404", formats: [:html], status: 404)
  end

  def error
  end

  def site_map
  end

  def home
    render(layout: "blank")
  end

  def theme
  end

  def toggle_mobile_mode
    if CurrentUser.is_member?
      user = CurrentUser.user
      user.disable_responsive_mode = !user.disable_responsive_mode
      user.save
    else
      if cookies[:nmm]
        cookies.delete(:nmm)
      else
        cookies.permanent[:nmm] = "1"
      end
    end
    redirect_back(fallback_location: posts_path)
  end

  def discord
    unless CurrentUser.can_discord?
      raise(User::PrivilegeError.new("You must have an account for at least one week in order to join the Discord server."))
    end
    if request.post?
      time = (Time.now + 5.minute).to_i
      secret = PawsMovin.config.discord_secret
      # TODO: Proper HMAC
      hashed_values = Digest::SHA256.hexdigest("#{CurrentUser.name} #{CurrentUser.id} #{time} #{secret}")
      user_hash = "?user_id=#{CurrentUser.id}&username=#{CurrentUser.name}&time=#{time}&hash=#{hashed_values}"

      redirect_to(PawsMovin.config.discord_site + user_hash, allow_other_host: true)
    end
  end

  def robots
    expires_in(1.hour, public: true)
  end
end
