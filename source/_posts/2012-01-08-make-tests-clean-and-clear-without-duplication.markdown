---
layout: post
title: "Make Tests Clean and Clear without Duplication"
date: 2012-01-08 14:34
comments: true
categories: 
---

Some collegues and I were dicussing dupication in tests, specifically how much repitition of code across tests is acceptible.
On the one hand, you want each test to stand on its own and indicate what it's testing.  On the other hand, just because we're in
a test doesn't mean that all the rules about duplication of code don't apply; tests need to be maintained to, and if you make a
large change, you don't want to have to change it in several places.

This is actually a small part of a larger discussion about how we should structure our tests.

<!-- more -->

## What is a test?

To know how our test code shoudl be structure, we must understand what the purpose of a test is.  At its base, a test is some code that, when executed, checks that a bit of code behaves in a certain way.  We want our tests to be more than this.  A collection of these tests is more, however.  A collection of tests should describe the *behavior* of a piece of code.  We should be able to understand, from looking at a bunch of tests what the code is supposed to *do*.  Even this can be tricky, as we'll see.

Let's start with the basic structure of one test

### Structure of a single test

A test is made of up three parts:

1. *Setup* or *Given* - This part establishes the conditions under which the test will be performed.  This is crucial, and what makes programming hard - can we know *every* condition under which our code will run?  How will it run under those conditions?  We call this "Given" because we establishes the "givens" of our test; the things that we explicitly make true.
2. *Execute* or *When* - Here, we run the code we're testing.  This is easier, as it's usually a call to a public method of a class.  It's called "When" because of phrases like "When I calculcate the sales tax".
3. *Assert* or *Then* - The final part involves checking that what we executed in step 2 did what we thought it should do.  It's
   called "Then" because of the weay we might state assertions in English - "Then the total should be $56.12".

A very simple test might look like this:

```ruby Basic tests showing each part
def test_area
  # Given (setup)
  circle = Circle.new(10)
  # When (execute)
  area = circle.area
  # Then (assert)
  assert_equal 314,area
end
```

Certainly, this could be done in one line:

```ruby Test in a single-line, with the three parts obscured
def test_area
  assert_equal 314,Circle.new(10).area
end
```

This might save a few lines, but it obscures the setup, execution and assertion.  There isn't much advantage to this, but, tests
this simple rarely appear in real systems.  We tend to have problems with overcomplex tests.

Often, complex setup is required to establish all the "givens".
Further, the setup for several tests might be very similar, containing identical code with very small differences.  It's these
differences that form the true picture of the behavior of code under test.

### Structure of a set of tests

Let's take a simple domain that it's a bit more complex than our `Circle` class to see how tests interact.  Let's test a class
that, given a `Person`, returns a "salutation".  What makes this tricky is that people in our system don't always have a first
name or last name.  We want our `Salutation` class to handle this.

```ruby Basic tests for our Salutation class
class SalutationTest << Test
  def test_full_name
    # Given
    person = Person.new("David","Copeland",:male)
    salutation = Salutation.new(person)
    # When
    greeting = salutation.greeting
    # Then
    assert_equal "Hello, David!",greeting
  end

  def test_first_name_only
    # Given
    person = Person.new("David",nil,:male)
    salutation = Salutation.new(person)
    # When
    greeting = salutation.greeting
    # Then
    assert_equal "Hello, David!",greeting
  end

  def test_last_name_only_male
    # Given
    person = Person.new(nil,"Copeland",:male)
    salutation = Salutation.new(person)
    # When
    greeting = salutation.greeting
    # Then
    assert_equal "Hello, Mr. Copeland!",greeting
  end

  def test_last_name_only_female
    # Given
    person = Person.new(nil,"Copeland",:female)
    salutation = Salutation.new(person)
    # When
    greeting = salutation.greeting
    # Then
    assert_equal "Hello, Ms. Copeland!",greeting
  end
end
```

Read these tests over.  They should, hopefully, give you a picture of what the `Salutation` class is supposed to do, even though
we aren't seeing the actual implementation{% fn_ref 1 %}.  Of course, this isn't perfect.  If you look over the test class
quickly, all the tests look similar, and it's hard to tell what the differences are.  Specifically:

* The assertions in the first two tests are identical. Is this by coincidence, or by design?
* This test is hopelessly bound to the construction of a `Person`, even though this class doesn't test that construction; we
  simply want `Person` instances of a certain nature.

All of these issues make it unclear what's really being tested.  What part of each of these tests is *different* from the others
in a significant way?

## Making intent more clear

Our first issue is that the first two tests' assertions are identical.  This is, in fact, by design of the `Salutation` class -
if the person has a first name, we don't care if they have a last name.  Let's make that design clear:

