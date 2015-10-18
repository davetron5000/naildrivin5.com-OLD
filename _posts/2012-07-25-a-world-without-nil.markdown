---
layout: post
title: "&#10106;&#10144; A world without nil"
date: 2012-07-25 15:39
comments: true
categories: 
---
[Previously][functional-post], we saw how just using functions in Ruby, we could create a lot of powerful code.  Let's continue the theme of "programming with constraints" and try to solve an actual problem. `nil`.

<!-- more -->

## Is `nil` a problem?

`nil` creates problems in code clarity and revealing programmer intent.  `nil` means
"no value" sometimes, but other times it means `false`.  Other times it means "the developer didn't think of the proper default
for a value".  Rails migrations, by default, allow database columns to be nullable.  This is often not correct, and by making it
the default, you cannot tell the difference between "the business requires that this field be nullable" and "the developer forgot
to consider the nullability of this column".

The problems manifest when you see a test failure or production error where something is `nil` that you weren't expecting.  Now
you have to figure out if that value could be `nil` (and the original developer missed the edge case) or if it should *never* be
`nil`, and you have a more serious problem in either your data, business logic, or worse.

The reason this becomes complex isn't necessarily the concept of "no such value" (though this *is* a bit of a problem), but the way in which `nil` is treated by the language.  In Ruby, `nil` is the only instance of `NilClass` and has the following magical properties that cannot be bestowed on any other object:

* it is "falsey" (a trait shared with only one other value, `false`, the sole value of `FalseClass`)
* it is the default value of every variable

Because of these two things, we use it all over the place to represent "no value", and our code is littered with:

* `do_something if value.nil?`
* `foo ||= {}`
* `Array(some_list).each`

And so forth.  Avdi Grimm gave [a talk at Ruby Midwest][avdi-confident-code] called "Confident Ruby" that deals, in part, with nil and how to avoid it.  Things like `Array()`, `String()`, and null objects are good techniques.

But let's take a different approach.  What if there were no such thing as `nil`, and the language didn't support it?

## Can you imagine? A world without `nil`?

