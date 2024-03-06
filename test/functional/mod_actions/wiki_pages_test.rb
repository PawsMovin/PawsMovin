# frozen_string_literal: true

require "test_helper"
require_relative "helper"

module ModActions
  class WikiPagesTest < ActiveSupport::TestCase
    include Helper
    include Rails.application.routes.url_helpers

    context "mod actions for wiki pages" do
      setup do
        @wiki = create(:wiki_page)
        set_count!
      end

      should "format wiki_page_delete correctly" do
        @wiki.destroy

        assert_matches(
          actions:         %w[wiki_page_delete],
          text:            "Deleted wiki page [[#{@wiki.title}]]",
          subject:         @wiki,
          wiki_page_title: @wiki.title,
        )
      end

      should "format wiki_page_lock correctly" do
        @wiki.update!(is_locked: true)

        assert_matches(
          actions:         %w[wiki_page_lock],
          text:            "Locked wiki page [[#{@wiki.title}]]",
          subject:         @wiki,
          wiki_page_title: @wiki.title,
        )
      end

      should "format wiki_page_rename correctly" do
        @original = @wiki.dup
        @wiki.update!(title: "aaa")

        assert_matches(
          actions:         %w[wiki_page_rename],
          text:            "Renamed wiki page ([[#{@original.title}]] -> [[#{@wiki.title}]])",
          subject:         @wiki,
          old_title:       @original.title,
          wiki_page_title: @wiki.title,
        )
      end

      should "format wiki_page_unlock correctly" do
        @wiki.update_columns(is_locked: true)
        @wiki.update!(is_locked: false)

        assert_matches(
          actions:         %w[wiki_page_unlock],
          text:            "Unlocked wiki page [[#{@wiki.title}]]",
          subject:         @wiki,
          wiki_page_title: @wiki.title,
        )
      end
    end
  end
end
