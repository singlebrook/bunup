# frozen_string_literal: true

module Bunup
  module Values
    # Parse and handle version strings
    class Version
      def initialize(version_string)
        @version_string = version_string
      end

      def to_s
        @version_string
      end

      def major
        if from_git?
          # '6.0.0.rc2 b6f1d19' => 6
          @version_string.split(' ')[0].split('.')[0].to_i
        else
          # '6.0.0.rc2' => 6
          @version_string.split('.')[0].to_i
        end
      end

      def from_git?
        Services::ValidateGitVersion.new(@version_string).perform
      end

      def nil?
        @version_string == '' || @version_string.nil?
      end

      def valid?
        ::Gem::Version.correct?(@version_string) ||
          Services::ValidateGitVersion.new(@version_string).perform
      end
    end
  end
end
