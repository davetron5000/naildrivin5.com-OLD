---
layout: post
title: "Is Your DSL Really a Type System?"
date: 2013-02-28 08:21
comments: true
categories: 
---

The UserVoice developer blog posted [an interesting article][uservoiceblog] yesterday talking about
how they solve "The Rails Problem" of complex Rails apps having obese models that stymie code re-use.  The naive approach is just [to make classes][make_classes].

UserVoice's approach is different: they made a DSL for describing service calls.  The thing is, it's sort
of a type system - and a verbose one at that.

<!-- more -->

UserVoice's approach is called ["mutations"][mutations] and it's more than just
method calls.  You can specify quite a bit about our service calls, all to make the underlying logic very simple.  For example,
they have a "user signup" service and, in the most naive, but safe, way, it would look like this:

```ruby
class UserSignupService

  def self.signup(name,email,birthdate,newsletter_subscribe=false)
    raise "name is required"    if name.nil?
    raise "email is required"   if email.nil?
    raise "email must be valid" unless email =~ EMAIL_REGEX

    user = User.create!(name: name, email: email, birthdate:birthdate)
    NewsletterSubscriptions.create(email: email, user_id: user.id) if newsletter_subscribe
    UserMailer.async(:deliver_welcome, user.id)
    user
  end
end

user = UserSignupService.signup(name,email,birthdate)
```

This is a very paranoid, but rock solid implementation.  If you screw up calling it, you'll know why.  In Mutations, this code
would look like so:

```ruby
class UserSignup < Mutations::Command

  # These inputs are required
  required do
    string :email, matches: EMAIL_REGEX
    string :name
  end

  # These inputs are optional
  optional do
    boolean :newsletter_subscribe
    date :birthdate
  end

  # The execute method is called only if the inputs validate. It does your business action.
  def execute
    user = User.create!(inputs)
    NewsletterSubscriptions.create(email: email, user_id: user.id) if newsletter_subscribe
    UserMailer.async(:deliver_welcome, user.id)
    user
  end
end
# ...
outcome = UserSignup.run(params)
if outcome.success?
  #
else
  #
end
```

This is fairly interesting, as the "business logic" (the code in `execute`) is clean - it's just the bare logic.  The sanity
checking and other paranoia is handled by the framework.  Likely that tests of this are simpler as well - you don't need to
test the validations.  While this is great, I can't help thinking that ["every implementation
of parameter validation in Ruby contains an ad-hoc, informally-specified, bug-ridden, slow implementation of a real type system"][greenspun].  

To demonstrate, here's what this class would look like in Scala:

```scala
object UserSignup {
  def signup(name                : String,
             email               : Email,
             birthDate           : Option[Date],
             newsletterSubscribe : Boolean=false) : User = {
    var user = User.create_!(name,email,birthDate,newsletterSubscribe)
    if (newsletterSubscribe)
      NewsletterSubscriptions.create(email, user.id) 
    UserMailer.async('deliver_welcome, user.id)
    user
  }
}
var user:User = UserSignup.signup(name,email,Some(birthDate))
```

That's it.  No special DSL, no custom framework, nothing. Just the programming language.  Why?

First, we assume that `null` (Scala's analog of `nil`) is always a bug.  Good Scala programs are designed this way, and it's
not that bad to [program without null][nilpost], so a declaration like `name:String` in Scala means "name is a required
parameter".

Second, optional parameters use the `Option` type to indicate their optionality.

Next, for validating our email, we use the type system.  Instead of using a `String` for storing email addresses (the
hallmark of every [stringly typed][stringly] application), we require an instance of `Email`.  We might imagine it looks like
this:

```scala
class Email(var emailAddress: String) {
  if (!EMAIL_REGEX.matches(emailAddress)) {
    throw new InvalidInputError("Email address isn't valid")
  }
}

var goodemail = new Email("dave@foo.com") // all good
var badEmail  = new Email("dave.foo.com") // exception thrown
```

So, our `UserSignup` code can be **absolutely sure** that it gets a valid email.  Validating that email happens elsewhere, as
it should.

Finally, our callsite uses the same method that our class defines.  Under mutations, you define a method called `execute`, but
you call a method called `run`.  Both just take a hash, making the callsite somewhat opaque as to what's being passed in and
requiring you to know how the framework works in order to piece together what's being called. In Scala, you just call the
method that you defined.

There's no magic here, no framework, nothing other than idiomatic Scala code.  I like the way it encourages us to create a rich
set of types as opposed to strings and hashtables everywhere.  Types allow us to encode our understanding of the system,
domain, and logic - that's what they are for.  Statically checking that those types are used properly is a sanity check that
we've correctly encoded our understanding.

Also note how not-that-verbose the Scala code is, compared to the Ruby code.  The Java equivalent could not make that claim.

Anyway, I think Mutations looks like a cool library, and I plan on checking it out for writing Rails apps.  I did think it was worth pointing out that the problem of separating argument validation from method logic is largely a solved problem - by statically typed languages.

[uservoiceblog]: https://developer.uservoice.com/blog/2013/02/27/introducing-mutations-putting-soa-on-rails-for-security-and-maintainability/
[mutations]: https://github.com/cypriss/mutations
[nilpost]: http://www.naildrivin5.com/blog/2012/07/25/a-world-without-nil.html
[stringly]: http://www.globalnerdy.com/2010/05/09/new-programming-jargon/
[make_classes]: http://www.naildrivin5.com/blog/2013/01/02/dci-vs-just-making-classes.html
[greenspun]: http://c2.com/cgi/wiki?GreenspunsTenthRuleOfProgramming
