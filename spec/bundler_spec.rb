# frozen_string_literal: true

require 'spec_helper'

module Bunup
  RSpec.describe Bundler do
    describe '.validate_output' do
      it 'exits if gem is up to date' do
        status = double('status', success?: true)
        expect { described_class.validate_output(nil, nil, status) }.
          to raise_error(::SystemExit).
          with_message('Gem is up-to-date')
      end

      it 'exits if bundler error occurs' do
        status = double('status', success?: false, to_i: 1)
        stderr = 'stderr'
        expect { described_class.validate_output(nil, stderr, status) }.
          to raise_error(::SystemExit).
          with_message("#{stderr}\n")
      end

      it 'does not exit if bundler error indicated that gem is out-of-date' do
        status = double('status', success?: false, to_i: 256)
        stderr = 'stderr'
        expect { described_class.validate_output(nil, stderr, status) }.
          not_to raise_error
      end
    end
  end
end
