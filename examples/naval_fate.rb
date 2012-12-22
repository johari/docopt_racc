require File.expand_path("../../lib/docopt.rb", __FILE__)

begin
  require "pp"
  pp Docopt::docopt(DATA.read)
rescue Docopt::Exit => e
  puts e.message
end

__END__
Naval Fate.

Usage:
  naval_fate [options]

Options:
  -h --help     Show this screen.
  --version     Show version.
  --speed=<kn>  Speed in knots [default: 10].
  --moored      Moored (anchored) mine.
  --drifting    Drifting mine.
