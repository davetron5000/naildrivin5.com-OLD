---
layout: post
title: "The War on Comments"
date: 2012-01-11 08:32
comments: true
categories: 
---

Code comments often get a bad rap, especially in the Ruby community, with phrases like "code should be self-documenting" floating around, legitimizing the production of code with no documentation at all.  In fact, code comments are one of the many useful tools developers have to make their intent clear, and writing them off as a "code smell" is naive and dangerous.

<!-- more -->

## The Two Types of Comments

Before we dig in, it's important to understand that there are two types of comments.  There are comments that serve as _API Documentation_ and comments that are, for lack of a better term, _explanatory_.

I'm not going to argue that you should write API documentation for your public APIs.  You should, and anyone insisting that you shouldn't is just being lazy.  It's worth pointing out that API documentation comments are there to help you _write_ code, primarily.  They help answer the question "what code do I need to accomplish this task?".

The other type of comment, explanatory comments, are there to help you _read_ code, and this is why they are so important to use and **to get right**.  Code is read many more times than written, and I doubt you'll find a professional developer who would argue _against_ writing code for readability.

## Explanatory Comments

Explanatory comments are those that seek to explain something about the code that the author (or maintiner) didn't feel was obvious from the code itself.  It's at this point that many will say that the mere existence of such comments is a [code smell][codesmell], or indicator that the code should be rewritten in a more clear way.

This rule of thumb makes a lot of assumptions about what sort of comments one might write as well as the expressiveness of source code.  Comments that merely explain _what_ the code does are, in fact, a code smell.  Comments that explain _why_ the code was written a certain way, or even why it exists at all, are not.  Understanding _why_ code is the way it can be is incredibly hard to encode in a programming language.  I still think "what" comments have their place, but let's tackle "why" comments, as these are a powerful tool for code authors and maintainers.

### "Why" Comments

Let's take the example from my [last blog entry][lastblog]: a salutation class.  Suppose our system has the following implementation:

```ruby Initial Implementation of Salutation
class Salutation
  def initialize(person)
    @person = person
  end

  def greeting
    if @person.honorific == :doctor
      "Hello, Dr. #{person.last_name}!"
    elsif @person.first_name.present?
      "Hello, #{person.first_name}!"
    elsif @person.male?
      "Hello, Mr. #{person.last_name}!"
    else
      "Hello, Ms. #{person.last_name}!"
    end
  end
end
```

This code is pretty clear, and it's easy to understand what it does.  A novice programmer might comment it like so:


```ruby Useless "what" comments
class Salutation
  def initialize(person)
    @person = person
  end

  def greeting
    # Check if they are a doctor, otherwise
    # use their first name, falling back
    # to their gender
    if @person.honorific == :doctor
      "Hello, Dr. #{person.last_name}!"
    elsif @person.first_name.present?
      "Hello, #{person.first_name}!"
    elsif @person.male?
      "Hello, Mr. #{person.last_name}!"
    else
      "Hello, Ms. #{person.last_name}!"
    end
  end
end
```

We can all agree these comments add noise.  So what's missing from this picture that the code can't express?  Something that seems odd is the explicit check for the `honorific` of `:doctor`.  Why do we only check that one?  Clearly there can be other values for `honorific`; why don't we check those?

Code like this is all over the place in a real production application.  This is part of what makes the job of a programmer challenging. We get requirements that are sometimes odd and result in akward code that isn't as clean as the idealized code you'd see in a book.  And so we have the dreaded _special case_, which results in code that sticks out like a sore thumb.

Code like this, at first, looks like a bug: "Oh no!  What if someone registers with the honorific of 'Sir'?  We're going to call them by their first name?".  Suppose in this case, it's not a bug.  Suppose in this case that this is intentional.  How would someone know that?

Explanatory Comments.

```ruby Helpful "Why" comments
class Salutation
  def initialize(person)
    @person = person
  end

  def greeting
    # We special case :doctor because the Initech
    # style guide for messaging requires it, and we need
    # to be compliant with it.  Since we have very few users with
    # honorifics other than doctor, we don't want to get into a 
    # complex honorific mapping mapping situation right now, so
    # we just handle this one explcitly.
    if @person.honorific == :doctor
      "Hello, Dr. #{person.last_name}!"
    elsif @person.first_name.present?
      "Hello, #{person.first_name}!"
    elsif @person.male?
      "Hello, Mr. #{person.last_name}!"
    else
      "Hello, Ms. #{person.last_name}!"
    end
  end
end
```

**Now** it makes sense.  We got some annoying requirement and had to meet it.  The reality of the data in our system made the cost of a more generalized soluation have little benefit, so we did the simplest thing that could possibly work *and* were nice enough to explain ourselves.

This is the sort of comment that is incredibly useful for understanding code.  I would argue that *any* time you do something weird or akward in your code, you should explain why you did it that way.  Future you will thank you in the following ways:

* You'll understand, six months from now, why you wrote what appears to be awkward code.
* The maintainer of this code won't ask you about it.

