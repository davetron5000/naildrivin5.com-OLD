---
layout: post
title: "&dagger; Stitch Fix Git Workflow"
date: 2013-07-30 11:04
comments: true
categories: 
---

The Stitch Fix [tech blog][blog] is up, and I just posted [how we use Git and Hubot][post] to automate deployment, without having a complex series of
branches and tags.

> This is fairly simple - new code goes on branches, master is always deployable (when clean), and `deploy/production` always contains whatever's on production. 

[My book][book] talks about bootstrapping new applications, and my recommendation is to set up continuous deployment.  If you've ever worked on a release
schedule, you'll know that continuous deployment is a pure joy.  It's also a boon to the users, who get the features and fixes as fast as possible.

[blog]: http://stitchfixjobs.com/blog
[post]: http://stitchfixjobs.com/blog/2013/07/30/our-git-workflow/
[book]: http://www.theseniorsoftwareengineer.com
