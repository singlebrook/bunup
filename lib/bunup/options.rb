require 'optionparser'
require 'ostruct'

module Bunup
  attr_reader :options

  def self.options=(opts)
    @options ||= opts
  end

  # Handle command-line switches
  class Options < ::OpenStruct
    def self.parse!(args)
      args = ['--all'] if args.empty?
      options = new
      opt_parser = ::OptionParser.new do |opts|
        opts.banner = 'Usage: bunup [options] | <gem_name> [<gem_name>...]'
        opts.program_name = 'bunup'
        opts.version = ::Bunup::VERSION

        opts.on('--all', 'Update all outdated gems (default)') do
          options.all = true
        end

        assume_yes_msg = 'Answer "yes" to major version update prompts ' \
          'and run non-interactively'
        opts.on('-y', '--yes', '--assume-yes', assume_yes_msg) do
          options.assume_yes = true
        end

        opts.on('-h', '--help', 'Prints this help') do
          puts opts
          exit
        end
      end
      opt_parser.parse!(args)
      ::Bunup.options = options
    rescue OptionParser::InvalidOption => e
      puts e
      puts opt_parser
      abort
    end
  end
end
