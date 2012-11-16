---
layout: post
title: "Why you can't refactor test code"
date: 2012-11-16 11:18
comments: true
categories: 
---

Was having a discussion with [Mike Gehard][mike], [Jeff Simpson][jeff], and [Dan Hopkins][danh] about [Dan Mayer's][danm] [excellent post][danpost], and we go on the topic of refactoring test code.  My assertion is that you cannot, technically speaking, refactor test code, because you have no tests of the test code.  [_Refactoring_][refactoring] cannot be done without tests that assert that the changes you've made haven't introduced problems.

The discussion put forth a few such tests of tests code, such as running it on prod, having the tests continue to pass, or measuring coverage.  Unfortunately, none of these are sufficient to call changes in test code a _refactoring_.  I would call it a _rewrite_ or _redesign_, and I think that the distinction is important.

<!-- more -->

## Refactoring

A _refactoring_ is *very* safe (not 100% safe), because you have tests.  A _rewrite_ is unsafe, because you don't have that safety net.  You can rewrite test code, yet tests can continue to pass, and coverage can remain the same, in the face of a mistake.  I'm not saying you shouldn't rewrite your tests to make them cleaner, but you should be honest that what you are doing is different from a code refactoring - namely riskier.  Let's demonstrate.

## Example

Consider a very simple domain of a person, that has a greeting and can possibly buy booze.  We have a lovely special case that anyone with a name ending in "Kennedy" can buy booze, but everyone else has to be 21.  I know this is contrived (sorry DHH), but it's simple enough to grok and complex enough to demonstrate the issue.

Here's our code:

```ruby
class Person
  attr_reader :name, :gender, :birthdate

  def initialize(name,gender,birthdate)
    @name      = name
    @gender    = gender
    @birthdate = birthdate
  end

  def can_buy_booze?
    (Time.now - @birthdate >= 21.years) || name =~ /Kennedy$/
  end

  def greeting
    case gender
    when :male   then "Hello Mr. #{name}"
    when :female then "Hello Ms. #{name}"
    else              "Hello #{name}"
    end
  end
end
```

And our test:

```ruby
class PersonTest
  def test_accessors
    birthdate = 21.years.ago
    person = Person.new("foo",:male,birthdate)
  
    assert_equal "foo",person.name
    assert_equal :male,person.gender
    assert_equal birthdate,person.birthdate
  end

  def test_can_buy_booze
    person = Person.new("foo",:male,21.years.ago)
    assert person.can_buy_booze?
  end

  def test_kennedy_can_buy_booze
    person = Person.new("Joe Kennedy",:male,20.years.ago)
    assert person.can_buy_booze?
  end

  def test_cannot_buy_booze
    person = Person.new("foo",:male,20.years.ago)
    assert !person.can_buy_booze?
  end

  def test_male_greeting
    person = Person.new("foo",:male,21.years.ago)
    assert_equal "Hello Mr. foo",person.greeting
  end

  def test_female_greeting
    person = Person.new("foo",:female,21.years.ago)
    assert_equal "Hello Ms. foo",person.greeting
  end

  def test_other_greeting
    person = Person.new("foo",:other,21.years.ago)
    assert_equal "Hello foo",person.greeting
  end
end
```

The test clearly covers 100% of the `Person` class (even going so far as to test the accessors/constructor).

It also has a lot of repetition and irrelevant literals in it (see [my post][testpost] on why this is bad).  Making new tests will require some copy and paste (in fact, I did a lot of copy and paste to write these tests).  Let's "refactor" the test to clean some of this up.

## "Refactoring" our test

We'll create a method that makes `Person` instances (which is hand-rolled "factory" [which is really a prototype, but whatever FactoryGirl]), and uses "reasonable" values for anything that's not needed specifically for the test:

```ruby
def some_person(attributes = {})
  Person.new(attributes[:name]      || "foo",
             attributes[:gender]    || :male,
             attributes[:birthdate] || 21.years.ago)
end
```

We can then clean up each test method, so that the only literals in each test are those relevant for the test:

```ruby
class PersonTest
  def test_accessors
    birthdate = 21.years.ago
    person = Person.new("foo",:male,birthdate)
  
    assert_equal "foo",person.name
    assert_equal :male,person.gender
    assert_equal birthdate,person.birthdate
  end

  def test_can_buy_booze
    person = some_person
    assert person.can_buy_booze?
  end

  def test_kennedy_can_buy_booze
    person = some_person(:name=> "Joe Kennedy")
    assert person.can_buy_booze?
  end

  def test_cannot_buy_booze
    person = some_person(:birthdate => 20.years.ago)
    assert !person.can_buy_booze?
  end

  def test_male_greeting
    person = some_person
    assert_equal "Hello Mr. foo",person.greeting
  end

  def test_female_greeting
    person = some_person(:gender => :female)
    assert_equal "Hello Ms. foo",person.greeting
  end

  def test_other_greeting
    person = some_person(:gender => :other)
    assert_equal "Hello foo",person.greeting
  end

private

  def some_person(attributes = {})
    Person.new(attributes[:name]      || "foo",
               attributes[:gender]    || :male,
               attributes[:birthdate] || 21.years.ago)
  end
end
```

All the tests still pass, and our code coverage (as reported by any reasonable open-source Ruby code coverage tool, which is to say line coverage) is still 100%.

We missed something, however.  Can you spot it?  We actually **lost** test coverage (which is to say "what code got executed").

## In which we see our error

Now let's refactor the `Person` class, hoping that any mistakes we make will be demonstrated by our we-hope-it's-equivalent-refactored test.  We'll extract the "Kennedy" regexp into a constant.

```ruby
class Person
  CAN_DRINK_IF_YOUNGER = /kennedy$/

  # omitted unchanged code...

  def can_buy_booze?
    (Time.now - @birthdate >= 21.years) || name =~ CAN_DRINK_IF_YOUNGER
  end
end
```

You might notice that we screwed something up, but we rely on our tests, which all pass with flying colors. Coverage is still 100%, so we ship it.

But now our code is broken.  If we ran the *original* test, the test `test_kennedy_can_buy_booze` will fail, because the extracted regexp has a lower-case 'k', not an upper-case 'k'. What happened?

The reason our "refactored" test didn't catch it is that we messed up converting `test_kennedy_can_buy_booze`.  That test *should* have looked like this:

```ruby
def test_kennedy_can_buy_booze
  person = some_person(:name=> "Joe Kennedy", :birthdate => 20.years.ago)
  #                                            ^^^^^^^^^^^^^^^^^^^^^^^^^
  assert person.can_buy_booze?
end
```

We needed to make the `Person` under 21 to trigger the special case of the name ending in `Kennedy`.  Instead, we accidentally relied on our prototype method, which uses a default age of 21, which is the age at which you can buy booze, regardless of your last name.

So, our tests passed every step of the way, but we a) lost test coverage and b) were able to introduce a bug.

