---
layout: post
title: "&#10106;&#10144; Responsible Refactoring"
date: 2013-08-08 09:11
comments: true
categories: 
---
Emboldened by tests, and with the words "ruthless refactoring" in my head, I used to "improve" the codebase I was maintaining at a previous job.  One day,
my "cleanup" caused production to break.  How could this be?  I was being Agile.  I was Testing.  I was Merciless in my Refactoring.  I had found Code
Smells, dammit!

I was being irresponsible.

<!-- more -->

Lets be clear, first:  I'm not going to be talking about the third step of the TDD cycle.  Refactoring code that's in development and not
currently running on production is something you must absolutely do.  Work clean, and _write_ clean code.  What we're talking about is changes to existing,
running code.

In [Production is All That Matters][prodblogpost], I outlined the importance of code in production and how to keep it running smoothly.  One thing I
didn't touch on was changing that code.  Every change to production introduces a risk of breaking something.  Any system beyond a to-do list or blog
engine has complexity that can be difficult to cover by tests.  Integration tests are brittle, and cross-system tests more so.  Manual QA is the most
brittle of all.

Ideally, the size of your changes to production should be commensurate with the size of the feature you are adding.  Small features should require small
changes.  Large changes should be an indicator of a large or complex feature.

A pure refactoring breaks this rule completely - a refactoring adds no direct business value to the application, yet introduces risk that something will break.

"But," you say, "refactoring bad code makes it easier to change in the future.  It makes us faster later, and we can deliver more business value then!"

"The future", you say?  I say [You Ain't Gonna Need It][yagni], AKA YAGNI.  We tell ourselves not to invent features or add complexity to our code because
we don't know what the future holds.  I would say that refactoring outside of the TDD cycle should be viewed in the same light.

How then, do we prevent our code base from rotting?  How can we *ever* improve it?  If we focus our efforts on demonstrable business value - the future
be damned - how do we avoid having a big pile of shit codebase?

Before we answer, consider a piece of code you'd like to refactor.  When you see it, it just looks bad.  It's hard to follow, has poor naming, and is
generally ugly.  It's _begging_ to be cleaned up.  Now suppose that for the next six months, no requirement surfaces, nor bug is found, that requires modifying that code. Is its lack of cleanliness _really_ a problem?

Clean code is not an end unto itself.  Repeat: clean code is not an end unto itself<a name="back-1"></a><sup><a href="#1">1</a></sup>.

Clean code is a feature of code that is easy to change.  Code that is easy to change enables us to provide value to the business more easily.

Our job isn't to write clean code.  Our job isn't even to necessarily even write code at all.  It's to use software to deliver business value.

With that in mind, let's get back to the question at hand: how do we improve our codebase?

When faced with a change we need to make, we form a plan of attack.  This plan may be entirely in our heads, or we might sketch it out, but at some level
we decide how we're going to get started.  I would argue that there are at least two ways to tackle every problem:

* Plow through, making the change as expediently as possible, changing only what's needed to ship.
* Clean up or improve the code in a way that makes the change easier, then make the change.

All you have to do is decide which approach will deliver more value more quickly.  To be honest, it's often the first approach, but it's not *always*.
Occasionally, it's actually faster to clean things up first.

And **this** is how you improve your codebase. When cleaning up the code _enables you to work faster_ for a task you aren't dreaming up but _actually have at
hand_, refactoring is the way to go.

The beauty of this approach is that you never again need a "refactoring story" in your backlog, nor do you need to get "permission" to clean up some code.   You simply do it to get your job done faster and better.

Of course, we are bad at estimating, so how can we know what to do?  Here's some guidelines that I've found helpful in determining if a refactoring will
help:

* Changes to public APIs - function, method, module, or class names - are almost never worth it, especially in a dynamically typed language, especially in Ruby but even moreso in JavaScript.
* If you have to change a test, it's probably not worth it (and not technically a refactoring).
* If you'll be deleting code, it's probably a good sign.
* If you are unfamiliar with the code, resist the urge to "clean it up" - we often conflate "I don't understand this" with "this is poorly designed".

When you *do* decide a refactoring is going to help, be sure to put that refactoring in its own commit.  Ideally, get that refactoring up on production in advance
of your change (depending on the significance of your change).  Your tests only tell you what works, not what doesn't.  Production can give you more
information.

Pushing your refactoring to production ahead of the actual change also has a nice side-effect: it forces you to consider the risk of the refactoring.  When deciding what to do, if you know your refactoring is going up to production on its own, it allows you to think more clearly about the risk involved in the proposed refactoring.  You may decide it's not worth it.

This is what I call _responsible refactoring_.  Although you don't get to go apeshit "improving" your codebase, you do get a clear and simple process to make the code better in a way that has demonstrable, immediate benefits.  Think about it next time you are tempted to "clean up" some smelly code.

----

<footer class='footnotes'>
<ol>
<li>
<a name='1'></a>
<sup>1</sup>It's also worth pointing out that the following things are <strong>also</strong> not ends unto themselves: object-orientated, pure functional, immmutabile, referentially transparent, thread safe, O(log n), fast tests, the smallest-sized-CSS-you-can-dream-of, and performance.  I'm sure I left out about a billion things<a href='#back-1'>↩</a>
</li>
</ol></footer>
[prodblogpost]: http://www.naildrivin5.com/blog/2013/06/16/production-is-all-that-matters.html
[yagni]: http://en.wikipedia.org/wiki/You_aren't_gonna_need_it
