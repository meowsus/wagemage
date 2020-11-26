require 'tmpdir'
require 'open3'
require 'pathname'

require 'slop'
require 'colorize'
require 'octokit'

module Slop
  class PathOption < Option
    def call(value)
      Pathname.new(value)
    end
  end
end

Octokit.configure do |c|
  c.auto_paginate = true
end

require 'wagemage/version'
require 'wagemage/helpers'
require 'wagemage/cli'
require 'wagemage/repo'

module Wagemage
  class Error < StandardError; end
  class OptionError < Slop::MissingRequiredOption; end

  extend Helpers
end
