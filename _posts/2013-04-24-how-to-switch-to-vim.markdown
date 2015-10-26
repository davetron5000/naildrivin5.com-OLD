---
layout: post
title: "How to switch to Vim"
date: 2013-04-24 09:38
feature: true
---

From time to time, I see people in my twitter stream attempting to switch to Vim.  This is a
good thing.  The problem is that they appear to be viewing the switch as swapping out one
tool for another.  

This is not what switching to Vim means, nor is it a good reason to switch.

The reason to switch to Vim is to _work better_.  I realize "better" is subjective, but
whatever way _you_ define it is what it means - code faster, edit text more easily, automate
your workflow, whatever.

As such, switching to Vim is to _throw out_ your old editor (or plan to) and replace it with
a _different tool_ that works differently and is, hopefully, better.  Stop asking for "a
plugin that does XXX like Sublime Text does things".  If Sublime Text has a plugin for what
you want, you don't need Vim.  Vim might very well have a plugin that does whatever XXX is,
but it's more likely that you don't need a plugin, or that Vim provides a way to
accomplish your _real_ goal much more efficiently.

Here's how to make the move.

<!-- more -->

First, you aren't going to learn much Vim from this.  There are tons of great tutorials about
how to actually _use_ Vim.  You will, of course, need those to switch to Vim, but you'll also need
a bit of a plan.  This is that plan.

1. Run stock at first.
2. Ease into it.
3. Learn to install and remove extensions.
4. Add configuration and extensions only when needed.

## Run stock at first

Don't install Janus.  Don't install someone's dotfiles.  Don't install anything but Vim.  Vim is hard enough to learn without dealing with someone else's idea of a good
editing environment.  Remember, your goal is to edit text (and code) better.  You'd be surprised at just how easy that is with a vanilla install of Vim and a bit of elbow grease.

It's also important that, when learning Vim, you learn it from first principles.  You need to know in your heart of hearts that Vim editing is all about combining movements with actions.  It's like playing a musical instrument.  

To learn to play guitar, you should grab an acoustic and a chordbook.  You should *not* get a Marshall half-stack, vintage pedalboard, and Gibson Custom Shop Les Paul Slash Special Signature Edition.  In all honesty, you're likely to find out a Fender Strat works just fine with a good distortion pedal, so don't start off with a bunch of crap in your `~/.vim` directory.

## Ease into it

You don't want to uninstall Chocolat (or whatever) and jump into your next coding assignment with Vim.  At least not at first.  That will be bad for you and your company.  Instead, tell your operating system that henceforth, all text files, Markdown files, Asciidoc files and any other text-like format shall be edited in Vim.  Then, proceed to use Vim only for editing _text_.

Although editing text doesn't benefit from many of Vim's amazing plugins and features, it requires _just enough_ for you to "level up" and get better at editing text. Before you know it, you'll be deleting words, moving the cursor with search, creating abbrevations and all the other great stuff that makes Vim Vim, but in a safe, easy environment of text editing.  If you don't edit a lot of text, shame on you.  You should write more.  It's good for you.

Now, don't just go into insert mode and cursor around like you're in Notepad.  This is where
those tutorials and references come in.  Follow them and use them.  My advice is:

* When you get a thought down, hit escape to go to command mode<a name="back-1"></a><sup><a href="#1">1</a></sup>.  A.B.C. Always Be in Command Mode.  A, Always, B, Be, C, in Command Mode.  You enter command mode mode or you hit the bricks.
* When are ready to type, enter insert mode and type.  Then hit escape when you are done.  A.B.C.
* Before touching the mouse, the cursor keys, the backspace key, or the delete key, ask yourself what you are *really* trying to do.  Are you *really* deleting 10 characters that
  are all adjacent to each other or are you deleting a word?  Are you *really* moving down 12 lines or are you going to the next paragraph?
* Stop thinking about characters and lines.  Think in words, sentences, paragraphs, tokens, blocks.  You are learning the Weirding Way, here.  Visualize where you want the cursor to go, and make it go there.  If you repeated a keystroke to do it, _try harder_.

Eventually, you will start to discover things you want to improve about your setup.  Almost always, they can be fixed by mapping new commands or adjusting configuration.  The Vim help is truly amazing.  Read it.  Like a book.

On occasion, you will need more than what you can achieve with just mappings and configuration.  This is when you *might* benefit from an extension.  You need to know how to easily install (and remove) them.

## Learn to install and remove extensions

I'm gonna get prescriptive here. Just do it this way, and when you get your brown belt, you can switch to something else.  Install [pathogen] and use that to manage your Vim extensions.  Why?

Your `~/.vim` directory (as well as the system Vim directory) has a specific structure organized by a file's meaning _to Vim_.  For example, all syntax files go in one place, and all
help files go in one place, etc.  This means that installing extensions using stock Vim results in a smattering of files all over the place related by Vim function and not by semantic function.  All the Ruby-related files are not in a directory called `ruby`.  It's not good, but you can't expect a 30+ year old editor to have got everything right the first time.

Pathogen solves this by allowing each extension to have its own Vim-like directory structure completely separate from all others.  This is just like a "bundle"-type system in more modern editors.  This means you can easily add and remove extensions with just a few commands.

Here's how to set it up:

```
> mkdir -p ~/.vim/autoload ~/.vim/bundle
> curl -Sso ~/.vim/autoload/pathogen.vim \
    https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
```

Put this at the top of `~/.vimrc`:

```
execute pathogen#infect()
syntax on
filetype plugin indent on
```

This gives you a system in which to manage extensions.  Test it by doing this:

