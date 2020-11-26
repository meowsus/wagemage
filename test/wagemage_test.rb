require "test_helper"

class WagemageTest < Wagemage::Test
  test 'defines errors' do
    assert Wagemage.const_defined?(:Error)
    assert Wagemage.const_defined?(:OptionError)
  end

  test 'helper methods' do
    output, errors = capture_io { Wagemage.say('hello') }

    assert_empty errors
    assert_equal "\e[0;37;49mhello\e[0m\n", output
  end
end
