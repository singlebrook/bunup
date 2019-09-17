# frozen_string_literal: true

module Bunup
  module Services
    # Validate that version of gem installed from a git source is valid
    class ValidateGitVersion
      # https://stackoverflow.com/questions/468370/a-regex-to-match-a-sha1#468378
      SHA_REGEX = /\b[0-9a-f]{5,40}\b/.freeze

      def initialize(version_string)
        @version_string = version_string
      end

      def perform
        version, sha = @version_string.split(' ')
        return false if sha.nil?

        ::Gem::Version.correct?(version) &&
          !sha.match(SHA_REGEX).nil?
      end
    end
  end
end
