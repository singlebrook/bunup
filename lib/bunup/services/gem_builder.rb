module Bunup
  module Services
    class GemsBuilder
      def initialize(gem_names, only_explicit:)
        @gem_names = gem_names
        @only_explicit = only_explicit
      end

      def perform
        bundle_outdated.split("\n").map do |line|
          next unless Bundler::OUTDATED_PATTERN =~ line

          match_data = Bundler::OUTDATED_PATTERN.match(line)
          build_gem(match_data)
        end.compact
      end

      private

      def build_gem(match_data)
        ::Bunup::Gem.new(
          name: match_data[:name],
          installed_version: match_data[:installed],
          newest_version: match_data[:newest]
        )
      end

      def bundle_outdated
        puts 'Checking for updates'
        Bundler.outdated(
          @gem_names,
          @only_explicit ? %i[--only-explicit] : []
        )
      end
    end
  end
end
