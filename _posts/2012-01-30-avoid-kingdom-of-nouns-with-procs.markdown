---
layout: post
title: "Avoid the Kingdom of Nouns with Procs"
date: 2012-01-30 9:00
comments: true
categories: 
---

Hopefully you've read Steve Yegge's excellent [kingdom of nouns][nouns] essay, in which he bemoans a pattern that exists in a lot of Java-base systems.  The tell-tale sign is a class named `ThingDoer` with a single method `doThing()`.  Systems like this don't arise simply because Java is the way it is, but when you follow [SOLID][solid] principles (particularly the [single responsibility][SRP] and [dependency inversion][DI] principles), your code ends up with lots of small classes that do one thing only.

In Java, you are basically stuck with this, but in Ruby (or any OO language that supports closures/blocks/functions), we can fight this by using Procs instead of classes.

<!-- more -->

## SOLIDifying some code

First, let's take some code that needs refactoring and see what it looks like with classes.  We'll look at a very simple base class for handling events in a system based on [Resque][resque].  Our base class allows us to do two things that a generic Resque event can't: retry events later, and queue arbitrary events.  Let's have a look at the code<a name="back-1"></a><sup><a href="#1">1</a></sup>:

```ruby Base class for handle events
class Event::Base

  def self.perform(params)
    self.new.perform(params)
  end

  def perform(params)
    raise "subclass must implement"
  end

protected

  def self.queue_event(klass,options)
    Resque.enque(klass,options.merge({ :queued_at => Time.now }))
  end
  
  def self.requeue_later(params)
    new_params = { :attempt_number => 0 }.merge(params)
    new_params[:attempt_number] += 1

    raise "Requeued too many times" if new_params[:attempt_number] > 5

    sleep(new_params[:attempt_number])
    queue_event(class,new_params)
  end
end
```

We might use this like so:

```ruby Simple event class
class RenameEvent < Event::base
  def perform(params)
    if person = Person.find_by_id(params[:person_id]).nil?
      requeue_later(params)
    else
      person.name = params[:name]
      person.save!
    end
  end
end
```

Our base class is doing too much.  It's OK for it to provide the queuing and re-queuing functionality, but it shouldn't be implemented there.  Further, there's aspects of *how* the functionality is implemented that we might want to be able to change in our subclasses.  This is the perfect application for dependency inversion.

In our naive approach, we'll make one class for each function we have, namely:

* A class to queue events onto Resque, adding in the `queued_at` timestamp
* A class to orchestrate requeuing events, failing after a certain number of attempts
* A class to sleep and perform the actual requeuing
* Our base class to provide access to these features

Let's have a look:

```ruby Queuer class
class Queuer
  def queue(klass,options)
    Resque.enque(klass,options.merge({ :queued_at => Time.now }))
  end
end
```

```ruby Requeuer
class Requeuer
  def initialize(requeue_strategy,max_attempts=5)
    @requeue_strategy = requeue_strategy
    @max_attempts = max_attempts
  end

  def requeue(klass,options)
    new_params = { :attempt_number => 0 }.merge(params)
    new_params[:attempt_number] += 1

    raise "Requeued too many times" if new_params[:attempt_number] > @max_attempts

    @requeue_strategy.requeue(klass,new_params[:attempt_number],options)
  end
end
```

```ruby RequeueStrategy
class RequeueStrategy
  def initialize(queuer)
    @queuer = queuer
  end

  def requeue(klass,attempt_number,options)
    sleep(attempt_number)
    @queuer.queue(klass,options)
  end
end
```

Whew!  Now, to use all this, our base class becomes:

```ruby A now SOLID base class
class Event::Base

  def initialize(requeuer=nil)
    @requeuer = requeuer || Requeuer.new(RequeueStrategy.new(Queuer.new))
  end

  def self.perform(params)
    self.new.perform(params)
  end

  def perform(params)
    raise "subclass must implement"
  end

protected

  def requeue_later(params)
    @requeuer.requeue(self.class,params)
  end
end
```

Our base class is a *lot* cleaner, and we can now test it more easily without [mocks making things difficult][cleantest].

But, we're firmly in the Kingdom of Nouns, e.g. `queuer.queue()`.  We'd like to keep our code nicely designed, but get rid of the superfluous naming and structure around the tiny bits of code we have.  Let's use Procs.

## Procs instead of classes

The easiest class to convert to a `Proc` is going to be `Queuer`, since it has no real dependencies and is just a wrapper around a very simple line of code:

```ruby Base class using a Proc instead of Queuer
class Event::Base

  QueueEvent = lambda { |klass,params|
    Resque.enque(klass,options.merge({ :queued_at => Time.now }))
  }

  def initialize(requeuer=nil)
    @requeuer = requeuer || Requeuer.new(RequeueStrategy.new(QueueEvent))
  end

  def self.perform(params)
    self.new.perform(params)
  end

  def perform(params)
    raise "subclass must implement"
  end

protected

  def requeue_later(params)
    @requeuer.requeue(self.class,params)
  end
end
```

`RequeueStrategy` now becomes:

```ruby RequeueStrategy using a Proc instead of a class
class RequeueStrategy
  def initialize(queue_event)
    @queue_event = queue_event
  end

  def requeue(klass,attempt_number,options)
    sleep(attempt_number)
    @queue_event.call(klass,options)
  end
end
```

Notice that we're using the name `queue_event` instead of `queuer`.  A Proc isn't, conceptually, a thing, but an action that we're passing around, so we name it as such.  

