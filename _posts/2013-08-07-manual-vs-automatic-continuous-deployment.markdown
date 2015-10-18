---
layout: post
title: "&dagger; Manual vs Automatic Continuous Deployment"
date: 2013-08-07 12:31
comments: true
categories: 
---

My ex-colleague from LivingSocial, [Dan Mayer][dantwitter] posted a [great read about continuous deployment][danpost], and the tradeoffs when doing an automatic deploy:

> After considering some of the real world implications of automated continuous deployment, I didn’t feel it was right for our team on most of our projects at the moment. Both because we would need a bit of additional tooling around deployment and dashboards, and because our tests are far to slow.

It's a good (and quick) read. Having worked on at least one of the apps that Dan's talking about, I would agree he's making the right call and that if your test suite is slow, automatic deployment can be a killer.  I also think there's a relationship between the size of the contributor group and the speed of the test suite - the more devs pushing stuff in, the faster it has to be.

In [my book][book], there's a chapter on bootstrapping new applications, and my recommendation is to set up automatic continuous deployment from the start.  I stand by that, because it basically turns the problem Dan identifies around: slow tests slow your deployment which should thus motivate keeping tests slow (and applications lean).  We'll see how it works out at [Stitch Fix][gitblog].  We have one app with a somewhat slow test suite, and three with relatively fast ones.  Automatic deploys work really well so far.

[dantwitter]: https://twitter.com/danmayer
[danpost]: http://mayerdan.com/programming/2013/08/04/thoughts-on-continuous-deployment/
[book]: http://www.theseniorsoftwareengineer.com
[gitblog]: http://stitchfixjobs.com/blog/2013/07/30/our-git-workflow/
