# frozen_string_literal: true

module ArtistsHelper
  def link_to_artist(name)
    artist = Artist.find_by(name: name)

    if artist
      link_to(artist.name, artist_path(artist))
    else
      link = link_to(name, new_artist_path(name: name))
      notice = tag.span("*", class: "new-artist", title: "No artist with this name currently exists.")
      "#{link} #{notice}".html_safe
    end
  end

  def link_to_artists(names)
    names.map do |name|
      link_to_artist(name.downcase)
    end.join(", ").html_safe
  end

  def link_to_pool_artists(names)
    names.map do |name|
      tag = Tag.find_or_create_by_name(name, user: User.system)
      link_to(name, show_or_new_artists_path(name: name), class: "tag-type-#{tag.category}")
    end.join(", ").html_safe
  end
end
