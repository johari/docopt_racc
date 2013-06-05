module Docopt
  module Constants
    SHORT_OPT = /-[a-z]/i
    LONG_OPT = /--[a-z][a-z-]+/i
    DELIM = /(, *)| +/
    VAR = /<[:a-z\/ ]+>|[A-Z]+/
    ARG = /[a-z]+|-/
    LDOTS = /\.\.\./
    PROG_NAME = /[\w\._-]+/

    USAGE_BLOCK = /^.*usage:\n?/i
    OPTIONS_BLOCK = /^.*options:\n?/i
  end
end
