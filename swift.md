# What Swift Can Tell Us About Programming Language Trends

To the surprise of just about everyone, Apple announce a new programming language, Swift, at WWDC this Monday.
This is an rare event for us programmers, as we don't often get to see what the biggest technology company on the planet (who
owns one of the biggest platforms on the planet) thinks about programming language design.

Swift embodies two major themes in programming language design that have come to the forefront in the last several years:
functions as first-class values, and static typing.

<!-- more -->

## Why this matters

Apple is the biggest technology company in the world.  Their platform—iOS—is one of the largest in the world (possibly **the**
largest, depending on how you want to measure it).  The tools they provide will be used by millions of developers, but developers
must continue to want to use those tools.  Their decisions must be both self-serving and developer-friendly.

Apple also doesn't make decisions lightly or on a whim.  Apple is careful, controlled, and calculating.  As evidence: Swift has been in development [since 2010][swiftpost] and they've managed to keep it entirely secret.  

What all this means is that we're seeing a programming language designed to be used by millions of users, designed by a company
made up of incredible technologists, with a heavy focus on design, produced after careful thought and consideration.  Like I
said, this doesn't come along very often.

So what features does Apple think a modern programming language should have?

## Swift's Unsurprising Featureset

Reading "The Swift Programming Language" (a quick an easy read, BTW), I found myself nodding along with each feature introduced.
Tuples: check. Named Paramaters: check.  Default Parameters: check.  Protocols: check. Functions: check.  Properties: check.  With one exception{% fn_ref 1 %}, there's not a feature in Swift that hasn't been part of at least one other mainstream programming language that's come to prominence in the last 10 years.  And that's the point.  
  
From one of the authors' web page:

> Of course, it [Swift] also greatly benefited from the experiences hard-won by many other languages in the field, drawing ideas from Objective-C, Rust, Haskell, Ruby, Python, C#, CLU, and far too many others to list.

Although programming-language nerds will take issue with much of how Swift implements particular features, few of these features
themselves are controversial.  **Of course** a new programming language will have tuples and pattern-matching.  **Of course** a
new programming language will have functions.  **Of course** a modern programming language will provide a solution to the dreaded [billion-dollar mistake][nilquote].

We all knew that Apple [had to][copland] come out with a new language at some point.  A lot of us hoped it would be an existing
language (Ruby?), but I think we all knew in our heart of hearts that that's just not Apple.  Apple likes to control its
own destiny, even if it can't quite [be the best initially][maps].

For me, I was on the edge of my proverbial seat about the type system: would Apple go the Ruby and Clojure (and, sigh, JavaScript) way and eschew static typing, or would they strengthen the type system in Objective-C and make a statically-typed language?

We now have our answer.

## Static Typing is Here to Stay

Swift's type system is best described as "way better than Java's", or perhaps "far more comprehensible than Scala's".  In fact,
Swift could be viewed as yet another new language designed for high-performance that uses static typing as a means to achieve
that.  Like Scala, Go, and Rust before it, Swift doesn't shy away from requiring that programmers provide type information for
variables and parameters.

This isn't Java—Swift makes
heavy use of type inference so that the types of your variables and parameters can be known without having to specify them
explicitly.  In general, it looks like method signatures will likely need type annotations, but little else (this has been my
experience with Scala as well).

Apple's decision here is a broad statement about programming language design, developer productivity, and developer happiness.
From "The Swift Programming Language" (emphasis mine):

> Swift adopts safe programming patterns and adds modern features to make programming easier, more flexible, and more fun…Swift combines the best in modern language thinking with *wisdom from the wider Apple engineering culture*. The compiler is optimized for performance, and the language is optimized for development, without compromising on either.

Apple is saying more than "static types are great for performance" or "static types make IDEs better".  They are saying that
their belief on the best way to write code is using a statically-typed language.  I find this fascinating.  And they aren't
alone.

## My God, it's Full of Types

Android uses Java, a statically-typed language (which, admittedly, has a shitty type system).  Google internally makes heavy use of C++ and Go, both statically typed.  Twitter was an early adopter of Scala, despite the fact that they started out as a Ruby shop and that JRuby is a pretty awesome way to use the JVM.  Even Facebook's Hack language has support for type annotations.  

The only major platform not using a typed language is the Web. This fact is certainly not the result of deep thinking and
analysis, because the Web isn't a managed platform.  It's more of a Mexican standoff that's somehow keeping JavaScript alive.

What this means is that a lot of smart people, whose businesses depend on a functional and performant platform that must also attract developers (either as partners or employees), are all going with statically-typed languages.  It's hard to argue that the future of programming is anything other than better and more expressive type systems, checkable by a computer.  

Ignore this trend at your peril.

----

{% footnotes %}
  {% fn The notion of given named parameters different names for the caller than the implementor is not something I've seen before, and it's kinda genius, as it seeks to make the callsite more readable without a cost to the function's implementation %}
{% endfootnotes %}
