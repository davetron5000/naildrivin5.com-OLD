--- 
title: Introducing Methadone, the Awesome Command-Line Library
layout: post
---

I've spent the last year [writing a book][book] on building awesome command-line applications in Ruby.  Over the course of
writing it, I've used a lot of Ruby libraries for building command-line apps, and none of them work quite right.  In my book, I
spent significant time on [OptionParser][optparse], since it's builtin, and [GLI][gli], since I wrote it (and since it's actually very
fully-featured compare to the alternatives).

I just finished up an appendix where I showed alternate implementations of the running examples using [main][main], [thor][thor], and [trollop][trollop].  I did this for a few reasons:

* These tools are popular, and people have asked if they'd be included
* They are, by and large, very different from how `OptionParser` and GLI work
* I wanted to give them a real shakedown

I also surveyed many other tools, but, alas, I couldn't include everything.  Each of these tools have a common theme, which is to
avoid the boilerplate of `OptionParser`, and make it really easy to parse command-line arguments.  They all have done this, but at 
a cost.  All of them are less powerful and extensible than `OptionParser`, and only slightly more compact (or, in the case of
main, more verbose).

Enter [methadone][methadone], which has all of `OptionParser`'s power, but the compactness of these other frameworks.

<!-- more -->

## Another command-line option parser?

Yes and no.  Methadone isn't a re-implementation of command-line option parsing.  It's barely a DSL, making use of almost no
meta-programming, `class_eval`, or other craziness.  It's a plain Ruby proxy to `OptionParser`, with some helper methods.  It makes
idiomatic option parsing and command-line app design as seemless as possible, but doesn't force *any* of itself on
you.  In this post, I'll derive its syntax while showing you the basics of how to structure a simple command-line app.  
You'll have to [buy the book][book] to dig deeper<a name="back-1"></a><sup><a href="#1">1</a></sup>.

## Basic Command-line App Structure

Most command-line apps start off with parsing the command-line with `OptionParser` (which typically consists of setting values into
some `Hash`), defining a few helper methods, and then, at the end, implementing the main logic of the program:

```ruby
#!/usr/bin/env ruby

require 'optparse'

options = {}

parser = OptionParser.new do |opts|
  opts.banner 'My awesome app'
  
  opts.on("-u USERNAME","--username","The username") do |user|
    options[:username] = user
  end

  opts.on("-v","--verbose","Be verbose") do 
    options[:verbose] = true
  end

  # etc.

end

parser.parse!

def some_helper_method
end

def some_other_helper_method

puts "Starting program" if options[:verbose]

# etc, the main logic of your program
```

Yuck.  The boilerplate option parsing is bad enough, but the structure is all wrong.  The interesting stuff is all the way at the bottom; you have to read the thing in the wrong order.  At the very least, you should extract the core logic into a `main` method, put that at the top, and call it at the end.

```ruby
#!/usr/bin/env ruby

require 'optparse'

def main(args)
  # main logic of your app
  0 # or return nonzero if something went wrong
end

def some_helper_method
end

def some_other_helper_method

puts "Starting program" if options[:verbose]

options = {}

parser = OptionParser.new do |opts|
  opts.banner 'My awesome app'
  
  opts.on("-u USERNAME","--username","The username") do |user|
    options[:username] = user
  end

  opts.on("-v","--verbose","Be verbose") do 
    options[:verbose] = true
  end

  # etc.

end

parser.parse!

exit main(ARGV)
```

Now, we can see, immediately upon opening the file, the main thing this app is doing.
Of course, an exception might be raised.  We may even do it on purpose, but we can't have the app vomiting a stack trace to the user, so we wrap our call to `main` in a `begin..rescue` block:

```ruby
begin
  exit main(ARGV)
rescue => ex
  STDERR.puts ex.message
  exit 1
end
```

## Methadone's Main Method

The structure we just saw is pretty decent, and gives us, and future contributors, an easy way to follow the code.  Users also
get a pretty decent experience and never have to see a backtrace.

This brings us to the first feature of methadone.  Instead of including this boilerplate every time, we extract it into a module, 
`Methadone::Main`, which gives us two methods: `main` and `go!`.

