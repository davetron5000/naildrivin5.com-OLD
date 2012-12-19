---
layout: post
title: "Re-use in OO: Inheritance"
date: 2012-12-19 09:30
comments: true
categories: 
---
Over the past several months, the Rails community, at least to my eyes, has become increasingly concerned with managing the
complexity that appears when following the "fat model, skinny controller" advice prescribed my many Rails experts.  The real
issue, however, is _reusability_.  How can logic be easily used in two places?  In your average object-oriented language, there
are four primary ways to accomplish this:

* Copy and Paste
* Inheritance
* Composition
* Mixins

None are so superior to the other as to always be applicable, so how can we know when to use one over the others?

<!-- more -->

We re-use code to avoid duplication, yes, but also to get our jobs done more quickly.  The form of our re-use is important,
as it has the capability to change the way we've modeled our solution in code.  And the way we model our solution in an
object-oriented language is via classes, or types.  We create classes that represent various domain concepts, and each class
forms a _type_ that describes what is, and is not, part of that domain concept.

Before we get into that, it's worth talking about the most basic form of code re-use - one that we've all certainly used before:
copy and paste.

## Copy and Paste

Copy and paste is usually a sign of [sloppy code][sloppost], however there are two forms of re-use where copy and paste is
acceptable.  The first form, which I'll call _Stackus Overflowus_ is when you find a snippet of code somewhere that solves a
problem at hand, and copy it into your codebase.  Usually, it's a small amount of code for which there is no obvious library you
can pull in, and you only need said code in one location in your app.  Copy and paste is the quickest way to move on, and,
assuming the code is "universal", is unlikely to need to be updated later.

The second is more subtle and rare.  Suppose you have two bits of logic in your app that are identical but that are concerned
with entirely different domain concepts or business processes - the code is the same _by happenstance_.  Will it improve the
codebase to extract this duplicated logic somewhere?  What if these already different business processes diverge further?  Now,
you have to deal with making your extracted, ["DRY"][DRY] code deal with this divergeance.

You can actually make your app *harder* to change by "drying up" code that really isn't _the same by design_.  But, in my
experience, this is rare.

More common in OO systems is inheritance.

## Inheritance

Wikipedia defines [inheritance] as:

>  a way to reuse code of existing objects, or to establish a subtype from an existing object, or both

I'm going to assume _single_ inheritance here, as that is common in common OO languages, and this means that a class only has one
supertype - you get one class as your base class, and that's it.

Re-use via inheritance is the most far-reaching and drastic - your new subclass gets the entire public interface of the
superclass, plus whatever public interface it exposes on its own - as well as all the private methods and members.  It's copy and
paste performed by the compiler or runtime.

Inheritance also makes a design statement - it says that the new subclass *is a type of* the superclass.  The new class is a more
specialized, less abstract version of the superclass.  The runtime should treat instances of the subclass the same as instances
of the superclass.

Often, however, we subclass to simply pull in code we'd like to re-use.  In a rails app, all controllers inherit from
`ApplicationController`.  In an aging, complex Rails app, `ApplicationController` becomes a dumping ground of random methods that
are needed by "a lot" of controllers - it's effectively a global scope for code that doesn't have an obvious place to go.

On good days, inheritance is a powerful tool to describe the types that make up your system.  Code can be re-used and customized,
often in ways not intended by the designer of the super class.  This can be very powerful, but it can also lead to a mess.
Further, it can be hard to test classes that re-use code from a superclass - just try to test an active record object without
having access to the database.

Finally, inheritance brings a public interface to your subclass that you may not want.  Each time you subclass, you create a
class with more public methods, which actually can _dilute_ the very types you are trying to create.

In a language like Ruby or Scala, where we have mixins (see below), I find inheritance to be useful only when I'm truly defining
a hierarchy of types - when I want to say "here is a generic type, and I'm going to make some specializations of it to avoid
massive `if` statements all over my code", or when I need to customize a type I didn't create, for the purposes of using it with
code expecting the original type.

