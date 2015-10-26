---
layout: post
title: "What Makes Code Hard to Understand?"
date: 2014-07-13 14:33
link: http://arxiv.org/pdf/1304.5257.pdf
---

[@garybernhardt][garybernhardt] linked to a short academic paper on code readability, called ["What Makes Code Hard to Understand?"][paper].  It's a quick read that details an experiment where researchers showed severals versions of the same program to a bunch of programmers and asked them to guess the output.  Each version had the same [cyclomatic complexity][cc] and lines of code, but differed only in formatting, variable naming, and use of types.

Choice quote:

> The physical aspects of notation, often considered superficial, can have a profound impact on performance [of programmers to understand what code will
> do]

In particular, in a program that relied on order of operations, two versions were given, one in which one space was used around operators (`zigzag`) and
another where the operators were all vertically aligned (`linedup`):

> Programmers were more likely to respect the order of mathematical operations in the `linedup` version of `whitespace`, showing how horizontal space can emphasize the common structure between related calculations.

Also, they presented three versions of code to calculate the area of a rectangle, using free variables, tuples, and a `Rectangle` class:

  > Programmers took longer to respond to the `tuples` version of `rectangle` despite it having fewer lines than the `class` version. It is not uncommon in Python to use tuples for (x, y) coordinates, but the syntactic "noise" that is present in the tuples version for variable names (e.g., `r1_xy_1`) and calculations (e.g., `width = xy_2[0] - xy_1[0]`) likely gave programmers pause when verifying the code's operation.

  This was not something that was initially obvious to me as I learned programming, but I have come to realize the importance of typography in writing
  code.  From [my post][typography] on the subject over a year ago:

> But, it's not just the content - the code itself - that affects readability. How it's presented matters and if we're going to talk about presentation, we have to talk about typography.


[typography]: http://www.naildrivin5.com/blog/2013/05/17/source-code-typography.html
[garybernhardt]: http://twitter.com/garybernhardt
[paper]: http://arxiv.org/pdf/1304.5257.pdf
[cc]: http://en.wikipedia.org/wiki/Cyclomatic_complexity