`main` takes a block that represents our main method from before.  `go!` calls that block, handling the exceptions for us.  Our app now looks
like so:


```ruby
#!/usr/bin/env ruby

require 'methadone'

include Methadone::Main

main do |args,go,here|
  # main logic
  # raise exceptions at will
end

# declare options and helper methods as before

go!
```

`go!` will extract the contents of `ARGV` leftover after parsing and pass them to the block.  Since they're passed as individual arguments, you don't have to call `shift` a bunch of times on some array.  Just name your parameters whatever, and Metahdone takes care of it.   If your main block raises an exception, `go!` will handle catching it, messaging the user without a backtrace, and exiting nonzero<a name="back-2"></a><sup><a href="#2">2</a></sup>.

## Parse Options with no Loss of Power

Notice how we can still safely use `OptionParser`.  Methadone doesn't hide that.  As we'll see, it provides some more features to make option
parsing even easier.  First, we can get rid of the `options` `Hash` as well as the actual creation of the `OptionParser` instance.

Methadone provides two methods: `options` and `opts`.  `options` provides access to a `Hash` that we can use inside our `main` block.  `opts`
provides access to the underlying `OptionParser` instance that is automatically created.  We can now remove a few lines of code, losing *no*
functionality:

```ruby
opts.banner 'My awesome app'

opts.on("-u USERNAME","--username","The username") do |user|
  options[:username] = user
end

opts.on("-v","--verbose","Be verbose") do 
  options[:verbose] = true
end
```

Given that `opts` is baked in, there's no need to even use that for our cases, because Methadone provides a method `on` that proxies to the
underlying `OptionParser`.  You can still use `opts` to access anything else, but for declaring command-line options, just call `on`
directly:

```ruby
opts.banner 'My awesome app'

on("-u USERNAME","--username","The username") do |user|
  options[:username] = user
end

on("-v","--verbose","Be verbose") do 
  options[:verbose] = true
end
```

You can see, as we peel off layers of boilerplate, Methadone hides nothing; it's just making commonly-written code easier to write. At any time,
you can abandon it and go back to the old way.  

So far, we've only saved a few lines of code and a couple of characters.  That's because we haven't seen the true power of the `on` method.
`on` is more than just a proxy to `OptionParser`.  It does one additional thing for us:  it we omit the block, Methadone will provide one 
for us.  That Methadone-provided block simply sets the value from the command-line in the
`options` `Hash` automatically.  Meaning that the above code is equivalent to this:

```ruby
opts.banner 'My awesome app'

on("-u USERNAME","--username","The username")
on("-v","--verbose","Be verbose")
```

Not bad!  This means that *all* we need to do, assuming we're doing things idiomatically, is to give `on` the names of our options and their
descriptions.  Note, however, this *still* proxies to `OptionParser`'s `on` method.  Suppose we only allowed usernames with all lower-case
characters?  In Methadone, as in `OptionParser`, you pass in a `Regexp`:

```ruby
on("-u USERNAME","--username","The username",/^[a-z]+$/)
on("-v","--verbose","Be verbose")
```

Suppose you want the value type-converted for you?  We have access to the underlying `OptinParser`, so we can set that up easily:

```ruby
opts.accept(User) do |username|
  User.find_by_name(username)
end

on("-u USERNAME","--username","The username",User)
on("-v","--verbose","Be verbose")
```

## Do the Right Thing

You've noticed that we are still setting our banner manually.  You've also noticed our banner is kinda lame;  It doesn't say what our app
does nor does it give an overview of how to use it.  It should look like so:

    $ awesome_app.rb --help
    Does so many awesome things, you won't believe it.

    Usage:  awesome_app.rb [options] thing other_thing [optional_thing]

Since Methadone knows that our app takes options (by virtue of us having declared them), and it knows the name of
our app, we just need to tell it what our app does, and it will assemble the banner for 
us<a name="back-3"></a><sup><a href="#3">3</a></sup>.

```ruby
main do |thing,other_thing,optional_thing|
  # logic
end

on("-u USER","--username","The user name")
on("-v","--verbose","Be verbose")

description "Does so many awesome things, you won't believe it."

go!
```

