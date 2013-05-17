---
layout: post
title: "&#10106;&#10144; Source Code Typography"
date: 2013-05-17 08:53
comments: true
location: Washington, DC
categories: 
---

What's the one thing we, as developers, do with source code more than anything else?  We _read_ it.  Sure, we change it, and even occasionally we write new source code, but, by and large, we _read_ source code.  We read it to know how to use it.  We read it to know where to change it.  We read it to understand what it does.

But, it's not just the content - the code itself - that affects readability.  How it's presented matters and if we're going to talk about presentation, we have to talk about typography.

<!-- more -->

One could argue that, all things being equal, source code should be written in a way optimized for reading.  Sure, occasional performance concerns require putting readability in the backseat, but this is rare.  Source code should be written to be understood by people.

This isn't a radical concept, and it's why we have structured programming, why we use descriptive variable names, and why we have conventions about where the files containing source code live. If a codebase is like a book, we're all agreed how to title the chapters, where the table of contents should go, and what the index looks like.

But there's also how the code is presented to us - the code's _typography_.  Typography is, according to Wikipedia, "the art and technique of arranging type in order to make language visible."  _Type_ of course, is the presented text, so typography, then, answers the question "what does each letter look like, and where does it go?"

We use typography all the time in our code.  We indent it whenever a new scope is created.  We limit our line lengths to a certain number of characters.  We color-code bits of code according to their purpose, aka syntax highlighting.  Some of us even align other parts of our code, such repeated inline comments, like so:

```java
int left = shape.positionLeft(); // Our display is left-oriented
int top = shape.positionTop();   // We start drawing pixels from the top
```

This sort of "code formatting" isn't about correctness, it's about aesthetics, all in aid of making the code easier to read.  Typography doesn't address what _should_ be written but rather how it should be presented to make what _was_ written as readable as possible.

A designer friend recommended ["The Elements of Typographic Style"][elements], by Robert Bringhurst.  This is "The Art of Computer Programming" for typography.  Very early in the book, Bringhurst has this to say:

> Well-chosen words deserve well-chosen letters; these in turn deserve to be
> set with affection, intelligence, knowledge and skill.  Typography is a link,
> and as it ought, as a matter of honor, courtesy and pure delight, to be as
> strong as others in the chain.

This is a passion for "fonts and stuff" that I never knew existed.  But, he's right.  A well-typeset book is a leisurely stroll on a spring day, while a poorly set document is an encumbered march through a muddy field on a rainy day. 

If you are at all interested in typography, typesetting, or fonts, I highly recommend the book.  It's easily read, well-written, and - of course - beautifully typeset.

In the book, he talks about font choices, line heights, kerning, alignment, grids, tables, and anything else you could possibly imagine needing to make a design decision about when putting words onto a page.  But, it's all about prose.  Can we apply any of these lessons to source code?

We've already established that programmers generally get value out of typography, via indentation and whitespace.  Many of us have a favorite fixed-width font for editing, and we can all argue about what the proper length of a line of code should be.

Some languages, like CoffeeScript and Python, require adherence to certain typographic principles - you must indent new blocks of scope.  The Go language comes bundled with its own typesetting program: `gofmt`.  Thus, all Go programs adhere to a strict set of typographic principles.  There's a certain logic to this.

Is indenting and color-coding our source enough?  Can we make our code even more readable by heavier use of typography?

Let's find out.

We'll start with C, one of the oldest "high-level" languages.  Here is the source code for the `strcpy` function from the BSD kernel:

```c
char *
strcpy(to, from)
        register char *to;
        register const char *from;
{
        char *save = to;

        for (; (*to = *from) != 0; ++from, ++to);
        return(save);
}
```

It's a short routine that packs a lot of functionality.  It's set according to the BSD guidelines, with an 8-character indent (likely a tab).  Other than that, there's not much going on typographically.  Does this make it hard to read?  Can we make it easier to read without changing the code?

Let's start with the function declaration.  I like how the return type (line 1) is on a different line than the function and argument names (line 2), as it breaks up the signature into different chunks.  The argument declarations themselves (lines 3 and 4), which each appear on their own line after the function name, could be better set, in my opinion.

