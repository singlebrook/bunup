# frozen_string_literal: true

module Bunup
  # Parse args, run services, handle output, and handle exits
  class CLI
    COMMITING_MSG = 'Commiting Gemfile and Gemfile.lock changes'
    E_DIRTY_GEMFILE = 'Gemfile and/or Gemfile.lock has changes that would ' \
        'be overwritten. Please stash or commit your changes before running ' \
        'bunup.'
    GIT_REF_UPDATE_WARNING = 'WARNING: %<gem_name>s is installed from a git ' \
        'repo and is being updated from %<installed_version>s to ' \
        '%<newest_version>s. This update could include breaking changes. ' \
        'Continue? [y/N] '
    MAJOR_VERSION_UPDATE_WARNING_FMT = 'WARNING: %<gem_name>s is being ' \
        'updated from %<installed_version>s to %<newest_version>s. This is ' \
        'a major version update with possible breaking changes. ' \
        'Continue? [y/N] '
    UPDATING_MSG_FMT = '(%<remaining>s) Updating %<gem_name>s ' \
      '%<installed_version>s -> %<newest_version>s'

    def initialize(args)
      @options = ::Bunup::Options.parse!(args)
      @args = args
      @exit_status = true
    end

    def run
      abort(E_DIRTY_GEMFILE) unless ::Bunup::Services::Commiter.clean_gemfile?
      @gems = build_gems
      update_and_commit_changes
      exit @exit_status
    end

    private

    def build_gem(match_data)
      ::Bunup::Gem.new(
        name: match_data[:name],
        installed_version: match_data[:installed],
        newest_version: match_data[:newest]
      )
    end

    def build_gems
      bundle_outdated.split("\n").map.with_object([]) do |line, gems|
        next unless Bundler::OUTDATED_PATTERN =~ line

        match_data = Bundler::OUTDATED_PATTERN.match(line)
        gems << build_gem(match_data)
      end
    end

    def bundle_outdated
      puts 'Checking for updates'
      Bundler.outdated(bunup_all? ? [] : @args, only_explicit: @options[:only_explicit])
    rescue ::SystemExit => e
      handle_system_exit(e)
      ''
    end

    def bunup_all?
      @options.all
    end

    def bunup_many?
      @args.count > 1 || bunup_all?
    end

    def commit
      Services::Commiter.new(@gem).perform
    end

    def handle_system_exit(exception)
      @exit_status = exception.success?
      msg = []
      msg << 'ERROR:' unless exception.success?
      msg << exception.message
      puts "#{msg.join(' ')}\n"
      raise exception unless bunup_many?
    end

    def major_version_update?
      return false if @gem.newest_version.nil? || @gem.installed_version.nil?

      @gem.newest_version.major > @gem.installed_version.major
    end

    # A major version update has breaking changes, according to Semantic
    # Versioning (https://semver.org/spec/v2.0.0.html). Let's make sure the
    # user is aware of that.
    def prompt_for_git_ref_update
      print format(
        GIT_REF_UPDATE_WARNING,
        gem_name: @gem.name,
        installed_version: @gem.installed_version,
        newest_version: @gem.newest_version
      )
      if @options[:assume_yes_for_git_update]
        print "assuming yes\n"
      else
        unless $stdin.gets.chomp.casecmp('y').zero?
          raise ::SystemExit.new(true, 'No update performed')
        end
      end
    end

    # A major version update has breaking changes, according to Semantic
    # Versioning (https://semver.org/spec/v2.0.0.html). Let's make sure the
    # user is aware of that.
    def prompt_for_major_update
      print format(
        MAJOR_VERSION_UPDATE_WARNING_FMT,
        gem_name: @gem.name,
        installed_version: @gem.installed_version,
        newest_version: @gem.newest_version
      )
      if @options[:assume_yes_for_major_version_update]
        print "assuming yes\n"
      else
        unless $stdin.gets.chomp.casecmp('y').zero?
          raise ::SystemExit.new(true, 'No update performed')
        end
      end
    end

    def update
      puts format(
        UPDATING_MSG_FMT,
        remaining: "#{@gems.find_index(@gem) + 1}/#{@gems.count}",
        gem_name: @gem.name,
        installed_version: @gem.installed_version,
        newest_version: @gem.newest_version
      )
      Services::Updater.new(@gem).perform
    end

    def update_and_commit_changes
      @gems.each do |gem|
        @gem = gem
        begin
          prompt_for_major_update if major_version_update?
          prompt_for_git_ref_update if @gem.installed_from_git?
          update
          commit
        rescue ::SystemExit => e
          handle_system_exit(e)
          next
        end
      end
    end
  end
end
