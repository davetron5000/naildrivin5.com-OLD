---
layout: post
title: "&#10106;&#10144; Making it Right: Technical Debt vs. Slop"
date: 2012-10-05 11:36
comments: true
categories: 
---
We were recently having a discussion at work about "doing it right" and "technical debt".  The discussion revolved around the
optionality of "doing it right" - when is it OK to not "do it right"?

I would say it's **almost never** OK to write code incorrectly.  If your understanding of what "doing it right"
means includes an "optional" clause, **you have the wrong definition**.  As professionals, we should always do it right.  We
should always do our work correctly.  I don't mean we should over-engineer, nor do I mean that we should solve an abstract
problem instead of the one in front of us for "flexibility", but we should have a basic standard that we inflexibly hold
ourselves to.

Writing code that **does not** adhere to our personal standards of correctness isn't technical debt - it's slop.

<!-- more -->

* Code with no tests isn't technical debt, it's slop.
* Code that passes its test due to copy and paste isn't technical debt, it's slop.
* Code with conditional expressions that wrap the screen isn't technical debt, it's slop.
* Code that you write, without knowing _why_…it's slop.

The people who've paid for us to write code (which I will call _stakeholders_ for lack of a better term), do not want slop, *even
if they don't even know what that means*.  They want The Feature, the Whole Feature, and Nothing But The Feature, but they don't
want it wrapped around a pile of shit.  And you know it.

Stakeholders trust us to do things correctly, and to not over-engineer some solution.  They trust us not to turn a boring problem
into an interesting one, and its our responsibility to deliver something done "right".

## "Right" isn't an option

You must first absolve yourself of the notion that "doing it right" is optional.  Doing this requires you to do two things:

* Be honest with yourself about the differences between solving the problem in front of you in a clean way and turning that
  problem into an architecture astronautic framework generified flexibilty extraction.  "Doing it right" doesn't mean you get to
  extract a framework at the end.  "Doing it right" doesn't mean the code is now an open-source project.
* Stand firm about the quality of work you will deliver.  You will not deliver slop.  Ever.  You are a professional who knows what you are
  doing and you are paid a very high salary for that expertise.  Do not take a shit on it by delivering slop as completed work.

## Holmes on Homes - Get in the mindset

Coming to terms with what "doing it right" really means can be difficult, especially if you don't have much experience.  Your instinct is to provide immediate gratification to a
stakeholder, and you might not truly understand the difference between "doing it right" and flying off with the Architecture
Astronauts.  We'll get to some techniques to help.

But first, I'd encourage you to watch an episode of the HGTV television program [Holmes on Homes][holmes].  If you've ever spent time in someone else's codebase, you will identify very closely with Mike Holmes (the host) and the problems he faces.  He's called in to clean up a mess made by other home contractors.  His catch phrase is "make it right".

Sometimes, Mike has to rip out entire rooms to fix a problem introduced by another contractor who took a shortcut, or did
something wrong.  Other times, he simply applies the right technique or tool for the job, at little additional cost over "the
quick and incorrect way" another contractor might.

It's also important to note that Mike doesn't turn one thing into another.  If a homeowner's deck is faulty, he doesn't give them
a screened-in porch.  He fixes the deck to make it right.

Watching the show, you will also begin to see how stakeholders view your work.  The homeowners (who are the stakeholders of these
projects) typically don't have the technical
expertise necessary to examine the work they've paid for.  They will only ever see the finished veneer of a project, and trust
the contractor to have done the right thing underneath.  Sound familiar?

## Be the stakeholder

Think about when *you've* been the stakeholder.  If you've hired a contractor to do some work, this is the perfect analog, though
if you've ever paid a CPA to do your taxes, hired a lawyer, or had surgery, you've been the stakeholder.  You have no idea how
the professional you've hired does their work, and while you want it done as quickly and cheaply as possible, you expect a certain
standard of quality.

Suppose you're having something rewired in your hose and the electrician runs out of wire.  Suppose he sees that you have enough
speaker wire to finish the job, and offers to use that.  It'll save you time and money.  Would you accept this?  Of course not,
and you'd be wise to treat everything this person says from then on with extreme suspicion.  They are offering you a
solution that is wrong, and presenting it with the same validity as the correct solution (going to the store to buy more
of the correct wire).

So, why are you offering your stakeholder, who's put their trust in you, a cheap, easy, and dangerous way out?  Why present an
option that you know to be wrong?  Stakeholders want solutions, not decisions, and they don't have the ability to make a
technical decision anyway - that's why they hired you!

## How to make it right

Here's how to make it right, in four steps.

1. **Think before you type**.  Do you understand the problem you are solving?  How will you solve it?  What should the system
   look like when it's done?  Agile teaches us to avoid "Big Design Up Front", but we've interpreted this as "JUST START
   TYPING!!!!".  Don't just start typing.  Think.  Write something down if you need to.  It's OK.  This is the hardest part to
   remember to do.
2. **Write a test or tests**.  Yup, write your tests first.  There's a few reasons to do this.  First, you want a test to exist
   when all is said and done, and writing it *right after you thought about the problem* is the best time to do so.  Second, you
   want a way to run your code while you work on it.  An automated test, run from the command-line or your IDE is **way** easier
   than manually doing it.  Finally, a test persists as your intention of how the system should work, and you **already know how
   it should work**, so write it down now…as a test.  This is the hardest, most tedious step, so it's nice to get it out of the
   way early.
3. **Get it working**.  As quickly as possible, make the test pass.  It can be sloppy. It can be less than ideal.  You can make a
   mess.  What you want is to get the code into a shape where it does what you want it to do.  This should be the easiest part of
   the process.  Any idiot can make code work.
4. **Make it right**.  I'm not going to use the "R" word here.  In this step, you clean up the mess you made.  You remove duplicate code.  You change your print statements to log statements.  You extract your complex conditionals into methods.  You move unrelated code into new classes.  It's fast.  It requires being creative, and is extremely satisfying.  Also, your brain is in the problem, so there's no better time to do this than right now.  **This is the most fun and rewarding part of writing a computer program**.  That's why it's important, and that's why we do it last.

Repeat these steps until you've solved the problem in front of you.

## What about technical debt?

* A shitty variable name isn't technical debt, it's slop.
* Absent API documentation isn't technical debt, it's slop.

Technical debt is an assumption you know does not hold (e.g. no user will buy more than three items at a time).  Technical debt
is a design decision you know to be less than optimal (e.g. we'll special case these orders to use a different shipping provider
instead of creating a new shipping subsystem).  Technical debt is code to stop the bleeding of your business (e.g. shut off
all access to the beta site until this wave of users from TechCrunch has passed).  Technical debt is not sloppily written code.
It is clean code that is less than optimal.

When you acquire technical debt, **write it the fuck down**.  It's **that** important.  Ideally, you would write it as a code
comment where the debt was acquired.  If that won't work, include it as the commit message when you change the system.

And then add a new task to your task list to pay it off.

But always make it right.

_If you enjoyed this post or want to find out more about dealing with technical debt and sloppy code, I've written [an entire book][sweng] on the subject called "The Senior Software Engineer".  Pick up a copy - it's only $25!_

[holmes]: http://www.hgtv.com/holmes-on-homes/show/index.html
[sweng]: http://www.theseniorsoftwareengineer.com
