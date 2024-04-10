# frozen_string_literal: true

module Admin
  class DashboardsController < ApplicationController
    def show
      @dashboard = authorize(AdminDashboard.new)
    end
  end
end
