---
layout: post
title: "A Protocol for Code Reviews"
date: 2012-04-02 20:30
comments: true
categories: 
---
{% blockquote Jeff Casimir, The Twitters, https://twitter.com/j3/status/186961864234770433 %}
Anyone have a (formal / step-by-step) protocol for code reviews?
{% endblockquote %}

Yes, I do.  At [Opower][opower], we were pretty serious about code reviews.  We didn't review every commit, but we did review a lot, and, after a while, fell into a pretty decent routine.  This is an adaptation of that that I think is pretty decent.

<!-- more -->

## Prepare

The code authors should send out the diff, either as a pull request, or whatever the equivalent is in the tool of choice.  This should include:

* What the purpose of the change is
* Links to any supporting tickets, documentation, etc.
* A Place To Start

With all that, the reviewers should get an email, inviting them to review the code.  This is important, because you need to identify the people whose feedback you want.  Don't just email `people_who_installed_ruby@theuniverse.com`; email people who either *should* see your change, or whose feedback you want.

### A Place to Start?

Depending on the complexity of the change, this could be the name of the class/method where one should start reading, or a full-blown design document explaining the approach and structure of the change.  The point is that the reviewers have *no clue* how your code works, and need somewhere to get going.

## Asynchronous Review

This is "review by online tool", e.g. Github Pull Requests.  To make this work, you *must* have a tool that allows per-line commenting and discussion.  The reviewers will start at the Place to Start, review the code, and comment on things.  Reviewers should comment on anything they see fit, and they should follow [Wheaton's Rule][wheaton]: Don't be a dick.  The review**ee** promises not to take anything personally.  This can be hard to do, especially if you are new to the team, or inexperienced.  I'd recommend that for first-time employees, skip this and go to the _Synchronous Review_ as it can be less intimidating.

### Responding to comments

The reviewee should absolutely respond to comments.  I would expect comments to be one of these three responses:

* You are right, I will change that.
* You are wrong, because of _some explanation_, and perhaps I'll drop some comments or better-name my variables before I push this to make it clear.
* I'm confused, can you elaborate?

### Uploading changes

As important as it is that your review tool allow per-line comments, it's equally important that your review tool allow new changes to be added to the review *without blowing away the comments*.  Reviewers should be able to tell that you've made changes based on their feedback and see if it makes sense

### Stylistic Comments

Early reviews at Opower wasted an inordinate amount of time on stylistic things.  We eventually adopted a house style and our reviews moved on to important things.  You are not a special butterfly and you are not a snowflake who can only express him or herself through your clever variable names and indenting style.  Follow the house style, or at least the style of the code you are in so you can *get better feedback on your code* instead of arguing about where commas should go.

## Synchronous Review

If there are too many "I'm confused" comments, or the overall design/approach of the solution seems undesirable, it can greatly help if you hold a meeting with the interested parties to talk out the issues in the review, rather than creating an endless stream of comments in the review tool.

This review should be attended *only* by those with an interest in the outcome.  It should be timeboxed to hopefully 30 minutes, but not more than an hour, and the end result should be a "todo" list for the reviewee to correct the issues.  The ability to project the code on the screen is a plus, and the code authors best know how to navigate their codebase.  Senior developers have a responsibility to school them on this during the review.  It's the only way you'll learn. The issues would be of the form:

* Code author didn't understand the problem, and a larger rework is indicated
* Reviewers didn't understand the solution, and, after explaining, the author either reworks the code to be more understandable, or provides documentation to clear things up

## Completion

When the code is done to the satisfaction of those involved, the final commit should contain a link to the review in the review tool. This is crucial for future archaeologists  that might want to know what's going on; seeing the discussion can be helpful.

## Doing this with Github

Github's pull requests are less than ideal for this, depending on how you work.  Primarily, a reviewer wants to see the diff between the current system and how the system would look with the new code applied.  Last I checked, this view in Github doesn't allow per-line commenting, making it almost useless (see update, 11/21).

What I'd recommend is to squash the commit onto a branch specifically for the review (e.g. `reviews/TICKETNUM-DESCRIPTION`).  When the code author needs to add changes in response to the review, just add those diffs to the branch.  When everything is done, squash all *that*, and merge it.  One diff, one thing to deal with and understand.  

If you really want the sausage-making to be part of mainline history, then merge your changes plus one additional change representing all changes you made based on the review, with the message being a link to the review branch in Github.

## Doing this with Crucible

[Crucible] was tailor-made for this, and all you need to do is choose changesets and have at it.  You can add diffs as needed, and the commenting system is rich.  Crucible is not as polished and slick as Github, but it works great.

## Conclusion

This may sound like a lot, but it's *really* lightweight, once you start doing it, and it's way better than zillions of emails or
long, horrible meetings.  Just try it.

## Update, 11/21

Github pull requests actually *do* let you comment per line on the diff view.  This wasn't always the case, and is still not the case for non-pull request branches.  I
still feel like Github's PR mechanism isn't totally awesome, especially because it can be hard to see what someone's done to address code review comments, and, if you
force-push, all hell breaks loose, but it's gotten better.

Also, it seems that Crucible is [going the way of the dodo][crucible-eol], so scratch that.  Maybe I need to re-write this post every 6 months?!

[opower]: http://www.heyitsopower.com
[wheaton]: http://twitter.com/#!/wilw/statuses/5966220832
[Crucible]: http://www.atlassian.com/software/crucible/overview
[crucible-eol]: https://confluence.atlassian.com/display/CRUCIBLE/End+of+Support+Announcements+for+Crucible
