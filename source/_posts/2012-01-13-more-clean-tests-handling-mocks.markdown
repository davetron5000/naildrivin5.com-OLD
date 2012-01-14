---
layout: post
title: "More Clean Tests: Handling Mocks"
date: 2012-01-13 08:47
comments: true
categories: 
---

In a [previous post][cleantests], I talked
about the overall structure of a test and how that was important to understand the test itself.  A brief review:


* *Given* - Establish the conditions under which the test will run
* *When* - Run the code under test
* *Then* - assert that the code did what you expect

This structure becomes problematic when using mock objects.

<!-- more -->

## The Trouble with Mocks

When using [mock objects][mocks] in a test, you typically use a
mocking framework (like [mocha][mocha]) to modify the behavior of objects the class-under-test collaborates with.
You often test that the class-under-test made certain calls to its collaborators.  Let's look at an example.

Suppose we have an existing system and we wish to start recording some statistics, such as the number of times a method is called
or how long a method takes to run.  We've created a class, `Statistics`, that has some class methods on it to do the recording:

```ruby Statistics class outline
class Statistics
  # Add one to stat_name
  def self.count(stat_name)
    # ...
  end
end
```

We want to start using this class in our `Salutation` class to keep track of the number of times we're calling `#greeting`.
In order to add this in, we need to test that `Salutation#greeting` is calling `Statistics.count`.  While we could set up a fake
statistics server and examine it during our test, it's more straightforward to use mocks.  


```ruby Testing the use of Statistics
class SalutationTest << TestCase
  def test_that_we_log_statistics
    saluation = Salutation.new(Person.new('David','Copeland',:male))
    Statistics.expects(:count).with('saluation.greeting.count')
    saluation.greeting
  end
end
```

What will happen is, if we don't call `Statistics.count("saluation.greeting.count")` in the `Salutation` class, this test will
fail.  That's what a mocking framework like mocha does for us.

Of course, there's something odd about our test.  There's no call to any sort of `assert` method.  The Given/When/Then is very
unclear.  For a real-world test that requires a lot more setup, it can be even more difficult to see what's actually being
tested.  Essentially, the "Given/When/Then" is "out of order":

```ruby 'Then' and 'When' inverted
class SalutationTest << TestCase
  def test_that_we_log_statistics
    # Given
    saluation = Salutation.new(Person.new('David','Copeland',:male))
    # Then
    Statistics.expects(:count).with('saluation.greeting.count')
    # When
    saluation.greeting
  end
end
```

## Making our Intent Clear

We'd like to keep our test method in a canonical structure, or at least have some part of it follow the Given/When/Then
structure.  Unfortunately, our "Then", the mock expectations, simply _have_ to occur _before_ the "When".  I think
we can make it clearer, so let's add a bit of code to help.

First, we'll create a method named `when_the_test_runs_then` to clearly indicate that our expectations
are part of our "Then", and that they are going to be checked when the test runs, which happens later.  We'll also add a no-op
method, `assert_mocks_were_called` that will allow our test to always have an assert and provide us with a way to be explicit
about what's being asserted.  Although this "assert" method doesn't do anything, it allows use to distinguish between "this test
passes when the mocks are called as expected" from "I forgot to actually test for something".

```ruby 'Then' and 'When' inverted
class SalutationTest << TestCase
  def test_that_we_log_statistics
    when_the_test_runs_then {
      Statistics.expects(:count).with('saluation.greeting.count')
    }

    # Given
    saluation = Salutation.new(Person.new('David','Copeland',:male))
    # When
    saluation.greeting
    # Then
    assert_mocks_were_called
  end

  def when_the_test_runs_then; yield; end
  def assert_mocks_were_called; end
end
```

We've still deviated from our canonical structure, but the test _reads_ better: "When the test runs then expect this method to be
called; now let's run the test"

Of course, we've just taken our first step out of "plain old Ruby" and created framework code.  This is the price you pay for
using mocks; testing with mocks complicate our tests.   By using some lightweight "control structure" helper methods, we can at
least make the intent clear.

## Other Structural Disruptions

