class StatsController < ApplicationController
  respond_to :html

  def index
    stats = Cache.redis.get("e6stats")
    if stats.blank?
      @stats = StatsUpdater.run!
    else
      @stats = JSON.parse(stats)
    end
  end
end
