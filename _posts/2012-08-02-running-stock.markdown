---
layout: post
title: "Running Stock"
date: 2012-08-02 09:55
comments: true
categories: 
---

One of my fellow developers asked me the other day if I had any good dotfiles for `bash`.  I realized I don't.  I don't even have `ll` aliased to `ls -l` like most of the known universe.  I realized that I like to run as stock as I can.

<!-- more -->

Here's what I have aliased in `bash`:

```sh
alias vi='mvim'
alias ps='ps auxwwwwwwww'
alias ls='ls -FG'
alias irb=pry
```

That's **it**.  I type `bundle exec` if I have to (and always in anger).  I have a function called `go` that sets up a few things for working on a particular project (e.g. `go gli` before I start working on [gli]), but otherwise, I type the commands as
they come and use whatever options I need at the time, even if I tend to use the same options a lot (e.g. `grep -r`).

Over the years, my muscle memory has evolved around _just using the shell as it is_ and not wound around a lot of customizations.  As such, when I'm tunneled into some production server, or other location where I don't have my dotfiles (such as another
developer's box), I'm almost exactly as proficient as I am in my own environment.

Sure, it takes some probably-measurable amount of time to type `bundle exec` or `ls -l` instead of `bx` or `ll`, but I find I don't spend a lot of my time typing things.  I spend most of it reading and thinking, and there's really no shortcut for that.

Similarly, my global `git` config contains only one alias: `lol`, which shows logs on one line (`log --oneline --graph --decorate`).

My `.vimrc` is a bit of an exception, as I have a fair amount of default configuration overridden, but in terms of mappings, I still don't have that much set up.  I use [pathogen] plugins and know the shortcuts many of them provide (like the amazing [rails.vim][railsvim]), but I don't tend to customize them that much.  Here's all the
mappings I have setup:

```
" cd to directory of current file
map c :cd %:p:h
" open buffer list
map b n\be
" next error
map   :cnext
" fold this line
map f !!fold -w77 -s 
" ^O tries to open the thing under the cursor using gf
map  sgf
" Avoid annoying ^Z minimizing to nowhere
map  
```

Again, that's **it**.  Whenever I'm in `vi`, *anywhere*, I'm 99% effective.

I tend to automate things away when they become annoying, so I guess I don't tend to get annoyed by typing small words into the terminal.  My brain thinks in chunks of words, which is why I dislike abbreviations and acronyms.  They seem like a vestige of
the days when we had to write things instead of auto-complete them.

Anyway, I'd recommend all developers try to run as stock as possible.  I bet you won't be as slowed down as you think, and you won't feel hamstrung in an environment you can't totally control.

[gli]: http://davetron5000.github.com/gli
[pathogen]: https://github.com/tpope/vim-pathogen/
[railsvim]: https://github.com/tpope/vim-rails
