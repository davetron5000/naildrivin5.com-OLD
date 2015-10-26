---
layout: post
title: "The Complexity of Object-Oriented Design"
date: 2014-07-11 09:17
feature: true
---

I can't say what a codebase designed to Alan Kay's idea of "object-oriented" might look like.
I *can* say what your average developer (including myself) actually creates using object-oriented languages, tools, and techniques.
The result is a constant battle to tame complexity.
I'm going to lay out one source of that complexity, because it's baked-in to object-orientation, and I debate that it provides any utility in making programs easy to understand or change.

<!-- more -->

Consider a procedural language in which no global symbols are possible:

```ruby
def salutation(first_name,last_name)
  if first_name != nil
    "Hey #{first_name}!"
  else
    "Hello, #{last_name}"
  end
end

salutation("Dave","Copeland") # => Hey Dave
salutation(nil,"Jones")       # => Hello, Jones
```

Because there are no global symbols, we can easily (and totally) understand this routine.
Everything it requires to do its job is passed as parameter, and every affect it has is part of its return value.

Such a language would be unusable at any real complexity, because we could not decompose logic into smaller re-usable routines.
Consider if we are creating a message for someone:

```ruby
def create_message(first_name,last_name,message,from)
  salutation = if first_name != nil
                 "Hey #{first_name}!"
               else
                 "Hello, #{last_name}"
               end
  %{
#{salutation},

#{message}

           Sincerely,

           #{from}
}
end
```

This routine, like `salutation`, is still simple to understand.
Everything it needs to do its job is passed as a parameter and its entire affect is described in its return value.

But, since we don't have global symbols (or any other obvious way to share logic), we've had to duplicate `salutation`.
Although our hypothetical language encourages simple design, it's not usable in its current state.

If we could wrap up the salutation logic, along with the data it needed, into a single package, that could allow re-use.

## Objects: Data & Functionality?

In an object-oriented language, we have the ability to associate functionality with data, so we might logically have the `first_name` and `last_name` in some sort of object, and that object will implement the `salutation` method.

```ruby
class Person
  def salutation
    if first_name != nil
      "Hey #{first_name}!"
    else
      "Hello, #{last_name}"
    end
  end
end
```

Now, our `create_message` doesn't need to reproduce the `salutation` logic, but can use it from the new `person` object:

```ruby
def create_message(person,message,from)
  %{
#{person.salutation},

#{message}

           Sincerely,

           #{from}
}
end
```

This seems good, right?  We still don't need global symbols, and we've found a way to encapsulate and re-use logic.

## Why are global symbols bad?

Suppose that instead of creating objects, we had the ability to define a global symbol.
We could re-use `salutation` by making in global, meaning that `create_message` could be implemented as follows:

```ruby
def create_message(first_name,last_name,message,from)
  %{
#{salutation(first_name,last_name},

#{message}

           Sincerely,

           #{from}
}
end
```

We've successfully re-used `salutation`, but look at how complex `create_message` has become!  Before, **all** input to `create_message` was in its parameter list.
*Now*, its inputs are the parameter list and **every global symbol**.

Consider how we might send a message:

```ruby
def send_message(email_addresses,message)
  for email_address in email_addresses
    email(email_address,message)
  end
end
```

In addition to having all global state as its input, `send_message`'s *output* is also anything available in global state.
`send_message` returns nothing, but has an affect on the outside world nontheless.

All this means that any routine that has access to a shared global state is going to be more complex than one that doesn't, and that, without discipline, a program making use of shared global state will be harder to understand, test, and modify.

This gives us a new insight into our object-oriented solution.  Although `send_message` retained its simplicity, we've actually created a miniature global state in our `Person` class.

## Objects Are Their Own Shared Global State 

Our `Person` class from above omitted a few details, namely where `first_name` and `last_name` came from.
In most OO languages, you'd assume they are instance variables, so let's add a bit more code to make this a Ruby class.

```ruby
class Person
  def initialize(first_name,last_name)
    @first_name = first_name
    @last_name  = last_name
  end

  def salutation
    if @first_name != nil
      "Hey #{@first_name}!"
    else
      "Hello, #{@last_name}"
    end
  end
end
```

This is now a working Ruby implementation of our `Person` class.
Look again at `salutation`.
What are its inputs?
It takes no parameters, but is freely able to reference instance variables.
So, its inputs are **every instance variable of the object**.
Currently, there are only two, but it's entirely possible, and likely, that we'll have objects with many more instance variables, and more functionality.

Let's add the ability to change a person's name, which is a reasonable operation to provide (I'm showing the entire class instead just of the changes):

```ruby
class Person
  def initialize(first_name,last_name)
    @first_name = first_name
    @last_name  = last_name
  end

  def salutation
    if @first_name != nil
      "Hey #{@first_name}!"
    else
      "Hello, #{@last_name}"
    end
  end

  def first_name=(new_first_name)
    @first_name = new_first_name
  end

  def last_name=(new_last_name)
    @last_name = new_last_name
  end
end
```

`first_name=` and `last_name=` take a parameter, but they don't return a (useful) value.
The point of those methods is to change the internal state of the object, meaning that their affects are *not* part of their return value.

This is the same problem we had with global variables!
Certainly, instance variables, due to their natural proximity to the code that can access them, create _less_ of a mess, but they still create the same type of complexity.


Now add inheritance and mixins to your toolbelt, and you have *even more* inputs and outputs to each routine.

This means that object-oriented designs encourage the creation of routines that have multiple, implicit inputs and have multiple, implicit outputs.
Object-oriented design, by its very nature, encourages writing complex routines.

To combat this complexity, we have had to develop a lot of "rules", "laws", and "principles", and their application is a source of constant debate.
Even for someone with years of experience, it can be difficult to know how to best-factor an object-oriented codebase.

Let's go back to the problem we were originally trying to solve.

## Remove All Implicit State

I've been using "global" a lot, but what we really mean is "implicit".
It's the ability of a routine to access symbols outside its scope that is the source of complexity here.
So let's go back to our original routines and see how else we could solve the problem of sharing code, but without introducing implicit state.

Here are the two routines again:

```ruby
def salutation(first_name,last_name)
  if first_name != nil
    "Hey #{first_name}!"
  else
    "Hello, #{last_name}"
  end
end

def create_message(first_name,last_name,message,from)
  salutation = if first_name != nil
                 "Hey #{first_name}!"
               else
                 "Hello, #{last_name}"
               end
  %{
#{salutation},

#{message}

           Sincerely,

           #{from}
}
end
```

Clearly, `create_message` needs to access the logic in `salutation`, so let's allow that.
I'll do this using valid Ruby syntax, where `&foo` as a parameter denotes a passed function and `&method(:foo)` turns a function into a passable function.

```ruby
def salutation(first_name,last_name)
  if first_name != nil
    "Hey #{first_name}!"
  else
    "Hello, #{last_name}"
  end
end

def create_message(first_name,last_name,message,from,&salutation)
  %{
#{salutation.(first_name,last_name},

#{message}

           Sincerely,

           #{from}
}
end

create_message("Dave","Copeland","Nice blog post!","Yourself",method(&salutation))
```

Now, we've re-used our logic, and all the routines in question still maintain a single source of input and a single destination for output.
`create_message` has gotten slightly more complex, due to the additional parameter, but it's also lost complexity due to being able to re-use `salutation`.

Can we build an entire system like this?
The functional programmers say we can (and they have certainly proved this).
Might be something to think about.
