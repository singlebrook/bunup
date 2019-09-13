# frozen_string_literal: true

require 'spec_helper'

module Bunup
  RSpec.describe CLI do
    it 'updates a gem and commits to git' do
      gem_name = 'gem_name'
      installed_version = '1.0.0'
      newest_version = '1.1.0'
      cli = described_class.new([gem_name])

      gem_stub = instance_double(
        '::Bunup::Services::Gem',
        name: gem_name,
        installed_from_git?: false,
        installed_version: Values::Version.new(installed_version),
        newest_version: Values::Version.new(newest_version)
      )
      allow(::Bunup::Gem).to receive(:new).and_return(gem_stub)

      commiter_stub = instance_double('::Bunup::Services::Commiter')
      allow(::Bunup::Services::Commiter).
        to receive(:new).
        with(gem_stub).
        and_return(commiter_stub)
      expect(commiter_stub).to receive(:perform)

      expect(::Bunup::Bundler).
        to receive(:outdated).
        with([gem_name]).
        and_return(
          "#{gem_name} (newest #{newest_version}, " \
            "installed #{installed_version})"
        )

      updater_stub = instance_double(
        '::Bunup::Services::Updater',
        perform: nil,
        update: nil
      )
      allow(::Bunup::Services::Updater).
        to receive(:new).
        with(gem_stub).
        and_return(updater_stub)
      expect(updater_stub).to receive(:perform)

      output = capture_standard_output { cli.run }
      expect(output.join).
        to include('Checking for updates').
        and include('(1/1) Updating gem_name 1.0.0 -> 1.1.0')
    end

    it 'aborts if Gemfile is dirty' do
      expect(::Bunup::Services::Commiter).
        to receive(:clean_gemfile?).
        and_return(false)

      output = capture_standard_error { described_class.new(['gem_name']).run }
      expect(output.join).
        to include(described_class::E_DIRTY_GEMFILE)
    end

    describe '#build_gems' do
      it 'builds gems from bundler output' do
        cli = described_class.new([])
        expect(cli).
          to receive(:bundle_outdated).
          and_return(
            "rails (newest 5.2.1, installed 5.2.0, requested ~> 5.2.0)\n" \
              'rails (newest 5.2.1, installed 5.2.0)'
          )
        built_gems = []
        expect { built_gems = cli.send(:build_gems) }.not_to raise_error
        built_gems.each do |gem|
          expect(gem.name).to eq('rails')
          expect(gem.installed_version.to_s).to eq('5.2.0')
          expect(gem.newest_version.to_s).to eq('5.2.1')
        end
      end
    end

    describe '#handle_system_exit' do
      it 'prints the error message' do
        msg = 'Exception message'
        exception = ::SystemExit.new(false, msg)
        cli = described_class.new(['some_gem'])
        output = capture_standard_output do
          cli.send(:handle_system_exit, exception)
        end
        expect(output).
          to include("ERROR: #{msg}")
      end
    end

    describe '#prompt_for_major_update' do
      it 'it exits if user does not want to update major version' do
        gem_name = 'gem_name'
        installed_version = '1.0.0'
        newest_version = '2.0.0'

        gem_stub = instance_double(
          '::Bunup::Gem',
          name: gem_name,
          installed_from_git?: false,
          installed_version: Values::Version.new(installed_version),
          newest_version: Values::Version.new(newest_version)
        )
        allow(STDIN).to receive(:gets).and_return('n')

        cli = described_class.new(['some_gem'])
        allow(cli).to receive(:build_gems).and_return([gem_stub])
        expect { cli.run }.
          to raise_error(::SystemExit).
          with_message('No update performed')
      end

      it 'it handles major version updates for gems installed using git' do
        gem_name = 'gem_name'
        installed_version = '1.0.0 d021ade'
        newest_version = '2.0.0 b6f1d19'

        gem_stub = instance_double(
          '::Bunup::Gem',
          name: gem_name,
          installed_from_git?: true,
          installed_version: Values::Version.new(installed_version),
          newest_version: Values::Version.new(newest_version)
        )
        allow(STDIN).to receive(:gets).and_return('n')

        cli = described_class.new(['some_gem'])
        allow(cli).to receive(:build_gems).and_return([gem_stub])
        expect { cli.run }.
          to raise_error(::SystemExit).
          with_message('No update performed')
      end

      it 'does not exit when assuming yes' do
        installed_version = '1.0.0'
        newest_version = '2.0.0'

        gem_stub1 = instance_double(
          '::Bunup::Gem',
          name: 'some_gem1',
          installed_from_git?: false,
          installed_version: Values::Version.new(installed_version),
          newest_version: Values::Version.new(newest_version)
        )
        gem_stub2 = instance_double(
          '::Bunup::Gem',
          name: 'some_gem2',
          installed_from_git?: false,
          installed_version: Values::Version.new(installed_version),
          newest_version: Values::Version.new(newest_version)
        )
        allow(STDIN).to receive(:gets).and_return('n')

        cli = described_class.new(%w[some_gem1 some_gem2 -y])
        allow(cli).to receive(:build_gems).and_return([gem_stub1, gem_stub2])
        expect { cli.run }.
          to raise_error(::SystemExit).
          with_message('exit')
      end
    end

    describe '#prompt_for_git_ref_update' do
      it 'it exits if user does not want to update major version' do
        gem_name = 'gem_name'
        installed_version = '6.0.0.rc1 d021ade'
        newest_version = '6.0.0.rc2 b6f1d19'

        gem_stub = instance_double(
          '::Bunup::Gem',
          name: gem_name,
          installed_from_git?: true,
          installed_version: Values::Version.new(installed_version),
          newest_version: Values::Version.new(newest_version)
        )
        allow(STDIN).to receive(:gets).and_return('n')

        cli = described_class.new(['some_gem'])
        allow(cli).to receive(:build_gems).and_return([gem_stub])
        expect { cli.run }.
          to raise_error(::SystemExit).
          with_message('No update performed')
      end

      it 'does not exit when assuming yes' do
        installed_version = '6.0.0.rc1 d021ade'
        newest_version = '6.0.0.rc2 b6f1d19'

        gem_stub1 = instance_double(
          '::Bunup::Gem',
          name: 'some_gem1',
          installed_from_git?: true,
          installed_version: Values::Version.new(installed_version),
          newest_version: Values::Version.new(newest_version)
        )
        gem_stub2 = instance_double(
          '::Bunup::Gem',
          name: 'some_gem2',
          installed_from_git?: true,
          installed_version: Values::Version.new(installed_version),
          newest_version: Values::Version.new(newest_version)
        )
        allow(STDIN).to receive(:gets).and_return('n')

        cli = described_class.new(%w[some_gem1 some_gem2 -y])
        allow(cli).to receive(:build_gems).and_return([gem_stub1, gem_stub2])
        expect { cli.run }.
          to raise_error(::SystemExit).
          with_message('exit')
      end
    end
  end
end
