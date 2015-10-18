---
layout: post
title: "If you call out bad code, make sure it's bad first"
date: 2013-01-24 11:57
comments: true
categories: 
---

So, [someone shared some code][replace] on Github and some classic [developer snark][heatherpost] rolled in.  And then
there were [some][steve] [apologies][corey] about it.  I saw those snarky tweets when they came through, clicked to the Github
project, didn't understand what the issue was, and went back to work.

Now, I'm all for bad projects and bad code being called out.  Our industry produces some shitty code, and a general lack of
craftsmanship can kill business, or even people.  So bad code needs to be pointed out.  The question is, is this bad code?  I
think we can all agree that if it *is* bad code, we should try to point it out in a more constructive way (and I know it's easier
said than done), but let's forget the tone and focus on the message.  Is `replace` a silly project, or implemented in a stupid
way?

No, it's not.

<!-- more -->

I think we can evaluate a project based on three criteria:

* should it exist at all?
* does it use the right technology?
* are the lines of code well written?

## Should it exist at all?

`replace` is a command line app, which is something [near to my heart][clibook].  Writing a command-line app to automate
something tedious is what good developers do (even if you can wrangle `sed`, `awk`, `mv` etc. to do it without scripting
it).  The use case of `replace` is one I've needed many times, and, when I did, I hacked together some pile of shit shell script
to do it one-off and then promptly deleted it because then no one would know my shame in having made such bad code.

So, I'd say that it's completely reasonable that this exists and wouldn't be surprised if many people found it useful. I believe
this is why I initially didn't understand the negative reaction.  I saw "some command line that makes search/replace across files
way easier than dealing with `sed` and friends" and figured that was useful and good.


## Does it use the right technology?

This question is around identifying things like using Java to manage UNIX processes, or using Ruby for complex mathematical
processing - is this really the best use of the chosen technology.  In this case, the command line app is written in JavaScript and requires Node to be installed in order to execute.

In Avdi Grimm's [take on this][avdi] he writes:

> But I do share the opinion of a number of my colleagues that using a reactor-based framework in a language lacking native fibers, coroutines, continuations, or threads leads to messy code.

I totally agree with Avdi on this, but I don't think it's *that* relevant to the choice of technology here.  It turns out that if
you want to write a command-line app in JavaScript, Node is the best way to make that happen, as it gives you a nice "shebang"
style way of doing things, along with some I/O functions that don't exist in regular JavaScript. The code for `replace` *does*
have async as an option, but it's not like this thing pops up a web server and gets lost in callback hell.  And, even if it did,
I wouldn't say it's de-facto wrong to use Node for a command-line app, given that it's written in JavaScript.

Which leads us to ask: "should command-line apps be written in JavaScript at all?"  Of course, it depends.  JavaScript isn't the
*best* language to write CLI apps, but it's not a bad choice.  It's dynamically typed, has powerful code organization techniques, and supports collection, regex, & object literals.  If you write a lot of JavaScript for your primary project, writing command-line tools in JavaScript makes a lot of sense.

So, I think JavaScript is a fine choice of technology, and, because of this, Node is the most reasonable "JavaScript runtime" to
use.

## Is the code itself well written?

For a command-line app, I would say it's pretty good.  There's a proper option parser in place, with useful and complete help
text, and all configureability is done via command-line options - as it should be.  The main thing this project is lacking is
automated tests, but it does include some sample files that can be used to exercise the app's functionality via manual testing on
the command-line (that's certainly better than *many* of the command-line scripts I've written over the years).

The main code itself, all contained in `replace.js`, is fairly straightforward.  The main routine is a bit complex, but it's
not hard to follow and method extraction has clearly been used to keep the main routine readable.  I'm sure it could be done more
cleanly, but it's pretty good as it is.

So, I'd say this code is pretty well written.

## Conclusions

Maybe you don't like Node, or JavaScript, or command-line scripts that wrap or re-implement certain UNIX pipelines.  That's fine,
and I won't argue those points.  But that doesn't mean that such things are inherently bad.  One of the hardest things to learn
as a developer is to stop making emotional arguments (or publicizing emotional responses) and start making *technical* arguments.

I won't claim to be great at this, but it's something I spend time on trying to improve, even if it's at the cost of learning
some new language or framework.  It's an ongoing process, and this blog post is part of that process.

I'll leave you with some *actually* bad code from a bad project - one of mine: a Java project to parse a YAML-like format and
turn it into XML.  At the time, I'd never heard of YAML, and the entire thing uses regexes for parsing, along with a giant mess
of a "doit" method that's screaming for a refactor.  Feast your eyes on [this][mybadcode].  It should never have been made, nor
should it have been done in Java, and the code is quite a mess.


[replace]: https://github.com/harthur/replace
[heatherpost]: http://harthur.wordpress.com/2013/01/24/771/
[steve]: http://blog.steveklabnik.com/posts/2013-01-23-node
[corey]: http://programmingtour.blogspot.com/2013/01/im-sorry.html
[clibook]: http://www.pragprog.com/titles/dccar
[avdi]: http://devblog.avdi.org/2013/01/24/im-sorry-too/
[mybadcode]: https://github.com/davetron5000/fauxml/blob/master/src/java/com/naildrivin5/fauxml/Parser.java#L118
