---
layout: post
title: "Even More Clean Tests:Magic Values"
date: 2012-02-16 18:50
comments: true
categories: 
---

In the [last][cleantest1] two [posts][cleantest2] about "clean tests", we talked about the structure of a test, how to eliminate duplication, and how to make intent clear when using mocks.  We left off with a question of [magic values][magicvalues]: Why do we seem to use them in our tests, when we *know* they are wrong in production code?  Let's explore that and see how to eliminate their use in our tests without making the tests hard to understand.  

<!-- more -->

In non-test code, pretty much *any* literal that isn't 0, 1, -1, the empty string, `nil`/`null`, or some universal constant like 60 (number of seconds in a minute), is a _magic value_.  A naked literal just sitting out there with no context makes code hard to understand, and we usually whisk them away inside a constant or injected value.  Suppose we come across this code:

```ruby
if percentage < 0.75
  show_graph
else
  show_no_data
end
```

We want to know what `0.75` actually *means*.  If we'd used a constant, it would be clearer, like so:

```ruby
if percentage > THRESHOLD_FOR_DATA_DISPLAY
  show_graph
else
  show_no_data
end
```

Now we know that we're comparing our percentage against a threshold and not some arbitrary value.

Tests, on the other hand, require a lot of literals, because we tend to be setting up very specific conditions, and that's much easier with an _example_ of some input.  Here's a test for our `Saluation` class that we've seen before:

```ruby
def test_full_name
  # Given
  person = Person.new("David","Copeland",:male)
  salutation = Salutation.new(person)
  # When
  greeting = salutation.greeting
  # Then
  assert_equal "Hello, David!",greeting
end
```

We have four magic values:

* `"David"`
* `"Copeland"`
* `:male`
* `"Hello, David!"`

Do these all need to be in there?  Which ones are actually relevant, and which are true magic values that we should eliminate?

You'll recall that in the [first post][cleantest1] on clean tests, we made this test clearer via *method extraction*, like so:

```ruby
def test_full_name
  # Given
  person = person_with_full_name("David")
  salutation = Salutation.new(person)

  # When
  greeting = salutation.greeting

  # Then
  assert_equal "Hello, David!",greeting
end
```

Essentially, we've hidden the fact that the last name and gender don't matter inside the `person_with_full_name` method.  Some developers would object to this, preferring to have each test method stand on its own, without chasing down lots of helpers.  This is a fair point, so let's get rid of some irrelevant magic strings another way:

```ruby
def test_full_name
  # Given
  person = Person.new("David",any_string,any_gender)
  salutation = Salutation.new(person)

  # When
  greeting = salutation.greeting

  # Then
  assert_equal "Hello, David!",greeting
end

private 

def any_string
  Faker::Lorum.words(5).join('')
end

def any_gender
  rand(2) == 1 ? :female : :male
end
```

We've still got helper methods (`any_string` and `any_gender`), but they're tiny *and* they convey some information: the last name and the gender can be _anything_; they _don't matter_.  If you aren't familiar with [faker][faker], it's a handy gem for generating nonsense within certain parameters.  This is perfect for creating values that don't matter.


Does "David" matter?  It matters more than the last name and gender, since it will show up in our greeting, but the first name could just as easily be "Mark" or "Mary".  So, let's eliminate this magic value as well:

```ruby
def test_full_name
  # Given
  first_name = any_string
  person = Person.new(first_name,any_string,any_gender)
  salutation = Salutation.new(person)

  # When
  greeting = salutation.greeting

  # Then
  assert_equal "Hello, #{first_name}!",greeting
end

private

def any_string
  Faker::Lorum.words(5).join('')
end

def any_gender
  rand(2) == 1 ? :female : :male
end
```

Now, we're talking!  Read the test, in English: "first name is any string, a person has that as their first name, with any string as their last and any gender as their gender.  Make a salutation for that person, and get the greetting.  The greeting should equal 'Hello' plus the first name".  We've come *very* close to encoding a specification of our `Salutation` class without using a special test framework *or* magic values, and the *entire* test is in the test method.

Just to hammer this home, lets port over the test that handles the case when you have no first name:

```ruby
def test_last_name_only_male
  # Given
  person = Person.new(nil,"Copeland",:male)
  salutation = Salutation.new(person)
  # When
  greeting = salutation.greeting
  # Then
  assert_equal "Hello, Mr. Copeland!",greeting
end
```

