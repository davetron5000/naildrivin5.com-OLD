---
layout: post
title: "&#10106;&#10144; Thinking In Types"
date: 2014-06-30 09:00
comments: true
categories: 
---
In a previous post about Swift, I talked about how [static types were increasingly seen as important in programming language design][swiftpost].  "Static" concerns a lot of developers, especially those using languages like Ruby or JavaScript.  Let's forget about that word and just talk about types.

[swiftpost]: http://www.naildrivin5.com/blog/2014/06/04/what-swift-tells-use-about-programming-language-trends.html

What do we mean by _types_?

{% blockquote Morpheus, The Matrix (paraphrased) %}
Types are everywhere, they are all around us, even now in your very programs. You can see them when you look at your browser, or when you start up your editor. You can feel them when you go to work, when you go to meetups, when you buy your conference passes. 
{% endblockquote %}

Morpheus is correct, types are at the absolute core of every program we write, "static" or not.

<!-- more -->

Although types are a **deep** topic, there's not much to them when you get right down to it.  [From Wikipedia](http://en.wikipedia.org/wiki/Datatype):

> a type…determines the possible values for [data]; the operations that can be done on [that data]; the meaning of the data; and the way values of that type can be stored.

Take this Ruby routine:

```ruby
def square(x)
  x * x
end
```

Although you can't see it in the source directly, `x` has a type, as does the return value of `square`.

Clearly, `x` is intended to be a number.  So, the valid values for `x` would be all numbers.  Invalid values would be booleans, strings, and anything else that isn't a number.  `x` also supports an operation to multiply it by another number.

What about *this* routine:

```ruby
def divide(numerator,denominator)
  numerator / denominator
end
```

You may think that both `numerator` and `denominator` have the same type.  They do not.  While both are ostensibly numbers, 0 is not a valid value for `denominator`, because there's no such thing as dividing by zero.  `denominator` has a slightly different type than `numerator` in that there is one additional valid value for `numerator` that is not valid for `denominator` (namely, zero).

You'll notice that none of the types are being made explicit–they are only in the mind of the programmer.

## The Mind of a Programmer

Just because the source code doesn't explicitly annotate the type of each variable,
parameter, or routine, doesn't mean no types were used in the creation of the
code.  It also doesn't mean that the programmer didn't have a set of valid values and available operations in mind when writing it.

This "programmer intent" of what accepted values and operations are is the very essence of programming.  Programs exist to transform data
across a series of operations, resulting in new data.  Just because the types involved aren't explicit, doesn't mean they aren't there.

There are many ways to make types more explicit.  Depending on the language, you can define new types to codify your assumptions about what data is valid. 

Suppose we are modeling an item for purchase.  An item has a price:

```ruby
class Item
  def price
    @price
  end

  def price=(new_price)
    @price = new_price
  end
end
```

We could have a guess at the type of `price`.  With just a modicum of domain knowledge
we could guess it's some sort of number.

Suppose that in the system where this code appears, a "business rule" is that prices cannot be negative.  Further, since it is a price, and monetary systems rarely go beyond two decimal points, the valid values for price may have at most two decimal places{% fn_ref 1 %}.

If items and their prices are important to our system, it could be difficult to remember these restrictions as you work on the code.  It could also be difficult for newcomers to understand these rules.   Finally, there's the question of what the value represents?  The number of cents? The whole dollar amount as an IEEE Float?

Because the type isn't explicitly laid out anywhere, the system is harder to understand and modify than it needs to be (as well as more prone to errors). 

Let's make this type explicit by defining a new type called `Price`.

```ruby
class Price
  attr_reader :number_of_cents
  def initialize(number_of_cents)
    raise ArgumentError unless number_of_cents >= 0
    raise ArgumentError unless number_of_cents == Integer(number_of_cents)
    @number_of_cents = BigDecimal.new(number_of_cents)
  end

  def dollars
    @number_of_cents / 100
  end
end
```

Now, because we have an explicit type defining a price in our system, anyone can easily understand the rules and logic about prices.  We've also made it extremely difficult to use incorrectly (this is Ruby, after all, so the only things that are impossible are strong guarantees).

By defining the `Price` type explicitly, we can now constrain the values for prices, but what about operations?

## Operations

