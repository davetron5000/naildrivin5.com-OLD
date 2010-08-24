--- 
title: My first iPhone App - Part 1
layout: post
---

## Background

Last year, I spent most of my free time becoming familiar with Ruby, Rails, and Scala.  I'm by no means an expert, but I'm trying
to follow the advice of the [Pragmatic Programmers][pragprog] and learn a new language/system every year.  This year, it's
going to be the iPhone API and Objective-C.  I coded some WebObjects applications in Objective-C many years ago, so the language
isn't totally unfamiliar, but the iPhone SDK, obviously, is.  After working my way through the first several
chapters of the [Dudney and Adamson's "iPhone SDK Development"][iphone_sdk] book, I decided I was ready to try my first real app.

## First App

My girlfriend and I enjoy wine, but are largely novices.  On a trip to Napa we started writing down the wines we'd tried and keeping personal
ratings of them.  The idea being twofold: try to remember good wines/avoid bad ones, and try to hone in on what our tastes are.  There are
so many wines and so many flavors and smells, it's just impossible to keep in your head.  So, I created a Google Spreadsheet and a form to allow us to enter wines on the go, via our smart phones.  The Goolge Docs form is less than usable, and this seems like the perfect job for a native iPhone app.

### User Experience

Aside from learning the ins and outs of the SDK, another main goal is focus on making a highly-usable application (at least for myself and my girlfriend).  So, before diving into Core Data and modelling the domain, my first version of the applicaton simply presents the "add a new wine" screen.  This will be the screen I spend the most time in, and it's important to make it fast and easy.

The Google Spreadsheet currently collects:

* Wine Name
* Vineyard
* Vintage (year)
* Varietal
* Type (e.g. red/white)
* Where we had
* When we had
* My rating
* Her rating
* Tasting Notes

That's obviously too much for one iphone screen, and, if I'm entering something in a hurry, I might not have time to go through all that.  Further, I think adding multiple ratings makes things a bit confusing, so I focussed my screen on the identifying characteristics (name/vineyard/vintage), the rating, and the type:

![First Attempt](/images/wine_brain_new_wine_1.jpg)

As you can see, I tried to fit the "where" on the bottom, as well as a "enter more information" button.  After loading this on the phone, it was just not working out, plus I was missing the varietal, which is fairly important (at least to me).  

My next attempt simply ignores the "add more" concept, and, by using the segmented control, I was able to fit the type into a more compact area, while including the varietal as a "slot-machine"/picker.

![Second Attempt](/images/wine_brain_new_wine_2.jpg)

My plan is to load this onto the phone and try using it the next few times I'm out.  I figure I can do without the tasting notes or location if it keeps the UI simple

### The Code

Objective-C and XCode are a whole different world from Java or Ruby.  First thing that bit me is the memory management.  I was familiar
with the rules (or so I thought).  Basically, if you call a method like "copyXXX" or "initXXX" to create a new object, you must
<code>release</code> it when you are done with it.  If you get access to an object through any other means, you should *not* release it.

{% highlight objc %}
// my class has an NSArray called varietals that I'm initializing here
varietals = [NSArray arrayWithObjects:
                  @"Barbera",
                  @"Cabernet Franc",
                  // snip
                  @"Zinfandel",
                  @"Other",
                  nil];
{% endhighlight %}

Since I'm *not* calling an "init" style method, I figured I didn't need to release it in <code>dealloc</code>. For some reason, this made me decide that I didn't need to <code>retain</code> it.  This caused my first crash and trip through the debugger to figure out what in the heck is going on.

{% highlight objc %}
// my class has an NSArray called varietals that I'm initializing here
varietals = [[NSArray arrayWithObjects:
                  @"Barbera",
                  @"Cabernet Franc",
                  // snip
                  @"Zinfandel",
                  @"Other",
                  nil] retain];
{% endhighlight %}

Since I needed <code>varietals</code> to survive the method where I was initializing it, I had to <code>retain</code> it.

### Other struggles

Interestingly, laying out the UI and getting that hooked up isn't too bad; the thing I'm having the most trouble with is figuring out what is the "unsurprising" way of doing things; tutorial code from books is rarely very well written; it's usually done in a certain way to make concepts clear, but I haven't yet found a definitive "here's how you organize your code" or "iPhone best practices" that seems relatively comprehensive.

At any rate, I figure if I can get the UX to be reasonably good, the rest should sort itself out.

I'll continue posting about my progress here on my blog.  If I can get the app polished and working, my girlfriend might demand and Android version.  Would be interesting to compare the two paradigms (especially since Android is all Java, which has been my bread-and-butter for many years).

[Continued in Part 2][part2], [Part 3][part3], [Part 4][part4], and [Part 5][part5]

[pragprog]: http://www.pragprog.com
[iphone_sdk]: http://pragprog.com/titles/amiphd/iphone-sdk-development
[part2]: /blog/2010/06/27/iphone-app-part-2.html
[part3]: /blog/2010/06/29/iphone-app-part-3.html
[part4]: /blog/2010/07/08/iphone-app-part-4.html
[part5]: /blog/2010/07/18/iphone-app-part-5.html
