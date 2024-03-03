# frozen_string_literal: true

FactoryBot.define do
  factory(:rule) do
    sequence(:name) { |n| "rule_name_#{n}" }
    sequence(:description) { |n| "description_name_#{n}" }
  end
end