![275](http://25.media.tumblr.com/tumblr_ltbtgjU70B1qztjn5o1_500.jpg)

Suppose there were no such thing as `nil` in Ruby.  Every variable would require that a value be assigned to it at declare time, and the runtime would raise an exception if you tried to use a variable/parameter/etc. without a value.


How would that change the way we code?

Of course, we could re-invent it:

```ruby
class NilClass
  @@nil = NilClass.new
  def self.new
    @@nil
  end

  def nil?
    true
  end
end

class BasicObject
  def nil?
    false
  end
end

$nil = NilClass.new
```

This gives us a value that means "no value", but without the magic provided by the language, what good is it?

Let's return to our domain from the previous post, where we want to make a system that manages users in a database.  Since we now have our fully armed and operational object-oriented programming language, we might be inclined to make a `Person` class:

```ruby
class Person
  attr_reader :name, :birthdate, :gender, :title, :id
  def initialize(name,birthdate,gender,title,id)
    @name = name
    @birthdate = birthdate
    @gender = gender
    @title = title
    @id = id
  end
end
```

Remember, we don't have `nil`, so we don't have a default value for any variable - we must assign one explicitly or we'll get runtime errors.  Given the code above, this shouldn't be a problem, since we assign values to our ivars when they are declared.

If you recall, however, we have two optional values in our `Person`: `title`, and `id`. `title` is simply optional - a person might not have a title - while `id` will only be populated if the person has been stored in the database.  How can we model this?

## Generic optional values?

Scala (a statically-typed functional/OO language that runs on the JVM), "solves" this by creating an `Option` type that makes explicit the concept of an optional value<a name="back-1"></a><sup><a href="#1">1</a></sup>.  In Ruby, it would look like this:

```ruby An optional type
# The base class that also serves as a factory for instances
class Optional
  # Optional value that has a value
  def self.some(value)
    Some.new(value)
  end

  # Optional value with NO value
  def self.none
    None
  end
end

class Some < Optional
  attr_reader :value
  def initialize(value)
    @value = value
  end

  def exists?
    true
  end
end

class None < Optional
  def self.exists?
    false
  end
end
```

We can use it like so:

```ruby Using our optional type
dave = Person.new("Dave","1972-01-01",:male,Optional.none,Optional.none)
rudy = Person.new("Rudy","2001-01-01",:male,Optional.some("cat"),Optional.some(42))

class Person
  def salutation
    if title.exists?
      title.value + ' ' + name
    else
      name
    end
  end
end
```

So, we've replaced what would be a call to `.nil?` in regular Ruby with a call to `.exists?` in our nil-less Ruby.  Is this really any better?  We could wrap the logic of "do one thing if there's a value, do another if there isn't" into a method on `Optional`:

```ruby
class Some
  def with_value(&block,&_)
    block.call(self.value)
  end
end

class None
  def self.with_value(&_,&block)
    block.call
  end
end
```

We could then implement `salutation` like so:

```ruby
class Person
  def salutation
    self.title.with_value(
      ->(title) { title + ' ' + name },
      ->        { name }
    )
  end
end
```

Yech.  We might be able to play some syntax games and clean this up, but this is *not* an improvement.  `if/else` statements are
easy to understand and with the magic of `nil`, the logic is pretty straightforward:

```ruby using nil's falsiness
class Person
  def salutation
    if self.title
      self.title + ' ' + self.name
    else
      self.title
    end
  end
end
```

`Optional`, as we've defined it, is just a degenerate implementation of `nil` that has a terrible API<a name="back-2"></a><sup><a href="#2">2</a></sup>.  It *does* have the advantage of not being magic - we are required to provide a value for every variable, which is nice - but can we do better?

## Solving the problem in front of us

Let's step back and just try solving the problem in front of us, instead of adding the general concept of optional values.  What if we used the type system more explicitly?  

Suppose we define `Person` to be only the *required* values, i.e. the bare essence of a person in our system, and then create
mixins for the optional values.  We could make a mixin like `Stored` act as both a "tag" for an object that is stored in the
database, and as the location for related code.

```ruby
class Person
  # Every person must have a name, birthdate, and gender.
  attr_reader :name, :birthdate, :gender
  def initialize(name,birthdate,gender)
    @name = name
    @birthdate = birthdate
    @gender = gender
  end
end

module Stored
  attr_reader :id
end

module Titled
  attr_reader :title
end
```

Note that we don't make `id` or `title` mutable; they are still read-only fields.  So, how do they get set?  We tightly couple
`Person` with these new modules and set the fields there.

```ruby
class Person
  def title=(title)
    @title = title
    self.extend(Titled) # THIS object is now a Titled, but other Person instances are not
  end

  def id=(id)
    @id = id
    self.extend(Stored)
  end
end
```

Note that if we wanted to maintain total immutability, we would need to jump through a few hoops:

```ruby
class Person
  def with_title(title)
    self.dup.tap { |person|
      person.extend(Titled)
      person.instance_variable_set("@title",title)
    }
  end
```

In either case, we end up with an instance that has mixed in `Titled` and absolutey has a value for `title`.

How would this affect our `salutation` method?

```ruby
class Person
  def salutation
    if self.kind_of?(Titled)
      "#{title} #{name}"
    else
      name
    end
  end
end
```

We've replaced a generic check - for `nil` - with a specific check - for being `Titled`.  This may not seem like an improvement, but I'd argue that it makes our domain a bit richer and more intention-revelaing.  It turns an implementation decsion (treating `nil` as not having a title) into something explicit. And, at the end of the day, if we need logic based on the existence of a value, well, we're going to need to use `if` statements.  

Or are we?

Before we answer that, it's worth noting that although `Titled` is specific to our `Person` class, `Stored` is a more generic concept that could be broadly used to explicitly call out records not stored in the database.  Imagine an `update` method like so:


```ruby
def update(record)
  raise NotStoredError unless record.kind_of?(Stored)
end
```

That reads a lot better to me than a `nil` check<a name="back-3"></a><sup><a href="#3">3</a></sup>.  It also abstracts away the way in which we know that a record is stored, but without requiring a common superclass.

Back to our `if` statement.  We have a business rule based on the existence of a value, so it seems we just have to live with the conditional logic, right?  Not exactly.  What if both `Person` and `Titled` implemented `salutation`?

Person would use the "default if no title" version, because a raw `Person` has no title:

```ruby Person's default implementation of salutation
class Person
  def salutation
    name
  end
end
```

Once `Titled` is mixed in, we know that we absolutely have a title, so we override it with the correct logic given a title:

```ruby Titled overrides it, since it knows it has a value
module Titled
  def salutation
    title + ' ' + super
  end
end
```

Now, *this* is interesting.  We're using polymorphism and inheritance as a way to avoid `if` statements.  If we'd used `nil` to
represent "no title", we'd be stuck with conditional logic.  The added constraint of programming without `nil` has forced us to
get creative and resulted in a cleaner solution.

We've now used the type system to create an explicit description of our domain, and we didn't need `nil`.  Of course, a type that has a lot of optional values will require a lot of these sorts of modules, and it could get ugly.  This might be a good thing.

Now that we can handle optional values in our data structures, what about containers?  

## Optional values in container classes

I see a lot of code using `first` or `last` on an array as a shortcut for checking if the array is empty and, if not, getting the first or last element respectively.  Obviously, this would have to stop, but what about so-called "sparse arrays" where some indeces contain `nil` values?  Dealing with this cleanly is not simple given the currently API of `Array`.  Of course, if the language never had `nil`, you could imagine that `Array` would have *some* facility for dealing with this.  On idea would be that each accessor method would accept an optional block that would be run if there were no value, so that the caller could provide a default:

```ruby Imaginary Array API when we don't have nil
list = []
list[0]                               # => raises IndexError
list[0] { |index| "default#{index}" } # => default0
list.first { "default" }              # => default
```

When we're talking about containers, however, we'd need to be able to model "there is no value at this location" more explicitly.  Since *this* actually *is* a generic problem, we can bring back our `Optional` class to handle it.  We could assume that the `Array` class bakes in the use of `Optional`, but a) the API would be somewhat inconvienient and b) it doesn't help us in the real world.  What if we created a mix-in that we could use for `Array` instances that contained optional values?

