#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "environment"))
require "faker"

28.times do
  User.create!(name: Faker::Internet.username.tr(" ", "_").tr(".", "_"), email: Faker::Internet.email, password: "pawsmovin", password_confirmation: "pawsmovin")
end
