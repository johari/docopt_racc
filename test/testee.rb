#!/usr/bin/env ruby
require File.expand_path("../../lib/docopt.rb", __FILE__)

require 'json'

doc = STDIN.read

begin
  res = Docopt::docopt(doc).to_json
  puts res
rescue Docopt::ARGVError => e
  # $stderr.puts $!
  puts '"user-error"'
rescue => e
  raise e
  exit 1
end
