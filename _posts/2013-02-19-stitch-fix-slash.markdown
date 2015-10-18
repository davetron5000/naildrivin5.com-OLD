---
layout: post
title: "Stitch Fix!"
date: 2013-02-19 08:18
comments: true
categories: 
---

Today is my first official day<a name="back-1"></a><sup><a href="#1">1</a></sup> a [Stitch Fix][stitchfix], where I'll be joining the small but awesome engineering team!  What I love about Stitch Fix is that it's such a simple business: buy clothes for one price, sell them at a higher price.  It's the very essence of what a business does.  "All" we have to do is find more people to buy things from us, figure out what they want to buy, and sell to them as efficiently as possible.

<!-- more -->

I got an overview of their operations, and it's amazing how well the business seems to work with almost no real automation (which is where the engineering team comes in).  This sort of thing - writing software to make other people's jobs vastly simpler - is what I love about programming.  It reminds me of a particular user of the software I was writing for the [US Marshals Service][usms]

I'd been there well over a year, and our requirements came from the government's technical project manager.  He was an old timer,
knew the business, and gathered new requirements and features from the users (who were a wide variety of cops, administrators,
and other IT people).  But now, we were getting to meet some real users in a real district office.  We talked to a lot of
different people about how they used the software and, more importantly, what they did at their jobs.

Learning about Stitch Fix's operations made me think of one person in particular from this trip.  Her team handled transporting
prisoners from jail to court - when a prisoner's court date arrived, the Marshals had to make sure he was in a bus that morning
headed to the courthouse from jail.  Part of this woman's job was to assemble that list on paper and hand it to the deputies in
charge of prisoner transport.

Unfortunately, there was no specific feature in the software to generate and print this list.  What she did instead was to call
up the list on screen via a custom query.  This was a VT100 app, so only about 20 prisoners were viewable on the screen at a
time.  She would then _print the screen_, and scroll to the next page, repeating this printing until she got the entire list.
The result was a stack of papers with 80x24 screenshots printed on them.

*And then* she would _cut out the list_ from each piece of paper before finally _taping the lists together_ and copying it to
hand off to the deputy.  It took her well over an hour each day.  And she wasn't the only one doing this - it was the simplest
way to assemble this list.

My colleagues and I were *begging* to fix this.  It would've taken one of us *maybe* a day to fully implement, fully test, and
deploy a report that would simply print out the list.  But, it wasn't a priority on the project plan, so it never got done. This
was *years* ago, so I hope this poor woman has retired or that *someone* has fixed this.

At Stitch Fix, I'm looking forward to actually *solving* these sorts of problems.  These really are the reason software is so great - minimal effort "typing shit into the computer" can save *days* for someone else.  Sometimes I think my job is to eliminate the need for tape and scissors.

---

<footer class='footnotes'>
<ol>
<li>
<a name='1'></a>
<sup>1</sup>I actually started yesterday, but it was a holiday, so almost no one was in the office (though I <em>did</em> get productive things done :)<a href='#back-1'>↩</a>
</li>
</ol></footer>

[stitchfix]: http://www.stitchfix.com
[usms]: http://en.wikipedia.org/wiki/United_States_Marshals_Service
