require 'open3'

module Bunup
  # Run bundler commands
  class Bundler
    # Expects:
    #   "rails (newest 5.2.1, installed 5.2.0)"
    #   or
    #   "rails (newest 5.2.1, installed 5.2.0, requested = 5.2.0)"
    OUTDATED_PATTERN = /
      (?<name>.*)\s
      \(newest\s(?<newest>.*),\s
      installed\s(?<installed>.*?)
      (,\srequested.*)?
      \)
    /x.freeze
    # Expects: "Bundler version 1.17.0"
    VERSION_PATTERN = /Bundler version (?<version>(\d|\.)*)/.freeze

    # Expected output format:
    #   "\ngem-name (newest 1.0.0, installed 2.0.0)\n"
    def self.outdated(gem_names, args = [])
      stdout, stderr, status = Open3.capture3(
        "bundler outdated #{gem_names.join(' ')} #{args.join(' ')} --parseable --strict"
      )
      validate_output(stdout, stderr, status)
      stdout.strip
    end

    def self.validate_output(stdout, stderr, status)
      # `bundler outdated` exits with a 0 status if the gem is up-to-date
      raise ::SystemExit.new(true, 'Gem is up-to-date') if status.success?

      # `bundler outdated` exits with a status of 256 if the gem is out-of-date.
      # If it exits with some other status, print the error and exit with that
      # status
      unless status.to_i == 256
        raise ::SystemExit.new(
          status.to_i,
          (stderr == '' ? stdout : stderr).chomp + "\n"
        )
      end
    end

    def self.version
      bundler_version = `bundler --version`
      match_data = bundler_version.match(VERSION_PATTERN)
      raise 'Unexpected Bundler version format' if match_data.nil?

      ::Gem::Version.new(match_data[:version])
    end
  end
end
