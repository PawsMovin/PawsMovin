# frozen_string_literal: true

class StorageManager::Null < StorageManager::Base
  def store(io, path)
    # no-op
  end

  def delete(path)
    # no-op
  end

  def open(path)
    # no-op
  end
end
