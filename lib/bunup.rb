# frozen_string_literal: true

Dir.glob(File.dirname(__FILE__) + '/bunup/**/*.rb').sort.each do |file|
  require file
end

# Our top-level namespace
module Bunup; end
