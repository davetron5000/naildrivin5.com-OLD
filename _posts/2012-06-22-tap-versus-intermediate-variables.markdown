---
layout: post
title: "Tap versus intermediate variables"
date: 2012-06-22 12:55
comments: true
categories: 
---

In my [Ruby style guide][style-guide], I mention the preference for using Ruby's `tap`:

> When you must mutate an object before returning it, avoid creating intermediate objects and use tap:

I thought it might be interesting to expand on this.

<!-- more -->

## What is `tap`?

First off, `tap` is a method on `Object` that takes a block, which is passed itself, and evaluates to itself.  Whoa.

```ruby
class Object
  # Imagined implementation
  def tap(&block)
    block.call(self)
    self
  end
end
```

An interesting use of `tap` is when debugging a [Law of Demeter][demeter] violation:

```ruby
# before
@person.parents.first.nag(:are_we_there_yet?)

# after
@person.parents.tap { |parents| puts parents.inspect }.first.nag(:are_we_there_yet?)
```

No matter what happens inside of the block you give to `tap`, the call always evaluates to the object itself.  We don't change the string of calls, but can inject code into it.

This is not the power of `tap` in my opinion.  I use `tap` when:

* I'm writing a method that creates and returns an object
* I must modify or call methods on that object before returning it

## Intermediate Variable Elimination Front

From [my last blog post][srp-rails], I had this method:

```ruby
def create_new_user(params)
  User.create(params).tap { |new_user|
    if new_user.valid?
      UserMailer.deliver_welcome_email(new_user)
    end
  }
end
```

Between creating the user and returning it, I needed to do some other stuff, so I create a scope in which to do it with `tap`.  

The classic approach is to use an intermediate variable for the new user and looks like so:

```ruby
def create_new_user(params)
  new_user = User.create(params)
  if new_user.valid?
    UserMailer.deliver_welcome_email(new_user)
  end
  new_user
end
```

Same lines of code, so why is the `tap` version better?

From my style guide<a name="back-1"></a><sup><a href="#1">1</a></sup>:

> Intermediate objects increase the mental requirements for understanding a routine. `tap` also creates a nice scope in which the object is being mutated; you will not forget to return the object when you change the code later

Let's look at our intermediate routine again, this time, marking a few places in the code

```ruby
def create_new_user(params)
  new_user = User.create(params)
  if new_user.valid?
    UserMailer.deliver_welcome_email(new_user)
  end
  # 1
  new_user
  # 2
end
```

1. Here is where any new code should be added to this method.
2. Here is where you might add new code that will cause this method to break

A developer's instinct is to add new code "at the bottom".  In the "intermediate variables" version, the last line is special, so
you have to add code on the _second to last line_.

But, isn't that the same in the `tap` version?  No, because `tap` creates a scope, visually and literally.

```ruby
def create_new_user(params)
  User.create(params).tap { |new_user|
    if new_user.valid?
      UserMailer.deliver_welcome_email(new_user)
    end
    # 1
  }
end
```

The location of #1 is logically "the bottom", because it's the end of the scope in question, and thus where you are more
likely to put new code.  It *also* alleviates you from having to worry about making sure that `new_user` is the last thing
evaluated; `tap` handles that.  No matter what new code you add, the new user is always returned.

I find this simple little thing makes certain routines easier to understand and modify.

## Appendix: What if I don't write Ruby code?

In Scala, this can be achieved using implicits:

```scala
object Tapper {
  implicit def anyToTapper[A](obj: A) = new Tapper(obj)
}

class Tapper[A](obj: A) {
  def tap(code: A => Unit): A = {
    code(obj)
    obj
  }
}

import Tapper._

new User(params).tap { newUser =>
  if (newUser.isValid) {
    UserMailer.deliverWelcomeEmail(newUser)
  }
}
```

In JavaScript, you can just put it on `Object`:

```javascript
Object.prototype.tap = function(block) { block(this); return this; };

function createNewUser(params) {
  return new User(params).tap( function(newUser) {
    if (newUser.isValid()) {
      new UserMailer().deliverWelcomeEmail(newUser);
    }
  });
}
```

In Java, you're screwed, but just for fun, let's try:

```java
public interface TapFunction<T> {
  void apply(T object);
}

public class Tapper {
  public static <T> T tap(T object, TapFunction<T> function) {
    function.apply(object);
    return object;
  }
}

import static Tapper.tap;

public void createNewUser(Map<String,?> params) {
  tap(new User(params),new TapFunction<User>() {
    public void apply(User newUser) {
      if (newUser.isValid()) {
        UserMailer.deliverWelcomeEmail(newUser);
      }
    }
  });
}
```

Not exactly a huge win in Java :)  Now, who'll write this in C?

----

<footer class='footnotes'>
<ol>
<li>
<a name='1'></a>
<sup>1</sup>It's a great exercise to create a style guide and then explain <em>why</em> you follow a particular rule.  You might be surprised at the number of “I just like how it looks” reasons.<a href='#back-1'>↩</a>
</li>
</ol></footer>

[style-guide]: http://davetron5000.github.com/ruby-style
[demeter]: http://en.wikipedia.org/wiki/Law_of_Demeter
[srp-rails]: http://www.naildrivin5.com/blog/2012/06/10/single-responsibility-principle-and-rails.html
