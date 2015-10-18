---
layout: post
title: "&#10106;&#10144; What is 'better' code?"
date: 2012-06-27 14:48
comments: true
categories: 
---

We all want better code.  Rails creator David Heinemeier Hansson said that the only way to evaluate a code change is if the new code is "better" than the old.  Of course, he didn't define what he meant by "better".  At Scottish Ruby Conf, Dave Thomas said that good code is code that is easy to change.  This is a bit more specific, but not really enough to give any real direction.

Let's see if we can derive a real understanding of code quality.

<!-- more -->

What do we do with code?  In decreasing order of frequency:

* _We execute it._  Hopefully, our code spends most of its time executing.
* _We read it._  To gain an understanding, to review it, to change it, we must read it.
* _We change it._  To add new features, or fix bugs, we must change it.
* _We write it._  On occasion, we'll write new code.

The most frequent thing we do with code?  Execute it.  Code that runs, based on our current understanding (i.e. passes its tests), is the absolute minimum of acceptability.  It's at this point that average developers typically stop.  If it works, ship it! 

We aren't average developers.  We want to do better.

With almost equally great frequency, our code gets read by humans.  We might read code to prepare for a change.  We might read code to understand how a business rule works.  We might read code as an example of how to do something, or to gain an understanding of some abstract concept.  We read code a lot.

Is there anything objective we can say about code readability?

## Readability

Readability answers the question "How quickly can someone understand this code?"  We must first define "someone".  A good rule of thumb is "any developer that could be hired to work here".  You may need to get more specific, but generally constraining the context to your current team will work well.

Once we've got context for understanding code, the most obvious thing we could measure would be its size.

### Size

Size can mean two things: length (the number of lines of code) and _density_ (the amount of information per line of code).  The more code you must evaluate, by either measure, the longer it will take to come to an understanding.  The distinction between length and density is interesting.  Short, but dense code, can be just as difficult to grasp as long sparse code.

```ruby Dense, but short code
def create_new_person(first_name, last_name, birthdate)
  raise "first name and last name required" if first_name.nil? || last_name.nil?
  Person.create(:first_name => first_name, :last_name => last_name).tap do { |person|
    person.age = Time.now.year - birthdate.year if birthdate.present?
  }
end
```

Here's the same routine, rewritten to be as sparse as possible:

```ruby Longer, sparser code
def create_new_person(first_name, last_name, birthdate)
  if first_name.nil? || last_name.nil?
    raise "first name and last name required" 
  end
  person = Person.create(:first_name => first_name, :last_name => last_name)
  if birthdate.present?
    person.age = Time.now.year - birthdate.year
  end
  person
end
```

Which one do you find easier to understand?  I would argue that the answer is not so clear-cut.  What *is* interesting is that modern languages, like Ruby or Scala, tend to encourage denser, shorter programs.  Some densly-packed statements are idiomatic, and are easily understood, while others become impeneatrable code golf.  Know the difference and you can get a good sense of the size of a piece of code.

### Variables

Any field, parameter, global, or local variable is a "variable" for the purposes of code readability.  Variables are placeholders for the calculations our code performs, and the more of them there are, the more abstract pieces of data you must hold in your head in
order to understand a piece of code.

Beyond the raw count of variables, the scope of each variable can also affect our understanding of code.  A routine that uses nothing but local variables will be easier to undestand than one using all globals.  Since globals can change outside of the routine you are reading, you need to have a higher level grasp of the system, so you can understand what possible values those variables might have.  The smaller the scope of a variable, the easier it is to understand what values it might have, and the easier it is to understand the code it's used in.

Of course, variable names are important, too.  Descriptive (and accurate) names help our understanding, while symbol or inaccurate names can harm it.

