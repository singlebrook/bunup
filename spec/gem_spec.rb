require 'spec_helper'

module Bunup
  RSpec.describe Gem do
    describe '#validate' do
      it 'validates the gem name' do
        invalid_gem_name = '!'
        attributes = {
          name: invalid_gem_name,
          installed_version: nil,
          newest_version: nil
        }
        expect { described_class.new(attributes) }.
          to raise_error("Invalid gem name: #{invalid_gem_name}")
      end
    end

    it 'validates the installed version' do
      invalid_version = 'p1.0'
      attributes = {
        name: 'gem_name',
        installed_version: invalid_version,
        newest_version: '1.0.0'
      }
      expect { described_class.new(attributes) }.
        to raise_error(::SystemExit).
        with_message("Invalid version for gem_name: #{invalid_version}")
    end

    it 'validates the newest version' do
      invalid_version = 'p1.0'
      attributes = {
        name: 'gem_name',
        installed_version: '1.0.0',
        newest_version: invalid_version
      }
      expect { described_class.new(attributes) }.
        to raise_error(::SystemExit).
        with_message("Invalid version for gem_name: #{invalid_version}")
    end
  end
end