*This* is why I would not call the change we made to our tests a _refactoring_.  We simply have no way to know that the change we made didn't break something.  I would say that we _rewrote_ or _redesigned_ the test.  The difference is important.

I'm also not saying that we shouldn't change our tests to make them better, but doing so is a riskier process and is clearly *not* a refactoring.  It's important that our terms of art are used accurately, as they convey, specifically, what we are doing.

### On the meaning of "coverage"

Most code coverage tools report only on line coverage.  With an expressive language like Ruby, there's a lot going on on each line of code.  To truly understand what parts of the code are executed, we need [condition converage][coverage].  If we had that, we could've seen that our "refactored" test no longer covered the second condition of our expression inside `can_buy_booze?`.  **That** being said, there could still be cases where a mistake in our test "refactoring" allowed bugs to creep in that would not have been possible otherwise.

[testpost]: http://www.naildrivin5.com/blog/2012/02/16/even-more-clean-tests-magic-values.html
[coverage]: http://en.wikipedia.org/wiki/Code_coverage
[refactoring]: http://en.wikipedia.org/wiki/Code_refactoring
[mike]: http://www.twitter.com/mikegehard
[jeff]: http://www.twitter.com/fooblahblah
[danh]: http://www.twitter.com/boulderdanh
[danm]: http://www.twitter.com/danmayer
[danpost]: http://mayerdan.com/ruby/2012/11/11/bugs-per-line-of-code-ratio/
