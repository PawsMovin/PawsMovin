# frozen_string_literal: true

module SensitiveParams
  # Common values for Rails query parameter filtering
  PARAMS = %i[passw secret token _key crypt salt certificate otp ssn email].freeze
end
