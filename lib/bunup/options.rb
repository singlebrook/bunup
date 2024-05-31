# frozen_string_literal: true

require 'optionparser'
require 'ostruct'

module Bunup
  # Handle command-line switches
  class Options < ::OpenStruct
    def self.parse!(args)
      options = new
      opt_parser = ::OptionParser.new do |opts|
        opts.banner = 'Usage: bunup [options] | <gem_name> [<gem_name>...]'
        opts.program_name = 'bunup'
        opts.version = ::Bunup::VERSION

        opts.on('--all', 'Update all outdated gems (default)') do
          options.all = true
        end

        assume_yes_msg = 'Answer "yes" to all major or git version update ' \
          'prompts, or all, and run non-interactively. Defaults to all.'
        opts.on(
          '-y', '--yes', '--assume-yes [major, git]',
          Array,
          assume_yes_msg
        ) do |list|
          if list.nil?
            options[:assume_yes_for_major_version_update] = true
            options[:assume_yes_for_git_update] = true
          else
            list.each do |version_type|
              case version_type.strip
              when 'major'
                options[:assume_yes_for_major_version_update] = true
              when 'git' then options[:assume_yes_for_git_update] = true
              end
            end
          end
        end

        opts.on('--only-explicit') do
          options[:only_explicit] = true
        end

        opts.on('-h', '--help', 'Prints this help') do
          puts opts
          exit
        end
      end
      opt_parser.parse!(args)

      options.all = true if args.empty?

      options
    rescue OptionParser::InvalidOption => e
      puts e
      puts opt_parser
      abort
    end
  end
end
