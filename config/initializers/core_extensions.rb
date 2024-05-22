# frozen_string_literal: true

module PawsMovin
  module Extensions
    module String
      def to_escaped_for_sql_like
        gsub(/%|_|\*|\\\*|\\\\|\\/) do |str|
          case str
          when "%"    then '\%'
          when "_"    then '\_'
          when "*"    then "%"
          when '\*'   then "*"
          when "\\\\", "\\" then "\\\\"
          end
        end
      end

      def truthy?
        match?(/\A(true|t|yes|y|on|1)\z/i)
      end

      def falsy?
        match?(/\A(false|f|no|n|off|0)\z/i)
      end
    end
  end
end

class String
  include PawsMovin::Extensions::String
end
