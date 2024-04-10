# frozen_string_literal: true

module PostReplacementRejectionReasons
  def self.run!
    [
      "Upscaled",
      "Different Image",
      "Lower Quality",
    ].each_with_index.map do |data, index|
      next if data == ""

      PostReplacementRejectionReason.find_or_create_by!(reason: data, order: index + 1)
    end
  end
end
