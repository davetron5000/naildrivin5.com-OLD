---
layout: post
title: "&#10106;&#10144; Inconsistent Architecture"
date: 2013-08-21 09:32
comments: true
categories: 
---

Quick, which is better: MiniTest or RSpec?  HAML or ERB?  SASS or LESS?

If you are building your first Rails app at your company, it doesn't matter.  They all work more or less the same, so just pick one and go.  Take a vote or declare by fiat, but get on with your life.  No project ever failed because they picked HAML over ERB.

If, on the other hand, you are building a new Rails application that runs in an existing technical infrastructure (which is far more likely), then these are the absolute wrong questions to be asking.  Use what your team already uses _unless there's a good technical reason not to_.  Why?

Because consistency is far more important than most other factors.

<!-- more -->

## Consistency is an enabler

Consistency is the ultimate enabler.  Rails developers should know this better than most, because Rails is built on this very principle.  For example, in Rails, database primary key columns are named `ID` by default.  This consistency allows Rails to not only make things easier for us, but it also frees us from a pointless debate about naming conventions.  It really doesn't matter if the primary key for the `ADDRESS` table is `ID` or `ADDRESS_ID`, but it *really* matters that all tables use the same naming scheme.  

Such consistency enables productivity and agility.  When faced with change, Rails eliminates a large number of decisions we have to make{% fn_ref 1 %}.  Need to store some data?  Just choose the name of that data, and Rails handles naming the class and where it will be stored.  Need a new page in your app?  Just choose the name and Rails tells you were to put the code, even generating it for you.

Compare this to an application written using Spring MVC.  Spring is flexible.  It's so
flexible.  There are probably 10 ways to map a URL to code, and all of them have equal
complexity.  Which means that your Spring MVC app will be hard to understand and
modify, as each developer maps URLs in their own special way, or you, as the tech lead,
spend an inordinate amount of time reviewing changes and keeping things consistent.
This is time that Rails tech leads don't need to spend.

Changes that are constrained to one application aren't the most difficult task a
developer faces, however.  As service-oriented architectures become more prevalent,
organizations often require changes that cross application boundaries.  For example,
you may need to move to a publish/subscribe model for performance
reasons, or you might need share views between applications to provide a
unified UI to key decision-makers.

## Cross-Application Changes are Key to Success

An organization's ability to make cross-application changes in the face of changing requirements or business climate can be crucial to staying competitive and successful.  Being unable to make changes can go so far as to sink a company{% fn_ref 2 %}.

Changes across several applications in your architecture are difficult.
They require coordinated changes and consolidation of code, all timed to a
simultaneous release.

Consistency across applications is a force-multiplier for enabling these types of changes.  An Inconsistent Architecture can make these changes unnecessarily difficult, cost-ineffective, or even impossible.

## An Inconsistent Architecture Makes You Slow

So, if your team has successfully fielded applications, yet is debating "MiniTest vs. RSpec", you're blowing it.  You need to be asking, instead, "What advantage will we gain by introducing this new library?" and you must also answer the question "Does this advantage outweigh the negative impact of having an Inconsistent Architecture?"

Here are some of the negatives:

* Team in a Constant State of Debate
* Cross-Application Work is Taxing
* Extraction of Shared Code Difficult

### A State of Constant Debate

Each new application requires a renewed debate about which "standard libraries" to use.  Inevitably, this debate also includes the meta-debate about standardization of libraries.  These debates are a waste of time.  Instead of delivering value to your customer or business, you are arguing about significant whitespace and "clean" markup.  Your competitors are laughing.

More to the point, however, the constant debate means you cannot develop tooling around application creation and management, because many more decisions are required than if you had a consistent set of agreed-upon libraries and techniques.  This means that the burden of application creation goes up, meaning the value of creating such applications goes down, meaning your business is overall less responsive.

### Cross-Application Work is Taxing

In an Inconsistent Architecture, each application carriers its own unique set of libraries and microframeworks.  This means that anyone doing cross-application work - difficult enough by its nature - now must contend with several different ways of accomplishing the same thing.  Realistically, no one is going to have deep knowledge of all these tools and libraries.  

This means that cross-application work will take longer as the developer in question must head to the documentation much more frequently.  Worse, said developer could simply shoe-horn code for unfamiliar libraries into what they find familiar, making it worse for everyone.

The result is that cross-application work takes longer than it should, and the
resulting code in the relevant applications will be of poorer quality.  A team that has a collective
and deep understanding of fewer tools is going to be more effective than one with only a shallow collective understanding of many tools.

### Extraction of Shared Code Difficult

Often, cross-application work involves consolidating features according to business or operational requirements.  For example, you might be setting up a centralized user authentication system for all of your applications.  Each application might have slightly different requirements, so your extracted system must meet all of them.  

When the code in all these applications is consistent in tooling and approach, this task is much simpler than when a smattering of libraries have been used.  Consider templating languages: even discerning that a template in ERB and one in HAML represent the same thing can be difficult; seeing the differences in order to create a correct shared UI even more-so.

This means the tasks of consolidating code, features, and behavior is now more difficult than they should be - everything must be converted into a common form, rather than simply moved around.

## Is it worth it?

Having an Inconsistent Architecture carries a lot of negatives.  In [my book][book], I have an entire chapter on setting up a new application.  In that
chapter, I talk about the "blessed stack", which is the set of tools, libraries, and frameworks in use at your organization.  For example, at [Stitch Fix][stitchfix], we use Rails, RSpec, ERB, CoffeeScript, Resque, SASS, and Postgres.

