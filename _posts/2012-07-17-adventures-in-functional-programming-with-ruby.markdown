---
layout: post
title: "&#10106;&#10144; Adventures in functional programming with Ruby"
date: 2012-07-17 11:33
comments: true
categories: 
---
The following is an aimless journey through a degenerate form of Ruby, in an effort to learn a bit more about functional programming, simplicity, and API design.

Suppose that the only way we have to organize code in Ruby is to make lambdas, and the only way we have to structure data are arrays:

```ruby
square = ->(x) { x * x }
square.(4) # => 16

person = ["Dave",:male]
print_person = ->((name,gender)) { 
  puts "#{name} is a #{gender}"
}
print_person.(person)
```

This is the most bare-bones essence of functional programming: all we have is functions.   Let's write some real-ish code this way and see how far we get before it starts
becoming painful.

<!-- more -->

Suppose we want to manipulate a database of people, and someone has provided us a few functions to interact with a data store.   We want to use these to add a UI and some validations.

Here's how we interact with our data store:

```ruby
insert_person.(name,birthdate,gender) # => returns an id
update_person.(new_name,new_birthdate,new_gender,id)
delete_person.(id)
fetch_person.(id) # => returns the name, birthdate, and gender as an array
```


First, we need to be able to add a person to our database, along with some validations.  We'll get this data from user input (we can assume that `puts` and `gets` are built-ins that work as expected):

```ruby
puts "Name?"
name = gets

puts "Birthdate?"
birthdate = gets

puts "Gender?"
gender = gets
```

We need a function to do our validations and add a person to the database.  What might it look like?  It should accept the attributes of a person and return
either an id (on successfully validation and insertion), or an error message, representing what went wrong.   Since we don't have exceptions or hashes - just arrays -
we're going to have to get creative.

Let's create a convention in our system that every business logic methods returns an array of size 2.  The first element is the return value on success, and
the second element is an error message on failure.  The presence or absence of data in one of these slots indicates the result.

Now that we've sorted out what we accept as arguments and what we're going to return, let's write our function:

```ruby
add_person = ->(name,birthdate,gender) {
  return [nil,"Name is required"]                  if String(name) == ''
  return [nil,"Birthdate is required"]             if String(birthdate) == ''
  return [nil,"Gender is required"]                if String(gender) == ''
  return [nil,"Gender must be 'male' or 'female'"] if gender != 'male' && gender != 'female'

  id = insert_person.(name,birthdate,gender)
  [[name,birthdate,gender,id],nil]
}
```

If you aren't familiar with `String()`, it is a function that coalesces nil to the empty string, so we don't have to check for both.

With this function, what we'd like to do is call it in a loop until the user has provided correct input, like so:

```ruby
invalid = true
while invalid
  puts "Name?"
  name = gets
  puts "Birthdate?"
  birthdate = gets
  puts "Gender?"
  gender = gets
  result = add_person.(name,birthdate,gender)
  if result[1] == nil
    puts "Successfully added person #{result[0][0]}"
    invalid = false
  else
    puts "Problem: #{result[1]}"
  end
end
```

Of course, we never said anything about `while` loops :)  Suppose we don't have them.  

## Loops are just functions (called recursively)

To loop, we simply wrap our code in a function and call it recursively until we achieve the desired result.

```ruby
get_new_person = -> {
  puts "Name?"
  name = gets
  puts "Birthdate?"
  birthdate = gets
  puts "Gender?"
  gender = gets
  result = add_person.(name,birthdate,gender)
  if result[1] == nil
    puts "Successfully added person #{result[0][0]}"
    result[0]
  else
    puts "Problem: #{result[1]}"
    get_new_person.()
  end
}

person = get_new_person.()
```

We can envision that our code is going to have a lot of `if result[1] == nil` in it, so let's wrap it in a function.
The great thing about functions is that they allow us to re-use structure, as opposed to logic.  The structure here is 
checking for an error and doing one thing on success and another on error.

```ruby
handle_result = ->(result,on_success,on_error) {
  if result[1] == nil
    on_success.(result[0])
  else
    on_error.(result[1])
  end
}
```

