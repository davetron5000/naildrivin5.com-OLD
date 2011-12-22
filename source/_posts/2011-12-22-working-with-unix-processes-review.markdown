---
layout: post
title: "Review of 'Working with Unix Processes'"
date: 2011-12-22 08:37
comments: true
categories: 
---

I just finished reading the short and to-the-point [Working with Unix Processes][processbook], by Jess Storimer.  Although
I cut my teeth on C and UNIX programming, it's been a while, and I figured I'd check the book out to see what insights it might
have, especially given that it's written from a Ruby perspective.

In short, I'd recommend this book to someone interested in command-line Ruby (and who might have [my book][mybook]), but who has
very little UNIX programming experience.  This book is a crash-course in the basics of UNIX Process management.

That being said, if you are (or have been) familiar with things like `fork` and `exec`, you'll find this book a bit too light, especially given the price.

<!-- more -->

## The Good

The information in the book is accurate and presented at excellent pace; the reader isn't expected to ingest too much knowledge
at once, and the author brings the reader one step-at-a-time through understanding UNIX process management.  In a nice touch, the author pauses on occasion to connect the information presented to "real world" scenarios.

The book also delves slightly into the realities of using these tools in the context of particualr Ruby implementations.  

The appendeces of the book are a walkthrough of certain parts of [Resque][resque] and [unicorn's][unicorn] source code,
relating back to the concepts learned in the book.  This is something few books do, but that I find very illuminating.  Here, it
demonstrates real-world use of the concepts outlined in the book.

## The Bad

At $27 ($7 *more* than [my book][mybook], and *$22 more* that Avid Grimm's so-far-wonderful [Objects on Rails][objrails]), I was hoping for a little more depth.  The book clocks in at 90 pages in PDF (77 pages
  in iBooks) and feels more like an introduction.    For the price, I was hoping for a lot more depth.

As an example, the section "Daemon Processes" shows the use of the `setsid` system call.  Although the purpose of using the call
is explained, *that* explanation makes no sense.  I have no idea what a "session leader" or "process group" are, and these terms
are never touched on in the book, nor is there a link to find out more.  A cursory search of the internet turned up only the
information presented here.  Piecing this together is the insight a book like this should provide; it's what makes the
information worth paying for.

I also feel like some discussion of named pipes would be warranted, as well as things like `select` and `poll`, which are at the
heart of the current fad in evented programming.

The book could also benefit from some editing, as there were *just* enough grammar and spelling mistakes to distract me, as well as numerous formatting bugs with source code in the ePub version.  I also think that using running, real-world examples would make the points more clear; the examples aren't particularly compelling (although the appendeces make up for this significantly, since they *do* relate the concepts to real code).

The book also includes some source code that is never really discussed and, honestly, I'm not sure what I'm supposed to do with
it.

## Conclusions

Don't let these criticisms spoil you, though.  If you have no clue what a process is, or what `exec` is for, this book will teach
that to you, simply and quickly.  This book fills a gap that a lot of developers have these days; it shouldn't require writing C
code to learn the UNIX fundamentals.  This book proves that to be true.



[processbook]: http://workingwithunixprocesses.com/
[mybook]: http://www.awesomecommandlineapps.com/
[resque]: https://github.com/defunkt/resque
[unicorn]: http://unicorn.bogomips.org/
[objrails]: http://avdi.org/devblog/2011/11/15/early-access-beta-of-objects-on-rails-now-available-2/