To get around the limitations of inheritance, the most obvious alternative is to use composition.

## Composition

_Composition_, as [defined by Wikipedia][composition] is:

> a technique by which classes may achieve polymorphic behavior and code reuse by containing other classes that implement the desired functionality instead of through inheritance.

This definition is focused on where the implementation of a particular public interface lives.  With inheritance, we present a
public interface whose implementation is provided by the superclass.  Here, it's done via "some other class".  In a statically
typed language like Java, composition is a pain - you have to define all the methods and proxy their calls to the composed class.
For a dynamic language like Ruby, classes like `Delegator` or a well-crafted `method_missing` can make this a snap.

But we're talking about code-reuse here.  As it applies to code re-use, the term "composition" colloquially means "call methods on
a private object".  In other words, if I want to re-use some shared logic, I put that logic in a class, create an object of that
class, and call its methods.

This has the advantage of being easy to implement and easy to understand - it's probably what an inexperienced person would do if
they didn't know about inheritance.  Using composition in this way doesn't affect our types - our class' public
interface remains unchanged - and doesn't require fitting our model into some complex hierarchy.

This technique has a few downsides:

* method calls are on some object, making them more verbose
* if we create said objects as needed, we make isolated testing clumsy, difficult, or even impossible
* if we instead use [inversion of control][ioc] and let someone else give us the objects we need, we now have to have some "container" to "wire up" all of these dependencies.

The last two issues are particularly dicey.  In your average Java app, using externally configured dependency injection is the
defacto standard, so you get used to writing classes based on inversion of control.  In Ruby or Rails, this is not the way things work, and adding this "object container" just feels wrong.  The "container" adds complexity that we'd like to avoid, even if it affords us easier isolated testing.

Is there a way to avoid the issues and restrictions around inheritance, but without the baggage of composition?  There is:
mixins.

## Mixins

Back on Wikipedia, a [mixin] is defined as:

> a class that provides a certain functionality to be inherited or just reused by a subclass, while not meant for instantiation

This is a bit vague, but the idea is that we can "mix in" methods from one class into another without creating a rigid, single
"is a" relationship, but without *also* having to use complex delegation to a composed object.

Ruby uses modules for mixins, and Scala uses traits.  Neither are technically classes, but they *are* types.

The way in which code is re-used from a mixin is identical to the way it's done via inheritance - the methods magically appear as
if part of the class.  This goes for both private/protected members *and* public members.  You can also mixin as many
modules/traits as you like - there's no practical limit.

In DHH's [blog post][dhh], he creates a mixin called `Taggable` that represents "a thing that has tags".  This allows you to create a single bit of code for whatever it means to have tags, and to re-use it across the system.  He describes a second mixin called `Visible` that works similarly, before describing how we might use both of those in the same class.

This has a lot of positive effects:

* A single place for shared logic
* Said logic is available expediently - no need to call methods on another object
* No need to manage instances of other objects or worry about inversion of control
* Isolated testing is much simpler than with inheritance

This sounds like a pretty awesome solution to the problems presented by both inheritance and composition.  So, what's the
problem?

The "abuse cases" of mixins are particularly annoying.  Case #1 involves including "too many" mixins.  Since a mixin can contain
public members, namely methods, a class with a lot of mixins will have a very large public footprint.  The resulting
objects begin to move away from a "type" toward a "god object".  The rules of coupling and cohesion start to come into
play, and you can end up with a system where changes to a module that's frequently included can have disastrous effects.  Making
this mess with inheritance or composition is *much* more difficult.

Of course, no technique should be dismissed because those with bad design taste abuse it.  I find a good rule of thumb is in how
these mixins are named. Mixins names should adjectives, not nouns or verbs.  Although DHH refers to this pattern as "concerns",
you'll notice that none of his mixins are named "Concerns". He doesn't have a `PersonConcerns` module, but instead has
modules for various features to be added.  If you can't name your mixins as adjectives, you might be doing something wrong, and
if your mixin has the word "Concerns" in it - you've definitely screwed up.

