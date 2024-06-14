# frozen_string_literal: true

class RenameUserFeedbackTable < ActiveRecord::Migration[7.1]
  def change
    rename_table(:user_feedback, :user_feedbacks)
  end
end
