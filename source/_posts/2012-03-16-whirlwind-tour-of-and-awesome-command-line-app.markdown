---
layout: post
title: "Whirlwind Tour of an Awesome Command-Line App"
date: 2012-03-15 18:59
comments: true
categories: 
---

[My book][clibook] is now officially published and in print, so to celebrate, I'm going to give you a whirlwind tour of the book in the form of a code walkthrough.  In just four hours over 2 mornings, I created a simple but robust command-line app that demonstrates almost all of the lessons from my book.  Let's have a look.

<!-- more -->

I `grep` a lot of log files [at work][work].  LivingSocial processes thousands of credit card transactions per day, across a highly distributes, asynchronous system and when things go wrong, the log files are the first place to look.  I'll write a post some day about logging, but I *love* logging and log liberally.  This means that I `grep` is my go-to tool for analysis.  Even though `grep` can highlight search terms in output, with long and complex log lines, it can be hard to pick out just what I'm looking for.

For example, I might want to see all lines for transaction #987876736.  If there's matching lines, what I need is to find the credit card token (don't worry that's *not* the credit card _number_, we never store that or log that **anywhere**).  I usually just visually scan for it, but I thought "Wouldn't it be nice to have a tool to highlight additional terms in output?".

## To the command-line!

So, in just a few short hours, [hl][hl] was born.  Not only does `hl` solve my problem cleanly and clearly, but it exhibits most other aspects of an awesome command-line app.  The [table of contents][toc] for the book pretty much sums up these aspects:

* Have a Clear and Concise Purpose
* Be Easy To Use
* Be Helpful
* Play Well with Others
* Delight Casual Users
* Make Configuration Easy
* Distribute Painlessly
* Test, test, test
* Be Easy To Maintain

## Have a Clear & Concise Purpose

I think I've outlined that pretty well.  `hl` highlights search terms in any output to assist with visual scanning of output.

## Be Easy to Use

This is a *big* topic, but here's an example of using `hl`:

```sh
$ grep 987876736 my_logs.log | hl credit_card_token
```

`hl` does what it's asked, by default, without a lot of fuss, just like any other UNIX command

## Be Helpful

`hl` is based on [methadone][methadone], which is a proxy to [OptionParser][optionparser], which is *the* tool to use for parsing the command-line in Ruby.  It's very powerful, and generates a canonical, documented UI for your app:

```sh
$ bin/hl --help
Usage: hl [options] [search_term] [filename]

Highlight terms in output without grepping out lines

v1.0.0

Options:
    -c, --color COLOR                Color to use for highlighting
                                     (red|green|yellow|blue|magenta|cyan|white)
                                     (default: yellow)
    -b, --[no-]bright                Use bright colors
    -n, --[no-]inverse               Inverse highlight
    -u, --[no-]underline             Underline highlight
    -p, --regexp PATTERN             Search term as explicit option
    -i, --[no-]ignore-case           Ignore case in match
        --version                    Show help/version info

Default values can be placed in the HL_OPTS environment variable
```

Note how much `OptionParser` gives us:

* Ability to describe our app, its version, and basic invocation syntax
* Nicely formatted list of options and descriptions
* Ability to accept "negetable" options (we'll talk about that in a second)

Further, I've gone to the trouble to make sure that a restrictive option like `--color` clearly indicates the acceptable values as well as the default.  Finally, I've made sure that all options are available in short-form (for easy typing on the command line) and long-form (for clarity when scripting and configuring our app).

Here's the code that makes this happen (if you aren't familiar with methadone, the method `on` behaves almost exactly like the `on` method in `OptionParser`):

