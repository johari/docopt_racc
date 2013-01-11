$dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift $dir + '/../lib'

require "yaml"

def load_raw name
  path = File::expand_path("../raw/#{name}", __FILE__)
  File.open(path).read
end
