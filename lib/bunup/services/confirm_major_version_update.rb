module Bunup
  module Services
    # A major version update has breaking changes, according to Semantic
    # Versioning (https://semver.org/spec/v2.0.0.html). Let's make sure the
    # user is aware of that.
    class ConfirmMajorVersionUpdate
      MAJOR_VERSION_UPDATE_WARNING_FMT = 'WARNING: %<gem_name>s is being ' \
        'updated from %<installed_version>s to %<newest_version>s. This is ' \
        'a major version update with possible breaking changes. ' \
        'Continue? [y/N] '.freeze

      def initialize(gem)
        @gem = gem
      end

      def perform
        return false if @gem.newest_version.nil? || @gem.installed_version.nil?

        if major_version_update?
          print_message
          if @options.assume_yes
            warn "assuming yes due to flag\n"
          else
            unless STDIN.gets.chomp.casecmp('y').zero?
              raise ::SystemExit.new(true, 'No update performed')
            end
          end
        end
      end

      private

      def major_version(version)
        version.split('.')[0].to_i
      end

      def major_version_update?
        major_version(@gem.newest_version) >
          major_version(@gem.installed_version)
      end

      def print_message
        print format(
          MAJOR_VERSION_UPDATE_WARNING_FMT,
          gem_name: @gem.name,
          installed_version: @gem.installed_version,
          newest_version: @gem.newest_version
        )
      end
    end
  end
end
