require 'slop'

require 'codeslave/version'

module Codeslave
  class Error < StandardError; end

  class CLI
    def initialize(args)
      @options = Slop.parse(args) do |option|
        option.bool '-h', '--help', 'print this help'
        option.on '-v', '--version', 'print the version'
      end

      puts @options if @options.help?
      puts "Codeslave v#{Codeslave::VERSION}" if @options.version?
    end

    def run
    end
  end
end
