--- 
title: My first iPhone App - Part 4
layout: post
---

_See [Part 1][part1], [Part 2][part2], and [Part 3][part3] first_

The past week was spent trying to understand the best way to expand my application's features without have a ton of duplicated code or UI.
It was also a learning experience on Core Data.  Thankfully, [Stackoverflow][stackoverflow] and its amazing contributers were very helpful.

## Core Data Blunders
It started as I made my first foray into implementing the search screen (i.e. the home screen of my app):
    
![Home Screen](/images/wine_brain_homescreen.jpg)

Three of the searches (most recent wines, wines by rating, and all wines) end up doing the same thing more or less: Query for some data, sort it a certain way, and show it in a <code>UITableView</code>.  I ended up creating a custom table cell view and I wanted all three to use it:

![Custom Cell](/images/wine_brain_custom_cell.jpg)

Access to Core Data-provided entities is done through objects of the class <code>NSFetchedResultsController</code>, which takes what amounts to a database query and provides many ways of accessing the results, including caching, callbacks, and iteration.  When using a table view, you typically have your view controller handle callbacks for this class, which allows the table to update itself when items are added, removes, or changed.  All of this boilerplate is given to you at the start of the project.  So far so good.

My plan was to create additional <code>NSFetchedResultsController</code> instances inside my table view controller class and then switch between them.  A fine idea that lead that numerous random difficult-to-reproduce crashes.

It turns out the basic idea of what I was doing was good, but my implementation exposed a sore lack of understanding of how all this stuff fit together.  I'm still not sure I fully grasp it (and wish the book I bought had a bit of a deeper dive into Core Data), but after some more reasoning, I got around it.  Essentially, leaving the unused <code>NSFetchedResultsController</code> instances connected to my table view *and* having caching turned on *and* not properly reloading data when switching searches created a situation where they were all pretty confused about the underlying state of the database.

With some judicious management of these instances, as well as disabling caching, I now have a fully-functional "Recent Wines", "Wines By Rating" and fancy indexed "All Wines" view (index meaning I can jump to wines by letter, a la the Contacts application).

Unfortunately, the result of turning off caching is that it takes a noticable blip of time to summon any of these views.  I may just come full circle and end up with three different <code>UITableViewController</code> instances and NIBs just so I can leave Caching on.

## User Experience

Once I had gotten back to a stable app, I loaded it up on my phone and headed into the field.  A few nights ago, Amy and I ended up at one of our favorite restaurants/wine bars in DC, [Proof][proof].  We've been there several times, and many of their wines-by-the-glass are in the Wine Brain.  While they rotate their selections, I was curious as to what I'd had there previously.  Unfortunately, I had yet to implement the search-by-location feature :)  Combing through the "All Wines" view was a bit frustrating.  This made obvious several features that are now on the top of my list (some planned previously, some not):

* Find wines by location
* Actually *entering* the location at which I had a wine
* Location-aware assistance of location (e.g. "Are you at Proof?  Here's what you've had there...")
* Ability to text-search the "all wines" list

The good news is that my cursory reading of my book and the API docs indicates that these things are going to be *very* easy to implement.

## Objective-C

There's a lot to like about Objective-C, and a lot to dislike.  Even though the handling of multiple arguments is a bit strange, I find it actually results in fairly readable code.  It feels very Apple; different, but usable.  Even though it's a lot to type out something like:

    NSString *stripped = [canonicalName stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];

It *is* pretty readable, regardless of what programming language you are coming from.  That being said, stack traces and error messages on crashes are nigh-useless, and the overall testability of iPhone apps is pretty behind the times.  This months [issue of Prag Prog's magazine][pragprog] has an interesting article on [iCuke][icuke], which I look forward to trying out.  I've resulted to keeping a text file of test cases that I have to manually run through to make sure I haven't broken anything, and it feels, well, 1997.  The rumours of a Apple's switch to Ruby are too good to be true, but one can always dream.

_Continued in [Part 5][part5]_

[part1]: /blog/2010/06/23/iphone-app-part-1.html
[part2]: /blog/2010/06/27/iphone-app-part-2.html
[part3]: /blog/2010/06/29/iphone-app-part-3.html
[part5]: /blog/2010/07/18/iphone-app-part-5.html
[stackoverflow]: http://www.stackoverflow.com
[pragprog]: http://pragprog.com/magazines
[proof]: http://www.proofdc.com
[icuke]: http://github.com/unboxed/icuke
