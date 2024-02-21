class ForumCategory < ApplicationRecord
  has_many :forum_topics, -> { order(id: :desc) }, foreign_key: :category
  validates :name, uniqueness: { case_sensitive: false }

  after_create :log_create
  after_update :log_update
  before_destroy :prevent_destroy_if_topics
  after_destroy :log_delete

  before_validation(on: :create) do
    self.order = (ForumCategory.maximum(:order) || 0) + 1 if order.blank?
  end

  def can_create_within?(user = CurrentUser.user)
    user.level >= can_create
  end

  def self.reverse_mapping
    order(:order).all.map { |rec| [rec.name, rec.id] }
  end

  def self.ordered_categories
    order(:order)
  end

  def prevent_destroy_if_topics
    if forum_topics.any?
      errors.add(:base, "Forum category cannot be deleted because it has topics")
      throw :abort
    end
  end

  module LogMethods
    def log_create
      ModAction.log!(:forum_category_create, self,
                     forum_category_name: name,
                     can_view: can_view,
                     can_create: can_create)
    end

    def log_update
      ModAction.log!(:forum_category_update, self,
                     forum_category_name: name,
                     old_category_name: category_name_before_last_save,
                     can_view: can_view,
                     old_can_view: can_view_before_last_save,
                     can_create: can_create,
                     old_can_create: can_create_before_last_save)
    end

    def log_delete
      ModAction.log!(:forum_category_create, self,
                     forum_category_name: name,
                     can_view: can_view,
                     can_create: can_create)
    end
  end

  module SearchMethods
    def visible
      where(can_view: ..CurrentUser.user.level)
    end
  end

  include LogMethods
  extend SearchMethods
end
