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
      @installed_version = Values::Version.new(installed_version)
      @newest_version = Values::Version.new(newest_version)
      validate
    end

    def installed_from_git?
      installed_version.from_git? || newest_version.from_git?
    end

    private

    def validate
      abort "Invalid gem name: #{name}" unless valid_name?
      unless installed_version.valid?
        abort "Invalid version for #{name}: #{installed_version}"
      end
      unless newest_version.valid?
        abort "Invalid version for #{name}: #{newest_version}"
      end
    end

    def valid_name?
      name =~ NAME_PATTERN
    end
  end
end
