#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "environment"))
require "faker"

max = User.maximum(:id)
(1..28).each do
  User.create!(name: Faker::Internet.username.tr(" ", "_").tr(".", "_"), email: Faker::Internet.email, password: "pawsmovin", password_confirmation: "pawsmovin")
end
