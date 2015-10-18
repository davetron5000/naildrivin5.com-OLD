---
layout: post
title: "A defense of ivars in Rails controllers"
date: 2014-02-09 13:43
comments: true
categories: 
---

Had a discussion with another developer at a meetup about testing Rails controllers.  I test controllers *a lot*.  In fact, I start most new features with a controller test.  I also use ivars as the means of passing data from controller to view.  Ex-colleague Adam Keys recently wrote a [good piece about not using ivars][adampost]:

> If you stick with ivars long enough, you’re going to end up with two kinds of misadventures.
> Most commonly, you’ll wonder why @user is nil for some view or edge case…
> This leads to the second misadventure: where did this @user thing come from2? 

He then goes onto propose creating methods, since it makes testing and experimentation easier.

Personally, I would find this far more confusing.  Ruby's tagline could be "where did *that* come from?".  You can't write Ruby
without `grep`ping.  A lot.  And the string "@user" is going to be a lot easier to grep for than "current_user".
Finding "@user =" moreso.

But this is all beside the point.  Fighting controllers and avoiding ivars unnecessarily adds complexity to Rails to solve a problem that is created not by Rails but by bad programming practices.  Hiding those practices behind methods, helpers, and objects is just that - hiding.  If want to avoid sloppy controllers and views, don't fight Rails, instead do this:

* Adjust your mindset about what Controllers are.
* Adhere to three simple practices when writing controllers and views.

## What Rails Controllers Really Are

Stop thinking of controllers as regular objects/classes in the traditional Ruby sense.  The way they are written, tested, and
used gives no indication that they are conventional.  Instead, think of controllers as
namespaces for functions, each having a single input—`params`—whose purpose is to render a view given some data:

```ruby
def show(params)
  user = User.find(params[:id])
  render 'show', values: { user: user }
end
```

```erb
<h1><%= user.name %></h1>
```

As Rails is a DSL for making web applications, it uses the "specialness" of a controller to abstract away boilerplate so that all
we need to write is what's specific to our application.

First, there's no need to have `params` passed in explicitly:

```ruby
def show
  user = User.find(params[:id])
  render 'show', values: { user: user }
end
```

Next, we can automatically handle rendering:

```ruby
def show
  user = User.find(params[:id])
  values = { user: user }
end
```

Finally, we can condense the passing of values to mere assignment:

```ruby
def show
  @user = User.find(params[:id])
end
```

```erb
<h1><%= @user.name %></h1>
```

This description of what controllers really are is borne out in a canonical controller test:

```ruby
# Setup our test data
user = User.create!(name: 'Dave')

# call our function, giving it a value for `params`
get :show, id: user.id

# assert something about the assigned values
assert_equal user, assigns(:user)
```

If you are comfortable using `let` to assign values in RSpec, you should be totally OK with this.

Because a controller isn't a conventional object or class, but is instead a namespace for functions, it has no need of ivars.
Knowing this, Rails co-opts the ivar mechanism to make our lives easier and our code easier to read and write.
That you can declare an ivar anywhere in a controller and that doing so causes
confusion is *your problelm*, not Rails.  Avoiding ivars in favor of a custom mechanism seems more difficult in the long run than
just making a commitment to just three simple practices.

## Three Practices to Keep Your Controllers and Views Clean

When you take care with your views and controllers, the Rails Way results in code that is easy to read and modify.

### Assign ivars only in controller actions or, if you must, filters.###

Since your controller methods should be short, as should your filters, you can easily see all ivars assigned by a controller in one screenful of text.  Yes, you can assign ivars anywhere you want.  Don't do that.  You wouldn't do that in any other class in your system, so why does the ability to do it in controllers necessitate a deviation from Rails idioms?

### Assign as few ivars as possible. ###

Ideally, you have a single type describing the contract between controller action and
view and that value is always expected to have a value. If that "type" isn't a database-backed ActiveRecord model, you know what: spend 60 seconds [making a class][classpost]. If it takes you longer to create a model describing what your view expects, sharpen your tools.

But, there's a reason I didn't say "Assign one ivar".  Sometimes you need orthogonal data, such as reference data for select
boxes, and assigning it in the controller as a second ivar can end up being much simpler that either putting it into your
model object or as a helper.

### Do not use ivars in partials. ###

This is usually the source of a lot of confusion and problems in Rails views.  It's not the fault of Rails, but it's another bad
programming practice.  Using ivars in partials is akin to this Ruby code:

```ruby
class Greeter
  def initialize(person)
    @person = person
  end

  def greet
    @first_name = @person.first_name
    "Hello #{normalize_name}"
  end

  def normalize_name
    @first_name.strip.downcase.capitalize
  end
end
```

Treat calls to `render partial:` as a method call and pass in arguments that that partial needs to work.  Design that partial to
require (and document) what should be passed in.  Inside a view, think of ivars as global data.  We don't use global data to pass
arguments to methods.

It may seem braindead to write `render partial:'form', locals: { user: @user }`, but you will thank yourself later
for spending 5 seconds being explicit.  The partial can now be moved around and re-used easily, because its contract is explicit.


## Don't Fear ivars - Fear Bad Coding Practices ##

These rules are incredibly simple to follow, and make your code easy to write, read, and maintain.  Your controller tests are
easy to write, and your partials can be easily extracted if needed.

You see time and time again that Rails conventions are designed around making readable and maintainable code in the context of
good programming practices.   Rails was never intended to make it hard to write bad code, but to make us productive.  If we are
comfortable making a mess and ignoring years of lessons learned about programming, Rails isn't going to help us.


[adampost]: http://therealadam.com/2014/02/09/a-tale-of-two-rails-views/
[classpost]: http://technology.stitchfix.com/blog/2013/12/20/presenters-delegation-vs-structs/
