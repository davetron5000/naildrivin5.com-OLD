---
layout: post
title: "Understanding New Programming Languages"
date: 2014-06-05 18:19
comments: true
categories: 
---

In reading "The Swift Programming Language" to prep for my [post on how Swift informs us about programming language trends][swiftpost], I was surprised at how straightforward the language's features seemed:

> I found myself nodding along with each feature introduced. Tuples: check. Named Parameters: check. Default Parameters: check. Protocols: check. Functions: check. 

I realized it wasn't just because Swift has unsurprising features, but because I'm familiar enough with enough other languages
that I've experienced or used those features before.  Although I write mainly in Ruby and JavaScript at work, I have a lot of
experience with Java and C, and had my head was in Scala for quite a while a few years ago.

Although the forms of Swift's various features differ from their analogs in other languages, conceptually, they are the same: the
generic type system is similar to Java's, and the tuples are close enough to Scala's that all I need to do is understand the
syntax.

It really is true that the more languages you know, the easier it is to "pick up" new ones.  This is a *great* reason to 
[learn a new programming language every year][pragprog].

If all you know are dynamic languages like Ruby or JavaScript{% fn_ref 1 %}, or you are only familiar with Java or C#, you are increasingly at
a disadvantage when trying to acquire new skills.  Learning something like Swift (or Scala, or Elixir, or whatever) requires not
just understanding the syntax of the language, but the very _concepts_ that underpin its features (some of which can be mind-bending).


[swiftpost]: http://www.naildrivin5.com/blog/2014/06/04/what-swift-tells-use-about-programming-language-trends.html
[pragprog]: http://pragprog.com/the-pragmatic-programmer

---

{% footnotes %}
  {% fn <strong>Particularly</strong> JavaScript.  It has probably the <em>least</em> features of any modern programming language. If you've never experienced a truly powerful and expressive language, you will be more and more behind as the industry moves on. JavaScript won't go away, but it's becoming assembly language.  You <strong>don't</strong> want to be an assembly programmer. %}
{% endfootnotes %}
