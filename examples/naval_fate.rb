require File.expand_path("../../lib/docopt.rb", __FILE__)
require "pp"

usage = <<-DOCOPT
Naval Fate.

Usage:
  naval_fate.rb ship new <name>...
  naval_fate.rb ship <name> move (-x <x> -y <y>)... [--speed=<kn>]
  naval_fate.rb ship shoot <x> <y>
  naval_fate.rb mine (set|remove) <x> <y> [--moored|--drifting]
  naval_fate.rb -h | --help
  naval_fate.rb --version

Options:
  -h --help     Show this screen.
  --version     Show version.
  --speed=<kn>  Speed in knots [default: 10].
  --moored      Moored (anchored) mine.
  --drifting    Drifting mine.

DOCOPT

options = Docopt.parse usage do |err|
  puts err
end

pp options