A C argument declaration is made up of modifiers (`register`, `const`), a data type (`char *`), and a name (`from`).  In this case, the elements of each declaration are vertically aligned, but in an odd way (likely their alignment is merely by happenstance - both arguments are declared `register`).  The `char` for the argument `to` aligns with the `const` of the argument `from`.  `const` is a modifier, and `char` is a data type.  Things that are different are aligned with each other, which implies a sameness that doesn't exist.

Let's re-set the argument list, aligning like with like, forming a table structure, like so:

```c
char *
strcpy(to, from)
        register       char* to;
        register const char* from;
```

Now, the arguments block forms a table of three columns.  The modifiers make up the first column, the data types are aligned in the second column, and the names are in the third column (also notice how the syntax highlighting reinforces the new table structure).  We've also re-set the data type such that there is no space between `char` and `*` - the data type of both of these variables is "pointer to char", so it makes more sense to put the space before the argument name, not in the middle the data type's name.

Let's move onto the `for` loop.  I've always found the `for` loop in C to be an odd construct, and it squeezes quite a bit of functionality into a small space.  It has two parts: the loop declaration and the loop body.  The declaration itself has three sub-parts: an initializing section, a test to see if the loop should continue, and code to run each time through the loop (the body is also executed each time through the loop, which is one reason I find this construct strage).

This particular `for` loop is tricky, because there is no initializing code in the declaration, nor is there a loop body.  To make this loop easier to read, we could rewrite it, but typography isn't about changing the words, it's about honoring them and making them easier to understand.  Can we re-set this code without changing it, but make it more readable?

One thing that would be handy is to make it more clear that there is *intentionally* no initializing code nor loop body.  We'd also like to make it simpler to see each part of the `for` loop for what it is.  Let's add some whitespace and vertical alignment to see if we can improve it.

```c
for (
                          ; 
        (*to = *from) != 0; 
        ++from, ++to
    )
    ;
```

By vertically aligning the semi-colons, the missing initializer jumps right out at you.  The whitespace created by the semicolons now looks intentional - that space couldn't be there by accident.  We've done the same with the loop body, although we took care *not* to vertically align that semi-colon, thus creating a visual distinction between the two parts of the `for` loop.

With regard to the intentionally missing elements, developers might reveal this intent via a comment, like `/* no-op */`.  What I find interesting is that we can do this with mere typography.  The reader feels the intention without being directly told.

Let's look at another example, this time using a much more recent programming language: Ruby.  Ruby takes its syntactic cues from Smalltalk and relies much less on analphabetic characters like braces and parens.  It also supports a powerful literal syntax for arrays and hash tables.  You can't read too much Ruby code before coming across a `Hash` literal.

Let's look at the routine from Ruby on Rails for creating a text field tag in HTML:

```ruby
def text_field_tag(name, value = nil, options = {})
  tag :input, { :type => "text", :name => name, :id => sanitize_to_id(name), :value => value }.update(options.stringify_keys)
end
```

