# frozen_string_literal: true

class StatsController < ApplicationController
  respond_to :html, :json

  def index
    stats = Cache.redis.get("e6stats")
    if stats.blank?
      @stats = StatsUpdater.run!
    else
      @stats = JSON.parse(stats)
    end
    respond_with(@stats)
  end
end