There's another pattern we see in tests that disrupts the structure in much the same way that the use of mocks does.  That
disruption is block-based asserts, the most common of which is `assert_raises`.  For example, suppose we're testing that our
`Saluation` class requires a non-`nil` `Person` in its constructor.  We could test that like so:

```ruby Testing that code raises an Exception
def test_that_constructor_requires_a_person
  assert_raises ArgumentError do
    Salutation.new(nil)
  end
end
```

This test is weird for two reasons: the first is that the "Given" is implicit.  The second is that the "Then" comes before the
"When":

```ruby The Given/When/Then of our block-based assertion test
def test_that_constructor_requires_a_person
  # Given - we are going to use a nil Person
  # Then
  assert_raises ArgumentError do
    # When
    Salutation.new(nil)
  end
end
```

We can clean this up by creating a variable for our `nil` `Person` and putting our "Then" code inside a block, which we then pass
to `assert_raises`:

```ruby More clear test with block-based assertions
def test_that_constructor_requires_a_person
  # Given
  nil_person = nil
  # When
  code = lambda { Salutation.new(nil_person) }
  # Then
  assert_raises(ArgumentError,&code)
end
```

We've had to jump through a slightly awkward hoop of putting the code-under-test in a lambda, but now things are in a consistent
structure.  This example might seem a bit too simplisitc.  What about another popular block-based assertion, `assert_difference`?
It's commonly used in Rails apps to check that a certain number of records were written to the database.  While I think that this
assertion is generally not needed, it is commonly used.  
Here's an example where we suppose that an `after_save` hook is memoizing a
derived field for us.

```ruby Complex test using assert_difference
test "we can save and our after-save hook runs, generating the full_name attribute" do
  # Given
  first_name = 'David'
  last_name = 'Copeland'
 
  # Then
  assert_difference('Person.count') do
    # When
    person = Person.create(:first_name => first_name, last_name => last_name)
    # Then
    assert 'David Copeland',person.full_name
  end
end
```

*Now* the structure is very strange.  If we try to apply our `lambda` solution above, it's still a bit odd:

```ruby Applying a lambda to our Rails test
test "we can save and our after-save hook runs, generating the full_name attribute" do
  # Given
  first_name = 'David'
  last_name = 'Copeland'

  # When
  code = lambda {
    person = Person.create(:first_name => first_name, last_name => last_name)
    # Then
    assert 'David Copeland',person.full_name
  }
 
  # Then
  assert_difference('Person.count',&code)
end
```

Yikes.  This is arguably worse.  Since only one line of code inside our "When" block is really affecting the condition that
`assert_difference` tests for, we can take advantage of Ruby's ability to create instance variables on-demand and pass
the person outside of the `assert_difference` block:

```ruby Canonically-structured Rails test using assert_difference
test "we can save and our after-save hook runs, generating the full_name attribute" do
  # Given
  first_name = 'David'
  last_name = 'Copeland'

  # When
  create_person = lambda { 
    @person = Person.create(:first_name => first_name, last_name => last_name)
  }
 
  # Then
  assert_difference('Person.count',&create_person)
  assert 'David Copeland',@person.full_name
end
```

That's much better; we can now clearly see the setup, the code being tested, and all the assertions together.

It may seem slightly unusual, but by working to keep all your tests structured around Given/When/Then, you will find them
readable weeks and months later, and others will be clearly able to see their intent.

## Next

We still have a fair way to go to get our tests really clean and clear.  For example, do we need to have those `#Given`, `#When`,
and `#Then` comments
everywhere?  I [think comments are powerful][commentspost], but having the same group of comments everywhere 
feels like repetition we can eliminate.
Another issue is the use of "magic values", or literals, in our test code.  In the test above, we create a male person with the
name "David Copeland".  Is any of this relevant to the test?  If not, why is it there?

We'll deal with these issues in the next post.

[cleantests]: http://www.naildrivin5.com/blog/2012/01/08/make-tests-clean-and-clear-without-duplication.html
[mocks]: http://en.wikipedia.org/wiki/Mock_object
[mocha]: http://mocha.rubyforge.org/
[commentspost]: http://www.naildrivin5.com/blog/2012/01/11/the-war-on-comments.html
