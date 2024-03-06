# frozen_string_literal: true

FactoryBot.define do
  factory(:takedown) do
    email { "takedown@example.com" }
    reason { "test" }
    instructions { "test" }
  end
end
