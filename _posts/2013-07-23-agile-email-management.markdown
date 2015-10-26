---
layout: post
title: "Agile Email Management"
date: 2013-07-23 08:27
feature: true
---

Email is a fact of life.  It's the primary conduit through which all information in our work life flows.  Clients email us.
Users email us.  Project managers email us. Our issue management systems email us.  Heck, even our _apps_ email us when things are going wrong.

Managing email can be tricky - if you spend too much time on it, you don't get any other work done, and if you don't spend enough
time on it, you appear flaky at best and incompetent at worst.  Over the past several years, I've developed a system for managing
email as a developer that maximizes my responsiveness without creating an undue burden on my workload.  In short, I'm a lot more
agile in how I deliver results by allowing emails to occasionally "overrule" my otherwise prioritized backlog.

I'm going to share it with you to see if you like it

<!-- more -->

First, we need to understand what is actually coming to us via email.  Emails have many attributes that we'll need to use to
figure out what to do:

* Is the email actionable?
* If it is, do I need to take action now?
* If not, should someone else take action now?
* If not, is this action even worth doing?

It's actually fairly easy to manage your inbox if you think along these lines.  The key to making it work is the second question,
"Do I need to take action now?"  By being honest about your workload and your interpretation of you and your team's priorities, you will always be working on what's important. You'll also transform "urgent" (i.e. not urgent) requests into conversations about priorities instead of an ever-growing list of to-dos or a black-hole of unresponsiveness.

The basic process is:

0. Lightly filter unactionable and highly-actionable emails
1. Read all unread email
2. Archive unactionable emails
3. Identify which actionable emails are priorities
4. Defer all the rest by starting a discussion about priorities
5. Address priority emails immediately

## Lightly filter unactionable and highly-actionable emails

Ideally, you don't get regular emails that can be machine-identified as unactionable.  We don't live in the ideal world, so set
up filters for these.  These are emails that you **never** need to read as they come in.  Set your email client to archive - not
delete - these messages.

Second, there are emails that are a requirement for immediate action.  For example, if your website is down.  Configure your
email client to forward these to your cellphone via SMS and _leave them as unread_.

This is the only filtering you should do.  As we'll see, we'll be keeping our inbox very clean, and machine-filtering of emails
only serves to hide things from your attention.

Once you've set this up, the remaining emails you receive will require you to read them.

## Read all unread email

The more frequently you read email, the less you will have to read each time you do so.  I tend to read emails within 15 minutes
of their arrival, however checking once per hour is probably a good place to start.  You should not be "heads down" in code for
more than an hour at a time, so this is a good cadence for checking your email.

Each time you check email, read *all* of it.  You want to establish a Service Level Agreement (SLA) that you read all your emails
at least once per hour (during business hours of course).  This means that any request anyone has of you can get your attention
within 59 minutes.  Doing this reduces the need for others to find you in person, call you on the phone, hit you up on IM or
otherwise interrupt you on _their_ schedule.

Reading email less frequently is an invitation for constant disruption, because anyone who feels their request is urgent will not
want to wait very long for a response.  They are highly likely to wait an hour.

Once you've read your emails, you need to start addressing them before getting back to work.

## Archive all unactionable emails

Un-actionable emails are emails where the _sender_ agrees that no response is required from you.  This is important.  Just
because _you_ think an email is unactionable, it doesn't mean the sender does.  Don't passive-aggressively archive emails that are
poorly written or that request information you feel is unimportant.

Once you've identified unactionable emails, archive them.  Never delete your email.  Never.  Delete. Email.  You want to be able
to pull up any email anyone sent you - it's an historical record that often clashes with our fallible human memory.

The remaining emails will require you to do _something_.  This requires prioritization.

## Identify which actionable emails are priorities

Every email that is actionable must now be prioritized; actionable doesn't mean "do it now".  I prefer a modified version of the Merlin Mann School of Priority.
Merlin says that there is only ever one priority - the thing you are working on right now.  I take this one step back and feel that
actions or requests are either a priority or they are not.  There are no relative priorities - just a boolean "yes" or "no".

Priority requests are those that require a response within the next 24 hours (accounting for weekends and holidays).  Judge this on your own - if you feel a request is a
priority, then you agree with the sender and can get to it.  If you disagree with the sender, they must convince you - it's your
time on the line, so the request isn't a priority until you are convinced.

Do not reply to emails that you've identified as priorities.  Since you'll be getting to this request quickly, you can simply
deliver one reply when the work is done.  "I'm on it" is not helpful and invites further emails.

Any emails that are *not* priorities, however,  *do* require a response.

## Defer all the rest by starting a discussion about priorities

