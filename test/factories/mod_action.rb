# frozen_string_literal: true

FactoryBot.define do
  factory(:mod_action) do
    creator
    action { "test" }
  end
end