```ruby Mix-in to make it easier to work with Arrays that contain Optional values
module OptionalValuesArray

  # Set a value directly
  def []=(index,value)
    super[index] = Optional.some(value)
  end

  # clear the value at this index
  def clear_value(index)
    super[index] = Optional.none
  end

  # get the value or, if it's not there, call the block
  def [](index,&block)
    super[index].with_value(
      ->(value) { value },
      ->()      { block.call(index) }
    )
  end

  # iterate over only the values that exist
  def each_value(&block)
    super.each(optional)
      optional.with_value(
        ->(value) { block.call(value) },
        ->()      { }
      )
    end
  end

  # Map only the values that exist
  def map_values(&block)
    [].tap { |new_array|
      self.each_value do |value| 
        new_array << value
      end
    }
  end
end

optional_values_allowed = [].extend(OptionalValuesArray)
no_optional_values = []
```

This API might not be "right", but we can see that, without `nil`, we have to be explicit about which arrays can be missing
values and which cannot.  That makes our code more intention-revealing.  If Ruby really didn't have `nil`, I would expect the
Array class to better "bake-in" this concept so that the API was clean and easy.

`Hash`, on the other hand, comes built-in with everything we need to avoid `nil`, namely the `fetch` method:

```ruby
hash = { :foo => :bar, :baz => :quux }
hash.fetch(:foo)                   # => :bar
hash.fetch(:blah)                  # => raises IndexError
hash.fetch(:blah) { |key| "crud" } # => "crud"
```

By using `fetch`, we can be very clear about what we want to do.  Without a block, we are getting the value for a key that must exist.  *With* a block we indicate that we're getting a value for a key that is optional...and we must specify the value to use if it's missing.

An alternative is to specify a block that provides default values, and then use `[]`:

```ruby
hash = Hash.new { |key,value| :default_value }
hash[:foo] = :bar
hash[:foo]  # => :bar
hash[:blah] # => :default_value
```

Another way in which we use `nil` in a `Hash` is in the "options hash" pattern where we can parameterize a method call, typically
omitting keys where we want to use the default value provided by the API.  In this case, we use `nil` to mean "don't use the
default, but omit the value entirely".  