When the type of `price` was implicitly defined, and stored using a system-provided
type (like `Fixnum`), we automatically had access to a ton of operations that are
well-defined on that system type.  

Although we're unlikely to need to take the natural log of a price, we'll certainly need to at least add two prices together, and we've lost that ability by defining `Price` is merely a holder of valid data.  We'll need to add the operations explicitly.

This has an interesting effect on our design process.  Because we no longer get a bunch of operations "for free", we have to actually think through the operations we'll need to add to our type, based on our system requirements.

Addition is pretty straightforward:

```ruby
class Price
  def +(other_price)
    Price.new(@number_of_cents + other_price.number_of_cents)
  end
end
```

But what about subtraction?  We might subtract prices when doing an exchange, refund,
or discount, but if a price cannot be negative, what happens when we subtract one
price from a lower-valued price?  What if we do a percentage discount?  What would half
off an item that costs $33.33 be?  It's certainly not $16.665, because that's not a valid price.

Because we actually have to explicitly define the operations on a `Price`, we've
uncovered edge cases in our application logic that would've otherwise gone
un-noticed by keeping the type of `price` implicit.  By using types we've *forced*
ourselves to think through some critical application logic.

We've now seen that types always exist in our programs, and we can see how defining
them explicitly has benefits to the design of our code.  But how do we tell other
developers what the types of variables, parameters, and return values are supposed to
be?

## I Do Declare

Type _declaration_ is how we communicate the expected type of a variable, parameter, or return value.  For example, our `Item` class defined accessor methods for `price`:

```ruby
class Item
  def price
    @price
  end

  def price=(new_price)
    @price = new_price
  end
end
```

It may seem that no types have been actually declared here. While it's true that the Ruby runtime allows any value to be passed to (or returned from) any routine, the programmer *has* made a clear intent as to the types involved.

Given that our system has an explicitly-defined type called `Price`, it's highly
likely that the programmer is declaring that `price` returns a `Price` and `price=` expects a `Price` as its parameter (and that `@price` is intended to hold an instance of `Price`).  Compare to this code:

```ruby
class Item
  def price
    @price
  end

  def price=(number_of_cents)
    @price = Price.new(number_of_cents)
  end
end
```

Here, the programmer has declared that the parameter to `price=` is a number of cents, not a `Price`.  Even though the language is providing no guarantees
about the types of these values at runtime, the programmer has declared their types. 

Let's take a breath at this point and think of some words I **haven't** used: static,
compiler, inference, generics, annotate.  There's a difference between defining/declaring types and having a system that checks your code with respect to the constraints those types provide.

But let's not get ahead of ourselves.  

We've seen how we can both define and declare types in our code, but what good is it?  Why is this code:

```ruby
class Price
  # ...
end

def price=(price)
  @price = price
end
```

better than this:

```ruby
def price=(x)
  @price = x
end
```

Two words: boundaries.

## Bound by Types

Any moderately complex system is broken down into parts.  This [application architecture][archpost] is what allows us to work on complex systems without having to have the entire system in our head at once.

[archpost]: http://www.naildrivin5.com/blog/2014/05/27/rails-does-not-define-your-application-architecture.html

To make these parts of our system comprehensible, we define boundaries.  These
boundaries take the form of expected inputs and outputs.  When a routine can be
written with the assumption of only certain sorts of data coming in, it's easier to
write, understand, and change.

Types allow us to explicitly define the boundaries between bits of our code.  Types allow us to encode in our programs—rather than in documentation or oral history—what the
expectations are.  Types also encourage us to think about how our program will behave, because we have to think about the operations that should be available.

It's not like we aren't doing this already.  We *are*.  It's just a question of how explicit we want it to be and _how much help we want_ along the way.

## ¡Ayúdame!

A simple way to check that types are being used correctly is to simply add code that
checks:

```ruby
def price=(new_price)
  raise ArgumentError unless new_price.kind_of? Price
end
```

An advantage of this means of type-checking is that it's explicit, clear, obvious, and
can be used "as-needed" (e.g. for critical entry points where mistakes are likely to
be made). The disadvantage is that you will not find out until runtime if the wrong data has been used.

To deal with that, we can use tests so we have some assurances *before* the application is actually deployed:

```ruby
def test_price_returns_a_price_not_a_decimal
  item = FactoryGirl.create(:item)
  item = Item.find(item.id)
  assert_equal Price,item.price.class
end
```