Here, `:male` is *very* relevant, but `"Copeland"` doesn't particularly matter:

```ruby
def test_last_name_only_male
  # Given
  last_name = any_string
  person = Person.new(nil,last_name,:male)
  salutation = Salutation.new(person)
  # When
  greeting = salutation.greeting
  # Then
  assert_equal "Hello, Mr. #{last_name}!",greeting
end
```

With syntax highlighing, the relevant parts of the test literally *jump* out at you.  `:male` and `nil` are the *only* literals in this test, and they are therefore important.  

By removing as many magic values as possible, and replacing them with the _most general possible value_ to satisfy the test, we can make it crystal clear what's going on in each test.

Can we carry this concept further?  Consider the variable `person` in the last test.  Is this variable relevant?  Somewhat.  It is as relevant as `salutation` or `greeting`?  No.  `salutation` is the object under test, and `greeting` is the value we're testing.  Further, `last_name` is a value that's part of the expected result.  To make *this* distinction clear, we can take advantage of Ruby's ability to define fields on the fly:

```ruby
def test_last_name_only_male
  # Given
  @last_name = any_string
  person = Person.new(nil,last_name,:male)
  @salutation = Salutation.new(person)
  # When
  @greeting = @salutation.greeting
  # Then
  assert_equal "Hello, Mr. #{@last_name}!",@greeting
end
```

This might seem superfluous in such a small test, but in a larger, more complex test (especially one dealing with a lot of mocks), this can be really helpful.  You know that so-called "at" variables are important, and their values are meaningful across the "Given/When/Then" of the test, however local variables or short-lived and can be skimmed over when first understanding the test.

## Setup/Teardown

Let's have a brief word on setup and teardown methods.  I've seen a lot of tests use the `setup` method to set up various mock expectations, or do other test-specific setup.  A problem arises when you need to add a test that doesn't require that setup, or perhaps requires some additional setup.  This causes two problems:

* You must now piece together what the "Givens" of a particular test are
* You are setting up conditions that aren't relevant to all tests

Using nested contexts in tools like [RSpec][rspec] exacerbates this greatly, and it's not uncommon to have setup code littered
throughout the file.

I would suggest you keep all test-specific setup out of the `setup` method entirely.  Ideally, you won't even have one.  Occasionally, you'll need to set up something around global variables that can't be easily injected into your code.  More commonly, you'll have a `teardown` method to make sure the next test has a clean slate (e.g. clean up temp files, restore configuration to default, etc.).  These are OK.  What you want to avoid is having any "Givens" or "Thens" inside these methods.

## Conclusion

This brings us to the end of my whirlwind tour of clean tests.  The overall goal is to prioritize _comprehensibility_ of tests without sacrificing too much ease of creation.  Your tests are going to be read and modified a *lot* more than written.  In summary:

* Structure your tests in three parts: Given (setup), When (action), Then (assertions).
* Mock expectations *are assertions*, so put them in the "Then" block, and repeat the Given/When/Then if you need to due to your mocking framework.
* Don't duplicate test code that's the same *by design*, but *do* duplicate it if it's the same by *happenstance*.
* Values important to a test should be variables.
* Values irrelevant to a test should be hidden in "any" style methods.
* If these rules muddy your tests, break them.

## Afterword

I've been working this way for several months, and developed the [clean_test][cleantest] gem to help.  I'll introduce that in a future blog post, but look at some of the [tests][methodone-tests] written using these techniques.  I tend to prefer knowledge be stored digitally, and not in my brain, so these techniques really help.  Try writing your next set of tests like this and see what you think!

[cleantest1]: http://www.naildrivin5.com/blog/2012/01/08/make-tests-clean-and-clear-without-duplication.html
[cleantest2]: http://www.naildrivin5.com/blog/2012/01/16/more-clean-tests-handling-mocks.html
[magicvalues]: http://en.wikipedia.org/wiki/Magic_number_(programming)
[cleantest]: https://github.com/davetron5000/clean_test
[methodone-tests]: https://github.com/davetron5000/methadone/blob/master/test/test_sh.rb
[faker]: http://faker.rubyforge.org/
[rspec]: http://rspec.info/
