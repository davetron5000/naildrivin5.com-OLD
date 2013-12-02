---
layout: post
title: "&#10106;&#10144; Introduction to GLI"
date: 2013-11-23 12:41
comments: true
categories: 
---

Sitepoint recently published [Introduction to Thor][thor-intro] and, to be honest, I don't think Thor is a great tool for writing
command-line apps.  Thor is a great for writing Rails generators (likely the only reasonable tool), but I wrote GLI
specifically because I wanted a tool tailor-made to write awesome command-line apps.  

With the re-release of [my book][dccar2], which uses GLI to demonstrate how to build amazing command-line apps in Ruby, I thought
I'd mimic Sitepoint's post with a GLI version, and let you decide for yourself.

<!-- more -->

## What is GLI?

GLI is a Ruby library designed to make writing a "command-based" application (which I call a "command suite")
very easy.  It's designed to make the simple things simple, but to not hide anything from the developer.

I won't go back to getopt, but a fairly common way to create a command suite application is to use `OptionParser` to get command
line options, and then parse `ARGV` directly to figure out the "command":

```ruby
include "optparse"

options[:file] = "~/.todo"

opts = OptionParser.new do |opts|
  # declare a new options
  opts.on(
      "-f FILE","--file", # it can be -f or --file and requires an argument
      "Location of the todo list file (default ~/.todo)") do |file|
    options[:file] = file # when the user specifies it, save the argument in options[:file]
  end

  opts.on(
      "-l","--long",
      "List todo elements in long form") do |long|
    options[:long] = long
  end

  opts.on(
      "-a","--all",
      "List all todos, not just ones that haven't been completed") do |all|
    options[:all] = all
  end
end

opts.parse!  # parse the options, modifying ARGV

command = ARGV.shift

case command do
when 'new': 
  # Add a new todo to options[:file]
when 'done'
  # complete a todo and rewrite options[:file]
when 'list'
  # use options[:all] and options[:long] to output
  # the todo list in options[:file]
else
  # Print help
end
```

There are a few problems with this:

* The `--all` and `--long` options are only relevant to the `list` command
* There's no explicit documentation of the commands - we have to hope that the generic help will tell us what they do
* The option handling code is very duplicative and boilerplate
* Making this robust is tricky - if the user passes wrong options, we'll get a bad message

These are problems solvable by a framework more sophisticated than `OptionParser`

## First Steps with GLI

Typically, a new GLI app is generated for you by the `gli` command-line app:

```
> gem install gli
Fetching: gli-2.8.1.gem (100%)
Successfully installed gli-2.8.1
> gli init todo new done list
> cd todo
> bundle install
> bundle exec bin/todo help
NAME
    todo - Describe your application here

SYNOPSIS
    todo [global options] command [command options] [arguments...]

VERSION
    0.0.1

GLOBAL OPTIONS
    -f, --flagname=The name of the argument - Describe some flag here (default: the default)
    --help                                  - Show this message
    -s, --[no-]switch                       - Describe some switch here
    --version                               - Display the program version

COMMANDS
    done - Describe done here
    help - Shows a list of commands or help for one command
    list - Describe list here
    new  - Describe new here
```

OK, so what happened?  We haven't written any Ruby code, but we ran some commands, and had to use bundler.

GLI makes a few assumptions about how you want to work:

* You want a canoncially set-up Ruby project structure
* You want to write tests
* You want to distribute via RubyGems

None of these are requirements for GLI, so you could just as easily `gem install gli` and get to work.  The reason we are using
Bundler is because `bin/todo` does *not* hack the load path to load our files in `lib`.  At runtime, RubyGems will configure the
load path for our users, so everything in `lib` will be available.  In development, we don't have that, so we use Bundler, which
does the same thing.  You could also do `RUBYLIB=lib bin/todo help` if you prefer.

Back to our app, you'll notice that we have an application that produces a pretty decent help system already, so what does the code look like?

```ruby
#!/usr/bin/env ruby
require 'gli'
require 'todo'

include GLI::App

program_desc 'Describe your application here'

version Todo::VERSION

desc 'Describe some switch here'
switch [:s,:switch]

desc 'Describe some flag here'
default_value 'the default'
arg_name 'The name of the argument'
flag [:f,:flagname]

desc 'Describe new here'
arg_name 'Describe arguments to new here'
command :new do |c|
  c.desc 'Describe a switch to new'
  c.switch :s

  c.desc 'Describe a flag to new'
  c.default_value 'default'
  c.flag :f
  c.action do |global_options,options,args|
    puts "new command ran"
  end
end

desc 'Describe done here'
arg_name 'Describe arguments to done here'
command :done do |c|
  c.action do |global_options,options,args|
    puts "done command ran"
  end
end

desc 'Describe list here'
arg_name 'Describe arguments to list here'
command :list do |c|
  c.action do |global_options,options,args|
    puts "list command ran"
  end
end

pre do |global,command,options,args|
  true
end

post do |global,command,options,args|
end

on_error do |exception|
  true
end

exit run(ARGV)
```

