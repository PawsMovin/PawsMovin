# frozen_string_literal: true

module Moderator
  class DashboardsController < ApplicationController
    def show
      @dashboard = authorize(Moderator::Dashboard::Report.new(params[:min_date] || 2.days.ago.to_date, params[:max_level] || 20), policy_class: ::ModeratorDashboardPolicy)
    end
  end
end
