# frozen_string_literal: true

module Sources
  module Alternates
    def self.all
      return constants.reject { |name| name == :Base }.map { |name| const_get(name) }
    end

    def self.find(url, default: Alternates::Null)
      alternate = all.map {|alternate| alternate.new(url)}.detect(&:match?)
      alternate || default&.new(url)
    end
  end
end
