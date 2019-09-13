# frozen_string_literal: true

Dir.glob(File.dirname(__FILE__) + '/bunup/**/*.rb').each { |file| require file }

# Out top-level namespace
module Bunup; end