### Maintaining Comments

The second criticism typically leveled against comments is that they become out of sync with the code.  Continuing our `Salutation` example, suppose we later get a requirement to special-case college professors.  The quick and dirty solution would be:

```ruby Crufty, inaccurate comments in light of change
class Salutation
  def initialize(person)
    @person = person
  end

  def greeting
    # We special case :doctor because the Initech
    # style guide for messaging requires it, and we need
    # to be compliant with it, and have very few users with
    # other honorifics, so we don't want to get into a 
    # complex honorific mapping mapping situation right now
    if @person.honorific == :doctor
      "Hello, Dr. #{person.last_name}!"
    elsif @person.honorific == :professor
      "Hello, Prof. #{person.last_name}!"
    elsif @person.first_name.present?
      "Hello, #{person.first_name}!"
    elsif @person.male?
      "Hello, Mr. #{person.last_name}!"
    else
      "Hello, Ms. #{person.last_name}!"
    end
  end
end
```

Now the comment is out of sync with reality.  We have a nice explanation of special-casing `:doctor`, but not a word about `:professor`.  I would argue that the developer that wrote this code and called it "done" has been negligent.  He's **not done his job** and there's no excuse for this.  At the *very* least, he should replace the phrase "We special case :doctor" in the comment with "We special case :doctor and :professor".  There's many better ways to meet the new requirement, but for the purpose of keeping our focus on comments, *you must keep the comments and the code in sync*.  That's the job.  

Hopefully, you can see that comments that explain _why_ code is the way it is are important.  These sorts of comments are a powerful tool for expressing intent and making code readable, understandable, and clear, beause the reality is, not every problem that we have to solve can be done so in perfect-looking "clean" code.

So what about those "what" comments?  What about comments that explain _how_ code works and _what_ it's doing?  Those are certainly wrong in every case, right?  Not so.  Here's a (qualified) defense of those sorts of comments.

## Sometimes you need to explain what the code does

I don't write perfect code.  My code isn't always written in the most elegant, understandable way.  Yours isn't either.  The reasons for this are many: we didn't have time to make it as clear as possible, we couldn't think of the right name for something at the time we write it, we didn't really undertand the problem as much as we thought we did, etc.

And, just because you omitted all comments doesn't make your code magically comprehensible.  You might feel that code should be
self-documenting, but leaving out comments doesn't make it so.

If you spent any time in real production code, you know that the most brilliant developers can write some real stinkers, creating convoluted code that can be really hard to unravel.  I've done it many times, and I'm certain my ex-co-workers at Opower and Gliffy curse my name from time-to-time.  It's code like this that can benefit from some judiciously-placed "what" comments.

Suppose we come across this code:

```ruby mysterious code
def isqrt(square)
  square = square.to_i 
  return 0 if square == 0 
  raise RangeError if square < 0

  n = iter(1, square)
  n1 = iter(n, square)
  n1, n = iter(n1, square), n1 until n1 >= n - 1
  n1 = n1 - 1 until n1*n1 <= square
  return n1
end
def iter(n, square) 
  (n + (square / n)) / 2 
end
```

You might guess that this takes the square root, but boy is it impenetrable.  Some things are just complex and either can't be made more clear or external constraints exist (like time) that we just can't do so.  What we probably *could* do is add a few comments to help the poor sap that must fix a bug in this code later:


```ruby Less-than-ideal, but a bit more helpful
def isqrt(square)
  # just in case we don't get an int
  square = square.to_i 
  return 0 if square == 0 
  raise RangeError if square < 0

  # make our initial guesses, which are initially 
  # too high (intentionally; see next)
  n = iter(1, square)
  n1 = iter(n, square)

  # Refine our guesses until we get close enough
  n1, n = iter(n1, square), n1 until n1 >= n - 1
  # We're close enough when we're JUST under square
  n1 = n1 - 1 until n1*n1 <= square
  return n1
end
def iter(n, square) 
  (n + (square / n)) / 2 
end
```

The code is more noisy, yes, but now the reader has some clue as to what's going on.  It might even given him the confidence to refactor this in a way that no longer requires comments.

## What about tests?

Tests can give insight into how code is supposed to work.  Tests can rarely make clear the _why_ of code, and almost never
explain the complex guts of a routine.  And, let's be honest, even well-tested applications have horribly unreadable tests, rife
with [duplication][lastblog], magic numbers, questionable coding practices and other horrors we'd never include in our production
code.  We'll get to that.

The point is, comments are a way to include information that can't be (or wasn't) expressed in code _right next to the relevant
code_.  There's power in that, and a develper that completely writes this power off is being foolish.

## Bottom Line

* Document your public API
* Use comments to explain _why_ odd or surprising code was written
* Use comments to explain _what_ impenetrable code is doing if you just can't make it any more clear

Future you will thank you.

[codesmell]: http://en.wikipedia.org/wiki/Code_smell
[lastblog]: http://www.naildrivin5.com/blog/2012/01/08/make-tests-clean-and-clear-without-duplication.html
