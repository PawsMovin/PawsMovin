# frozen_string_literal: true

module Reports
  module_function

  LIMIT = 100

  def enabled?
    PawsMovin.config.reports_enabled?
  end

  def get(path)
    HTTParty.get("#{PawsMovin.config.reports_server_internal}#{path}", PawsMovin.config.httparty_options).parsed_response
  end

  # Integer
  def get_post_views(post_id)
    return 0 unless enabled?
    Cache.fetch("pv-#{post_id}", expires_in: 1.minute) do
      get("/post_views/#{post_id}")["count"].to_i
    end
  end

  # Hash { "post" => 0, "count" => 0 }[]
  def get_post_views_rank(date, limit = LIMIT)
    return [] unless enabled?
    Cache.fetch("pv-rank-#{date}", expires_in: 1.minute) do
      get("/post_views/rank?date=#{date.strftime('%Y-%m-%d')}&limit=#{limit}")
    end
  end

  # Hash { "tag" => "name", "count" => 0 }[]
  def get_post_searches_rank(date, limit = LIMIT)
    return [] unless enabled?
    Cache.fetch("ps-rank-#{date}", expires_in: 1.minute) do
      get("/post_searches/rank?date=#{date.strftime('%Y-%m-%d')}&limit=#{limit}")
    end
  end

  # Hash { "tag" => "name", "count" => 0 }[]
  def get_missed_searches_rank(limit = LIMIT)
    return [] unless enabled?
    Cache.fetch("ms-rank", expires_in: 1.minute) do
      get("/missed_searches/rank?limit=#{limit}")
    end
  end
end
