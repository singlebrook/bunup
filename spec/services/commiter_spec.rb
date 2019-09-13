# frozen_string_literal: true

require 'spec_helper'

module Bunup
  module Services
    RSpec.describe Commiter do
      describe '#message' do
        it 'returns a properly formatted message' do
          gem_name = 'gem_name'
          installed_version = '1.0.0'
          newest_version = '2.0.0'
          gem_stub = instance_double(
            '::Bunup::Gem',
            name: gem_name,
            installed_version: installed_version,
            newest_version: newest_version
          )
          commiter = described_class.new(gem_stub)
          expect(commiter.send(:message)).
            to eq('gem_name 2.0.0 (was 1.0.0)')
        end
      end
    end
  end
end
