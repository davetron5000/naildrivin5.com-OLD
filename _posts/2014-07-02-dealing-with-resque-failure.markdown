---
layout: post
title: "Dealing With Resque Failure"
date: 2014-07-02 11:27
link: http://technology.stitchfix.com/blog/2014/07/02/how-we-deal-with-failing-resque-jobs/
---

Over on [Stitch Fix's engineering blog][1], I wrote a [new post][2] on how we deal with tricky job failures.
Namely, make your jobs idempotent:

> Trapping `Resque::TermException` is really just kicking the can down the road. You might prevent some of your jobs from failing, but you'll still get failed jobs. Granted, they will fail at a lower rate, but it's still a rate correlated to the scale of your business.
> 
> The underlying problem is that jobs aren't **idempotent**.

Check out the entire thing [here][2].

[1]: http://technology.stitchfix.com/blog
[2]: http://technology.stitchfix.com/blog/2014/07/02/how-we-deal-with-failing-resque-jobs/
