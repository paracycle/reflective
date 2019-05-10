require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup

module Reflective
  class Error < StandardError; end
  # Your code goes here...
end
