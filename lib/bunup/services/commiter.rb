# frozen_string_literal: true

module Bunup
  module Services
    # Commit changes to Gemfile and Gemfile.lock to git
    class Commiter
      COMMIT_MESSAGE_FMT = '%<gem_name>s %<newest_version>s ' \
      '(was %<installed_version>s)'

      def self.clean_gemfile?
        `git status -s Gemfile Gemfile.lock` == ''
      end

      def initialize(gem)
        @gem = gem
      end

      def perform
        add
        commit
      end

      private

      def add
        `git add Gemfile Gemfile.lock`
      end

      def commit
        `git commit -m "#{message}"`
      end

      def message
        format COMMIT_MESSAGE_FMT,
               gem_name: @gem.name,
               newest_version: @gem.newest_version,
               installed_version: @gem.installed_version
      end
    end
  end
end
