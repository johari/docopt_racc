$dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift $dir + '/../lib'

require "yaml"
require "minitest/autorun"

def load_raw name
  path = File::expand_path("../raw/#{name}", __FILE__)
  File.open(path).read
end

agnostic_test_cases = File.open \
  File.expand_path("../raw/agnostic.yaml", __FILE__)
TEST_CASES = YAML::load(agnostic_test_cases.read)

misc_test_cases = File.open \
  File.expand_path("../raw/misc.yaml", __FILE__)
TEST_CASES.update(YAML::load(misc_test_cases.read))


class Catcher
  def initialize &asserter
    @asserter = asserter
  end

  def move alt, cons, args, data
    @asserter.call(alt, cons, args, data)
  end

  def alt reason
    raise reason
  end
end
