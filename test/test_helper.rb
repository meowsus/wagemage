require "bundler/setup"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "wagemage"

require "minitest/autorun"
require "vcr"
require "webmock"
require "active_support/all"
require "mocha/minitest"

# To add new cassettes, comment out this line and replace it with your
# own actual GitHub token. Before committing the cassette to Git,
# replace the token in the request with "REDACTED" and uncomment the
# following line. This will ensure your GitHub token won't accidentally
# be leaked.
ENV["WAGEMAGE_GITHUB_TOKEN"] = "REDACTED"

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = 'test/cassettes'
end

module Wagemage
  class Test < ActiveSupport::TestCase
    # base class for all tests
  end
end
