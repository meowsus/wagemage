require "test_helper"

class CodeslaveTest < Codeslave::Test
  test 'defines errors' do
    assert Codeslave.const_defined?(:Error)
    assert Codeslave.const_defined?(:OptionError)
  end

  test 'helper methods' do
    output, errors = capture_io { Codeslave.say('hello') }

    assert_empty errors
    assert_equal "\e[0;37;49mhello\e[0m\n", output
  end
end
