module Bunup
  module Services
    # Use bundler to update the gem and the Gemfile
    class Updater
      USING_PATTERN = /^Using (?<gem_name>.*) (?<installed>.*)$/

      def initialize(gem)
        @gem = gem
      end

      def perform
        update
      end

      private

      def bundle_update
        ::Open3.capture3("bundle update #{@gem.name}")
      end

      def update
        stdout, _stderr, _status = bundle_update

        # Bundler might be unable to update the gem, and won't say why.
        if stdout =~ /its version stayed the same/
          raise ::SystemExit.new(
            false,
            "Bundler tried to update #{@gem.name} " \
              'but is version stayed the same'
          )
        end
      end
    end
  end
end
