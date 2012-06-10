---
layout: post
title: "Single Responsibility Principle and Rails"
date: 2012-06-10 14:24
comments: true
categories: 
---

Was reading [the slides][slides] from Aaron Patterson's Magma Rails talk and noticed some pretty innocuous Rails code that, upon further reflection is the beginning of disaster for a growing application.  As many other Rubyists are beginning to realize, spreading your application logic across only models and controllers leads to a mess.  Let's look at the code, understand why it's bad, and create a better version.

<!-- more -->

Here's the code to create a new user and email them a welcome note:

```ruby
class UsersController < ApplicationController
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        UserMailer.deliver_welcome_email(@user)
      end
    end
  end
end
```

Simple enough, so what's the problem?  Let's list out the things this class does:

* creates a new `User` instance from form parameters
* saves the new `User` to the database
* Sends the user an email if the save was successful
* Renders the view

This is too many things.  Every time we need to add something else that happens when a user is created, we will have to modify this methods.  Further, any other part of the system that creates new users will have to duplicate this code (it's not hard to imagine some sort of user import feature to create new users from some other system).  

## Fat Models, Skinny Controllers

The Rails Way&#0153; is to put all of this into the model.  Using the power of Rails, we could do this:

```ruby
class UsersController < ApplicationController
  def create
    @user = User.create(params[:user])
  end
end

class User < ActiveRecord::Base

  after_create :deliver_welcome_email

private

  def deliver_welcome_email
    if self.valid?
      UserMailer.deliver_welcome_email(@user)
    end
  end
end
```

Is this better?  Well, our controller is a lot simpler, and now just creates the user and renders the view.  That's pretty much all it should be doing.  We've deferred our email to an `after_create` hook. 

All we've done is move the problem somewhere else.  We've also made testing our application a huge pain, because everywhere we create a `User` instance for a test, we'll fire off the `UserMailer`, so we'd need to stub that our otherwise arrange for that code not to run, *except* when we test that code.  Ugh.  

So, in solving one problem, we've created another, giving us two problems, now:

* The `User` class is doing too much (even if we count all of ActiveRecord as just "one thing")
* We've mixed up the concerns of creating instances of `User` objects with creating new users of our application.  The distinction might be subtle, but it's important.

We can solve both of these problems using the [single responsibility principle][srp] and by using one of Ruby's most powerful and, sadly, underused features: creating a new class.

## Use Classes

What we want is a single location for "someone new is using our application" and we *don't* want that conflated with the creation of the class we use to store that user's data in the database.

Since our new class is going to create new application users, let's call it `ApplicationUserCreator`.  I know it's the [Kingdom of Nouns][nouns], but the more classes you have, the more specific their names have to be.  We could [use lambdas][lambdas], but let's keep things simple for now.

```ruby
class ApplicationUserCreator
  # Creates a new user for the application, based on form parameters.
  # Returns the User instance that was created, which might be invalid
  def create_new_user(params)
    User.create(params).tap { |new_user|
      if new_user.valid?
        UserMailer.deliver_welcome_email(new_user)
      end
    }
  end
end

class UsersController < ApplicationController
  def create
    @user = ApplicationUserCreator.new.create_new_user(params[:user])
  end
end
```

Much better.  Our `User` class remains as it was originally - a class that holds data for the `USERS` table and provides CRUD operations for it.  Our controller is just as skinny in our second example - it launches the new user creation logic and renders the view.  We have a new class which is custom built to hold the new application user logic.

These three classes are now very easy to test and very easy to understand; they all simply don't do that much.  Also, the test for our business logic (the test for `ApplicationUserCreator`) is *blazingly fast*.

## Resilience in the Face of Change

Where a design like this really shines is when we need to add new features to our app.

Suppose we want to do something different when creating administrative users.  These users are still stored in the `USERS` table, but we want to send them a different welcome email (perhaps admin users get a more security-conscious email).

We could start peppering `UserMailer` with `if user.admin?` but that's just wrong, too.  The `UserMailer` already does enough - it emails new application users a welcome email.  It does *not* need to also email administrative users a security-related email.  Let's assume we've created `AdminUserMailer` to handle that.  We can also assume we have an `AdminUsersController` that looks
like so:

```ruby
class AdminUsersController < ApplicationController
  def create
    @user = ApplicationUserCreator.new.create_new_user(params[:user])
  end
end
```

Identical to `UsersController`, for now.  Our `ApplicationUserCreator` now needs to check if the new user is an admin.  The quick and dirty path, which will get us into trouble, is to check inside that class, like so:

```ruby
class ApplicationUserCreator
  def create_new_user(params)
    User.create(params).tap { |new_user|
      if new_user.valid?
        if new_user.admin?
          AdminUserMailer.deliver_welcome_email(new_user)
        else
          UserMailer.deliver_welcome_email(new_user)
        end
      end
    }
  end
end
```

Well, this sucks.  We now need to double our tests to handle the case where the new user is an admin.  What happens when we add the next few feature?  More `if` statements and more complication.  Lets decouple this class from the mailer it uses by allowing the mailer to be injectible:

```ruby
class ApplicationUserCreator
  def initialize(welcome_mailer=nil)
    @welcome_mailer = welcome_mailer
  end

  def create_new_user(params)
    User.create(params).tap { |new_user|
      if new_user.valid?
        self.welcome_mailer.deliver_welcome_email(new_user)
      end
    }
  end

private

  def welcome_mailer
    @welcome_mailer ||= UserMailer
  end
end
```

With this design, we can change mailers all we want, and won't ever need to change `ApplicationUserCreator` or its tests.  We
should add a test that `UserMailer` is the default and that we can inject our own mailer, but at that point,
`ApplicationUserCreator` is a completed class.

`AdminUsersController` now looks like this:

```ruby
class AdminUsersController < ApplicationController
  def create
    @user = ApplicationUserCreator.new(AdminUserMailer).create_new_user(params[:user])
  end
end
```

Not too bad.  The classes involved in user creation are all dead simple and easy to test.

Suppose we had a third type of user creation scenario where we *don't* want welcome emails to be sent at all?  Not a problem:

```ruby
class NoOpMailer
  def deliver_welcome_email(*args)
  end
end

ApplicationUserCreator.new(NoOpMailer).create_new_user(params[:user])
```

I realize that Aaron's code is just an example for a slide at a conference, but I can tell you from experience, that any time an authoritative source shows code to others, they take that as the "right way" to do things.  It took the Java community *years* to stop writing code like this:

```java
try {
  someCode();
}
catch (Exception ex)
  ex.printStackTrace();
}
```

This code snippet is in *every book* on Java I've ever read, and I get why authors write it, but it's Just Wrong. So is putting excessive business logic in your controllers or models.

## What you can do

It's very simple.  When you are adding code to your Rails app, ask yourself two questions:

* Is this code about getting data in the right configuration for the view?  If not, it does not belong in a controller.
* Is this code about manipulating data in the database?  If not, it does not belong in the model.

Very little of the code you write goes in a controller or model, based on the above criteria.  The code goes in some other class, possibly one you will have to create.  It doesn't go in a module that you include into your controller or model.  It doesn't go into a module that you `extend` your model with at runtime, it goes into a class.  That is the unit of code organization in an object-oriented language, so don't be afraid to use it.  

[slides]: https://speakerdeck.com/u/tenderlove/p/rails-four
[srp]: http://en.wikipedia.org/wiki/Single_responsibility_principle
[nouns]: http://steve-yegge.blogspot.com/2006/03/execution-in-kingdom-of-nouns.html
[lambdas]: http://www.naildrivin5.com/blog/2012/01/30/avoid-kingdom-of-nouns-with-procs.html
