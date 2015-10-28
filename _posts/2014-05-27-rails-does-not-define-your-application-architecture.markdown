---
layout: post
title: "Rails Does Not Define Your Application Architecture"
date: 2014-05-27 08:38
feature: true
---

While Rails doesn't prevent you from creating a well-architected application, it certainly doesn't
give you everything you need.  This is not so bad if your application is incredibly simple, but for anything of moderate
complexity (and I would argue that any app someone is paying you to produce is going to be moderately complex), Rails leaves a
lot of architectural decisions to you.

<!-- more -->

## What is application architecture?

When I say _application architecture_, I mean the way in which an application, at a very high level, is constructed.  The
application architecture is nothing more than a series of [design decisions](http://www.naildrivin5.com/blog/2014/03/07/what-rails-says-about-your-application-design.html) that answer questions like:

* How do I store and retrieve data?
* How do send output to the user?
* How does the user give me input?
* Where do I put my code?
* How do I run offline tasks?
* How do I schedule jobs?
* Where do my tests go?

Compared to any other application framework in my recent memory, Rails does a good job of answering these questions, but it
doesn't answer all of them, and its answers aren't always the ones you want to hear.

## Rails answers

Here's how Rails answers some of these questions:

* **How do I store and retrieve data?**  Make classes named for tables in your database.
* **How do I sent output to the user?** Expose instances of those classes to a templating language.
* **How do I get input from the user?** Input is a `Hash` formatted in a way that you can pass it directly to certain methods of
those classes.
* **Where do I put my code?** In general, put it in those data retrieval classes.  UI logic goes in your templates or in
globally-scoped free methods (helpers).

There is common thread in these answers and that is the model objects. You'll notice that Rails tightly couples areas of the application that should be decoupled.  Try changing how you store your data, and watch your form and url helpers fall apart <a name="back-1"></a><sup><a href="#1">1</a></sup>. 

The problem is that the question "Where do I put my code?" cannot have a simple answer, yet Rails has only a simple one to
give–put most code in your models.

The reason this answer is so bad is that in Rails, a "model" is an Active Record object that exposes the contents of a database
table via dynamically-generated methods (even calling these _data models_ isn't accurate, as most applications require modeling data in a way that does not correspond to relational database tables).

For example, what if we need to model a process?  The Rails Way is to find the nearest Active Record object and create a method for that process.  From any reasonable standard of design, this doesn't make a lot of sense.  Rails models, the holders of our application data, expose that data freely to anyone.  Going against years of object-oriented design prescriptions and diverting from our understanding of good design, Rails models break encapsulation, creating direct dependencies between every part of your application and your database.

## Encapsulation?  We don't need no stinking encapsulation!

A powerful feature of object-oriented design is encapsulation or data-hiding.  An object can expose coarse-grained operations
to its callers, but prevent the callers from accessing its internals.   This allows an object to change how it works without fear
that a caller is depending on its internal implementation.

For example, in the United States, a person's full name is created by appending their surname to their given name:

```ruby
me = Person.new(given_name: "David", surname: "Copeland")
puts "#{me.given_name} #{me.surname}" # => David Copeland
```

In China, however, the full name is reversed, so if we need to support Chinese people in our application, our code is now broken:

```ruby
me = Person.new(given_name: "Kong-sang", surname: "Chan")
puts "#{me.given_name} #{me.surname}" # => Kong-sang Chan (wrong)
```

We can "fix" it with `if` statements:

```ruby
if me.nationality.chinese?
  puts "#{me.surname} #{me.given_name}" # => Chan Kong-sang (right)
else
  puts "#{me.given_name} #{me.surname}"
end
```

This is not a good design, yet this is exactly the type of design that Rails would encourage us to use.  Why?

Active Record objects do not encapsulate their data. At all.  An Active Record object's purpose is to expose its innards.  By
creating a direct dependency between your UI code and your Active Record objects, you now have an application architecture that
is resistant to change.  The problem is that your UI code needs a full name, yet your Active Record object exposes only the
pieces needed to assemble it.

If all an Active Record object was was a conduit to and from a relational database, that would be fine.  After all, you *do* need a way to get data in and out of secondary storage and, at a certain point, you'll need to know what a person's surname and given name are.  But you don't need these values exposed globally, everywhere in your system.  

Why?  Why is it "OK" to break encapsulation to store data in a database, but not when formatting it for display?

The answer is related to the reasons a particular piece of code is likely to change.  Ask yourself which change is more likely: that you will store data differently in your database, or that you will need another way to display a person's name?<a name="back-2"></a><sup><a href="#2">2</a></sup>

In most reasonable application domains and organizations, the later is far more likely that the former.  Because of that, tightly
coupling the private data of a `Person` to the database storage mechanism is less of a risk than coupling it to your UI code.

To reduce this coupling, we want to hide the implementation of a person's full name behind some code.  Rails gives you two
options.  

The first is to create a helper method, which is a free method in the global namespace.  Aside from not being very
object-oriented, helpers have a host of problems related to being globally-scoped<a name="back-3"></a><sup><a href="#3">3</a></sup>.

The second is to simply create a method on `Person`, which seemingly encapsulates the details:

```ruby
class Person < ActiveRecord::Base

  def full_name
    if nationality.chinese?
      "#{surname} #{given_name}"
    else
      "#{given_name} #{surname}"
    end
  end
end
```

Does this seem like right place for this code?  Before adding this method, `Person` was a class that provided access to our secondary storage mechanism.  Even with the large footprint of Active Record, `Person` was a fairly focused and cohesive class. 

*Now*, it's in the business for formatting names based on nationality.  What if we later had a requirement to use a
gender-specific prefix for non-Chinese when we don't have a given name?

```ruby
class Person < ActiveRecord::Base

  def full_name
    if nationality.chinese?
      "#{surname} #{given_name}"
    else
      if !given_name
        if gender && gender.prefix?
          "#{gender.prefix} #{given_name}"
        else
          surname
        end
      else
        "#{surname} #{last_name}"
      end
    end
  end
end
```

What if we then need to use "Dr." for doctors?  What about other formal titles?  What about professional associations? Why is our class for accessing secondary storage changing so often?

One answer to this problem is that you extract the complex code when it "becomes a problem".  The theory being that there is
inherent complexity in having multiple classes and until that complexity is less than the complexity in `Person`, you keep the
code in `Person`.

To this, I say poppycock.  There is not a significant cost to having many classes.  Arguments to the contrary smack of not
knowing how to use one's editor.  You do not make application design decisions because you haven't figured out an efficient way
to navigate your source code.

I use vi, a very old text editor that is highly optimized for editing text.  It is not remotely optimized for working a Ruby on Rails project, yet I am very easily able to navigate a Rails codebase.  Given a class name, I can find the source file for that class, just as easily as I could navigate to a method within the current file.

This means that I can reap the advantages of many cohesive, simple classes, with none of the drawbacks of file navigation.  In
an editor created in the 70's.

If I were viewing this code, I would be mere keystrokes away from the implementation of `full_name`:

```erb
<%= person.full_name %>
```

Given *this* code, I would *still* be mere keystrokes away:

```erb
<%= FullName.for(person) %>
```

In fact, the second version would almost certainly be faster, because `FullName` will almost certainly be a very small class,
whereas `Person`, chock full of helper methods, will be huge.

## Help me Rails, you're my only hope!

I hinted at a possible alternative implementation above, so let's see what it might look like.  Again, this is just a
possibility:

```ruby
class FullName
  def self.for(person)
    if person.nationality.chinese?
      ChineseFullName.new(person.surname,person.given_name)
    else
      if person.given_name
        EuropeanFullName.new(person.surname,person.given_name)
      else
        if person.gender && person.gender.prefix?
          GenderSalutatingFullName.new(person.given_name,person.gender.prefix)
        else
          EuropeanFullName.new(nil,person.given_name)
        end
      end
    end
  end

  def initialize(surname,given_name)
    @surname = surname
    @given_name = given_name
  end

  class EuropeanFullName < FullName
    def to_s
      "#{@given_name} #{@surname}"
    end
  end

  class GenderSalutatingFullName < FullName
    def initialize(given_name,gender_prefix)
      super(nil,given_name)
      @gender_prefix = gender_prefix
    end

    def to_s
      "#{@gender_prefix} #{@given_name}"
    end
  end

  class ChineseFullName < FullName
    def to_s
      "#{@surname} #{@given_name}"
    end
  end
end
```

Well, holy crap that's a lot of code.  It might seem overly complex.  We turned a big bunch of `if` statements into a class
hierarchy with four different classes, just to format a string.

Look closer.  The series of `if` statements is still there—this is necessary complexity and we can't get rid of it<a name="back-4"></a><sup><a href="#4">4</a></sup>.  But, we've separated what type of format we need for how that format works.  Further, each class is *incredibly* simple.   Even if the concrete implementations of `FullName` were in their own files, we can still easily jump to the code involved.

Don't get too hung up on this particular design.  The important thing is that we've separated how we format people's names from
how we store them in the database.  This means that the more-likely changes to name formatting will not possibly impact the
less-likely changes to how we store people in the database.  

Also notice how neither the caller nor the formatting classes need
to have access to a person's information?  Name formatting—an operation that should only depend on name fragments—now only
depends on name fragments and not an entire `Person`.

This is the sort of design that object-oriented languages should encourage.  And it is not a design encouraged by Rails.

## What can we do?

The first thing is to divest yourself from the notion that increasing the number of behaviors on a class is OK if it's not "too many" or doesn't make the class "too big".  Forget the idea that you can cram all needed methods into one class until the class is "too complex", and then "fix" that class.  Instead, don't make a mess in the first place.  Put code where it should go from the get-go.

For example, consider where we started:

```ruby
# person.rb
class Person < ActiveRecord::Base
  def full_name
    "#{surname} #{given_name}"
  end
end

# person/show.html.erb
<%= person.full_name %>
```

Is the code above really less complex than:

```ruby
# person.rb
class Person < ActiveRecord::Base
end

# full_name.rb
class FullName
  def self.for(person)
    FullName.new(person.surname,person.given_name)
  end

  def initialize(surname,given_name)
    @surname    = surname
    @given_name = given_name
  end

  def to_s
    "#{surname} #{given_name}"
  end
end

# person/show.html.erb
<%= FullName.for(person) %>
```

The second version has three extra lines of code.  The ERB is almost identical.  And although it might've taken 30 more seconds
to enter the second code in than the former version, we will no longer ever have to decide if our `Person` class is "too big", or worry about refactoring it.  Ever.  We can safely enhance our name-formatting code as needed with one less decision to make.

This is where I think a lot of developers are getting to with Rails.  It's tricky enough to figure out how to implement the requirements we're given.  The fewer decisions we have to make, the easier our job is.  While Rails makes a lot of decisions for us, it still leaves us with a much more difficult decision - where does code go?

Essentially, Rails would have you start from the assumption that all code goes in an Active Record object unless there's a reason
it shouldn't.  My feeling is the opposite - code should not go in an Active Record object (or a controller) unless there's a good reason.

## An Appeal to Authority

I'm just one developer with my own experiences, so take this with a grain of salt.  I've maintained two different Rails codebases
(over a year for each one), and they were very large.

The first has an application architecture that followed all the Rails conventions.  Every feature of Rails was used, and there
were few idioms in the codebase that deviated from what Rails provides.  It was extremely difficult to work with.  It was hard to
find code, fix bugs, and add features, and simple changes frequently resulted in subtle bugs (occasionally, they were catastrophic).  The team was highly intelligent, motivated, and knowledgeable, and we had pretty good code review processes in place.

Worse was that the application was highly resistant to architectural changes.  Our team and business was growing and scaling.  I
spent three months hiding *one* table behind a RESTful API.  ONE table.

The second application I've worked on is one I'm working on now.  Well, it's rather many applications.  It started as a one
application, where the Active Record objects only dealt with the database.  All other code was elsewhere, usually in small,
single-purpose classes.  

When it came time to stand-up a second application that had different uptime requirements and different users, but needed to
share the database and some application logic, the process was surprisingly simple.  We moved code from one place to another and
everything pretty much worked.  Since then, we have several applications, all sharing the database.  We've changed in-line code
to run in background jobs as needed.  We've replaced some Active Record calls with Elasticsearch calls to increase performance
and enhance the user experience.

None of that took anyone months.  More like weeks, and we didn't introduce a lot of weird bugs.

All because we didn't accept Rails' default application architecture.  Note that we haven't _rejected_ it, we simply didn't accept
a simplistic answer to the question "Where does code go?" because we knew that such a question rarely can have such a simple
answer.

## Conclusion

Until now, I haven't mentioned testing, hexagonal, or anything else.  We're just talking about the basics of designing code in an
object-oriented language.  Rails encourages you to create fewer, larger, multi-purpose classes, yet provides no real benefit to
doing so.  You can, instead, create many smaller, single-purpose classes, but still get a lot of benefits of the other
application architecture decisions Rails makes.  You don't have to do everything it—or its creator—tells you to do.

---

<footer class='footnotes'>
<ol>
<li>
<a name='1'></a>
<sup>1</sup>Fixing this problem in Rails 2 was nigh-impossible.  It was extremely difficult in Rails 3, and possible in Rails 4, if you have the wherewithal to piece together a bunch of documentation. Search the Rails Guides for “ActiveModel” and you'll come up empty.  Rails models are Active Record objects, period.<a href='#back-1'>↩</a>
</li>
<li>
<a name='2'></a>
<sup>2</sup>I don't mean to imply that all applications have the same reasons for change, merely that you must ask the question, and that the question is a huge part of design.  Only you will know, based on the domain, company, and team, which parts of your application are more likely to change than others.<a href='#back-2'>↩</a>
</li>
<li>
<a name='3'></a>
<sup>3</sup>Because Ruby silently overrides methods when it encounters a new definition, you have to take great care in even medium-sized applications to avoid name clashes in helpers.  Rails helpers are a devolution in coding practice–even C uses prefixing as a means of namespacing to avoid this issue.  Ruby has modules and classes, which are much flexible and sophisticated ways to organize code.  Rails helpers ignore all that, and end up feeling like a huge design punt.<a href='#back-3'>↩</a>
</li>
<li>
<a name='4'></a>
<sup>4</sup>Well, we <strong>could</strong> get rid of via custom control structures, functions, table-based logic, or a host of other things, but that'll have to wait for another day.<a href='#back-4'>↩</a>
</li>
</ol></footer>