Of course, `RequeueStrategy` itself isn't much code; can we convert that?  The tricky part is that `RequeueStrategy` requires the ability to queue events and thus needs a `Queuer`.  We pass this in the constructor, which a `Proc` doesn't really have (at least conceptually).  Instead, we'll pass the queueing code in as a parameter to our newly re-made `SleepThenRequeue` `Proc`, which is now part of our base class.

```ruby Base class with RequeueStrategy now a Proc
class Event::Base

  SleepThenRequeue = lambda { |queue_event,klass,attempt_num,options|
    sleep(attempt_number)
    queue_event.call(klass,options)
  }

  QueueEvent = lambda { |klass,params|
    Resque.enque(klass,options.merge({ :queued_at => Time.now }))
  }

  def initialize(requeuer=nil)
    @requeuer = requeuer || Requeuer.new(QueueEvent,SleepThenRequeue)
  end

  def self.perform(params)
    self.new.perform(params)
  end

  def perform(params)
    raise "subclass must implement"
  end

protected

  def requeue_later(params)
    @requeuer.requeue(self.class,params)
  end
end
```

We now need to update `Requeuer` to hold onto the `QueueEvent` `Proc` so that it can pass it to the `SleepThenRequeue` `Proc`:

```ruby Requeuer updated
class Requeuer
  def initialize(queue_event,requeue_event,max_attempts=5)
    @queue_event = queue_event
    @requeue_event = requeue_event
    @max_attempts = max_attempts
  end

  def requeue(klass,options)
    new_params = { :attempt_number => 0 }.merge(params)
    new_params[:attempt_number] += 1

    raise "Requeued too many times" if new_params[:attempt_number] > @max_attempts

    @requeue_event.call(@queue_event,klass,new_params[:attempt_number],options)
  end
end
```

Now, our system has all the flexbility, testability, and comprehensibility that we get from applying SOLID principles, but we don't have any of the baggage and boilerplate of making actual classes that are mere wrappers for simple functionality.  

## Taking Advantage 

Let's see how this works be implementing a second requeuing strategy.  Suppose a subclass wants to have retried events go onto a different queue, instead of sleeping and re-queuing.  To enable this, we first make our base class a bit more configurable by introducing the method `self.requeue_strategy`, which returns a `Proc`.  The base class' implementation will simply return `SleepThenRequeue`.

```ruby Base class with multiple requeueing strategies
class Event::Base

  QueueEvent = lambda { |klass,params|
    Resque.enque(klass,options.merge({ :queued_at => Time.now }))
  }

  SleepThenRequeue = lambda { |queue_event,klass,attempt_num,options|
    sleep(attempt_number)
    queue_event.call(klass,options)
  }

  def initialize(requeuer=nil)
    @requeuer = requeuer || Requeuer.new(QueueEvent,self.class.requeue_strategy)
  end

  def self.perform(params)
    self.new.perform(params)
  end

  def perform(params)
    raise "subclass must implement"
  end

protected

  def self.requeue_strategy
    SleepThenRequeue
  end

  def requeue_later(params)
    @requeuer.requeue(self.class,params)
  end
end
```

Now, our subclass can return something else, but it *won't* have to make an entire class to do so:

```ruby Event that uses a different requeue strategy
class SomeEvent < Event::Base

protected

  def self.requeue_strategy
    lambda { |queue_event,klass,attempt_num,options|
      queue_event.call(klass,options.merge(:queue => 'scheduled', 
                                           :for => Time.now + attempt_num.minutes)
    }
  end
```

Of course, we're not constrained by Procs; after all a `Proc` is just a structural type for an object that reponds to `call`.  If
we needed some really complex requeuing, we could make a class:

```ruby Using a class if we need to
class ComplexRequeueingStrategy
  def call(queue_event,klass,attempt_num,options)
    # Do whatever
  end
end
```

This results in a much more flexible system that keeps ceremony, boilerplate, and noise to a minimum; the majority of our code is
the "business logic" or "necessary complexity".

## Conclusions

Of course, we can take this too far.  Suppose we made `Requeuer` into a `Proc`.  It would start getting cumbersome, since it has so many dependent objects to manage; a class is actually helpful here<a name="back-2"></a><sup><a href="#2">2</a></sup>.  

Just because Ruby is object-oriented doesn't mean that every bit of functionality has to live inside a method of a class.  A `Proc` is tailor-made to hold functionality and pass it around, so don't be afraid to use it if the situation warrants.

[dip]: http://en.wikipedia.org/wiki/Dependency_inversion_principle
[solid]: http://en.wikipedia.org/wiki/SOLID_(object-oriented_design)
[resque]: https://github.com/defunkt/resque
[DI]: http://en.wikipedia.org/wiki/Dependency_injection
[SRP]: http://en.wikipedia.org/wiki/Single_responsibility_principle
[cleantest]: http://www.naildrivin5.com/blog/2012/01/16/more-clean-tests-handling-mocks.html
[nouns]: http://steve-yegge.blogspot.com/2006/03/execution-in-kingdom-of-nouns.html

---

<footer class='footnotes'>
<ol>
<li>
<a name='1'></a>
<sup>1</sup>We have this awkward <code>self.process</code> because Resque calls a class method; we just create an instance and deal with that, as it's easier to test and implement as a normal class<a href='#back-1'>↩</a>
</li>
<li>
<a name='2'></a>
<sup>1</sup>In a more functional-oriented approach, this can be solved via <a href="http://en.wikipedia.org/wiki/Currying">currying</a>.  Accomplishing this cleanly in Ruby is an exercise for the reader.<a href='#back-1'>↩</a>
</li>
</ol></footer>
