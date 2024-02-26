# frozen_string_literal: true

module TagCategory
  module_function

  Category = Struct.new(:id, :name, :aliases) do
    KWARGS = %i[header suffix limit exclusion regex formatstr].freeze # rubocop:disable Lint/ConstantDefinitionInBlock
    attr_reader :admin_only
    attr_accessor(*KWARGS)

    def initialize(*, **kwargs)
      super(*)
      KWARGS.each do |key|
        send("#{key}=", kwargs[key])
      end
      self.aliases ||= []
      self.header ||= name.titlecase
    end

    def values
      [name, *aliases]
    end

    def title
      name.titleize
    end

    def admin_only?
      is_a?(AdminCategory)
    end

    def humanized?
      %i[limit exclusion regex formatstr].any? { |v| send(v).present? }
    end
  end
  class AdminCategory < Category; end

  GENERAL = Category.new(0, "general", %w[gen])
  ARTIST = Category.new(1, "artist", %w[art], header: "Artists", exclusion: %w[avoid_posting conditional_dnp epilepsy_warning sound_warning], formatstr: "created by %s")
  VOICE_ACTOR = Category.new(2, "voice_actor", %w[va], header: "Voice Actors", suffix: "_(va)")
  COPYRIGHT = Category.new(3, "copyright", %w[copy co], header: "Copyrights", limit: 1, formatstr: "(%s)")
  CHARACTER = Category.new(4, "character", %w[char ch oc], header: "Characters", limit: 5, regex: /^(.+?)(?:_\(.+\))?$/)
  SPECIES = Category.new(5, "species", %w[spec])
  INVALID = AdminCategory.new(6, "invalid", %w[inv])
  META = AdminCategory.new(7, "meta")
  LORE = AdminCategory.new(8, "lore", %w[lor], suffix: "_(lore)")

  def categories
    @categories ||= constants.map { |c| const_get(c) }.select { |c| c.is_a?(Category) }
  end

  def get(value)
    value = reverse_mapping[value] if value.is_a?(Integer)
    categories.find { |c| c.name == value.to_s.downcase }
  end

  def ids
    @ids ||= categories.map(&:id)
  end

  def mapping
    @mapping ||= categories.flat_map { |c| c.values.map { |v| [v, c.id] } }.to_h
  end

  def reverse_mapping
    @reverse_mapping ||= categories.to_h { |c| [c.id, c.name] }
  end

  def for_select
    categories.map { |c| [c.title, c.id] }
  end

  def regexp
    @regexp ||= Regexp.compile(mapping.keys.sort_by { |x| -x.length }.join("|"))
  end

  def value_for(string)
    mapping[string.to_s.downcase] || 0
  end

  def short_name_mapping
    @short_name_mapping ||= categories.flat_map { |c| c.aliases.map { |a| [a, c.name] } }.to_h
  end

  def short_name_list
    @short_name_list ||= short_name_mapping.keys
  end

  def short_name_regex
    @short_name_regex ||= short_name_mapping.keys.join("|")
  end

  def humanized
    @humanized ||= categories.select(&:humanized?).map(&:name)
  end

  def category_names
    @category_names ||= categories.map(&:name)
  end

  categories.each do |cat|
    define_method(cat.name) do
      cat.id
    end
  end

  SPLIT_HEADER_LIST = %w[invalid artist voice_actor copyright character species general meta lore].freeze
  CATEGORIZED_LIST = %w[invalid artist voice_actor copyright character species meta general lore].freeze
end