Wow, that is way off the page (or wrapping horribly, depending on how you're reading this).  

An important role that typography plays is to establish a "rhythm" to the typeset prose.  In a book, this means making decisions about font size, margins, line lengths, and so on.    The idea is to set each line long enough to let the reader take it in, but not so long that the reader becomes exhausted or loses their place.  This code has no rhythm and is exhausting to read.

Compounding the problem of overall length is that the information here is at varying levels of abstraction.  We have a method call to `tag`, some symbols, a `Hash`, and more method calls at the end.  By the time you get to the end of this line, it's hard to remember what it's even supposed to be doing.  We need to break this up with some sort of rhythm that will allow us to process it in chunks.

In English, we would establish this rhythm by analyzing the length of words and sentences. In source code, we have tokens and expressions. This Ruby method has 29 tokens, all on one line.  That line has several expressions as well, and both of these facts are what's making this line so hard to read.

Let's re-set this code to keep the tokens-per-line low but avoid splitting expressions across lines.

```ruby
def text_field_tag(name, value = nil, options = {})
  tag :input, 
      { 

        :type  => "text",
        :name  => name,
        :id    => sanitize_to_id(name),
        :value => value

      }.update(options.stringify_keys)
end
```

Each line now has only one or two expressions, and many fewer tokens.  We've also used indentation and whitespace to delineate each part of this code.

Both arguments to `tag` are left-aligned at the seventh column - similar things have similar alignment.  The biggest change, however, is in the `Hash` literal.  

First, we've offset its contents by whitespace, primarily to distinguish it from the call to the `update` method.  Without a blank line after the final value in the `Hash`, there's an unfortunate vertical alignment between the hash key `:value` and the method call to `update`.  We want to make it clear that these are distinct, and want to keep the reader from getting confused.

The `Hash` contents themselves have been re-formatted to form a visual table.  We've used the "hashrockets" as a dividing line between key and value, which results in both being vertically left-aligned.

The code now has more of a rhythm to it, and can be read more easily, with line breaks inserted to give the reader a rest at the appropriate times.

Before we finish, I'd like to examine a typographical convention I've seen in JavaScript code, and discuss why I believe it actually impairs readability, failing to honor the content and thus fail to help the reader.

The convention was born out of a common idiom in in JavaScript where variables are declared in a comma-delimited list after a single `var`, with the list terminated by a semicolon. The typographical convention I'm referring to is in how this list is formatted, namely, it's formatted with leading commas, like so:

```javascript
var x = shape.left()
  , y = shape.right()
  , numSides = shape.sides()
  ;
```

This is typeset poorly, insomuch as it does not honor the readability of the content, instead hindering it. 

The most important part of a variable declaration is the name of the variable (the second being its default value).  Putting a comma first creates at typographic roadblock between the reader and the information they need (the variable name).  That a comma is required between variable declarations is one of the least important pieces of information in this code, yet it's front and center.  This is bad typography.

The more conventional approach is much better, as the language's peculiarities simply fade away:

```javascript
var x = shape.left(),
    y = shape.right(),
    numSides = shape.sides();
```

Each line can now be easily read from left to right.  The `var` establishes this block as a "paragraph", and each declaration is a sentence. Each line is eminently readable - it starts with the name of the variable, which is what the reader is most interested in, and is followed by the default value.  The names are left-aligned and are the first thing on each line (save for the initial `var` which establishes that these are variables).  The commas, being incidental, are hidden nicely at the end of the line.

We can reinforce this structure with vertical alignment of the `=`:

```javascript
var x        = shape.left(),
    y        = shape.right(),
    numSides = shape.sides();
```

We could go even further and align the commas and semi-colon, however this draws attention to aspects of the code that aren't important (much as the comma-first style does).  Although JavaScript needs to know when each declaration ends, we, the human reader, already know - the line merely ends.  The declaration block itself ends with whitespace - that JavaScript requires a semicolon is incidental to reading this code.

This is why the "comma-first" typesetting is so distracting.  It puts the comma - something unimportant to reading the code - right up front, forcing the reader to slog through it to get to the real meat of the declaration.

I could go on about many more idiomatic typesetting in various languages, but I thought it would be a fun exercise to make an argument against this style, based purely on tyopgraphical concerns, and see if it sticks.

Thinking about code typography has made more more bold in my code formatting choices, but there is a practical cost to this: source control diffs.

Unlike a printed book, code changes frequently.  When we use heavier typography, we end up having to re-set the code around a particular change, and this creates non-functional changes to source code, making the overall changeset larger than it needs to be.  I suppose we'd have to start applying typographic principles to our diffs as well :)

Despite these problems, I still think it's worth taking a fresh look at code typography - anything that helps us read and understand code better has to be a good thing.  At the very least, having a clear understanding of why code is set in a certain way can help us better understand the purpose of the code, and the trade-offs we make between reading, modifying, and writing it.

---

Special thanks to [@mrmrs_][adam] for the book recommendation and to [@jxblk][jackson] for
reviewing this post.

[adam]: https://twitter.com/mrmrs_
[jackson]: https://twitter.com/jxnblk
[elements]: http://www.amazon.com/Elements-Typographic-Style-Robert-Bringhurst/dp/0881791326
