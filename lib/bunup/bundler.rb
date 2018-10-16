require 'open3'

module Bunup
  # Run bundler commands
  class Bundler
    OUTDATED_PATTERN = /
      (?<name>.*)\s\(newest\s(?<newest>.*),\sinstalled\s(?<installed>.*)\)
    /x

    # Expected output format:
    #   "\ngem-name (newest 1.0.0, installed 2.0.0)\n"
    def self.outdated(gem_names)
      stdout, stderr, status = Open3.capture3(
        "bundler outdated #{gem_names.join(' ')} --parseable"
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
  end
end