```
> cd ~/.vim/bundle
> git clone git://github.com/nanotech/jellybeans.vim.git jellybeans.vim
> vim some_file
```

Now, in Vim, do `:colorscheme jellybeans` and you should see your colors change (or at least you shouldn't get an error).

*Do not manage plugins by typing `git` commands*.  That was just a test.  We're here to improve things and the way you do that is with a _command line app_.  When you pass the Jedi trials (or cut Darth Maul in half), you can do something fancier, but this at least keeps you from typing a bunch of `git` commands:

```ruby
#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'
require 'open-uri'

options = {}

opts = OptionParser.new do |o|
  o.on("--clean","Delete everything before re-cloning") do
    options[:clean] = true
  end
end
opts.parse!

git_bundles = [ 
  "git://github.com/nanotech/jellybeans.vim.git",
  "git://github.com/tpope/Vim-vividchalk.git",
  # add more here
]

bundles_dir = File.join(File.dirname(__FILE__), "bundle")

FileUtils.cd(bundles_dir)

if options[:clean]
  puts "Trashing everything (lookout!)"
  Dir["*"].each do |d| 
    FileUtils.rm_rf d
  end
end

git_bundles.each do |url|
  dir = url.split('/').last.sub(/\.git$/, '')
  if File.exists?(dir)
    puts "  Skipping #{dir}, as it already exists"
  else
    puts "  Unpacking #{url} into #{dir}"
    `git clone #{url} #{dir}`
    if $?.success?
      FileUtils.rm_rf(File.join(dir, ".git"))
    else
      STDERR.puts "Problem with #{url}"
    end
  end
end
```

I keep this file in `update_bundles` in my `~/.vim` directory (which I keep in version control).  Since this is an [awesome command-line app][clibook], you can do `./update_bundles -h` and get some help.  Start off with `./update_bundles --clean`.  This will delete your one bundle and re-clone it, along with a second bundle. That's the "vividchalk" colorscheme, which I'm not recommending per se, but it's just a second thing you can use to check that you've got everything set up properly.  Do that via `:colorscheme vividchalk`.

To add extensions, place them inside the `git_bundles` hash and run `./update_bundles`.  To remove extensions, remove them from that hash and delete their cloned directory in `~/.vim/bundle`.  That's it.

Of course, with great power, comes great responsibility…to not junk up your bundles
directory with a bunch of stupid plugins you really don't need to write code better.

## Add extensions only when needed

I'm not saying you shouldn't experiment and explore, but you will get the most benefit from Vim by *not* installing plugins that re-create features of the degenerate editor you are trying to get away from.  You're leaving it for a reason.  Install plugins to solve editing and workflow problems you can't get around with what vim gives you.

For example, a lot of people install NERDTree because they like seeing the world's most difficult-to-use tree control from Windows Explorer right there in
ASCII-art form in Vim.  It turns out that controls like this were designed for locating files in a directory structure using a mouse on Windows 95.  

If you think you need this plugin, you may not have thought deeply about the problem you are facing.  Your problem is likely *not* "I need to navigate my project by tree structure and have it constantly there always even though I spend most of my time reading and writing particular code files".  Your problem is "I need to open a particular file more easily".  Vim has many ways to do that that are far better.  

The most degenerate way is to do `:e .` which brings up a file navigator in the current directory.  You can navigate the file system _with Vim_, which is great, but this is still not very efficient.  A better way is to read about `gf` or `:find`, or look into the `CommandT` extension.  All of these allow you to quickly find a file by name or path just by typing.  Typing is fast as hell.

This is just an example, and it's meant to illustrate that you should install extensions to solve _problems_, not to replicate _features of other editors_.  Sometimes they will be same, but often they will not be.

To find plugins, search GitHub.  Do not use Google, use GitHub.  If you find a plugin that you cannot install by having `update_bundles` clone it into your `.vim/bundle` directory, you might not be searching GitHub.  Or, you have a found a plugin that isn't being maintained and you should avoid using it.  Or, you should clone it to GitHub and start maintaining it.

As you get more comfortable, start using Vim for coding.  It will be painful, but at least you'll know how to navigate the project, copy & paste, and have some grasp of what's going, thanks to the grounding in first principles you got while editing plain text files.  

Find the plugin for the programming language you are using.  Read the help to see what it offers and, if it looks useful, install it.  You'll likely want it just to get the syntax highlighting and indentation stuff working.

Finally, share what you've learned with other Vim users.  Especially if they know more Vim than you.  Those conversations will go like this:

* _You_: "Hey, did you know about `#`?  It searches _backward_ for the word under the cursor!!"
* _Vim Master_: "Yes!  I love that command.  Do **you** know about `?`?  It repeats your last search backward.  `n` does the same forward!"

And then you learn something.  On occasion, the Vim grand master will learn something from you.  Vim just keeps on giving.  It's like that.  Vim users are never short of a few tips to share, and as smug as they are around Emacs users, and as arrogant as they are around _IDE_ users, they will be super-kind to anyone learning Vim.

So, go forth and switch! Run stock, then ease into it, then learn about pathogen, and then start leveling up.
The next time you find yourself in Microsoft Word staring at a row of j's, you'll know you've made the switch.

----

<footer class='footnotes'>
<ol>
<li>
<a name='1'></a>
<sup>1</sup>Yes, I realize most call it “normal” mode.  It <strong>should be</strong> the mode you are normally in.  That's the point, but I call it command mode, and I really wanted to make a Glengarry Glen Ross reference.<a href='#back-1'>↩</a>
</li>
</ol></footer>
[pathogen]: https://github.com/tpope/vim-pathogen
[clibook]: http://www.pragprog.com/titles/dccar
