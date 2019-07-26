require 'ostruct'

module Bunup
  # Easily access gem attributes
  class Gem
    # Gem name patterns taken from
    # https://github.com/rubygems/rubygems.org/blob/master/lib/patterns.rb
    SPECIAL_CHARACTERS = '.-_'.freeze
    ALLOWED_CHARACTERS = '[A-Za-z0-9' \
      "#{Regexp.escape(SPECIAL_CHARACTERS)}]+".freeze
    NAME_PATTERN = /\A#{ALLOWED_CHARACTERS}\Z/.freeze

    attr_accessor :name, :installed_version, :newest_version

    def initialize(name: nil, installed_version: nil, newest_version: nil)
      @name = name
      @installed_version = installed_version
      @newest_version = newest_version
      validate
    end

    def installed_from_git?
      Services::ValidateGitVersion.new(@installed_version).perform ||
        Services::ValidateGitVersion.new(@newest_version).perform
    end

    private

    def validate
      abort "Invalid gem name: #{name}" unless valid_name?
      unless valid_version?(installed_version)
        abort "Invalid version for #{name}: #{installed_version}"
      end
      unless valid_version?(newest_version)
        abort "Invalid version for #{name}: #{newest_version}"
      end
    end

    def valid_name?
      name =~ NAME_PATTERN
    end

    def valid_version?(version_string)
      ::Gem::Version.correct?(version_string)
    end
  end
end
