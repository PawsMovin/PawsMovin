module Moderator
  module DashboardsHelper
    def user_level_select_tag(name, options = {})
      choices = [
        ["", ""],
        *User.level_hash.reject { |_name, level| level < User::Levels::MEMBER }
      ]

      select_tag(name, options_for_select(choices, params[name].to_i), options)
    end
  end
end
