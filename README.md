Docopt -- Option Parser
=======================

Docopt is an easy-to-use option parser optimized for developer happiness.
With Docopt, you can parse command-line options easily. Here's an example:

```ruby
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
```

Great! Now run

    $ ./naval_fate.rb ship new peace love happiness rainbows

to get

```ruby
{"--help"=>false,
 "--version"=>false,
 "--speed"=>"10",
 "--moored"=>false,
 "--drifting"=>false,
 "ship"=>true,
 "new"=>true,
 "<name>"=>["peace", "love", "happiness", "rainbows"],
 "move"=>false,
 "-x"=>0,
 "<x>"=>[],
 "-y"=>0,
 "<y>"=>[],
 "shoot"=>false,
 "mine"=>false,
 "set"=>false,
 "remove"=>false}
```

THAT'S JUST AWESOME! (see how this would be implemented with optparse)

GETTING HELP
------------

There are handful of examples in `examples/` directory to get you started.

If you had any problems, ask questions on
[Stack Overflow](http://stackoverflow.com) with the tag `docopt.rb`.


We also prepared some howtos in `docs/` folder. There you'd find

* howto use docopt for modular CLIs with subcommands (like rails or git)
* howto get free zsh/bash completions
* howto set validations for resulting options hash

You may fancy reading the Docopt language reference and Docopt
language agnostic tests.

INSTALL
-------

Either add this line to your Gemfile

    gem 'docopt', '~> 0.6.0'

and run `bundle install`, or install it with gem command like this

    $ [sudo] gem install docopt

You can also [try Docopt in your browser!](http://try.docopt.org)

Docopt is known to work with the following rubies:

  * MRI 1.8.7, 1.9, 2.0
  * jruby
  * rubinius

CONTRIBUTING
------------

Wanna help? AWESOME! take a look at [the contributing guide](./CONTRIBUTING.md).

If you have suggestions, open an [issue on github](/issues)



### THANKS

* [Blake Williams](https://github.com/shabbyrobe) and
  [Alex Speller](https://github.com/alexspeller) for their work on
  older versions of docopt.rb
* [Vladimir Kleshev](https://github.com/halst) for his original work
  on docopt python
* Other awesome [contributors](/contributions)!!

LINKS
-----

* [Github project page](http://github.com/johari/docopt_racc)
* [Examples](/examples)
* [HOW-TOs and docs](/docs)
* [Try docopt in your browser](http://try.docopt.org/)

LICENSE
-------

Copyright &copy; 2013 Nima Johari et. al.

Docopt is available under an MIT-style license. see `LICENSE-MIT` file.

This software is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantibility and fitness for a particular
purpose.