```ruby Making the design more clear
class SalutationTest << Test
  def test_salutation_uses_first_name
    [ "Copeland", nil ].each do |last_name|
      # Given
      person_with_first_name = Person.new("David",last_name,:male)
      salutation = Salutation.new(person_with_first_name)
      # When
      greeting = salutation.greeting
      # Then
      assert_equal "Hello, David!",greeting,"For person #{person_with_first_name}"
    end
  end
end
```

Now, it's very clear that the last name doesn't matter.  Note that since we're now executing our given/when/then in a loop, we need to include the person used in the salutation in our assertion message so if it ever fails, we know which `last_name` caused it.

This clears up our biggest issue, but what about the duplication of creating `Person` instances?  Outside of the fact that any
change in the constructor `Person` will break this test, it's also not clear what's different about all of these `Person`
instances.  Even if we're familiar with the constructor, it's still not 100% clear what _kind_ of person we're setting up as a
"Given".  

We could certainly drop a few comments in, but we have a more powerful tool: method extraction.

```ruby Tests with Person construction extracted to methos
class SalutationTest << Test

  def test_salutation_uses_first_name
    # Given
    first_name = "David"

    [ person_with_first_name_only(first_name), 
      person_with_full_name(first_name) ].each do |person_with_first_name|
      # Given
      salutation = Salutation.new(person_with_first_name)
      # When
      greeting = salutation.greeting
      # Then
      assert_equal "Hello, #{first_name}!",greeting,"For person #{person_with_first_name}"
    end
  end

  def test_last_name_only_male
    # Given
    salutation = Salutation.new(male_with_only_last_name("Copeland"))
    # When
    greeting = salutation.greeting
    # Then
    assert_equal "Hello, Mr. Copeland!",greeting
  end

  def test_last_name_only_female
    # Given
    salutation = Salutation.new(female_with_only_last_name("Copeland"))
    # When
    greeting = salutation.greeting
    # Then
    assert_equal "Hello, Ms. Copeland!",greeting
  end
end
```

Now, it's painfully clear *which* type of person we're setting up.  We've also been able to eliminate the `person` variable,
which was only really needed to construct the `Saluation` instance.  It's existence muddied the test code, so the elimination
of that makes the tests more clear.  The extracted methods are trivial:

```ruby Factory methods for Person intances
def person_with_first_name_only(first_name)
  Person.new(first_name,nil,:male)
end

def person_with_full_name(first_name)
  Person.new(first_name,'Smith',:male)
end

def male_with_only_last_name(last_name)
  Person.new(nil,last_name,:male)
end

def female_with_only_last_name(last_name)
  Person.new(nil,last_name,:female)
end
```

Granted, our test is a lot more lines of code than it was, but it's also a lot more clear.  Since code is *read* much more often
than written, good, clean code should favor readability.  Our test code now does, clearly communicating, for each test, what the
conditions are under which we're going to test, what code we're testing and what behavior we expect our code to exhibit, all with
a minium of comments -- the code speaks for itself.

Of course, we can still introduce further confusing duplication.  As our codebase grows, we'll see that duplication will also
grow.

## Behavior in the face of change

Let's consider a new subclass of `Salutation` called `FormalSalutation`.  This new subclass will implement the somewhat
old-fashioned notion of referring to married women as "Mrs." and unmarried women as "Miss".  It will also
spell our "Mister".  We'll copy the tests for
`Salutation` and enhance them as a naive first step.

```ruby Tests for the new FormalSalutation class
class FormalSalutationTest << Test

  def test_salutation_uses_first_name
    # Given
    first_name = "David"

    [ person_with_first_name_only(first_name), 
      person_with_full_name(first_name) ].each do |person_with_first_name|

      # Given
      person_with_first_name = person_with_first_name(
      salutation = FormalSalutation.new(person_with_first_name)
      # When
      greeting = salutation.greeting
      # Then
      assert_equal "Hello, #{first_name}!",greeting,"For person #{person_with_first_name}"
    end
  end

  def test_last_name_only_male
    # Given
    salutation = FormalSalutation.new(male_with_only_last_name("Copeland"))
    # When
    greeting = salutation.greeting
    # Then
    assert_equal "Hello, Mister Copeland!",greeting
  end

  def test_last_name_only_married_female
    # Given
    person = female_with_only_last_name("Copeland")
    person.marry!
    salutation = FormalSalutation.new(person)
    # When
    greeting = salutation.greeting
    # Then
    assert_equal "Hello, Mrs. Copeland!",greeting
  end

  def test_last_name_only_unmarried_female
    # Given
    salutation = FormalSalutation.new(female_with_only_last_name("Copeland"))
    # When
    greeting = salutation.greeting
    # Then
    assert_equal "Hello, Miss Copeland!",greeting
  end

private 
  def person_with_first_name_only(first_name)
    Person.new(first_name,nil,:male)
  end

  def person_with_full_name(first_name)
    Person.new(first_name,'Smith',:male)
  end

  def male_with_only_last_name(last_name)
    Person.new(nil,last_name,:male)
  end

  def female_with_only_last_name(last_name)
    Person.new(nil,last_name,:female)
  end
end
```