The book uses the concept of the "blessed stack" as a way to re-frame the decisions you make when creating a new application.  To re-state something from above, if your applications all use SASS, you shouldn't be having a "SASS vs. LESS" debate, you should be answering the question "What does LESS bring to the table that makes the pain of inconsistency worth it?"

The answer is almost always "nothing" (for most values of "SASS" or "LESS").

That one tool is theoretically "better" than another is a discussion for happy hour.  If no standard has been established for a particular need, have a _quick_ debate, and then make a decision (either by fiat or by vote).  Time spent debating is time not [delivering results][resultsexcerpt], and your team's success does not hinge upon "clean markup".

## But, how do we advance?

As with the discussion around [responsible refactoring][refactoringpost], there is an
escape hatch to what seems like myopic thinking.  The reading-comprehension-impaired
took away from that post "never refactor", and the same crowd could interpret this
post as "never use new technology".

Both the refactoring and this one revolve around reasons: do you have a good reason to
refactor that code?  OK, great, let's do it. At the start of this post, I said that you should use what your team is already using **unless there's a good technical reason not to**.

## A Good Technical Reason

A mature and effective team is always open to debate, but such a team is also
impervious to fallacious arguments.  "The Rails Way" is an appeal to authority.
"Most developers use it" is an argumentum ad populum (and I'd be willing to bet you
didn't conduct a real study anyway).

Here are some technical reasons (all of which you should be prepared to prove):

* We can't meet our deadlines without library X
* The standard won't meet our performance requirements
* Our default stack is a fundamental mismatch for the problem at hand
* We're about to lose official support for the status quo/status quo is no longer maintained
* This is a low-risk, low-impact project - experimentation might be OK

There are probably others more specific to your project, but the point is that you
really should be able to outline _why_ introducing an inconsistency is a net win.
Beware Résumé-Driven-Development.

And, I know this all from experience.  I have been personally responsible for introducing technologies not meeting this burden in two different jobs. I'm still in contact with some of the developers at both jobs, and these decisions were not a net win, despite whatever problems they may have solved for me in the short-term{% fn_ref 3 %}.

This experience is what brought me to this realization - there's nothing like making a
mistake yourself to get clarity on the right way to do things.

## Evolving the Status Quo

You might feel that working under such a "regime" means that you'll never learn
anything new, and you'll be stuck on the same old version of whatever web framework
you have.

The culture I'm describing here isn't a conservative one, it's one that values
consistency.  Understand the difference.

It turns out that a culture of consistency enables technical evolution moreso than one that does not.  When all applications have the same "shape", it becomes markedly easier to move forward with technology choices.

At Stitch Fix, we have currently three Rails apps in production.  The Ruby parts of
them all have a similar shape - the use of controllers, models, and service objects
is fairly similar.  We also have an array of shared gems that have similar shapes as
well.  We use the same libraries across all apps for the most part.

This consistency will make our collective move to Rails 4 a lot smoother than
if every application and gem did things differently.  This will allow one or two
developers to move our team forward with little disruption in service or feature delivery.

If, instead, we'd fielded a mixture of Rails and Sinatra apps, used different testing
frameworks and different CSS pre-compilers, the task would be orders of magnitude more
difficult.  In this way, a culture of "use whatever you want" would actually hold the
organization _back_ from using new technology.  I've worked there.  Twice.  And they
are still dealing with legacy libraries and tools.

## Step-by-Step Instructions

Here is my ideal approach to technology choice, incredibly summarized ([the book][book] goes into more detail):

1. Use what you are already using.
1. If someone wants to deviate, see step 1.
1. If someone *really* want to deviate, refuse to debate "Old vs. New".  Refuse.   The
   debate *must* be "New vs. Consistency".  Be open to convincing arguments, and call
   out fallacious ones.
1. If the problem at hand is a new one for your team, quickly choose the new standard so that you never have to make this decision again.  I'd recommend a brief discussion followed by a vote, with developers writing the code breaking ties, but if you need to decide by fiat, so be it.
1. Review the "blessed stack" periodically.  What's working?  What's not?  What does
   the future look like?  Can you get there?  Be deliberate and not arbitrary in your
   technical evolution, but *do evolve*.  Without this step, the entire thing falls
   apart.

A younger version of myself would not be into this way of working, so I can understand
if some of you think this is oppressive.  All I can tell you is that it is a pure joy
to solve problems amidst a consistently-architected set of applications, all of which
are themselves internally consistent, despite the technology that makes things
consistent{% fn_ref 4 %}.  Such an
environment is encouraging of problem-solving, which is what I love about programming.
Arguing over `describe` vs. `test` seems de minimis now.


----

{% footnotes %}
  {% fn And you can see very clearly what Rails <strong>doesn't</strong> provide by surveying the common debates, for example where business logic goes. %}
  {% fn It can also be very unpleasant working on teams like this, because over time, interesting and high-value projects become impossible, and developers turn into ticket-takers, just pumping out simple features, since they are all that can be reasonably accomplished %}
  {% fn To be fair (to myself), in one of these cases, the team was encouraged to use whatever we wanted for whatever reason, and I bought into it. %}
  {% fn The easiest codebase I ever worked in was in Java, using Spring, because the code was so consistenty designed and written.  Almost every change to it felt like I was merely transcribing business logic. %}
{% endfootnotes %}

[book]: http://www.theseniorsoftwareengineer.com
[resultsexcerpt]: www.theseniorsoftwareengineer.com/focus_on_delivering_results_excerpt.html
[refactoringpost]: http://www.naildrivin5.com/blog/2013/08/08/responsible-refactoring.html
[stitchfix]: http://www.stitchfix.com
