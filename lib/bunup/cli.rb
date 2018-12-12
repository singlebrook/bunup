module Bunup
  # Parse args, run services, handle output, and handle exits
  class CLI
    COMMITING_MSG = 'Commiting Gemfile and Gemfile.lock changes'.freeze
    E_DIRTY_GEMFILE = 'Gemfile and/or Gemfile.lock has changes that would ' \
        'be overwritten. Please stash or commit your changes before running ' \
        'bunup.'.freeze
    UPDATING_MSG_FMT = '(%<remaining>s) Updating %<gem_name>s ' \
      '%<installed_version>s -> %<newest_version>s'.freeze

    def initialize(args)
      @options = ::Bunup::Options.parse!(args)
      @args = args
      @exit_status = true
    end

    def run
      abort(E_DIRTY_GEMFILE) unless ::Bunup::Services::Commiter.clean_gemfile?
      if Bundler.version < ::Gem::Version.new('1.17')
        gems = build_gems(only_explicit: false)
        update_and_commit_changes(gems)
      else
        puts '== Updating explicit dependencies =='
        explicit_gems = build_gems(only_explicit: true)
        update_and_commit_changes(explicit_gems)

        puts '== Updating transistive dependencies =='
        transitive_gems = build_gems(only_explicit: false)
        update_and_commit_changes(transitive_gems)
      end
      exit @exit_status
    end

    private

    def build_gems(only_explicit:)
      Services::GemsBuilder.new(
        bunup_all? ? [] : @args,
        only_explicit: only_explicit
      ).perform
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

    def handle_system_exit(exception)
      @exit_status = exception.success?
      msg = []
      msg << 'ERROR:' unless exception.success?
      msg << exception.message
      puts msg.join(' ') + "\n"
      raise exception unless bunup_many?
    end

    def update_and_commit_changes(gems)
      gems.each do |gem|
        begin
          Services::ConfirmMajorVersionUpdate.new(gem).perform

          puts format(
            UPDATING_MSG_FMT,
            remaining: "#{gems.find_index(gem) + 1}/#{gems.count}",
            gem_name: gem.name,
            installed_version: gem.installed_version,
            newest_version: gem.newest_version
          )
          Services::Updater.new(gem).perform

          Services::Commiter.new(gem).perform
        rescue ::SystemExit => e
          handle_system_exit(e)
          next
        end
      end
    end
  end
end
