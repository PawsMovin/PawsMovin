# frozen_string_literal: true

class AddModActionsSubject < ActiveRecord::Migration[7.1]
  def change
    add_column(:mod_actions, :subject_id, :integer)
    add_column(:mod_actions, :subject_type, :string)
  end
end
