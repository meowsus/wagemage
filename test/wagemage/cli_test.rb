require 'test_helper'

module Wagemage
  class CliTest < Test
    test 'run script in org repos' do
      skip 'runs interactively'

      cli = CLI.new [
        '-o', 'workarea-commerce',
        '-r', '^workarea-',
        '-b', '-stable$',
        '-s', 'hello_world'
      ]

      VCR.use_cassette :github_workarea do
        assert_output 'SCRIPT SUCCEEDED', -> { cli.run }
      end
    end

    private

    def assert_output(expected, action)
      output, errors = capture_io(&action)

      assert_empty errors
      assert_includes output, expected
    end
  end
end
