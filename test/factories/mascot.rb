# frozen_string_literal: true

FactoryBot.define do
  factory(:mascot) do
    sequence(:display_name) { |n| "mascot_#{n}" }
    background_color { "FFFFFF" }
    artist_url { "http://localhost" }
    artist_name { "artist" }
    mascot_file { fixture_file_upload("test.jpg") }
  end
end
