# Duck Typing Can Be Confusing

Here's a method, in Scala, to select lines of text that contain a particular string:

```scala
def grep(lines:Seq[String], toMatch:String):Seq[String] = {
  lines.filter { line =>
     line.contains(toMatch)
  }
}
```

This could be a lot tighter, [golf-wise][codegolf], but that's not the point.  If you are a Ruby programmer, and especially if
you disliked static types in Java, this is going to look a bit confusing.  There's a *lot* of code here that's just "telling the
compiler" what's going on: `grep` takes an argument `lines` that is a `Seq` of `String` instances as well as an argument
`toMatch` that is a `String` and the entire thing returns a `Seq` of `String`.  The Tyranny of Types&trade;!

Let's look at the Ruby version:

```ruby
def grep(lines,to_match)
  lines.select { |line|
    line[to_match]
  }
end
```

On its face, it looks a lot cleaner.  Almost the entire thing is just logic of what we're trying to do.  You might also say that
it's more flexible, since there are no types.  As long as we can `select` from `lines`, we're good.  This is the power of [duck
typing][ducktyping], right?

Duck typing, which is a form of [structural typing][structuraltyping] means that, as long as the objects in play respond to all
the messages they're being sent, everything is copasetic.  Of course, the routine is typically meant for particular types, and we
often document what those types are, so the caller knows how to use the method:

```ruby
# Returns lines that match a particular string
#
# lines:: an Array of String to filter
# to_match:: A String to search for
#
# Returns an Array of the Strings from +lines+ that contain +to_match+
def grep(lines,to_match)
  # ...
end
```

That's a bit of a mouthful, and it's not even accurate.  `grep` doesn't have any requirements whatsoever on `Array`, `String`,
or even `Enumerable`.  The Scala code, on the other hand, will absolutely not even *run* if you try to use values that don't
match the types.

Sure, you could open up the source of `grep` in the Rubydoc and sort out what it does and what could be safely passed in.
Unless `grep` is more complex.  It can be very hard (or impossible) to sort out what's safe to pass in by just reading the
source.  Often, you won't know until you try it at runtime.  Let's try writing out what we *do* know about `grep`'s behavior:

* Its first argument, `lines` must respond to a method `select` that has the following properties:
  * it must not require any arguments
  * it must take a block, which, *if called*, will be given exactly one value, which must have the following properties:
    * it must respond to the method `[]`, which must take exactly one argument which will always be `to_match`
    * the return value of `[]` is unspecified
  * The return value of the block is unspecified
  * The return value of `select` is unspecified
* Its second argument, `to_match`, can be anything and will be passed to the method `[]`, called on the parameter given to the block passed to `select`
* The return value of the method is whatever value is returned by the call to `select`

Wow, that is complicated.  Notice *how much detail* we have to get into about the behavior of the objects involved, but how significant parts of the way the method works are left unspecified.

To demonstrate this, we'll abuse `grep`:

```ruby
class Bar
  def [](arg)
    arg * 100
  end
end
class Foo
  def select(&block)
    count = 1
    count += block.call(Bar.new)
    count += block.call(Bar.new)
    count += block.call(Bar.new)
    count += block.call(Bar.new)
    count
  end
end

grep(Foo.new,45) # => 18001
```

Duck typing for the win?

Let's go back to our Scala version:

```scala
def grep(lines:Seq[String], toMatch:String):Seq[String] = {
  lines.filter { line =>
     line.contains(toMatch)
  }
}
```

We can write down the following *facts* about `grep`, without even looking at its source code:

* Its first argument, `lines`, must be a `Seq` containing `String` instances, or a subclass of that type
* Its second argument, `toMatch`, must be a `String` (there is no subclass of `String` possible in Scala)
* It returns a `Seq` containing `String` instances

The details of how `Seq` and `String` behave can be omitted, because they are defined, in detail, elsewhere in the system.

As such, while the Scala method has more "stuff" in it, it's actually easier to understand what it does.  Describing the
requirements for the parameters of a two line method in Ruby requires a deeply-nested bullet list.  The fact is, the *truth* about what methods in Ruby do is far more complex than in a statically typed language (and it requires complete access to the source code of the method and every method that method calls).

But what about flexibility?  Although my code to abuse `grep` is, well, bad, you could imagine some realistic ways to re-use `grep` that would not be possible in the Scala version, because of the strictness of the types.

Although Scala supports structural typing, it's actually quite difficult to figure out how to make this method work with *any* class that matches the methods being used.  This is as close as I could get, but doesn't compile:

```scala
def grep[T,U](lines   : { def filter(f:({ def contains(t:T):U }) => U]):U },
              toMatch : T):U = {
  lines.filter { line =>
     line.contains(toMatch)
  }
}
```

If the *Scala type system* has a problem with this, because even *it* can't sort out how to make this work, what hope do *we*
have?  It kinda scares me a little.

If we can't bring this flexibility to Scala, can we bring some of Scala's type safety to Ruby?  We can, and the result is not
what you'd call idiomatic Ruby:

```ruby
def grep(lines,to_match)
  raise "lines must be an Enumerable" unless lines.kind_of?(Enumerable)
  counter = =
  lines.select { |line|
    raise "Element #{counter} must be a String" unless line.kind_of?(String)
    counter += 1
    line[to_match]
  }
end
```

Yech.

What about tests?  Aren't tests the technique that frees us from needing types?  How do you write a test for `grep` that ensures
everyone is using it properly?  Sure, we can test that `grep` does what we intend, but if others start using it, we have no
control over what they do, and *we have only API documentation* as a means to help them understand.  So, to be safe, we document
our APIs using specific class names.

If we're doing that, what was the point of duck typing in the first place?

