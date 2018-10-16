require 'spec_helper'

module Bunup
  module Services
    RSpec.describe Updater do
      it 'exits if bundler is unable to update gem' do
        gem_name = 'gem_name'
        gem_stub = instance_double('::Bunup::Gem', name: gem_name)
        updater = described_class.new(gem_stub)
        expect(updater).
          to receive(:bundle_update).
          and_return('its version stayed the same')
        expect { updater.perform }.
          to raise_error(::SystemExit).
          with_message(
            "Bundler tried to update #{gem_name} but is version stayed the same"
          )
      end
    end
  end
end
