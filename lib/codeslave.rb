require 'slop'
require 'colorize'
require 'octokit'

Octokit.configure do |c|
  c.auto_paginate = true
end

require 'codeslave/version'
require 'codeslave/cli'
require 'codeslave/repo'

module Codeslave
  class Error < StandardError; end
end
