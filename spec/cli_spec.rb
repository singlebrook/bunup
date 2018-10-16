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
        installed_version: installed_version,
        newest_version: newest_version
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

      expect(cli).to receive(:verify_clean_gemfile)

      output = capture_standard_output { cli.run }
      expect(output.join).
        to include('Checking for updates').
        and include('(1/1) Updating gem_name 1.0.0 -> 1.1.0')
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

    describe '#prompt_for_major_upgrade' do
      it 'it exits if user does not want to upgrade major version' do
        gem_name = 'gem_name'
        installed_version = '1.0.0'
        newest_version = '2.0.0'

        gem_stub = instance_double(
          '::Bunup::Gem',
          name: gem_name,
          installed_version: installed_version,
          newest_version: newest_version
        )
        allow(STDIN).to receive(:gets).and_return('n')

        cli = described_class.new(['some_gem'])
        allow(cli).to receive(:build_gems).and_return([gem_stub])
        expect { cli.run }.
          to raise_error(::SystemExit).
          with_message('No update performed')
      end
    end
  end
end