Since we specified `new done list` on the command line to `gli init`, it went ahead and created command blocks for us.  Notice
that each command block is configured in the style of rake - we describe the command, document its arguments, and declare that
it exists.  You'll notice that each command has a generic `puts` in it, so we can see how our new app works right now:

```
> bundle exec bin/todo list
list command ran

> bundle exec bin/todo done
done command ran
```

We can also get help for particular commands already:

```
> bundle exec bin/todo help list
NAME
    list - Describe list here

SYNOPSIS
    todo [global options] list Describe arguments to list here
```

Not bad for having written absolutely no code!

## Filling it in

Let's replace the boilerplate with what we need for our todo list app.

```ruby
desc 'Location of todo file'
default_value '~/.todo'
arg_name 'path_to_file'
flag [:f,:file]

desc 'Create a new todo item'
arg_name 'text_of_todo'
command :new do |c|
  c.action do |global_options,options,args|
    todo = args.join(' ')
    # Add todo to the file at global_options[:file]
  end
end

desc 'Complete a todo'
arg_name 'todo_id'
command :done do |c|
  c.action do |global_options,options,args|
    id = args.shift
    # Locate id in global_options[:file] and mark it completed
  end
end

desc 'List todo items'
command :list do |c|
  c.desc 'Use long format'
  c.switch [:l,:long]

  c.desc 'Show all items, even uncompleted ones'
  c.switch [:a,:all]

  c.action do |global_options,options,args|
    # Read todos from global_options[:file]
    # and then use options[:long] and
    # options[:all] to figure out what
    # to display
  end
end
```

Basically, we've just replaced boilerplate text with our app-, command-, and option-specific help text.  We also removed the
example flags and switches and replaced them with the ones we'll actually need.

Notice that we specified `--file` outside of any command block, thus making it a global flag.  This is because all commands need access to the todo file.  Note also that the options `--long` and `--all`, which are specified inside the `list` command block, will only be available for the `list` command.

```
> bundle exec bin/todo help 
NAME
    todo - Describe your application here

SYNOPSIS
    todo [global options] command [command options] [arguments...]

VERSION
    0.0.1

GLOBAL OPTIONS
    -f, --file=path_to_file - Location of todo file (default: ~/.todo)
    --help                  - Show this message
    --version               - Display the program version

COMMANDS
    done - Complete a todo
    help - Shows a list of commands or help for one command
    list - List todo items
    new  - Create a new todo item

> bundle exec bin/todo help new
NAME
    new - Create a new todo item

SYNOPSIS
    todo [global options] new text_of_todo

> bundle exec bin/todo help list
NAME
    list - List todo items

SYNOPSIS
    todo [global options] list [command options] 

COMMAND OPTIONS
    -a, --[no-]all  - Show all items, even uncompleted ones
    -l, --[no-]long - Use long format
```

Notice how we see the documentation relevant to the command, and not in one global space?  Handy.

What I like about this design is that, although it's not "object-oriented", it's obvious and clear.  A command-line
interface isn't OO, it's declarative and command-oriented, so it makes sense to me that we describe our UI in the same way.

Also notice the structure of the command line.  In a Thor app, all command-line options must come at the end of the command line.
In a GLI app, the position of the switches determines their interpretation.

```
> bin/todo -f ~/.todo.txt -l list
error: Unknown options -l
> bin/todo list -l -f ~/.todo.txt
error: Unknown option -f
> bin/todo -f ~/.todo.txt list -l
# lists in long form from ~/.todo.txt
```

This creates namespaces for our options, which allows the creation of a rich user interface, if needed. I borrowed this design
from `git` (and, in fact, GLI stands for "Git-Like Interface").

Our application code would likely *not* live inside this file, but instead be delegated to classes located under `lib`, designed
and unit tested as you would in any application.  The file generated by `gli init` is already primed to look there.

## Digging Deeper

This example only scratches the surface.  Let's go over a few different handy features for managing our command suite.

### Powerful option parsing

It's usually good practice for switches (options that take no arguments) to have both a positive and "negative" version.  For
example, we'd want to be able to use `--no-long` or `--long`, as appropriate.  You can see from our help output that GLI supports this by default.  If the user
specifies `--no-all` on the command line, `options[:all]` will be false.

GLI makes this work because it's using `OptionParser` underneath.  This opens up some other powerful features.  

Suppose we want to give our new todo items a "category" and that we want to require the category to be one of "chore", "feature", or "bug".   The naive approach would be to examine `options[:category]` inside our `action` block and raise an error if it's not one of the three allowed values, GLI, via `OptionParser`, provides this for us:


```ruby
command :new do |c|
  c.desc "The category of the new todo"
  c.default_value 'chore'
  c.flag :category, must_match: %w(chore feature bug)

  # ...

  c.action do |global_options, options, args|
    # options[:category] will always be one of chore, feature, or bug
  end
end
```

