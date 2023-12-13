module Moderator
  module Dashboard
    module Queries
      UserTextVersions = ::Struct.new(:version) do
        def self.all(min_date, _max_level)
          ::UserTextVersion
            .where.not(version: 1)
            .where("user_text_versions.created_at > ?", min_date)
            .order(id: :desc)
            .limit(10)
            .map { |version| new(version) }
        end
      end
    end
  end
end