Here's a pattern I've seen in complex controllers, where ivars are used to pass variables between methods (you'll need to imagine many other controller methods here):

```ruby A Controller with too many variables that have a large scope
class PeopleController < ApplicationController
  def destroy
    id = params[:id]
    @person = Person.find(id)
    if can_destroy?
      @person.destroy
      redirect_to persons_path
    else
      flash[:error] = @error
      redirect_to persons_path
    end
  end

private

  def can_destroy?
    if @person.admin? 
      @error = 'You cannot delete an admin'
      false
    elsif @person.orders.unfulfilled.any?
      @error = 'Person has unfullied orders'
      false
    else
      true
    end
  end
end
```

Notice how both outcomes of `destroy` are redirects, yet we are setting `@person`.  In a Rails controller, you create ivars to communicate data to the view, but for a redirect, these variables don't apply.  `@person` is effectively a parameter passed to `can_destroy?` but without declaring it as a parameter.  Further, `@error` is being initialized in `can_destroy?` and acts as a return value.  Finally, does `id` need to be a variable at all?  It's only used in one place.  Here's a version that keeps variables to a minimum scope:

```ruby A Controller with fewer variables of smaller scope
class PeopleController < ApplicationController
  def destroy
    person = Person.find(params[:id])
    error = can_destroy?(person)
    if error.nil?
      person.destroy
      redirect_to persons_path
    else
      flash[:error] = error
      redirect_to persons_path
    end
  end

private

  def can_destroy?(person)
    if person.admin? 
      'You cannot delete an admin'
    elsif person.orders.unfulfilled.any?
      'Person has unfullied orders'
    else
      nil
    end
  end
end
```

Not only is the code a bit shorter, but each routine is simpler to understand, because the scope of the variables used are constrainted to only where they are needed.

### Number of classes/methods

This is where things get interesting.  If you need to follow the path of execution through many methods or classes to get an understanding of some code, it's going to be harder to do so.  Of course, with fewer classes, you'll tend toward larger methods which, of course, can also be hard to understand.

Consider the refactor from my [controversial blog post][srp_post].  In that post, I extracted a class from a Rails controller to handle the business process of creating a new user.  Although the two classes were both very short and easy to understand, the entire codebase went from one class that contained all the code, to two classes.  Which is easier to understand?  It depends.  But, by trying to quantify the differences in the code, we can approach an understanding.

### Paths through the code

Often referred to as "complexity" in computer science, the number of possble paths of execution through a piece of code can greatly affect its ability to be understood by a person.  Consider this slightly modified version of `can_destroy?` from our example above:

```ruby
def can_destroy?(person)
  errors = []
  if person.admin? 
    errors << 'You cannot delete an admin'
  end
  if person.orders.unfulfilled.any?
    errors << 'Person has unfullied orders'
  end
  return errors.join(',')
end
```

There are two `if` statements here, which gives us _four_ possible ways through this code.  This means that, to gain a real understanding of this code, we need to mentally play through all four scenarios in our heads.  Since the expression of each `if` statement is simple, this isn't so bad.  What if we needed to add a feature where employees are also not allowed to be destroyed in our controller?

```ruby
def can_destroy?(person)
  errors = []
  if person.admin? || person.is_employee?
    errors << 'You cannot delete an admin or employee'
  end
  if person.orders.unfulfilled.any?
    errors << 'Person has unfullied orders'
  end
  return errors.join(',')
end
```

We've added an additional case for our first `if` statement, and so we have more paths:

* `person.admin?` true, `#is_employee?` false, `orders.unfulfilled.any?` false
* `person.admin?` true, `#is_employee?` true, `orders.unfulfilled.any?` false
* `person.admin?` true, `#is_employee?` false, `orders.unfulfilled.any?` true
* `person.admin?` true, `#is_employee?` true, `orders.unfulfilled.any?` true
* `person.admin?` false, `#is_employee?` false, `orders.unfulfilled.any?` false
* `person.admin?` false, `#is_employee?` true, `orders.unfulfilled.any?` false
* `person.admin?` false, `#is_employee?` false, `orders.unfulfilled.any?` true
* `person.admin?` false, `#is_employee?` true, `orders.unfulfilled.any?` true

If we were to extract the first `if` statement's expression to a method, we'd reduce the complexity of this code:

```ruby
class Person
  def deletable?
    person.admin? || person.is_employee?
  end
end

def can_destroy?(person)
  errors = []
  if person.deletable?
    errors << 'You cannot delete an admin or employee'
  end
  if person.orders.unfulfilled.any?
    errors << 'Person has unfullied orders'
  end
  return errors.join(',')
end
```

We've simplified `can_destroy?`, but we've added a new method to `Person`.  Readability isn't so simple, is it?

Let's complicate things further by understanding our abilitiy to change code.

## Ability to Change 

When changing code, you often want to know where to make the change, but you also want to keep the scope of the change as small as possible.  Readability in general, and the measures we've outlined above in particular, affect this greatly.  If we have one giant routine, we know where to make the change, but if we have many single-purpose classes instead, the scope of our change is smaller.  Are there other aspects of our code that affect this?

In general, _coupling_ is an indicator of the scope of a particular change.  If two classes are tightly coupled, it means that a change one is likely to necessitate a change in another.  Further, a class that is coupled to many classes is going to result in a system that is harder to change.  This is the basis for the "Law of Demeter".  Code that "violates" this law is coupling itself to more classes than code that doesn't "violate" the "law" and is thus harder to change.

The dependencies between classes are a good indicator of coupling.

### Fan out

A class or method that uses a lot of classes or methods to do its work has higher coupling than one that uses fewer.  This is often referred to as _fan out_, and it means that the class in question is more likely to have to change when the classes or methods it uses change.  

### Fan in

Conversely, a class or method that a lot of other classes or methods use also has high coupling.  Obvious examples in a Rails app would be a central model object (like a person or an order), or helper methods in `ApplicationHelper`.  These objects and methods get used everywhere, and thus are very hard to change, because a change can have a ripple effect through the system.

Notice again how these conflict with other attributes of readability.  A routine that is quite large, but has no external dependencies has almost no coupling, but could be hard to understand, since it is long, potentially having many variables and many paths through the code. Code spread across many single-purpose classes in a loosely coupled way will be easier to change, but potentially harder to understand.

## Better

So, what is "better" code?  I don't think we'll ever have a fool-proof way of figuring this out, but we *do* have objective measures we can use to better explain why we think one piece of code might be better than another.    Next time you're reviewing code or doing a refactor, instead of relying on a gut feel of "better", jot down where the code stands along measurements like these. How does the new code compare to the old?  The answer might surprise you.

[srp_post]: http://www.naildrivin5.com/blog/2012/06/10/single-responsibility-principle-and-rails.html
