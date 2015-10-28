---
layout: post
title: "Rails' Degenerate Front-End Support"
date: 2014-08-07 08:59
comments: true
categories: 
feature: true
---

Rails front-end support is pretty degenerate and I don't understand why.  By "degenerate", I mean the mathematical notion of
"so simple as to belonging to another class".  And it seems that the Rails team isn't planning to do anything about
it any time soon, as DHH has doubled-down on "server-generated JavaScript responses".

Why isn't Rails leading the way here?  Where is the Rails that shocked the world with its elegant API for creating server-side
web applications?  It seems that it's still peddling the same solutions for rich user-interfaces as it was over four years ago.

<!-- more -->

## What was the world like that gave birth to Rails?

In 2005, to build a website, you either used a "throw it all into the view" technology (PHP), or a Model-View-Controller system
requiring a byzantine assemblage of configuration files (Java)<a name="back-1"></a><sup><a href="#1">1</a></sup>.
And it sucked.

But not for the reasons you think.  It wasn't so much that you had to create some configuration files in XML to
deploy a J2EE app, or that PHP is a terrible language.  It's because there were *so many ways* to do things.  I worked for years
on a Spring-MVC application and just in that framework alone, there were at least five ways to map a URL to code.  The framework
included at least three means of rendering HTML (ironicially, it contained zero ways to manage CSS).