Requests that aren't priorities have a chance of never being done.  Which means that there's no guarantee you will ever work on
them.  The sender needs to know this so that they can plan accordingly.  Part of being responsive and reliable is being clear
about what you _aren't_ going to be doing.  Since you're allowing certain requests to override your current work queue, this
means you get to say "no" to things that shouldn't.

For requests that you feel are important, but that you don't have time for, you have two options:

* Identify someone else who can do it.  In this case, reply as such and add said person to the email chain
* Commit to doing it in the next five days.  If you can't commit to this timetable, it's probably not that important, so make
this commitment only when you really can get it done.  Don't commit farther out, because your accuracy will go *way* down.

For requests you feel are *not* important (usually because they are not really a priority), you have to let the
requester know.  As briefly and tactfully as possible, lay out your reasons why you won't be able to address the request. Include a list of your current priorities - perhaps the requester knows something you don't that would change your priorities.

Since this email is going to be "bad news" to the sender, it's important that you write it well.  There's a section in [my latest book][sweng] about how do write effective emails, but the short answer is to be concise and read what you write before you send it.

Resist the urge to throw the request into your backlog or feature management system.  Your backlog is a black hole of broken promises and is a
dishonest and passive-aggressive way of dealing with your fellow co-workers's requests.  Respect them enough to tell them it's not a
priority and that you can't realistically guarantee you'll ever get to it.  Make _them_ prioritize it - even if by fiat.

Once you reply, archive the original email.  No more action is required on your part unless someone responds.  You'll handle
that response the next time you check email.

At this point, your inbox is a short list of emails representing urgent, priority actions, or requests you've agreed to address
in the next five days.  You can differentiate them by the existence of a reply.  Unreplied emails are your priority. Get to them.

## Address priority emails immediately

Generally, emails either request information or require writing code.  Address the emails requesting information first, as these
are the easiest to deal with.  Find a definitive answer, show how you arrived at it, send the reply, and archive the email.  It's
done and out of your life.

Requests that require writing code must now be balanced against your current workload.  I would recommend that bugs that you can
fix in three hours or less you fix immediately.  Your brain is already aligned to the bug by having read and prioritized the
email, so just fix it and get it out of your life.

For everything else, you'll have to find a way to deal with it in the next 24 hours.  Work in order based on whatever factors you
feel are important.

Whenever you complete something, reply with your results.  If you are using continuous deployment, reply when the code is on
production.  If you aren't, reply when code is in version control scheduled for release, and let the requester know when to
expect the code on production.

After 24 hours, any request you haven't addressed deserves a reply.  Your SLA for email _responses_ is 24 hours.  Since you have
no actual result to report, you'll need to indicate what the holdup us, and when you can expect to address the issue.

Once your priority requests are addressed, you'll need to factor in your "five-day" requests into your regular workflow.  Be sure
to circle back to the requester for any issues you haven't addressed in five days.  You may need to defer them or delegate them,
but if you find you are frequently unable to deliver on these promises, you need to start promising less of them.

It's important that you tailor your promises to match your actual delivered results as much as you can.  Not only does this make
you reliable, but it also allows others to accurately plan based on your availability and existing priorities.  They need - and
deserve - to know that you cannot handle but so much.  Acting as a black  hole makes it very hard for others to do their jobs,
because they don't know what you will (and will not) be delivering.

## What this all results in

It may seem like you're going to spend all of your time managing email and addressing the requests therein.  Remember that the key
to this is identifying priorities.  A priority is something you absolutely plan to do in the next 24 hours.  You can only do so
much in that time, especially given everything else you are working on, so it forces you to commit to very little.

The "five day" commitment further reinforces this but allowing some flexibility without leading anyone on about what you'll
be doing.

## What about my Scrumban Agile Board of Index Cards™?

I have seen very strict agile processes where the only way to insert work at the top of a developer's queue is if something is on
fire and the business is about to go under - everything else goes to the backlog.  This is anything but agile.

If you use a feature management system, it should be used for planned work according to a roadmap resulting from thinking
about solving business problems.  Such planning cannot account for the reality of how a system is built or used.  Over time,
pressure builds from the users of the system against the team's plan for its enhancement. Your inbox is a valve to releieve some of
that pressure.  It's a way to allow a controlled circumvention of your development process whenever it's warranted.

By carefully managing your email, you make yourself (and your team) much more responsive to the reality of the business.  By
promising only what can be delivered in 24 hours, you enable urgent requests to be addressed without becoming lost in a sea of
emails, all while providing honest and useful feedback to your users and co-workers about what can realistically be accomplished.

[sweng]: http://www.theseniorsoftwareengineer.com
