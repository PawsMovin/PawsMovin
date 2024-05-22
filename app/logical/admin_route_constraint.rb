# frozen_string_literal: true

class AdminRouteConstraint
  def matches?(request)
    return false unless request.session[:user_id]
    user = User.find(request.session[:user_id])
    user&.is_admin? || false
  end
end