Rails showed us that by *just deciding* on a few things, we can all be a lot more productive.  Rails showed us by
embracing a few conventions (or, really, [curated idioms](http://gilesbowkett.blogspot.com/2013/02/the-lie-of-convention-over-configuration.html)), our applications can be simpler to understand, easier to maintain, easier to test, etc, etc.

That Rails used Ruby is almost inconsequential.  The point is that Rails wasn't the embodiment of industry-wide agreed-upon best
practices; it was the embodiment of a _carefully curated set of practices_<a name="back-2"></a><sup><a href="#2">2</a></sup>.

And it was great.  As a lead engineer on a Spring-MVC project, I had to spend a lot of energy in code reviews making sure
everyone on the team stuck to our conventions, or the app would be an unmaintainable mess.  I had to make sure that new developers to the team knew how we did things (and why), so there was longer ramp-up than I would've liked.

As a team lead for a Rails project, I spend zero time doing that.  I don't have to argue with someone about how to connect a URL
to code.  I don't have to explain why we use template system X and not Y<a name="back-3"></a><sup><a href="#3">3</a></sup>.  The team just _solves problems_ instead of dealing
with the minutae of decisions that don't matter.

This is one of Rails' biggest strengths.  But it is sorely lacking in the front-end.

## Back End 2007: Meet Front-End 2014

Because computers and browsers are markedly more powerful than they were even 4 years ago, we have a lot more options to provide
solutions with our software.  We can create complex and highly-interactive UIs.  But there's a *ton* of ways to do it:

* JavaScript APIs
* JQuery
* Angular
* React
* Ember
* ExtJS
* Backbone
* Etc

There's a lot of great ideas in these frameworks, just as there were a lot of great ideas in the various web frameworks around in
2007.  And, just like web frameworks in 2007, they all have problems.

The difference from 2007 is that these front-end frameworks are all useless on their own.  Any web application needs a back-end.
And Rails is a terrific back-end.  Unfortunately, the Rails party-line is *still* to render HTML server-side and "just use
JQuery" if you want to do something other than render a template.  Try showing and hiding some `DIV`s in Rails with JQuery.  It
sucks.

And remember my snarky comment on Spring-MVC not supporting CSS management *at all*, yet calling itself a web framework?
The 2014 equivalent is the management of third-party front-end assets, for which Rails provides pretty much _no_ direct support.
Rails just assumes you'll have a
RubyGem that…contains CSS and JavaScript.  That either you must maintain or hope someone else maintains.  That can only depend on
other front-end assets if they, too, are managed and distributed as RubyGem.  Yes, [you can (and should) use Bower](http://growingdevs.com/stop-using-rubygems-and-start-using-bower.html), but it's kludgy at best.

Could it be that we just don't know enough about building richer user interfaces for there to be the mythical "RailsJS"?

## Waiting for Best Practices?

There are no "best" practices.  There are only practices which apply in certain situations.  Some apply in more situations than
others, but there is no "one way to do it" that, if we just wait long enough, will reveal itself.  We simply have to curate the
best set of practices we can, based on our current knowledge.

I see a few ways for Rails to address this:

* **Do nothing**.  That's what its doing now, and this is going to make using Rails painful.
* **Better client/server glue, but leave the specific front-end code to someone else**.  Here, we acknowledge that
Rails developers need a lot more front-end third-party packages than we did four years ago, and make that experience a lot better
than it is now.  We acknowledge that we're going to be writing a lot more JavaScript and add some semblance of support for
testing, and a standardized way to test in-browser.
* **End-to-end solution**.  Here, Rails provides a framework for every aspect of the web application.  "RailsJS" would be to
JQuery what Rails was to Ruby+ERB+`mod_ruby`+MySQL Gem: a curated set of conventions, embodied in code that make the "80% case"
dead simple.

The third option may be a unicorn.  While many server-centric web applications can be thought of as a "CRUD app" if you squint
hard enough, a rich user
interface doesn't quite fit any particular mold.  When you consider that such a user interface must also contend with the
assembler-like nature of CSS and HTML, a "RailsJS", if not carefully designed, could be too special-purpose as to not be
generally useful.

But hiding our heads in the sand and pretending server-generated JavaScript will carry us through seems like the wrong bet.  Even
for "non-ambitious" applications.

## We've All Got Some Ambition

My ex-colleague [Adam Keys](https://twitter.com/therealadam), in his [recent blog post](http://therealadam.com/2014/08/06/how-rails-fits-into-the-front-end/), has some great points, but this one stood out:

> For the rare team building ambitious applications, an opinionated framework like Rails is probably the last thing you want. Ambitious applications, perhaps by definition, are going to cut against the grain in one or more places. An opinionated framework is only going to get in the way of the opinions that make the application ambitious in the first place.

I think this creates a false dichotomy between "Yet another CMS app" and "Gmail".  I work on line-of-business apps that are used
to run an e-commerce startup.  These apps are not what I'd call "ambitious", but they certainly benefit from being more
interactive.  Simple things like showing dialogs, revealing/hiding markup, and refreshing a view based on server updated state
seem like features that almost any app would want, not just "ambitious" ones.

Doing these in e.g. JQuery is painful.  It requires a *lot* of boilerplate, is hard to test, and there's a lot of ways to do it.
This means there's, at best, a ton of friction when implementing these features, and, more likely, we deliver crappier solutions
because making something nicer takes too long.

Using a framework like AngularJS makes all of this much simpler; a lot of the friction is gone.  But, the second you bring something like that into your Rails app you 
[start to realize that the core team hasn't even considered it](http://angular-rails.com/bootstrap.html#front-end-dependency-management-with-bower).

Maybe this is a long way of agreeing with Adam's last point:

> I think a lot of this comes down to Sprockets' ability to gracefully grow to support front-end practice. It already does a pretty good job. Adding better support for browser components (e.g. Bower) would be good, as well as keeping up with SVG, web fonts and other somewhat special asset types.

Just an acknowledgment that many apps will need more sophisticated front-ends whose needs can't be served by "Server-Rendered
JavaScript" and "Just use JQuery" might be a step in the right direction.

The thing is, developers will move on.  The front-end is only getting more relevant as more and more can be done there to provide
a great user experience.  It seems logical that Rails would want to continue to be leading the industry on how to build web apps,
  but it seems like right now, it's starting to lag.



----

<footer class='footnotes'>
<ol>
<li>
<a name='1'></a>
<sup>1</sup>I'm going to pretend tech like JSF, that attempted to abstract away the fact that you were creating a web app, never existed.  Ech.<a href='#back-1'>↩</a>
</li>
<li>
<a name='2'></a>
<sup>2</sup>Some of which aren't actually all that “best”, e.g. colored, timestamp-less, multi-line logging.<a href='#back-2'>↩</a>
</li>
<li>
<a name='3'></a>
<sup>3</sup>This isn't <strong>entirely</strong> true, as shit like HAML exists.  You all know we could've gotten to the moon five years earlier if we hadn't been arguing about HAML, right?<a href='#back-3'>↩</a>
</li>
</ol></footer>
