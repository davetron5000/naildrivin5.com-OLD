---
layout: post
title: "What I learned interviewing with Instagram"
date: 2015-07-21 14:49
comments: true
categories: 
---

In September 2011, I interviewed at Instagram.
While I didn't ultimately get/take the job<a name="back-1"></a><sup><a href="#1">1</a></sup>, the experience had a pretty profound effect on me as a developer.  

What I learned during the interview process (which was really enjoyable, and became the basis for [my ideal technical interview process][interview]) was just *how much* two engineers with relatively little experience could accomplish.

<!-- more -->

My notes on the interview:

<blockquote>
<ul>
<li>a popular iPhone app</li>
<li>the back-end to serve millions and millions of users</li>
<li>an infrastructure that could be experimented with: attempt to run Mongo and see what happens</li>
<li>Implemented their data storage layer in Mongo, studied it, abandoned it</li>
<li>Enhanced their iPhone app with Open GL</li>
<li>Build, documented, and deployed an API and several clients</li>
<li>Created a demo using their API in Node</li>
<li>Have their entire infrastructure monitored; can identify any change in behavior of their system instantly</li>
<li>Have ready access to their data to support third-party hacking</li>
<li>Completely manage all of their servers</li>
</ul>
These are two guys with very little experience.
</blockquote>

If you had looked at these developers' résumés as of 2010, you would not find anything to indicate that they
could both design, build, launch, and maintain a hugely popular application used by millions of people
around the world..  And while I'm sure the code
that powered Instagram back in 2011 wasn't the greatest, these two guys had basically done everything
from designing the UI to launching an API, to managing servers on AWS.

They did this without a QA team, a system “architect”, a product manager, a _project_ manager, or a technical operations team.  

Before the interview, I didn't think such a thing would be possible.  I would've assumed that such an
undertaking would require years and years of experience, with an army of specialists each laser-focused
on one part of a greater whole.

Nope.

To me, this is what I mean when I use the term _full stack_.  It's not just about working at any level of
the stack, but about _not being afraid to_.  When faced with any problem, these two guys didn't show
fear, and didn't shy away…they dug in.

I used to _hate_ writing JavaScript.  Now, I have no fear and embrace it.  It turns out to be pretty darn
useful.  I used to immediately dismiss any solution that involved writing raw SQL.  I was above all that.
Now, I use it _a lot_, because it's the best way to solve a lot of thorny problems.

My current fear is around technical operations.  I'm working on overcoming it.  It's going to make me a
better developer.

Examine your habits and patterns.  What do you _always_ reach for?  What makes you feel uncomfortable.
What part of the software you build are you afraid of?

[interview]: http://theseniorsoftwareengineer.com/interview_potential_co-workers_excerpt.html

---

<footer class='footnotes'>
<ol>
<li>
<a name='1'></a>
<sup>1</sup>The process didn't get far enough along where they were deciding to make an offer or not.  We basically came to a point where I would need to be willing to move myself and my family out to SF so I could put in the blood, sweat, and tears necessary to help make them successful.  When I realized there was no way I could realistically do that, we split on good terms.  And then they got sold to Facebook for a billion dollars. Fortunately, I cannot stand Facebook and would <a href="http://naildrivin5.com/blog/2011/08/01/why-i-wont-work-for-google-twitter-facebook.html">never work there</a>.  At least, that's what I tell myself :)<a href='#back-1'>↩</a>
</li>
</ol></footer>
