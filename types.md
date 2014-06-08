In a previous post about Swift, I talked about how static types were increasingly seen as important in programming language
design.  I'd like to explain the benefits they can provide, but first we just need to talk about types in a more general sense.

Types is a **deep** topic.  [Wikipedia's entry on Datatype](http://en.wikipedia.org/wiki/Datatype) tells us:

> a type…determines the possible values for [data]; the operations that can be done on [that data]; the meaning of the data; and the way values of that type can be stored.

Practically speaking, types in a computer program are concerned with the set of valid values for a type and what operations can be performed on a particular piece of data.  Operations available is much simpler to understand, and often what we think of when we think of types.

For example:

```ruby
class Foo
  def bar
  end
end

foo = Foo.new

foo.bar  # => works
foo.quux # => fails
```

This is because we have not defined `quux` as an operation on values with the type `Foo`, but `bar` *is* an operation we've
defined.  

This is useful for several reasons:

* The collected operations give us clues about the purpose of the type
* We can have the system tell us if we're using a type incorrectly, which can catch quite a few bugs.

Less frequently discussed is the concept of "valid values" for a type.  For example, in most SQL database, the type `BOOLEAN` can
have three possible values: true, false, and null.  Compare this to the `bool` type in Java, where the only valid values are true
and false.

Of course, this are enforced by the systems in question.  A SQL database will likely not let you insert "foo" into a boolean
field, and the Java compiler will not execute a program that assigns "foo" to a `boolean`.

In a language like Ruby, this is fairly difficult.  On the surface, you might think it's because Ruby is "dynamic" or doesn't
have a compiler or isn't "statically typed".

In reality, Ruby simply provides no programmer access to assignment.  It is more or less impossible to change how this code
works:

```ruby
foo = "bar"
```

Now, in, say, Java, there is similarly no programmer access to assignment, but assignment is more "configurable", if you will:

```java
foo = "bar";        // illegal statement
String foo = "bar"; // works
String foo = 42;    // illegal assignment
```

In a sense, you tell Java what the possible values are for the symbol you are creating.   By saying `String foo`, you are
saying "the only valid values of `foo` are `Strings`".

You don't want to think about it as "telling the compiler the type of something", but rather "specifying constraints about your
program". If you think about it, it's not much different than:

```ruby
class Item < ActiveRecord::Base
  validates :price, numericality: { :greater_than => 0 }
end
```

Ironically, this is a *far worse* way to specify a constraint about your program than the Java way.

Still, with some discipline, you can get Ruby to help in the "allowed values" sense.  In our class above, we're saying that
`price` must be a number greater than 0, but we're actually going to be using Ruby's `FixNum` to store the value.  Why?

Why not create a type to describe a price?

```ruby
class Price
  def initialize(number_of_dollars)
    raise ArgumentError unless number_of_dollars.kind_of?(Fixnum)
    raise ArgumentError unless number_of_dollars > 0
    @number_of_dollars = number_of_dollars
  end

  attr_reader :number_of_dollars
end
```

Now we know if we have an instance of `Price`, the underlying numeric value it's wrapping will always be a number and be greater
than 0.  The disadvantage, of course, is that we lose all the operations we got with a `Fixnum`.  So we've done well by
constraining the possible values of this type, but don't have a good sense of the opertaions available.

Of course, isn't it worthwhile to actually think about what operations *should* be available?  Addition seems like a no brainer:

```ruby
class Price
  def +(other_price)
    Price.new(other_price.number_of_dollars)
  end
end
```

Subtraction, though, requires actually thinking through the implications.  Since a `Price` must be positive, what happens if you
subtract a price from one with a lower value:

```ruby
p1 = Price.new(10)
p2 = Price.new(5)

p2 - p1 # => what should this be?
```

There are a lot of possibilities, but whatever we choose is a design decision that shapes our system.  By storing prices as
numbers, we don't have to make that decision, but we've also not thought through the implications of it in our system.

By creating types to define our system, we ensure that we thinking these things through.

And this is something that developers experienced in "statically typed" languages have known for a while.  Because in a language
like Java you *have* to constrain each variable to the possible values of a given type, you think in types.  And, the more
expressive the type system is, the more likely you are the leverage the abilities of the system to check constraints for you.

Suppose we were using a language with such expressiveness.  Instead of the verbose incantation we need with ActiveRecord, we
could do something like:

```scala
class Item {
  var price:Price
}

class Price(number_of_dollars:Fixnum[0..]) {
  def +(price:Price):Price = { 
    Price(self.number_of_dollars + price.number_of_dollars) 
  }
}

item = Item()
item.price = Price(10)  // compiles and runs
item.price = Price(-10) // doesn't compile
```

It's clear that a goal of this imagined system is "prices must be positive".  In our imagined compiled language, we bake that
into the source in a way that an automated system can check it for us.  The check needs to be done regardless.  The Ruby version
of this requires not just testing that `price` never gets a non-numeric or negative number, but that _the system can handle a
non-numeric or negative price_.  

Let that sink in.  It's not just that `item.save` fails when `price` is less than zero.  Because the _system_ allows `price` to
be literally *anything*, we have to *also* test that any part of the system the depends on an item's `price` can deal with it.

We can combat this by using types more effectively (e.g. the `Price` class), but we'll never be as effective as an automated
system that validates the constraints laid out by our types are met.



---
 {% footnotes %}
 {% endfootnotes %}
