---
layout: post
title: "&dagger; Anatomy of a Rails Service Object"
date: 2015-06-02 09:14
comments: true
categories: 
---

I haven't been good at blogging for a while.  Most of my writing has been toward a new book (details
forthcoming), but I did manage to write up how I see designing service objects for Rails applications
over at [Stitch Fix's Eng Blog][sf-blog].

[Anatomy of a Rails Service Object][post]:

> We've given up on “fat models, skinny controllers” as a design style for our Rails apps—in fact we abandoned it before we started. Instead, we factor our code into special-purpose classes, commonly called service objects. 

The post goes over six rules of thumb that I've found useful, including class design, method parameter,
and return values.

[post]: http://technology.stitchfix.com/blog/2015/06/02/anatomy-of-service-objects-in-rails/
[sf-blog]: http://technology.stitchfix.com/blog
