# frozen_string_literal: true

class RemoveArtistsGroupNameAndIsActive < ActiveRecord::Migration[7.0]
  def change
    reversible do |r|
      r.down do
        execute "CREATE INDEX index_artists_on_group_name ON public.artists USING btree (group_name)"
        execute "CREATE INDEX index_artists_on_group_name_trgm ON public.artists USING gin (group_name public.gin_trgm_ops)"
      end
    end

    remove_column :artists, :group_name, :string, null: false, default: ""
    remove_column :artist_versions, :group_name, :string, null: false, default: ""

    remove_column :artists, :is_active, :boolean, null: false, default: true
    remove_column :artist_versions, :is_active, :boolean, null: false, default: true
  end
end