The tests are pretty clear as to what they are doing, but now we have two types of nasty duplication going on:

* Some of these tests are identical to those in `SalutationTest`
* Some of our private `person_*` methods are identical to those in `SalutationTest`

### Duplicated Tests

The way things are now, the duplicate tests in both `SalutationTest` and `FormalSalutationTest` communicate that the behavior
of these two classes, in regard anyone with a first name, is the same by happenstance;
there's nothing about the _design_ of our salutation concept that includes this behavior.

This design is, in fact, correct.  It was our intention that for both `Salutation` and `FormalSalutation` their
behaviors do not depend on one another.  If this were not the case, however, we'd do things differently.

Suppose our _intent_ was that any salutation in the system, when faced with a `Person` who had a first name, should *always*
respond with "Hello, first_name".  In that case, our tests should support that intent by sharing the test for people with first
names.  In addition to make the design intentions clear, it also makes it easy for someone creating a new salutation class to
check that their class is within the given design.

Onto our second form of cross-test duplication, the duplication in the setup of `Person` instances.

### Duplication in setup

In both `SalutationTest` and `FormalSalutationTest`, we create a person with a full name, a person with no last name, and a
male person without a first name.  It's done the same way in both test classes.  The code, as it stands now, is telling us that
this duplication is merely happenstance.  This is, in fact, not correct.  The real intent is that, given _the same set of
Givens_, `Salutation` should behave one way and `FormalSalutation` should behave another.  This is most clear when testing men
with no first name.

Since the setup of these two methods is the same, we'd like to communicate that in our implementation.  We could use a tool
like [FactoryGirl][factorygirl], but this puts all of our test data into global scope.  We only want our test data scoped to the
tests in question.  This is so that data can change as those sets of classes change, and we can be sure we aren't breaking other
classes.

We can do this without any special tools by using a module with a well-chosen name.  We'll create a namespace called
`SalutationTests` and a module inside called `People` that will contain our extracted methods.

```ruby Module for production `Person` instances for salutation tests
module SalutationTests
  module People
    def person_with_first_name_only(first_name)
      Person.new(first_name,nil,:male)
    end

    def person_with_full_name(first_name)
      Person.new(first_name,'Smith',:male)
    end

    def male_with_only_last_name(last_name)
      Person.new(nil,last_name,:male)
    end

    def female_with_only_last_name(last_name)
      Person.new(nil,last_name,:female)
    end
  end
end

class SalutationTest << Test
  include SalutationTests::People
end

class FormalSalutationTest << Test
  include SalutationTests::People
end
```

It's now clear that the setup for the first two tests of both `SalutationTest` and `FormalSalutationTest` are the same _by
design_.   Note that if we *did* choose to move to FactoryGirl later on, we only need to update this module to pull our
factories, instead of having to go into each test method and do it.  This is elementary structured programming.

## When we need a slight tweak to our setup

Suppose we want to make a third class, called `HonorificSalutation`.  Here, our setup is very similar, but not exactly the same,
as our common `Person` setup in `SalutationTests::People`.  Since we don't *have* to use this module, we could create `Person`
instances exactly how we'd like, and make it clear that the tests in `HonorificSalutationTest` aren't the same as those
in the other two.

However, this isn't exactly true.  The setup is *almost* the same and, since these three classes are all related, it makes sense
to share the similarities.  We want someone to look at `HonorificSalutation` and know what's _different_ about this class
from `Salutation` or `FormalSalutation`.  So, we re-use the methods from `SalutationTests::People` and modify the results during
the setup:

```ruby Tests for HonorificSalutation
class HonorificSalutationTest << Test
  include SalutationTests::People

  def test_doctor_with_no_first_name
    [ male_with_only_last_name('Copeland'),
      female_with_only_last_name('Copeland')].each do |person|
      # Given
      person.honorific = :doctor
      salutation = HonorificSalutation.new(person)
      # When
      greeting = salutation.greeting
      # Then
      assert_equal "Hello, Dr. Copeland!",greeting
    end
  end
end
```

What this code is saying is that when we test a person who's a doctor and has no first name, we want both a male and female
*exactly* like we had in our other tests, but the *one* difference between those tests and this is that `honorific`
is being set to `:doctor`.  This makes it very clear what's truly different.

## Conclusions

There's a lot more to this subject, but essentially what we're getting at is the meaning behind duplication.  Essentially, things
that are the same _by desgin_ should be shared.  Everything else is only the same by happenstance.  By coding your tests in this
way, you make the intent and design very clear.  And you don't need any special tools to do it.

[factorygirl]: https://github.com/thoughtbot/factory_girl

---

{% footnotes %}
  {% fn And, of course, please set aside the American-centric natrue of this class and domain.  I understand that many cultures have the names "reversed" from American-style or don't even have such a rigid name structre. %}
{% endfootnotes %}