Abuse case #2 is a misguided attempt at code organization.  To feel better about creating bloated god
objects, developers will extract groups of possibly-related functionality into a mixin and then mix it into the main class.  This
is hiding the problem of a bloated class that does too much.  Preventing this is easy - if your mixin isn't being used by more than
one class then it should not have been extracted (the naming rule helps, too - if you can't name something you're less likely to
extract it)

There's an interesting footnote of sorts to this technique, and that is DCI - Data, Context, and Integration.

## I really don't understand DCI, but

Jim Gay's [Clean Ruby][cleanruby] is an in-progress treatise on the DCI, and I've not read the entire thing, nor will I claim to understand DCI beyond examples I've read, including [Jim's recent post][jimgay].  But the examples are interesting.

In the classic use of mixins, one declares the modules to be mixed-in as part of the class definition.  In the examples around
DCI, however, one mixes-in the needed code *only when needed*.  So, a `Person` that might need tagging would only have `Taggable` mixed in when code requires the ability to tag a person.  By default, a `Person` would not be taggable.  In Ruby, this might look like:

```ruby
person = Person.find(params[:id])
person.respond_to? :tag_names # => false
person.extend(Taggable)
person.respond_to? :tag_names # => true
```

This sort of dynamic type manipulation is not possible in every language, but it seems interesting to me.  Although it has some
abuse cases that seem equally horrible to those of vanilla mixins, I can think of some legacy code that could've done well to
have code organized this way.  With "call-time mixins", developers could add features to core objects with relative
impunity, safe that their new changes wouldn't cause regressions across the system.  The idea is you add mixins for "use cases" or "roles" and that existing code, not needing these roles, will work as before, even if code somewhere else dynamically mixes in this new code.

At first blush, this seems like a great way to tame complexity in legacy apps where good design has gone out the window, and
line after line of legacy code has been dropped into core classes.  For a greenfield application, with careful attention to
design and code cleanliness, this seems like less of a win to me, and would lead to more "surprising" code.
But, I haven't read all of Jim's book, yet, so I look forward to him making the case.

## So, always use mixins?

Mixins *do* hit a sweet spot, practically speaking, but they aren't a panacea.  Here's my rules of thumb:

* Is the re-use concept an adjective?  Is it needed across the system by disparate classes?  Might be a mixin.
* Is the re-use concept a refinement, specialization, or customization of an existing type?  Might be time for inheritance.
* Can't figure out *what* to do? Use composition.  Composition is *always* safe because it's simple to create and use, even if
  it's more verbose.  Better to use composition when a mixin would do than to create a poorly-conceived mixin.
* Please be wary of copy and paste.


[dhh]: http://37signals.com/svn/posts/3372-put-chubby-models-on-a-diet-with-concerns
[jimgay]: http://saturnflyer.com/blog/jim/2011/10/04/oop-dci-and-ruby-what-your-system-is-vs-what-your-system-does/
[srppost]: http://www.naildrivin5.com/blog/2012/06/10/single-responsibility-principle-and-rails.html
[bettercodepost]: http://www.naildrivin5.com/blog/2012/06/27/what-is-better-code.html
[dci]: http://en.wikipedia.org/wiki/Data,_Context,_and_Interaction
[sousvide]: http://en.wikipedia.org/wiki/Sous-vide
[sloppost]: http://www.naildrivin5.com/blog/2012/10/05/making-it-right-technical-debt-vs-slop.html
[inheritance]: http://en.wikipedia.org/wiki/Inheritance_(computer_science)
[composition]: http://en.wikipedia.org/wiki/Composite_reuse_principle
[mixin]: http://en.wikipedia.org/wiki/Mixins
[cleanruby]: http://clean-ruby.com
[DRY]: http://en.wikipedia.org/wiki/Don't_repeat_yourself
[ioc]: http://en.wikipedia.org/wiki/Inversion_of_control