Now, our `get_new_person` function abstracts away the error handling:

```ruby
get_new_person = -> {
  puts "Name?"
  name = gets.chomp
  puts "Birthdate?"
  birthdate = gets.chomp
  puts "Gender?"
  gender = gets.chomp

  result = add_person.(name,birthdate,gender)

  handle_result.(result,
    ->((id,name,birthdate,gender)) {
      puts "Successfully added person #{id}"
      [id,name,birthdate,gender,id]
    }, 
    ->(error_message) {
      puts "Problem: #{error_message}"
      get_new_person.()
    }
  )
}

person = get_new_person.()
```

Notice what the use of `handle_result` allows us to explicitly name variables, instead of using Array de-referencing.  Not only can we name `error_message`, but, using Ruby's
array-extraction syntax, we can "explode" our person array into its attributes via the `((id,name,birthdate,gender))` syntax.

So far, so good.  This code is probably a bit weird looking, but it's not terribly verbose, or complex.

## Clean code uses more functions.

One thing that might seem odd is that our person has no real structure or formal definition.  We simply have an array, and a
convention that the first element is the name, second element is birthdate, etc.  Our domain is pretty simple as-is, but let's
suppose we want to add a new field: title.  What happens to our code when we do this?

Our database team delivers new versions of `insert_person` and `update_person` to us:

```ruby
insert_person.(name,birthdate,gender,title)
update_person.(name,birthdate,gender,title,id)
```

We then have to update our `add_person` method:

```ruby
add_person = ->(name,birthdate,gender,title) {
  return [nil,"Name is required"]                  if String(name) == ''
  return [nil,"Birthdate is required"]             if String(birthdate) == ''
  return [nil,"Gender is required"]                if String(gender) == ''
  return [nil,"Gender must be 'male' or 'female'"] if gender != 'male' && gender != 'female'

  id = insert_person.(name,birthdate,gender,title)

  [[name,birthdate,gender,title,id],nil]
}
```

And, since we use these extractions in `get_new_person`, **that** has to change, too.  Ugh:

```ruby
get_new_person = -> {
  puts "Name?"
  name = gets.chomp
  puts "Birthdate?"
  birthdate = gets.chomp
  puts "Gender?"
  gender = gets.chomp
  puts "Title?"
  title = gets.chomp

  result = add_person.(name,birthdate,gender,title)

  handle_result.(result,
    ->((name,birthdate,gender,title,id)) {
      puts "Successfully added person #{id}"
      [id,name,birthdate,gender,title,id]
    }, 
    ->(error_message) {
      puts "Problem: #{error_message}"
      get_new_person.()
    }
  )
}
```

This is the very definition of high-coupling.  `get_new_person` really shouldn't care about the particular fields of a person; it
should simply read them in, and then pass them to `add_person`.  Let's see if we can make that happen by extracting some of this code into new functions.

```ruby
read_person_from_user = -> {
  puts "Name?"
  name = gets.chomp
  puts "Birthdate?"
  birthdate = gets.chomp
  puts "Gender?"
  gender = gets.chomp
  puts "Title?"
  title = gets.chomp
  [name,birthdate,gender,title]
}

person_id = ->(*_,id) { id }

get_new_person = -> {
  handle_result.(add_person.(*read_person_from_user.())
    ->(person) {
      puts "Successfully added person #{person_id.(person)}"
      person
    }, 
    ->(error_message) {
      puts "Problem: #{error_message}"
      get_new_person.()
    }
  )
}
```

We've now abstracted the way in which we store a person into two functions: `read_person_from_user` and `person_id`.  At this
point, `get_new_person` will not need to change if we add more fields to a person.