```ruby bin/hl
#!/usr/bin/env ruby

require 'optparse'
require 'methadone'
require 'hl'

class App
  include Methadone::Main
  include Methadone::CLILogging

  main do |keyword,*filenames|
    # main logic here
  end

  description "Highlight terms in output without grepping out lines"

  options[:color] = 'yellow'
  colors = ['red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white']
  on("-c COLOR","--color","Color to use for highlighting",colors,"(#{colors.join('|')})")
  on("--[no-]bright","-b","Use bright colors")
  on("--[no-]inverse","-n","Inverse highlight")
  on("--[no-]underline","-u","Underline highlight")
  on("--regexp PATTERN","-p","Search term as explicit option")
  on("--[no-]ignore-case","-i","Ignore case in match")

  arg :search_term, :optional
  arg :filename, :optional

  version Hl::VERSION

  defaults_from_env_var 'HL_OPTS'

  go!
end
```

Methods like `arg`, `version`, and `description` are helpers from methadone (see the [intro][methadone_intro] for more), but note how *little* code it takes just to make a great and polished UI. 

The second part of a helpful app is to include more detailed documentation.  For a command-line app, this is expected to be in the form of a man page.  If you installed `hl` with RubyGems, try this:

```sh
$ gem man hl
```

You should see a nicely formatted man page!  Creating a man page is extremely simple thanks to [ronn][ronn].  `ronn` converts Markdown to troff, the format used by the man system.  Just add this to your Rakefile:

```ruby Rakefile Snippet
require 'methadone'
require 'fileutils'

include Methadone::SH
include FileUtils

task :man do 
  sh 'ronn --markdown --roff man/hl.1.ronn'
  mv 'man/hl.1.markdown','README.md'
end
```

And, your gemspec just needs:

```ruby Gemspec
  s.add_development_dependency('ronn')
  s.add_dependency('gem-man')
```

You'll also need to include the generated file `man/hl.1` in your `files` in your gemspec, but if you're using the gemspec created by Bundler, this happens automatically as long as the file is in source control.

That's *it*.   Now your app has a great UI *and* a man page, and all you had to do was drop a few lines of code and write a short Markdown file.

## Play well with others

An app that "plays well with others" on the command line, basically means that it acts as a _filter_: text comes in, and text comes out.  The expectation is that text from any other "well playing" program can be input into our program, and that our program's output can be piped into another program as input.

Since the purpose of our app is to add ANSI escape codes to the output for assistance with _human_ visual scanning, we can't claim that our _output_ plays well with others; it's not designed to.  But, we can still play well with the output from _other_ apps.

We saw that `hl` was designed to take input from a tool like `grep`.  `hl` can also highlight terms from any number of files given to it on the command line.  You can do this transparently in Ruby using the awesome [ARGF][argf], however Methadone doesn't support ARGF (a sad fact I learned while writing this app, and something [I'll address][argfbug] in the near future), so here's how did it (a few comments added to indicate what's going on):

```ruby Treating STDIN and a file list as the same source of data
# filenames is a possibly empty list of strings
files = if filenames.empty?
          [STDIN]
        else
          filenames.map { |_| File.open(_) }
        end
# files is now an Array of open IO objects
begin
  # highlighting code
ensure
  # we close the files since we didn't open them in "block" form; closing STDIN is OK to do
  # since we know our app will soon exit
  files && files.map(&:close)
end
```

Again, ARGF handles this transparently, but the point is, we want the standard input and a provided list of files to be treated the same by our program, and this is how I did it.

## Delight Casual Users

This is a "level up" from "being easy to use".  The idea behind the term "delight" is to provide a level of polish and attention to detail that your users will appreciate if they're observant, but hopefully not even notice, because your app "just works".

`hl` is similar in concept to `grep`.  Knowing this, I chose my command-line options carefully.  Initially, I had the short-form of `--inverse` as `-i`.  When I later added the ability to do a case-insensitive match, I realized that `-i` is the option to `grep` for "case-insensitive".  I quickly changed `--inverse` to have `-n` as its short-form, and made `-i` and `--ignore-case` the options for case-insensitivity.  These are the same values that `grep` uses, so a user who might subconciously type `hl -i` expecting a case-insensitive match will get it.

Further, I allowed the user to specify the search term either as a command-line argument, or as the argument to `-p` or `--regexp`, which are the option names `grep` uses.  It's a basic principle of design that things that are the same should be _exactly_ the same, so I used `grep` as my guide when `hl` implemented similar features.

