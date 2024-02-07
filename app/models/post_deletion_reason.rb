class PostDeletionReason < ApplicationRecord
  belongs_to_creator
  validates :reason, presence: true, length: { maximum: 100 }, uniqueness: { case_sensitive: false }
  validates :title, allow_blank: true, length: { maximum: 100 }, uniqueness: { case_sensitive: false }
  validates :prompt, allow_blank: true, length: { maximum: 100 }, uniqueness: { case_sensitive: false }
  validates :order, uniqueness: true, numericality: { only_numeric: true }
  validate :validate_prompt_and_title
  after_create :log_create
  after_update :log_update
  after_destroy :log_delete

  before_validation(on: :create) do
    self.order = (PostDeletionReason.maximum(:order) || 0) + 1 if order.blank?
  end

  def validate_prompt_and_title
    errors.add(:prompt, "is required") if prompt.blank? && title.present?
    errors.add(:title, "is required") if title.blank? && prompt.present?
  end

  module LogMethods
    def log_create
      ModAction.log(:post_deletion_reason_create, { report_reason_id: id, reason: reason, title: title, prompt: prompt })
    end

    def log_update
      options = {
        report_reason_id: id,
      }

      options.merge!({ reason: reason, reason_was: reason_before_last_save }) if saved_change_to_reason?
      options.merge!({ title: title, title_was: title_before_last_save }) if saved_change_to_title?
      options.merge!({ prompt: prompt, prompt_was: prompt_before_last_save }) if saved_change_to_prompt?

      ModAction.log(:post_deletion_reason_update, options)
    end

    def log_delete
      ModAction.log(:post_deletion_reason_delete, { report_reason_id: id, reason: reason, title: title, prompt: prompt, user_id: creator_id })
    end
  end

  module SearchMethods
    def quick_access
      where.not(title: nil, prompt: nil).order(id: :desc)
    end
  end

  include LogMethods
  extend SearchMethods
end
