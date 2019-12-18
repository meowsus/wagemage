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

require 'codeslave/version'
require 'codeslave/helpers'
require 'codeslave/cli'
require 'codeslave/repo'

module Codeslave
  class Error < StandardError; end
end