## Make Configuration Easy

In the book, I talk about using YAML as a configuration format for an `.rc` file.  This can be very useful for complex apps, but another technique that's handy is to allow an environment variable to hold default options.  `grep` does this via `GREP_OPTS` and if you were paying attenion, you noticed this line in `bin/hl`:

```ruby
  defaults_from_env_var 'HL_OPTS'
```

This tells methadone to look at the environment variable `HL_OPTS` for any options as well as the command line.  These options are placed first in `ARGV`, essentially like so:

```ruby Putting command-line options from the environment into ARGV
String(ENV[@env_var]).split(/\s+/).each do |arg|
  ::ARGV.unshift(arg)
end
```

(Note the use of `String` to make sure that `nil` gets turned into the empty string, saving us an `if` statement).  Methadone does this before parsing `ARGV`.  Using `unshift` means that any options the _user_ specifies will come _after_ those in `HL_OPTS` and therefore take precendence:

    $ export HL_OPTS=--color=cyan
    $ grep foo some_log.txt | hl --color=magenta

This is the same as

    $ grep foo some_log.txt | hl --color-cyan --color=magenta

This is also why I've provided the "negetable" forms.  Suppose you generally wanted inverse:

    $ export HL_OPTS=--inverse

If you wanted to run `hl` _without_ inverse, but there was no negetable option, the only way to turn it off would be to unset the environment variable.  With the negetable forms, it's simple:

    $ grep foo some_log.txt | hl --no-inverse

Since the users command-line options take precedence, things work out, but you can still configure your defaults.

Finally, I'd recommend that you use the long-form options in your configuration.  In other words, if you prefer bright and inverted highlights, do this:

    $ export HL_OPTS='--inverse --bright'

As opposed to

    $ export HL_OPTS=-nb

The second form is more compact, but your configuration is going to be _read_ more than written, and, 6 months from now when you are going through your `.bashrc`, you're going to appreciate seeing things spelled out; you'll know instantly what the configuration does and don't have to wonder about what `-n` means.

# Distribute Painlessly

RubyGems:

    $ gem install hl
    $ hl --help

That is all.

# Test, Test, Test

I wrote `hl` entirely using [TDD][tdd] and entirely using [aruba][aruba].  Here's a sampling:

```cucumber
  Scenario: Highlights with case insensitivity
    Given a file named "test_file" with the word "FOO bar foo" in it
    When I successfully run `hl -i foo ../../test_file`
    Then the entire contents of "test_file" should be output
    But the word "foo" should be highlighted in yellow
    And the word "FOO" should be highlighted in yellow
```

It was very easy to do this, although aruba could use a man page for easier reference.  I had to jump into its source too many times to get reminded of the syntax of the steps it provides.  Aruba also strips out ANSI escape sequences, which made testing `hl` a bit tricky.  There appears to be an option to _prevent_ this, but I couldn't get it to work, so I just used Aruba's internal API:

```ruby asserting highlighted output
Then /^the word "([^"]*)" should be highlighted in (.*$)$/ do |keyword,color|
  # #color is provided by rainbow, which we'll talk about in a bit
  expected = keyword.color(color.to_sym)
  # assert_partial_output and all_stdout are provided by aruba
  assert_partial_output(expected,all_stdout)
end
```

I still recommend aruba and cucumber, as it forces you to think about how users will use your app first, not how to implement it.  In fact, my initial implementation was a big hacky mess of stuff inside the `main` block.  Once the tests were in place, I refactored it to be a lot cleaner.

## Be Easy to Maintain

As I just mentioned, I was able to use my tests to refactor my code.  As such, the main block of `hl` is pretty simple:

```ruby main block in hl
main do |keyword,*filenames|
  if options[:regexp]
    Array(filenames).unshift(keyword)
    keyword = options[:regexp]
  end

  exit_now! 'search term or --regexp/-p required' if keyword.nil?

  keyword = keyword.dup
  highlighter = Hl::Highlighter.new(options)

  puts highlighter.highlight(filenames,keyword)
end
```

