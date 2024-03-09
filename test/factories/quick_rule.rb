# frozen_string_literal: true

FactoryBot.define do
  factory(:quick_rule) do
    sequence(:reason) { |n| "quick_rule_#{n}" }
    association(:rule)
  end
end