For example, in Rails 3, we can use `respond_with` to send an object to the caller in the
controller.  By default, the HTTP location header is set by examining the type of the object and getting a URL for it.
`respond_with` takes an options hash and, if we wish to avoid setting this header, we must set `:location` to `nil`:

```ruby Using nil to "unset" an option
class SomeController
  respond_to :json

  def create
    record = create_record_somehow
    respond_with record, :location => nil
  end
end
```

Doing this without `nil` is trickier, and I think it requires a small change in how we design APIs using the options hash.
The result, again, will be more intention-revelaing code.  Instead of using `nil` for "don't set the location header", we would
set an option that indicates that more clearly:

```ruby Imagined options for respond_with
class SomeController
  respond_to :json

  def create
    record = create_record_somehow
    respond_with record, :set_location => false
  end
end
```

This would even improve the implementation of `respond_with` as well:

```ruby Imagined implementation of respond_with if nil were not an option
def respond_with(record,options = {})
  options[:location] = options.fetch(:location) { default_location_for(record) }
  if options[:set_location]
    headers['Location'] = options[:location]
  end

  # and whatever else
end
```

Again, the absence of `nil` is making our code a *bit* longer, but much more intention-revealing and explicit.

In reality, though, `nil` exists and is used in many places.  Can we take anything from this to the real world?

## Back to reality

First and foremost, I would suggest that you design APIs in a way that `nil` is not required nor used.  Methods that return
collections should return an empty version instead of `nil`.  Method parameters should not allow `nil` to be passed in for any
value, and should use an options has for optional values.

Not every API is written this way, and to deal with them, there are a few handy methods provided by Ruby that can help:

* `String()` - converts `nil` to the empty string, and converts any string to itself.  Wrap a possibly-`nil` string in this and you avoid a `nil` check. (ActiveSupport's `#present?` is a way to do this, too, but `String()` works everywhere in Ruby)
* `Array()` - converts `nil` to an empty array and converts an array to itself.  Perfect for dealing with pesky APIs that insist on returning `nil` instead of an empty array.
* `Hash[Array()]` - by combining `Hash#[]` and `Array()`, we can convert nil to an empty hash and a hash to itself.  `Array()` will turn a `Hash` into a two-dimensional array, and `Hash#[]` will turn a two-dimensional array back into a `Hash`.  Since `Array()` turns `nil` into an empty array, `Hash[Array(nil)]` returns an empty has.  Ruby really should include a method named `Hash()` that does this, but it doesn't.

Beyond this, [null objects][nullobjects] are a useful pattern for encapsulating logic of the type "do this if some value is nil", and the [`try`][trymethod]
method in Rails is also very useful.

It's still interesting to think about a world without `nil`. Without it, we can still handle the absence of values in objects, as well as containers, and our code is more intentional-revelaing.  Why *do* we need `nil`?

----

<footer class='footnotes'>
<ol>
<li>
<a name='1'></a>
<sup>1</sup>The JVM still allows <code>null</code> and so does Scala, so <code>Option</code> only provides a way to express optional types more clearly; <code>null</code> is still there and is the default value of variables that aren't given an initial value.<a href='#back-1'>↩</a>
</li>
<li>
<a name='2'></a>
<sup>1</sup>It's worth pointing out that in Scala, <code>Option</code> is a lot more useful, because <code>null</code> has no such magical properties on the JVM like it does in Ruby.<a href='#back-1'>↩</a>
</li>
<li>
<a name='3'></a>
<sup>1</sup>I realize that Active Record encapsulates this concept in <code>new_record?</code>, but a) we're in an imaginary domain without Active Record and b) that Active Record encapsulates the <code>nil</code> check gives more credence that doing so is a good idea in general.<a href='#back-1'>↩</a>
</li>
</ol></footer>

[functional-post]: http://www.naildrivin5.com/blog/2012/07/17/adventures-in-functional-programming-with-ruby.html
[avdi-confident-code]: http://confreaks.com/videos/763-rubymidwest2011-confident-code
[nullobjects]: http://en.wikipedia.org/wiki/Null_Object_pattern
[trymethod]: http://api.rubyonrails.org/classes/Object.html#method-i-try