If you're confused about the use of `*` in this code, here's a brief explanation:  `*` allows us to treat an array as a list of arguments and vice versa.  In `person_id`, we
use the parameter list `*_,id`, which tells Ruby to place all arguments to the function, save the last, into the variable `_` (so-named because we don't care about its value),
and place the last argument in the variable `id`.  This only works in Ruby 1.9; in 1.8 only the last argument of a function may use the `*` syntax.  Further, when we call
`add_person`, we use the `*` on the results of `read_person_from_user`.  Since `read_person_from_user` returns an array, we want to treat that array as if it were an argument
list, since `add_person` accepts explicit arguments.  The `*` does that for us.  Nice!

Back to our code, you'll note that we still have coupling between `read_person_from_user` and `person_id`.  They both are intimate with how we store a person in an array.
Further, if we added new features to actually *do* something with our people database, we can envision more methods coupled to this array-based format.

We need some sort of data structure.  

# Data structures are just functions

In non-degenerate Ruby, we'd probably make a class at this point, or at least us a `Hash`, but we don't have access to those
here.  Can we make a real data structure just using functions?  It turns out we can, if we create a function that treats its first argument as an attribute of our data
structure:

```ruby
new_person = ->(name,birthdate,gender,title,id=nil) {
  return ->(attribute) {
    return id        if attribute == :id
    return name      if attribute == :name
    return birthdate if attribute == :birthdate
    return gender    if attribute == :gender
    return title     if attribute == :title
    nil
  }
}

dave = new_person.("Dave","06-01-1974","male","Baron")
puts dave.(:name)   # => "Dave"
puts dave.(:gender) # => "male"
```

`new_person` acts like a constructor, but instead of returning an object (which don't exist for us), we return a function that, when called, can tell us the values of the
various attributes of our person.  We explicitly itemize the possible attributes, so we have a fairly firm definition of what the type of a person is.

Compare this to a class that does the same thing:

```ruby
class Person
  attr_reader :id, :name, :birthdate, :gender, :title
  def initialize(name,birthdate,gender,title,id=nil)
    @id = id
    @name = name
    @birthdate = birthdate
    @gender = gender
    @title = title
  end
end

dave = Person.new("Dave","06-01-1974","male","Baron")
puts dave.name 
puts dave.gender
```

Interesting.  The size of these two bits of code is more or less the same, but the class-based version is full of _special forms_.  Special Forms are essentially magic provided by the language or runtime.  To understand this code, you need to know:

* what `class` means
* that calling `new` on the class's name calls the `initialize` methods
* what methods are
* that prepending `@` to a variable makes it private to the class' instance
* the difference between a class and an instance
* what `attr_reader` does

Compared to our functional version, all you need to know is:

* how to define a function
* how to invoke a function

Like I said, I find this interesting.  We have two ways of writing essentially the same code, and one way requires you to have a lot more special knowledge than the other.

OK, now that we have a real data structure, let's rework our code to use it, instead of arrays:

```ruby
read_person_from_user = -> {
  puts "Name?"
  name = gets.chomp
  puts "Birthdate?"
  birthdate = gets.chomp
  puts "Gender?"
  gender = gets.chomp
  puts "Title?"
  title = gets.chomp

  new_person.(name,birthdate,gender,title)
}

add_person = ->(person) {
  return [nil,"Name is required"]                  if String(person.(:name)) == ''
  return [nil,"Birthdate is required"]             if String(person.(:birthdate)) == ''
  return [nil,"Gender is required"]                if String(person.(:gender)) == ''
  return [nil,"Gender must be 'male' or 'female'"] if person.(:gender) != 'male' && 
                                                      person.(:gender) != 'female'

  id = insert_person.(person.(:name),person.(:birthdate),person.(:gender),person.(:title))
  [new_person.(person.(:name),person.(:birthdate),person.(:gender),person.(:title),id),nil]
}

get_new_person = -> {
  handle_result.(add_person.(read_person_from_user.()),
    ->(person) {
      puts "Successfully added person #{person.(:id)}"
      person
    }, 
    ->(error_message) {
      puts "Problem: #{error_message}"
      get_new_person.()
    }
  )
}
```

`add_person` is a bit noisier, due to the syntax of getting an attribute, but we can now add new fields very easily and keep things structured.  

## Object-orientation is just functions

We can also add derived fields.  Suppose we want a saluation for the person that uses their title?  We can make that an attribute of the person:

```
new_person = ->(name,birthdate,gender,title,id) {
  return ->(attribute) {
    return id        if attribute == :id
    return name      if attribute == :name
    return birthdate if attribute == :birthdate
    return gender    if attribute == :gender
    return title     if attribute == :title
    if attribute == :salutation
      if String(title) == ''
        return name
      else
        return title + " " + name
      end
    end
    nil
  }
}
```

Heck, we can create full-on OO-style _methods_ if we wanted to:

```ruby
new_person = ->(name,birthdate,gender,title,id) {
  return ->(attribute) {
    return id        if attribute == :id
    return name      if attribute == :name
    return birthdate if attribute == :birthdate
    return gender    if attribute == :gender
    return title     if attribute == :title
    if attribute == :salutation
      if String(title) == ''
        return name
      else
        return title + " " + name
      end
    elsif attribute == :update
      update_person.(name,birthdate,gender,title,id)
    elsif attribute == :destroy
      delete_person.(id)
    end
    nil
  }
}

some_person.(:update)
some_person.(:destroy)
```

While we're at it, let's add inheritance!  Suppose we have an employee that is a person, but with an employee id number:

```ruby
new_employee = ->(name,birthdate,gender,title,employee_id_number,id) {
  person = new_person.(name,birthdate,gender,title,id)
  return ->(attribute) {
    return employee_id_number if attribute == :employee_id_number
    return person.(attribute)
  }
}
```

We've created classes, objects, and inheritance, all with just functions, and in just a few lines of code.

In a sense, an object in an OO language is a set of functions that have access to a shared set of data.  It's not hard to see why adding an object system to a functional
language is considered trivial by those knoweldgable in functional languages.  It's certainly a lot easier than adding functions to an object-oriented language!

Although the syntax for accessing attributes is a bit clunky, I'm not feeling a *ton* of pain by not having classes.  Classes seem almost like syntactic sugar at this point,
rather than some radical concept.  

One thing that seems problematic is mutation.  Look at how verbose `add_person` is.  It calls `insert_person` to put our person into the database, and
gets an ID back.  We then have to create an entirely new person just to set the ID.  In classic OO, we'd just do `person.id = id`.

Is mutable state what's nice about this construct?  I'd argue that its compactness is what's nice, and the fact that this compactness is implemented via mutable state is just
incidental.  Unless we are in a severely memory-starved environment, with terrible garbage collection, we aren't going to be concerned about making new objects.  We *are* going
to be annoyed by the needless repetition of building new objects from scratch.  Since we already know how to add functions to our, er, function, let's add one to bring back
this compact syntax.

```ruby
new_person = ->(name,birthdate,gender,title,id=nil) {
  return ->(attribute,*args) {
    return id        if attribute == :id
    return name      if attribute == :name
    return birthdate if attribute == :birthdate
    return gender    if attribute == :gender
    return title     if attribute == :title
    if attribute == :salutation
      if String(title) == ''
        return name
      else
        return title + " " + name
      end
    end

    if attribute == :with_id # <===
      return new_person.(name,birthdate,gender,title,args[0])
    end

    nil
  }
}
```

Now, `add_person` is even simpler:

```ruby
add_person = ->(person) {
  return [nil,"Name is required"]                  if String(person.(:name)) == ''
  return [nil,"Birthdate is required"]             if String(person.(:birthdate)) == ''
  return [nil,"Gender is required"]                if String(person.(:gender)) == ''
  return [nil,"Gender must be 'male' or 'female'"] if person.(:gender) != 'male' && 
                                                      person.(:gender) != 'female'

  id = insert_person.(person.(:name),person.(:birthdate),person.(:gender),person.(:title))
  [person.(:with_id,id),nil] # <====
}
```

It's not quite as clean as `person.id = id`, but it's terse enough that it's still readable, and the code is better for it.

## Namespaces are just functions

What I'm really missing is namespaces.  If you've done any C programming, you know that your code becomes littered with functions that have complex prefixes to avoid
name-clashes.  We could certainly do that here, but it would be nice to have proper namespacing, like we get via modules in Ruby or object literals in JavaScript.
We'd like to add this without adding a feature to our language.  The simplest way to do that is to implement some sort of map.  We can already get explicit attributes
of a data structure, so we just need a more generic way to do so.

Currently, the only data structure we have is an array, and we don't have methods, since we don't have classes.  The arrays we have are really tuples, and the only general
operations we have are the ability to extract data from them.  For example:

```
first = ->((f,*rest)) { f    } # or should I name this car? :)
rest  = ->((f,*rest)) { rest }
```

We can model a map as a list, by treating it as a list with three entires: the key, the value, and the rest of the map.  Let's avoid the "OO style" of making "methods" and
just keep it pureful functional:

```
empty_map = []
add = ->(map,key,value) {
  [key,value,map]
}
get = ->(map,key) {
  return nil if map == nil
  return map[1] if map[0] == key
  return get.(map[2],key)
}
```

We can use it like so:

```
map = add.(empty_map,:foo,:bar)
map = add.(map,:baz,:quux)
get.(map,:foo)  # => :bar
get.(map,:baz)  # => :quux
get.(map,:blah) # => nil
```

This is enough to namepsace things:

```
people = add.(empty_map ,:insert ,insert_person)
people = add.(people    ,:update ,update_person)
people = add.(people    ,:delete ,delete_person)
people = add.(people    ,:fetch  ,fetch_person)
people = add.(people    ,:new    ,new_person)

add_person = ->(person) {
  return [nil,"Name is required"]                  if String(person.(:name)) == ''
  return [nil,"Birthdate is required"]             if String(person.(:birthdate)) == ''
  return [nil,"Gender is required"]                if String(person.(:gender)) == ''
  return [nil,"Gender must be 'male' or 'female'"] if person.(:gender) != 'male' && 
                                                      person.(:gender) != 'female'

  id = get(people,:insert).(person.(:name),
                            person.(:birthdate),
                            person.(:gender),
                            person.(:title))

  [get(people,:new).(:with_id,id),nil]
}
```

We could certainly replace our `new_person` implementation with a map, but it's nice to have an explicit list of attributes that we support, so we'll leave `new_person` as-is.

One last bit of magic.  `include` is a nice feature of Ruby; it lets us bring modules into scope to avoid using the namespace.  Can we do that here?  We can get close:

```
include_namespace = ->(namespace,code) {
  code.(->(key) { get(namespace,key) })
}

add_person = ->(person) {
  return [nil,"Name is required"]                  if String(person.(:name)) == ''
  return [nil,"Birthdate is required"]             if String(person.(:birthdate)) == ''
  return [nil,"Gender is required"]                if String(person.(:gender)) == ''
  return [nil,"Gender must be 'male' or 'female'"] if person.(:gender) != 'male' && 
                                                      person.(:gender) != 'female'

  include_namespace(people, ->(_) {
    id = _(:insert).(person.(:name),
                     person.(:birthdate),
                     person.(:gender),
                     person.(:title))

    [_(:new).(:with_id,id),nil]
  }
}
```

OK, this might be over the top, but it's fairly interesting to think of something like `include` as just a way to "type less stuff", and that we can achieve a similar
reduction in "typing stuff" by just using functions.

## What have we learned?

With just a few basic language constructs, we can create a fairly usable programming language.  We can create bona-fide types, namespaces, and even
do object-oriented programming, without any explicit support for these features.  And we can do so in more or less the same amount of code that would be required
by using Ruby's built-in support.  The syntax is *slightly* verbose compared to the full-blown Ruby equivalent, but it's not
*that* bad.  We could write real code using this degenerate form of Ruby, and it wouldn't be too bad.

Does this help us in our everyday work?  I think this is a lesson in simplicity.  Ruby is fraught with DSLs, abused syntax, and meta-programming, yet we've just
been able to accomplish a lot without even using classes!  Perhaps the problem you have in front of you can be solved by something simple?  Perhaps you don't
need anything fancy, but can rely on the more straightforward parts of your language.
