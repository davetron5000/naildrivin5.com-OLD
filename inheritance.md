# What if there were no classes?

Previously, we looked at using Ruby with just functions, as well as without null.  And it wasn't actually that bad.

But what about classes, and all the baggage they bring with them?  You hear mumblings about "class-oriented" programming, versus
"object-oriented" programming, and what does it even mean?

We all know that a class is a template for making objects.  At least that's part of what it does.  In Ruby, classes can also:

* Incorporate methods from other classes (inheritance) or modules (mixins)
* Act as a namespace for free functions
* Act as objects themselves, having internal state and methods

Further, code inside a class is "special", because of `self` (as well as Ruby's sugar for ivars).  Of course, all code in Ruby is
inside a class, but there is an implicit `self` identifier and it changes, depending on what you are doing.

```ruby
# Here, `self` refers to a free Object that is the default scope
class Foo
  # Here, `self` is the class itself
  def initialize(bar)
    # Here, `self` is the _object_, which actually doesn't technically exist at
    # the time you're writing the code - only when the code runs.
  end
end
```

Let's see it in action, by using `object_id` and `class.name`:

    > puts "#{self.class} - #{self.object_id}"
    Object - 70296958920080
     => nil
    > class Foo
    >   puts "#{self.class} - #{self.object_id}"
    >   def initialize(bar)
    >     puts "#{self.class} - #{self.object_id}"
    >   end
    > end
    Class - 70296958794480
     => nil
    > Foo.new(4)
    Foo - 70296958747880
     => #<Foo:0x007fde928289d0>

This might be a bit confusing, especially to newcomers.  It gets even more difficult when we consider @vars:

    @foo = "outer"
    class Foo
      @foo = "in class"
      def initialize
        @foo = "in method"
      end
    end

    > self.instance_variables
     => [:@prompt, :@foo] 
    > Foo.instance_variables
     => [:@foo] 
    > Foo.new.instance_variables
     => [:@foo] 
    1.9.3p286 :021 > 

Um, OK, so which values are which?

    > self.instance_variable_get("@foo")
     => "outer" 
    > Foo.instance_variable_get("@foo")
     => "in class" 
    > Foo.new.instance_variable_get("@foo")
     => "in method" 

This seems more or less logical.  Let's now add a class variable:

    class Foo
      @@foo = "class var in class"
    end

    > Foo.instance_variables
     => [:@foo] 

So, what did we just add?

    > Foo.class_variables
     => [:@@foo] 

So what's the difference between an instance variable of `Foo` and a class variable?  They seem to have the same scope.  A
difference is that instances of `Foo` cannot access `Foo`'s _instance_ variable `@foo`, but they *can* access the *class*
variable `@@foo`.  What about inheritance?

    > class Bar < Foo
    >   end
     => nil 
    > Bar.class_variables
     => [] 
    > Bar.instance_variables
     => [] 
    > Bar.new.instance_variables
     => [:@foo] 

Oh boy.

So, let's get rid of all this.  No more support for classes, and no more confusing class or instance variables, no more
inheritance or mixins.  Let's see what we can do without them.

First, we'll need a simple domain.  We'll make a greeting system that can do a formal and informal greeting, and we'll have a
hierarchy of people that can be greeted.  In Ruby, that would look like this:

```ruby
class Greeter
  def greet(person)
    "#{salutation}, #{name(person)}"
  end

protected

  def salutation
    "Hello"
  end

  def name(person)
    person.full_name
  end
end

class FormalGreeter < Greeter
protected
  def salutation
    "Good day"
  end
end

class InformalGreeter < Greeter
protected
  def name(person)
    person.informal_name
  end

  def salutation
    "Yo"
  end
end

class Person
  attr_reader :full_name
  def initialize(full_name)
    @full_name = full_name
  end

  def informal_name
    @full_name
  end
end

class EuropeanStylePerson
  def initialize(first_name,last_name)
    super("#{first_name} #{last_name}")
    @first_name = first_name
  end

  def informal_name
    @first_name
  end
end
```

So, we have two class hierarchies - one of Greeters using the template method pattern to allow subclasses to customize the
greetings without worry about assembling the overall message, and a second for people, the top being a general person who just
has a name, and a subclass that uses the euro-american style of having first names and last names.  This is certainly contrived,
but it's simple enough to get through and complex enough to make our lives without classes a bit difficult.

If we don't have classes, what *do* we have?  Let's give ourselves objects and methods as a start.  The person concept will be a
bit simpler to start with, so let's get that working, first.

```ruby
Person = Object.dup
def Person.informal_name
  full_name
end
```

OK, so we have `Person` that defines just one method: `informal_name`, and that just delegates to the non-existent method
`full_name`.   OK:

    > Person.informal_name
    NameError: undefined local variable or method `full_name' for #<Object:0x007fba21bc9a20>

So, our method works, but we're missing the `full_name` method that allows it to do something useful.  What we want is a specific
person who *does* have a `full_name`.

    > madonna = Person.dup
    > def madonna.full_name; "Madonna"; end
    > madonna.informal_name
     => "Madonna"

It's a bit clunky, but it does work.  Effectively, the `Person` object is like a class - it defines some constraints about how
the object works, but leaves all the details entirely.  A `Person` is something that has an `informal_name` that is the same was
whatever the `full_name` is.  Now, let's make a person with a euro-american style name:

    > dave = Person.dup
    > def dave.full_name; "#{informal_name} Copeland"; end
    > def dave.informal_name; "Dave"; end
    > dave.informal_name
     => "Dave" 
    > dave.full_name
     => "Dave Copeland" 

We've lost the entire notion of the `EuropeanStylePerson` as a *type*.  We could certainly make it tho:

    > EuropeanStylePerson = Person.dup
    > def EuropeanStylePerson.full_name; "#{informal_name} #{last_name}"; end
    > def EuropeanStylePerson.informal_name; "#{last_name}"; end
    > EuropeanStylePerson.full_name
    NameError: undefined local variable or method `last_name' for #<Object:0x007fba1d820a30>
    > EuropeanStylePerson.informal_name
    NameError: undefined local variable or method `last_name' for #<Object:0x007fba1d820a30>
    1.9.3p194 :045 > dave = EuropeanStylePerson.dup
    1.9.3p194 :047 > def dave.last_name; "Copeland"; end
    1.9.3p194 :048 > def dave.informal_name; "Dave"; end
    1.9.3p194 :049 > dave.full_name
     => "Dave Copeland" 
    1.9.3p194 :050 > dave.informal_name
     => "Dave" 

I find this fascinating.  A `EuropeanStylePerson` is `Person` whose full name is their `informal_name` plus a `last_name`, and
their `informal_name` is defaulted to their `last_name`.  It inverts the `Person` entirely, and it makes the two seem unrelated
as to the way their names are determined (which is actually somewhat true - a fact that is not clear from the class-based
version).

OK, so we have a somewhat klunky way to make objects that work, how about our greeters?

    > Greeter = Object.dup
    > def Greeter.salutation; "Hello"; end
    > def Greeter.name(person); person.full_name; end
    > def Greeter.greet(person); "#{salutation}, #{name(person)}"; end
    > Greeter.greet(madonna)
     => "Hello, Madonna" 

Notice how we don't have a different concept for a _class_ or an _instance_?  The `Greeter` object is ready to go as-is - there's
no reason to make some sort of weird copy of it just to call methods.

In essence, we've created a system where there no state within these objects.  `madonna`'s `full_name` will always be "Madonna"
until we redefine it to be something else.  It may seem subtle, but I think it's worth distinguishing _definiting the return value of a method_ from _exposing internal state_.  The class-based approach we started with exposes state, whereas our object-based approach returns a static value.

What about our inheritance hierarchy?  We can just use the techniques we've already seen.

    > FormalGreeter = Greeter.dup
    > def FormalGreeter.salutation; "Good Day"; end
    > FormalGreeter.greet(madonna)
     => "Good Day, Madonna"
    > FormalGreeter.greet(dave)
     => "Good Day, Dave Copeland"

    > InformalGreeter = Greeter.dup
    > def InformalGreeter.salutation; "Yo"; end
    > def InformalGreeter.name(person); person.informal_name; end
    > InformalGreeter.greet(madonna)
     => "Yo, Madonna"
    > InformalGreeter.greet(dave)
     => "Yo, Dave"

The system here is overall simpler: there are fewer concepts to have to understand.  We just need to know that `dup` makes a
copy, what a method is, and how to define one.  There's a lot of repetition, however - we don't have an easy way to define
multiple methods on an object, for example.

What about mixins?  Suppose that our `Person` hierarchy needs to mix-in a module called `HasRole` - this allows a `Person` to
have a role, and is used by other classes to share this code.  While simplistic, this is a common reason for using mixins.  In
class-based Ruby:

```ruby
module HasRole
  def role;
    @role
  end

  def role=(role)
    @role = role
  end
end

class Person
  include HasRole

  # other methods here
end
```

Note that we also introduce some explicit mutability - the `role` can be changed.  How do we handle this in our classless Ruby
that only has objects?  First, let's make an object to represent our role module.  It turns out that there's no way to store
state without using instance variables.  This is unfortunate, because it feels syntactically possible to do something like this:

```ruby
HasRole = Object.dup
def HasRole.role=(new_role)
  def self.role
    new_role
  end
end
```

or even

```ruby
HasRole = Object.dup
def HasRole.role=(new_role)
  define_method(:role) do
    new_role
  end
end
```

Neither of these work.  In both cases, the problem is that `new_role` is not found.  The reason is that the body of the method we
are defining is executed in a different _binding_ than the method that's being executed and thus the parameter to our method,
`new_role` isn't available.  We could simulate this with the following hackery:

```ruby
GLOBAL_STATE = {}
HasRole = Object.dup
def HasRole.role=(new_role)
  GLOBAL_STATE[self] ||= {}
  GLOBAL_STATE[self][:role] = new_role
  def self.role
    GLOBAL_STATE[self][:role]
  end
end
```

We basically use a global variable to carve out some state for ourselves.  Ick.  Instead, we're going to have to use ivars.  I
really can't see a way around it.

    > HasRole = Object.dup
    > def HasRole.role=(new_role); @role = new_role; end
    > def HasRole.role; @role; end
    > x = HasRole.dup
    > x.role = "foo"
    > x.role
     => "foo"

OK, given this, how do we "mix it in" to our `Person` class?  We want to take each method in `HasRole` and effectively create one
on `Person` that calls the one in `HasRole`.  This is getting hacky:

```ruby
HasRole.methods(false).each { |method_name|
  eval("def Person.#{method_name}(*args)
          @has_role ||= HasRole.dup
          @has_role.method(:#{method_name}).call(*args) 
        end")
}
```

First, we have to use `eval` because we don't know the method name and using `define_method` will define the method on the
underlying class of the `Person` object, which is a) against the rules, and b) not what we want anyway.  Next, we have to store
a copy of the `HasRole` class in an ivar, because if we *don't* than any copy of `Person` will operate on the same ivars in
`HasRole` and everyone will have the same role.  Again, not what we want.

Wow, this sucks.  Could we make this any easier?  

We could try to do something with `method_missing` and handle method dispatch ourselves.  This solves our problems here, but it
makes defining methods a lot more difficult, because we then need some context on which to call our own methods, e.g. `self`.


