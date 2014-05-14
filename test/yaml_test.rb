require File.expand_path("../test_helper", __FILE__)
require "shellwords"
require "docopt"


class TestParser < MiniTest::Unit::TestCase
end

TestParser.instance_eval do
  TEST_CASES.each_pair do |id, test_case|
    test_case["runs"] ||= []

    test_case["runs"].each_with_index do |run, index|
      self.send :define_method, \
        ("test_%s_run_%d" % [id, index]).to_sym do
          args = Shellwords.shellwords(run["prog"])
          case run["expect"]
          when "user-error"
            begin
              Docopt::docopt(test_case["usage"], args, true)
            rescue Docopt::ARGVError => e
              assert_equal run["because"], e.message if run.include? "because"
            else
              raise "user-error expected"
            end
          else
            begin
              assert_equal run["expect"], Docopt::docopt(test_case["usage"], args, true)
            rescue Docopt::ARGVError => e
              message = ""

              line_sep = "\n" + ("="*20) + "\n"
              ["ARGVError raised:",
               test_case["usage"],
               args.inspect,
               "expected:\n" << run["expect"].to_s,
              ].each do |line|
                message << line << line_sep
              end

              raise message
            end
          end
      end
    end
  end
end
