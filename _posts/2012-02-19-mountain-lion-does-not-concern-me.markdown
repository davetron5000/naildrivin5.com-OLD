---
layout: post
title: "Mountain Lion Does Not Concern Me"
feature: true
date: 2012-02-19 12:09
comments: true
categories: 
---
Apple has just announced [Mountain Lion][mountain-lion], the next version of OS X, due out in the summer.  Although it's more of an incremental upgrade than Lion was<a name="back-1"></a><sup><a href="#1">1</a></sup>, one of the most interesting features is [Gatekeeper][gatekeeper].  Gatekeeper, in brief, prevents unsigned code from running on OS X.  Although it can be disabled, it's on by default, and many feel this is the beginning of the end for users having full control of their computers.  I feel the opposite: it's *not* a slippery slope, and it's actually a *great* feature.  
<!-- more -->

With the release of the [Mac App Store][appstore], it was clear that Apple wanted users managing third-party software much as they do on iOS devices: blessed apps vetted by Apple.  [Marco Arment][marco] has written [in detail][marco-appstore] about how this approval process isn't that bad and that it's a net gain for users:

> First and foremost, the review process has created a level of consumer confidence and risk-taking that has enabled the entire iOS app market to be far bigger and healthier than anyone expected. Average people — the same people who have been yelled at for decades for clicking on the wrong button on the wrong incomprehensible dialog box and messing up their computers — can (and do) confidently buy large quantities of inexpensive apps impulsively, without having to worry that any of them will “break” their iPhones or iPads, rip them off, destroy their data, or require them to embarrassingly visit the corporate IT department, the Geek Squad, or their computer-savvy relatives (us) for help. Part of this is due to the highly sandboxed architecture enforced by the OS, but a big part is the app review process.

When Lion was released, there was a general feeling of fear amongst developers that, someday soon, the App Store would be the *only* way to get apps onto your Mac.  This would, in turn, destroy many useful apps that would just never make it through the review process (and, presumably, make development on a Mac much more difficult or impossible).  With what we know about Mountain Lion, it's clear that this dystopian future is not what Apple has in mind.  Gatekeeper is the proof.

[John Gruber][df] sums Gatekeeper up nicely in his [piece on Mountain Lion][df-mountain-lion] (emphasis mine):

>  It’s a system whereby developers can sign up for <strong>free-of-charge Apple developer IDs</strong> which they can then use to cryptographically sign their applications. If an app is found to be malware, Apple can revoke that developer’s certificate, rendering the app (along with any others from the same developer) inert on any Mac where it’s been installed. In effect, it offers all the security benefits of the App Store, except for the process of approving apps by Apple.

Finally, the feature can be entirely disabled:

!['Mountain Lion Security Preferences'](http://images.apple.com/macosx/mountain-lion/images/security_settings.jpg)

I think Apple would prefer "Mac App Store only" as the default.  Honestly, so would I.  I'd love to send my parents or sister a Mac that they simply *can't fuck up*.  *Many* grey hairs on my head are attributable to the trouble my family has gotten into with their PCs.  Granted, it's harder to get into this trouble with a Mac, but it's still possible.  And, as the Mac starts to take over [more and more of the PC market][asymco-mac], it will increasingly become a target for malware.

I think it's hard to argue that for "regular" users (and those of us doomed to support them), Gatekeeper is a net positive.

What about us developers?  Is this a win for us?  There's certainly a few unknowns:

* How does software installed via "traditional" means interact with this system?  If I download and compile the latest version of Ruby, but have Gatekeeper on, will it work?
* What about software written in a scripting language?  What if I `gem install` a Ruby command-line application (something I have a [vested interest in being able to do][clibook]), will it work?
* Will the option to "allow applications downloaded from&hellip;anywhere" go away in a future version of OS X?

It's hard to predict the answers to these questions without knowing more about how Gatekeeper works.  I *do* think that the mere existence of Gatekeeper's allowance of signed-but-not-from-the-App-Store-apps demonstrates Apple's understanding that developers and "power users" are important to the platform.  Think about it: what's in it for Apple to disallow unsigned applications completely?  What would Apple have to gain by making it difficult (or impossible) to write non-Mac software on a Mac?

Don't forget, many iOS and Mac apps are backed by web services written using tools like Ruby on Rails, PHP, or Java.  If Apple were to make it difficult (or impossible) to write, say, a Rails app on a Mac, it would be much more difficult to write an iOS app; the developer would need a second machine to write the web service.  It just doesn't make sense.

So, I think Gatekeeper is a win for average users, a win for geeks, and _not a concern_ for developers.    As such, I'm in favor of it.

----

<footer class='footnotes'>
<ol>
<li>
<a name='1'></a>
<sup>1</sup>I think Apple's plan of updating OS X every year is a good one - more releases with smaller features is just a better way of doing things.  I also wonder if the price of OS X is going to drop even further, to say $9.99?<a href='#back-1'>↩</a>
</li>
</ol></footer>

[marco]: http://www.marco.org
[marco-appstore]: http://www.marco.org/2011/02/04/ode-to-the-app-review-team
[df]: http://www.daringfireball.net
[df-mountain-lion]: http://daringfireball.net/2012/02/mountain_lion
[gatekeeper]: http://www.apple.com/macosx/mountain-lion/security.html
[asymco-mac]: http://www.asymco.com/2012/01/16/apple-is-the-top-personal-computer-vendor/
[mountain-lion]: http://www.apple.com/macosx/mountain-lion/
[appstore]: http://www.apple.com/mac/app-store/
[clibook]: http://www.awesomecommandlineapps.com
