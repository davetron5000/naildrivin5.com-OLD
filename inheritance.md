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

    # Here, `self` refers to a free Object that is the default scope
    class Foo
      # Here, `self` is the class itself
      def initialize(bar)
        # Here, `self` is the _object_, which actually doesn't technically exist at
        # the time you're writing the code - only when the code runs.
      end
    end

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

    class Greeter
      def greet(person)
        "Hello, #{person.full_name}"
      end
    end

    class FormalGreeter < Greeter
      def greet(person)
        "Good day #{person.full_name}"
      end
    end

    class InformalGreeter < Greeter
      def greet(person)
        "Yo, #{person.first_name}, wuzup?"
      end
    end

    class Person
      attr_reader :full_name
      def initialize(full_name)
        @full_name = full_name
      end

      def first_name
        @full_name
      end
    end

    class EuropoeanStylePerson
      attr_reader :first_name
      def initialize(first_name,last_name)
        @first_name = first_name
        @last_name  = last_name
      end

      def full_name
        "#{@first_name} @{last_name}"
      end
    end
