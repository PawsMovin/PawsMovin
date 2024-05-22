# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    sparams = params.fetch(:session, {}).slice(:url, :name, :password, :remember)
    if RateLimiter.check_limit("login:#{request.remote_ip}", 15, 12.hours)
      PawsMovin::Logger.add_attributes("user.login" => "rate_limited")
      return redirect_to(new_session_path, notice: "Username/Password was incorrect")
    end
    session_creator = SessionCreator.new(session, cookies, sparams[:name], sparams[:password], request.remote_ip, remember: sparams[:remember], secure: request.ssl?)

    if session_creator.authenticate
      url = sparams[:url] if sparams[:url]&.start_with?("/") && !sparams[:url].start_with?("//")
      PawsMovin::Logger.add_attributes("user.login" => "success")
      redirect_to(url || posts_path)
    else
      RateLimiter.hit("login:#{request.remote_ip}", 6.hours)
      PawsMovin::Logger.add_attributes("user.login" => "fail")
      redirect_back(fallback_location: new_session_path, notice: "Username/Password was incorrect")
    end
  end

  def destroy
    session.delete(:user_id)
    session.delete(:last_authenticated_at)
    cookies.delete(:remember)
    redirect_to(posts_path, notice: "You are now logged out")
  end

  def confirm_password
  end
end
