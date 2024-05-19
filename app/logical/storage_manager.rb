# frozen_string_literal: true

module StorageManager
  class Error < StandardError; end

  DEFAULT_BASE_DIR = "#{Rails.root}/public/data"
  IMAGE_TYPES = %i[preview large crop original]
  MASCOT_PREFIX = "mascots"
end
