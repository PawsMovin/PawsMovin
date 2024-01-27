module Admin::UsersHelper
  def user_level_select(object, field)
    options = User.level_hash.to_a
    select(object, field, options)
  end
end
