---
layout: post
title: "What I mean by 'calling out' bad code"
date: 2013-01-30 16:44
comments: true
categories: 
---

In my [earlier post][codepost] on how the [replace] command-line app isn't "bad code", I said:

> Now, I'm all for bad projects and bad code being called out.  Our industry produces some shitty code, and a general lack of
> craftsmanship can kill business, or even people.  So bad code needs to be pointed out.

The words I'm using here are a bit loaded, and actually distract from my real meaning.  I don't want to change the post, but
thought it was worth explaining what I meant and why it's important.

<!-- more -->

Uncle Bob actually weighed in on this debate [in a recent post][bobpost], and puts it much better:

> (BTW, There is nothing wrong with politely pointing out what you believe to be deficiencies in someone else's code. You don't want to be rude or condescending when you do this; but you do want to do it. How else can we learn unless someone points out where we've gone wrong? So please don't let this event stop you from valid review and critique.)

This is much more precisely what I mean, although this, too, carries the air of "I, the craftsman, am *correct*, and you, the
mere code monkey, have *much to learn*".  What I'm really talking about is code review.

Code review (or code inspection) is one of the few software development techniques whose effectiveness at defect removal has been
remotely proven scientifically.  Anecdotally, it always improves the code under review, and frequently improves the way the code
author and reviewers understand the problem.  There is really no downside to code review.

Although a seasoned veteran developer is going to more quickly and easily identify issues with code under review than a developer
with little or no experience, it *doesn't* mean that the reviewer/reviewee relationship has to go this way - I've had
developers more junior than me identify real issues with code I've written.  No one writes perfectly clean or correct code the
first time andk although tests help, tests only test that the code matches *your understanding* of the problem.  It doesn't take a
20-year senior developer to point out bad naming, poor API design, confusing structure, or a missed item from the requirements.

As to the phrases "called out" and "our industry produces some shitty code", I mean this more as a call to arms to experienced
developers.  *Make* the time to review code - apply your experience to the work done by those who haven't walked in your shoes.
Everyone will be better for it.  I wrote a post last year on [how to do a code review][codereviewpost] that should provide you a
good place to start.

As for unsolicited reviews of open-source software, I don't know that trolling Github for "bad" code is the best idea, but if you
put your code out there, expect (and embrace) commentary.  Hopefully, it will be in the form of a pull request, but if not, you
can still learn something and improve your code just via conversation.

[bobpost]: http://blog.8thlight.com/uncle-bob/2013/01/30/The-Craftsman-And-The-Laborer.html
[replace]: https://github.com/harthur/replace
[codepost]: http://www.naildrivin5.com/blog/2013/01/24/if-you-call-out-bad-code.html
[codereviewpost]: http://www.naildrivin5.com/blog/2012/04/02/a-protocol-for-code-reviews.html