`must_match` takes a wide variety of values, including an `Array`, `Hash`, or `Regexp`.

Flags also accept the option `:type` that can be used to do a type conversion.  `OptionParser` has some [conversions built-in](http://ruby-doc.org/stdlib-2.0.0/libdoc/optparse/rdoc/OptionParser.html), but we could do very sophisticated things if we wanted to:

```ruby
accept(Todo::Type) do |string|
  Todo.const_get(string.capitalize)
end

command :new do |c|
  c.desc "The type of the new todo"
  c.default_value 'chore'
  c.flag :type, must_match: %w(chore feature bug), type: Todo::Type

  # ...

  c.action do |global_options, options, args|
    # options[:type] will always be Todo::Chore, Todo::Feature, or Todo::Bug
  end
end
```

Nice!

### Default Values

You've probably noticed `default_value` being used.  This not only documents in our help text what the default of a flag is, but
it's also the default value in `global_options` or `options`.  You don't have to manage it yourself.

### Aliases

By default, GLI will identify a command based on the shortest unambiguous string.  In our case, `bundle exec bin/todo n` would be
recognized as the "new" command, because no other command starts with "n".

We can also provide explicit aliases by passing an array to `command`, much as we did with our flags and switches:

```ruby
command [:list,:show] do |c|

  # ...

end
```

### Global Hooks

If we were to fill in the three actions with actual code, you'd see that they all have some need to access the to-do list.  We
might create a class like `TodoList` and use it like so:

```ruby
c.command :list do 
  c.action do |global_options,options,args|
    todo_list = TodoList.load(global_options[:file])
    todo_list.tasks.each do |todo|
      puts todo
    end
  end
end

c.command :done do
  c.action do |global_options,options,args|
    todo_list = TodoList.load(global_options[:file])
    todo_list.complete!(args.shift)
    todo_list.save!(global_options[:file])
  end
end

c.command :new do
  c.action do |global_options,options,args|
    todo_list = TodoList.load(global_options[:file])
    todo_list.add(args.join(' ')
    todo_list.save!(global_options[:file])
  end
end
```

This can get repetitive.  Although we have a way to specify that all commands have the flag `--file`, it would be nice if we
could globally translate that filename into a real object and have it managed outside our commands.

That's where `pre` and `post` come in:

```ruby
pre do |global_options,command,options,args|
  $todo_list = TodoList.load(global_options[:file])
  true
end

post do |global_options,command,options,args|
  $todo_list.save!(global_options[:file])
end

c.command :list do 
  c.action do |global_options,options,args|
    $todo_list.tasks.each do |todo|
      puts todo
    end
  end
end

c.command :done do
  c.action do |global_options,options,args|
    $todo_list.complete!(args.shift)
  end
end

c.command :new do
  c.action do |global_options,options,args|
    $todo_list.add(args.join(' ')
  end
end
```

Here, `pre` receives the parsed command and options.  The `pre` block's code will execute before the contents of our `action` block.
`post`, too, receives this information and runs *after* our action block.  Our todo list app commands always have access to the parsed todo list file, and can be sure that any changes they make will
be saved to disk after.

### Subcommands

GLI allows infinitely nested subcommands.  For example, if we wanted to have our `list` command work a bit differently, such as
`todo list done` or `todo list inprogress`, we can model `done` and `inprogress` as subcommands:

```ruby
desc "List todo items"
command :list do |list|

  list.desc "Show only completed items"
  list.command :done do |done|
    done.action do |global_options,options,args|
      $todo_list.completed.each do |todo|
        puts todo
      end
    end
  end

  list.desc "Show only in-progress items"
  list.command :inprogress do |done|
    done.action do |global_options,options,args|
      $todo_list.in_progress.each do |todo|
        puts todo
      end
    end
  end
end
```

Subcommands have their own "option space", so you can create a very sophisticated UI if you need to.

## Conclusion

I've tried a lot of command-line libraries for Ruby and GLI is the most featureful, compact, and powerful one I've seen—I created
it to be that way.  The thing I like about it is that simple applications have simple source code, but if you need more complex
features, they are there for you.  The "shape" of your binfile mimics the shape of your app.  The bootstrapping from `gli init`
also sets you up to have a properly organized, easily distributable application—all hallmarks of an awesome command-line app.

"Build Awesome Command-Line Applications in Ruby 2" is [on sale now][dccar2] (and is a free upgrade for purchasers of the first version).
It covers the generic aspects of command-line development with Ruby, using GLI to demonstrate how to do it with command suites.
It's also a much deeper dive on `OptionParser`, which is a powerful tool you should learn for writing non-command-based
command-line apps.  The appendix covers Thor, Main, and Methadone as well.

[dccar2]: http://pragprog.com/book/dccar2/build-awesome-command-line-applications-in-ruby-2
[thor-intro]: http://www.sitepoint.com/introduction-thor/