This is the sort of logic you want in your `main` block:

* Handling the keyword-from-argument and keyword-from-command-line-option case
* Simple error checking
* Duping the keyword (since it comes in frozen)
* Calling our Highlighter

We defer all non-UI logic to the `Highlighter` class.  I decided to make each instance of the class able to highlight any files repeatedly based on a configuration, so the constructor takes in the formatting options, and the method `highlight` takes the list of filenames and the search term.

The actual highlighting is made possible via lots of list comprehension:

```ruby Learn you some list comprehensions
files.map { |_| _.readlines}.flatten.map { |_| highlight_matches(regexp,_) }.join("")
```

If you aren't comfortable with this use of chained calls, it can be very powerful.  What this does is:

* Map each file to an array of its contents as lines.  `[foo,bar]` becomes `[ ['first line of foo\n','second line of foo\n'],['first line of bar\n'],['second line of bar\n']]`
* Flatten that array of arrays to just one list of all lines of all files.  Our example array becomes: `[ 'first line of foo\n','second line of foo\n','first line of bar\n','second line of bar\n']`
* map those lines to the lines with the search term highlighted.  Supposing we wanted to highlight the word "line", our array becomes: `[ 'first \e[33mline\e[0m of foo\n','second \e[33mline\e[0m of foo\n','first \e[33mline\e[0m of bar\n','second \e[33mline\e[0m of bar\n']`
* join them all together into one big string
`"first \e[33mline\e[0m of foo\nsecond \e[33mline\e[0m of foo\nfirst \e[33mline\e[0m of bar\nsecond \e[33mline\e[0m of bar\n"`

Granted, this approach will probably have trouble with extremely large input, but `hl` was designed to work with the output of `grep`, so hopefully we won't have too much.  For me, this was The Simplest Thing That Could Possibly Work, so I'm keeping it for now (another advantage for ARGF users is that it makes a "streaming" implementation a lot easier).  

## Color

Color and formatting *are not* typically associated with awesome command-line apps; too much makes an app hard to use with other apps.  But, the whole purpose of `hl` is to colorize output, so for that I used [rainbow][rainbow], which is a pretty
simple enhancement to `String` that allows coloring and formatting.  We can see it in action in the `highlight_string` method of `Highlighter`:

```ruby highlight_string
def highlight_string(string)
  string = string.color(@options['color'].to_sym)
  string = string.inverse if @options[:inverse]
  string = string.bright if @options[:bright]
  string = string.underline if @options[:underline]
  string
end
```

Each method called on `string` is a method provided by Rainbow.  These methods return a new string with the appropriate ANSI escape codes added.

## In Conclusion

I hope this has been informative.  Keep in mind that I was able to write `hl` in just a few hours, using TDD and the end result is a highly polished, well-documented, easily installable and maintainable piece of software that will be a part of my command-line arsenal for quite a while.  You can do this, too.  It's pretty easy.  Lots of details and in-depth explanations are [in my book][clibook], which you should buy right now :)


[clibook]: http://bit.ly/cli-hl-blog-post
[work]: http://www.livingsocial.com
[hl]: https://github.com/davetron5000/hl
[toc]: http://www.awesomecommandlineapps.com
[methadone]: https://github.com/davetron5000/methadone
[optionparser]: http://ruby-doc.org/stdlib-1.9.3/libdoc/optparse/rdoc/OptionParser.html
[ronn]: https://github.com/rtomayko/ronn
[argf]: http://ruby-doc.org/core-1.9.3/ARGF.html
[argfbug]: https://github.com/davetron5000/methadone/issues/34
[tdd]: http://en.wikipedia.org/wiki/Test-driven_development
[aruba]: https://github.com/cucumber/aruba
[rainbow]: https://github.com/sickill/rainbow
[methadone_intro]: http://www.naildrivin5.com/blog/2011/12/19/methadone-the-awesome-cli-library.html
