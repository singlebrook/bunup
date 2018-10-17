require 'optionparser'
require 'ostruct'

module Bunup
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

        opts.on('-h', '--help', 'Prints this help') do
          puts opts
          exit
        end
      end
      opt_parser.parse!(args)
      options
    rescue OptionParser::InvalidOption => e
      puts e
      puts opt_parser
      abort
    end
  end
end