In a language like Ruby, where there's no built-in way to check or enforce type
declarations, you can run out of options quickly.  

There have been attempts to add richer type-checking systems to Ruby.
Rails' validations is probably the most prolific:

```ruby
class Item < ActiveRecord::Base
  validate :price, :numericality => { :greater_than_or_equal_to => 0 }
end
```

Here, we've declared the valid values of `price`, and we can invoke the type-checker
by calling `valid?` on the item.  We can even get a detailed explanation of type
violations by calling `errors` on the object.

You're read that right–Rails validations are a type system (and a verbose and cumbersome one at that).

Type systems like Rails' validations approach the limit of what you can do without
direct language support.

And, it can be frustrating at times to carefully design the types your system needs,
each one capturing business rules in **code** (instead of imprecise documentation or bafflingly-complex tests),
only to have type errors occur in your running application{% fn_ref 2 %}.

If you like the idea of modeling your system as a series of valid values and accepted
operations on those values, you're gonna need a new language.

## Language!

Some languages (often called "statically-typed languages") provide a way to verify
that your program is using defined types correctly.  Most of those languages are only
able to to do this by requiring that all values have a type declaration (or that the
type of a value can be unambiguously deduced).

If your last experience with such a language is this:

```java
List<String> names = new ArrayList<String>();
```

then it's **no wonder** you aren't a fan of having your source code checked for type
correctness.  **And**, if your main experience in _defining_ types is this:

```ruby
class Person
  attr_accessor :name
  attr_accessor :birthdate
  attr_accessor :address

  def initialize(name, birthdate, address)
    @name      = name
    @birthdate = birthdate
    @address   = address
  end
end
```

then it's **no wonder** you aren't a fan of using types in the first place.

Let's see what our `Item` and `Price` types look like in a modern language that supports type-checking, Scala:


```scala
case class Price(val numberOfCents: Int) {
  if (numberOfCents < 0) {
    throw new IllegalArgumentException("numberOfCents must be positive")
  }

  def dollars = new BigDecimal(numberOfCents) / 100;

  def +(other:Price) = Price(numberOfCents + other.numberOfCents)
}

case class Item(var price: Price)
```

That's 8 lines of Scala to 19 in Ruby.  **And** our Scala version will not even *execute* if we've misused it.
These "static types" may not tell us everything about our program, but we know that an `Item` will **never** contain an invalid price, **ever**:

```scala
item.price = 43 // compile error.  Will never, ever, ever execute
```

Hopefully, you're starting to see that explicit type declarations, and programs written to enforce them (often called compilers) are _tools_ you can use to make sure that your notion of how your system behaves has been correctly encoded in the source (as opposed to thinking of them as fussy gatekeepers you must satisfy).

In modern, statically-typed languages, you end up explicitly declaring types only when
the type of something is ambiguous.  Turns Out™ that with modern tools this isn't
nearly as often as you might think.

Of course, this might be more often than you'd _like_, but there's a nice side-effect
to being explicit about the types of values in your program: you start to think in
types.  You decompose problems as operations on types of data.  

You stop worrying
about edge cases, sanity checking, and whether or not "0" represents `true` or
`false`, and start focusing on the real problems you are solving (this is <strong>not</strong> to say that all programs written in statically-typed languages are bug free, easy to understand, or well-designed.  Just that such languages contain additional tools for you to use on your quest for bug free, easy-to-understad, well-designed code).

Thinking this way leads to a system with clearly defined boundaries that is easier to
understand and easier to modify.  And the good news is that there are a *lot* of tools
available to help you check your assumptions and validate at least *part* of your
model of the problem.

That's powerful.


---
{% footnotes %}
  {% fn Ironically, the standard numeric types in most programming languages actually can't hold all the valid values for the price that we've laid out.  Try adding up the cost of 10 $0.10 items in a Ruby or JavaScript console. %}
  {% fn Yes Virginia, calling methods on <code>nil</code> is a type error.  So is getting a negative value when you “should never” get one.  So is that time when you were writing your controller test and passed in booleans only to realize that <code>params</code> in an actual running Rails app will only ever have strings in it and your passing test ended up telling you jack shit about how your code would actually behave.  You know the time I mean. %}
{% endfootnotes %}