Finally, you'll note that our `main` block takes three arguments.  Methadone provides the method `arg` that allows us to name them (in the language the user will understand) and indicate which are required and which are optional. Methadone will put this information into the banner, and will fail if any required arguments are missing:

```ruby
main do |thing,other_thing,optional_thing|
  # logic
end

on("-u USER","--username","The user name")
on("-v","--verbose","Be verbose")

description "Does so many awesome things, you won't believe it."

arg :thing
arg :other_thing
arg :optional_thing, :optional

go!
```

Now, the banner looks like we'd like it, and we didn't have to do much more than describe our program.  You can
even bootstrap your app using the `methadone` command-line app.  It will create an empty app, using this structure, with
some helpful comments to let you describe your UI easily and quickly.  But it won't prevent you from doing any sort of crazy thing with
`OptionParser` that you need to.


## Sweet, Sweet Sugar

But wait!  There's more!  Complex programs start to look like this:

```ruby
if have_connection
  # puts "got a connection"
  file = request_data
  puts "Got data"
  if file.nil?
    STDERR.puts "Data was nil?"
  end
end
# puts "Moving on"
```

You've got a mix of commented-out debug statements, informational messages and tediously long statements sending error messages to the
standard error.  Methadone includes a special `Logger` instance, along with some helper methods, that does away with all this:

```ruby
include Methdone::CLILogging # sets up Logger, provides helper methods

if have_connection
  debug "got a connection"   # Calls logger.debug 
  file = request_data
  info "Got data"            # Calls logger.info
  if file.nil?
    error "Data was nil?"    # Calls logger.error
  end
end
debug "Moving on"            # Calls logger.debug
```

The logger is set up as follows:

* `debug` messages don't go anywhere.  
* `info` goes to the standard output.
* `warn`, `error`, and `fatal` go to the standard error.  
* Log messages are _unformatted_ when logged to a TTY
* Log messages are formatted with timestampes, levels, etc, when logged to a file

This means that for command-line use, the user sees messages formatted for them, and not horrible Maven-style enterprise logging.  As soon as
you use your app in `cron`, however, the logger senses the absence of a TTY and switches its format to this style, so that the log files *do*
have that valuable information.

You have complete access to the logger via `logger` and `logger=`, so you can ultimatley do whatever you want.

`Methdone::CLILogging` is included in `Methdone::Main`, so, if you followed the structure above, you have access to the logger and these
methods.

## Is there more?

In addition to all of this, Methadone provides some [Cucumber][cucumber] step definitions, based on [Aruba][aruba] that allow you to
test-drive your command-line app.  When you bootstrap your app using `methadone`, this will be set up for you.

I'm planning a few more things before v1.0.0, so checkout the [roadmap][roadmap] for more info.

And, don't forget the [buy the book][book]

----

<footer class='footnotes'>
<ol>
<li>
<a name='1'></a>
<sup>1</sup>Never fear, if you don't like Methadone, it only takes up a few scant pages at the end.<a href='#back-1'>↩</a>
</li>
<li>
<a name='2'></a>
<sup>2</sup>You can, of course, set <code>DEBUG</code> in the environment and a methadone-powered app <em>will</em> dump the stack on an exception.<a href='#back-1'>↩</a>
</li>
<li>
<a name='3'></a>
<sup>3</sup>Of course, you can continue to use <code>opts.banner=</code> to set your own if you like.<a href='#back-1'>↩</a>
</li>
</ol></footer>

[book]: http://www.awesomecommandlineapps.com
[optparse]: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/optparse/rdoc/OptionParser.html
[gli]: https://github.com/davetron5000/gli
[main]: https://github.com/ahoward/main
[thor]: https://github.com/wycats/thor
[trollop]: http://trollop.rubyforge.org/
[methadone]: https://github.com/davetron5000/methadone
[gogaruco-talk]: http://confreaks.net/videos/638-gogaruco2011-test-drive-the-development-of-your-command-line-applications
[aruba]: https://github.com/cucumber/aruba
[cucumber]: https://github.com/cucumber/cucumber
[roadmap]: https://github.com/davetron5000/methadone/wiki/Roadmap
