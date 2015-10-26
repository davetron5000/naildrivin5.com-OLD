---
layout: post
title: "Naming and API Design"
date: 2015-06-15 07:55
comments: true
categories: 
---

A tenet of design is that things that are the same should be obviously the same, and things that are different should be obviously different.  This is the most basic way to create consonance and contrast, and is a great rule of thumb when designing *anything*.  While Rails diverges from this in an annoying way<a name="back-1"></a><sup><a href="#1">1</a></sup>, Angular diverges in a baffling way that makes explaining it to a newcomer head-scratchingly difficult.

<!-- more -->

## The World's Silliest Programming Language

Imagine the following programming language.  To define a function, we name it using a _dasherized_ scheme,
with square brackets to offset the arguments:

```
define full-name[first-name,last-name]
  first-name + " " + last-name
end-define
```

Further imaging that in this programming language, to _invoke_ the function you use a camel-cased version
of the function name, and use parenthesis to offset the arguments:

```
print fullName("Dave","Copeland")
```

I don't think it's a stretch to call this language poorly designed.  Things that are the same—a
function—are handled differently depending upon the occasion.  The design of this language would benefit
greatly if you defined functions using the name symbol used to invoke them.

This example might seem pretty ridiculous, but this is _exactly_ what Angular does.

## Dashes, Camels, and “ng”

Angular uses _directives_ in HTML to bind your code to the DOM or to DOM events.  The simplist one to
understand is `ng-click`:

```html
<button ng-click="doit()">Do It! Do It, Now!</button>
```

This calls `doit`, whenever the button is clicked.

Are you curious about the documentation for `ng-click`?  It's filed under `ngClick`.  The text `ng-click`—the thing you must type into your application's source code to make it work—does not appear in Angular's
source code.  Everything talks about `ngClick`.  Why?  I have no idea.

It gets worse.

## Good Luck Finding That Thing You Downloaded

I'm writing a book on getting Angular, Rails, Bootstrap, and Postgres working together, and how these
four technologies in sum are greater than their parts.  It's going to be awesome.  Documenting Postgres
is easy (“check out this thing you didn't think a relational database could do!”), and for Bootstrap,
it's just as simple (“put this class on this element and…boom!”).

Angular has resulted in many passages like the following.  I'm talking about Angular's router, which is a
separate component.  The first thing the user has to do, after downloading the module, is configure it in
their application.  Essentially, you need to say "my app requires the router I just downloaded".

> That argument [when declaring the app] is our app's list of dependent modules.  It's currently empty, because we hadn't needed anything other than what's provided by Angular.  Now, we'll need to add `angular-route` to this array.
>
> Unfortunately, it's not as simple as adding `"angular-route"` to the array.  In Angular, the module name for declaring dependencies doesn't have to be the same as the name of the module we downloaded. For official Angular-provided modules this is unfortunately the case.  
>
> By convention, the name to use in code for an Angular module can be derived by replacing the `angular-` with `ng` and camel-casing the remaining module name.  That means that `angular-route` becomes `ngRoute` and so `"ngRoute"` is the string to add to our list of dependencies.

The reader has had type one string—“angular-route”—into their application's source code already (so that Bower/NPM/Whatever.JS could download it) And now, I have to give the reader _an algorithm they must execute mentally_ in order to know what string to type into another part of their application.

This is bad design.

When faced with bad design, there is often some sort of tradeoff, some reason the system was designed
this way.  While I can hazard a few guesses about the whole `ng-click`/`ncClick` issues<a name="back-2"></a><sup><a href="#2">2</a></sup>, I've got *zero* clue why the name of a module in your dependencies shouldn't be the name of the module
you downloaded.

It's so confusing that I have to invent a new phrase just to explain the difference.  If I download
`angular-route` and use `ngRoute` in my code, which of those is the _module name_?  Who knows?

Imagine if the module name was the…well…module name?

> That argument [when declaring the app] is our app's list of dependent modules.  It's currently empty, because we hadn't needed anything other than what's provided by Angular.  Now, we'll need to add `angular-route` to this array.

End of description!

Same things should be same.

----

<footer class='footnotes'>
<ol>
<li>
<a name='1'></a>
<sup>1</sup>Try explaining to someone new to Ruby and Rails how to find out what file should contain the class <code>SomeModule::SomeClass</code><a href='#back-1'>↩</a>
</li>
<li>
<a name='2'></a>
<sup>2</sup>All I can figure is that some fussy developer didn't want camel case in their markup, but you can't define a JavaScript function with dashes.  I'm not saying it's a <strong>good</strong> reason, but it is a reason<a href='#back-1'>↩</a>
</li>
</ol></footer>
