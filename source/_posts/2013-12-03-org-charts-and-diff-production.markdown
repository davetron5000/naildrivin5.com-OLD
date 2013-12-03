---
layout: post
title: "Org Charts and Diff Production"
date: 2013-12-03 08:47
comments: true
categories: 
---

Square's [@jackdanger][jackdanger] wrote a great post on his blog titled "[The Upside Down Org Chart][jackblog]." It's a great read on improving how reasonably-sized companies are structured.  His use of a tree that expands upwards, showing how management supports subordination, is genius.  It visually explains the role of management:

{% blockquote %}
For a tech company to describe their structure this way requires some humility from the leadership. It requires accepting that senior positions must be evaluated based on the support given to individuals on the team rather than the support given to the CEO or executives. But it makes the structure one in which nothing is extracted from the laborers – indeed it provides help that an individual could not find working alone.
{% endblockquote %}

His blog post's description of traditional top-down management structures brought back memories of teams I've been on that, despite having favorable org charts, were unpleasant.  The problem was that I was treated as (and acted like) a producer of [diffs], rather than a problem-solver.

<!-- more -->

Jack's post is, in part, a reaction to the typical strategies people are given for navigating a hierarchical corporate structure.
We're often told to "manage up" or "make your boss look good".  In the context of a large, dysfunctional, bureaucratic
organization, it can feel almost sickening to use these principles to drive your work.  Jack sums it up well:

{% blockquote %}
Nobody wants their work to be compromised by constantly having to "manage up" and certainly nobody wants to hand the benefits of their work to somebody else.
{% endblockquote %}

It's easy to cast the boss/direct-report relationship in an adversarial light, especially in a large company where it can be
difficult to understand the priorities of everyone involved.  In this scenario, "managing up" is akin to brown-nosing, and
"making your boss look good" sounds like giving credit to someone who didn't deserve it.

Personally, I don't see these techniques as inherently bad.  In a well-run company, the job of the managers is to make sure each
employee is coordinated toward the common goals of whatever it is the company does.  The problem is that, as "leaf nodes",
developers are often treated as widgets that ingest requirements and produce diffs. "Managing up" is about producing more diffs
faster, and making sure your boss knows about it.

For me, "managing up" is more about making sure you are solving the problems your boss has been tasked with getting your team to
solve.  Hopefully, these are the right problems to be solving.  The only way to find out is to become more than just a diff-producer or ticket-taker, but a true partner with your manager in collectively solving problems together.

## Producing Diffs

As developers, we love to talk how to produce better diffs (e.g. design patterns, coding techniques, editors, tools, frameworks, etc.).  Diffs are the only thing under our complete control.  Diffs are the most direct product of our labor.  But if we only view our jobs as producing diffs, we doom ourselves to being treated as cogs in a machine, interchangeable parts to plugged and re-plugged.  

I'm not happy just producing diffs.  I love programming, but it's not an end unto itself.  A computer program solves some problem
for someone, and I am happier when I know what that problem is (my diffs are better, too :).  I'd rather my boss know what
problems I've solved, and I'd rather my boss think about my job as solving problems, not producing diffs.  And, having been a
boss at times, I can tell you that it's much easier to understand my team when I know what problems they are solving, not which
tickets have been moved to "Resolved".

The problem is that, in a traditional company, we aren't presented with problems to solve, but with diffs to produce.  We're expected to trust our managers that the diffs we're asked to produce solve problems that need solving and
that all of those people "higher up the corporate ladder" are properly coordinating things to make the company successful.   This
can be difficult, if not impossible, to achieve.

And so what happens is that the diffs my manager asks me to produce may not actually solve the problems my manager needs solving.  If all I do is bang out diffs, am I really helping?  

If, instead, I align myself with my manager's goals, instead of simply doing what I'm told, together we can produce a better solution to the real problem.
My manager has more context than me about our team and the company. I have more context about the underlying technology, what
is possible, and what it takes to produce various solutions. If I can get a bit of my manager's context, and they a bit of mine, a better solution can be produced.

This is what I think of when I think of "managing up": the alignment of goals and a shared understanding.  Hopefully, my
manager's problems are the right problems to solve, but, even if they aren't, being on the same page is the first step to solving
*that* problem.

## Understand the Problem

In [my book][swengbook], there are three chapters devoted to writing software - one for fixing bugs, one for developing features,
and one for creating new applications.  In each case, the first step is to understand the problem being solved, _especially_ if a
specific solution has already been proposed.  

My book goes into some great detail about how to do this, but it all starts with simply asking "Why?".  Find out where the
requirements came from.  Find out what pain someone has that this is supposed to alleviate.  Find out how this saves the company
money.  Find out how it _makes_ the company money.  There should be a route from your ticket system to one of those places, even if it's circuitous.

Often, you'll find that the proposed solution isn't the best one for the underlying problem.  You might also find that the
problem really isn't a problem after all.  While it feels great to produce awesome code, it feels even better to produce *no
code* to solve a problem.

Approaching your work like this may make your boss look good.  But that's not the point.  The point is to spend your time wisely
and produce the best solution to the real problem.  That your boss and your team look good is incidental (but it's still a good thing).

Another side-effect of aligning your actions to business problems (instead of software requirements) is that you'll quickly uncover
dysfunction.  Sometimes the answer to the question "Why?" is "Because".  This answer is permission to start working on your resume
:)

In all seriousness, it's no fun to simply be a diff-producer, and if the company you are working at, regardless of its org chart,
has trapped you in the role of diff-producer, it's not going to be an enjoyable place to work.  You won't do your best work,
you won't learn, and you won't have much of a career.
   
So, take a break from learning how to produce amazing diffs and learn a bit about why you're doing what you're doing.  The
answers will make you a better developer.

---

_If you want to take control of your career, stop being a diff-producer, and start doing your best work, [my book][swengbook] has what you need._

[jackblog]: http://6brand.com/the-upside-down-org-chart.html
[jackdanger]: https://twitter.com/jackdanger/
[swengbook]: http://theseniorsoftwareengineer.com/
[diffs]: http://en.wikipedia.org/wiki/Diff
