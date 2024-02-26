# frozen_string_literal: true

module UsersHelper
  def email_sig(user, purpose, expires = nil)
    EmailLinkValidator.generate("#{user.id}", purpose, expires)
  end

  def email_domain_search(email)
    return unless email.include?("@")

    domain = email.split("@").last
    link_to "»", users_path(search: { email_matches: "*@#{domain}" })
  end

  def user_levels_for_select(min_level = User::Levels::MEMBER)
    User.level_hash.reject { |_name, level| level < min_level }
  end

  def user_level_select_tag(name, min_level = User::Levels::MEMBER, options = {})
    choices = [
      ["", ""],
      *user_levels_for_select(min_level),
    ]

    select_tag(name, options_for_select(choices, params[name].to_i), options)
  end

  def user_level_select(object, field, min_level = User::Levels::MEMBER)
    options = user_levels_for_select(min_level).to_a
    select(object, field, options)
  end
end
