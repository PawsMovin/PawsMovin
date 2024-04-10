#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "environment"))
require "faker"

total = 100
total.times do |i|
  puts "Creating users.. #{i}/#{total}" if i % (total / 10) == 0
  User.create(name: Faker::Internet.username.tr(" ", "_").tr(".", "_"), email: Faker::Internet.email, password: "pawsmovin", password_confirmation: "pawsmovin", created_at: 2.weeks.ago)
end
