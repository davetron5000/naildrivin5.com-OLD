---
layout: post
title: "Lookup tables with lambdas"
date: 2012-05-16 10:34
comments: true
categories: 
---

Yesterday, I tweeted:

<blockquote class="twitter-tweet"><p>x = Hash.new { |_,_|lambda {}}.tap { |hash|hash[:key] = lambda {}}x[attr].callFilthy?I kinda like it</p>&mdash; ❺➠ David Copeland (@davetron5000) <a href="https://twitter.com/davetron5000/status/202520727239409664" data-datetime="2012-05-15T22:07:58+00:00">May 15, 2012</a></blockquote>
<script src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

This may seem crazy, but it's a really just an enhanced use of what Steve McConnell, in "Code Complete", describes as
_Table-Driven Methods_.  Let's see what that has to do with my crazy `Hash` construct.

<!-- more -->

If you haven't read ["Code Complete"][code_complete], and you are a relatively inexperienced developer, I highly recommend it.  My
version has a lot of Pascal in it, and I think the latest might use Visual Basic (!), but it doesn't matter.  There's a lot of
useful gems in there.

One of them is "Table-Driven Methods", which he describes as

> a scheme that allows you to look up information in a table rather than using logic statements to figure it out

In the simplest form, you'd replace a `case` statement with a table lookup.  Consider this method that determines, based on the
type of credit card, what countries that card can be used in:

```ruby
def countries_usable_in
  case self.card_type
    when 'discover'
      ['US']
    when 'maestro'
      ['UK']
    when 'visa'
      ['US','UK','IE']
    when 'master_card'
      ['US','UK','IE']
    end
  end
end
```

This could be easily replaced by:

```ruby
CARD_TYPE_COUNTRIES = {
  'discover'    => ['US'],
  'maestro'     => ['UK'],
  'visa'        => ['US','UK','ZA'],
  'master_card' => ['US','UK','ZA'],
}

def countries_usable_in
  CARD_TYPE_COUNTRIES[self.card_type]
end
```

This is much less complex, both from a formal perspective, and from a general "what's going on here?" perspective.  We replace a
bunch of conditionals with a simple mapping.  Enhancing this code is simple: we just add a new entry to the `CARD_TYPE_COUNTRIES`
`Hash` and we're on our way.

This has a couple of problems with it.  You'll notice that both "visa" and "master_card" map to the same list.  What we really
want is to treat "discover" and "maestro" as special, and then for any other card type, return our default list of US, UK, and
South Africa.

Ruby's `Hash` constructor can be given a block that returns the value to use when a key is missing, so that would seem to be
useful:

```ruby
hash = Hash.new { |key,value
  "FOO"
}
hash[:blah] # => "FOO"
hash[:blah] = "BAR"
hash[:blah] # => "BAR"
hash[:crud] # => "FOO"
```

Of course, this makes it a bit awkward to populate our `Hash` with the lookup table, because we lose the literal syntax.  We can
deal with *this* by using `tap`, which passes the object called on it to the block passed to it, executes the block, throws away
the block's return value and returns the object on which we called `tap`.  Whoa.  Let's look at an example.

```ruby
CARD_TYPE_COUNTRIES = Hash.new { |key,value|
  ['US','UK','IE']
}.tap { |new_hash|
  new_hash['discover'] = ['US']
  new_hash['maestro']  = ['UK']
}
```

Now, when we call `CARD_TYPE_COUNTRIES['visa']`, this uses the block we gave to the constructor, but
`CARD_TYPE_COUNTRIES['maestro']` simply returns the literal array we assigned in `tap`.

So far so good.  Now, suppose we have a new requirement to add American Express.  Suppose that American Express isn't supported in African countries, but works everywhere else.  Since we don't want to hard-code what countries are in Africa, we'll need to consult the database.

```ruby
def countries_usable_in
  countries = CARD_TYPE_COUNTRIES[self.card_type]
  if self.card_type == 'american_express'
    countries - Continent.find("Africa").countries
  else
    countries
  end
end
```

We've re-introduced those pesky control structures we were trying to remove.  Why can't we do this?

```ruby
DEFAULT_COUNTRIES = ['US','UK','IE']
CARD_TYPE_COUNTRIES = Hash.new { |key,value|
  DEFAULT_COUNTRIES
}.tap { |new_hash|
  new_hash['discover']         = ['US']
  new_hash['maestro']          = ['UK']
  new_hash['american_express'] = DEFAULT_COUNTRIES - Continent.find("Africa").countries
}
```

This has two problems:

* The database query is only run on app startup, so any changes won't affect things until we restart (imagine our `COUNTRIES` table only having countries we support and not *all* countries; we want to add new countries without an app restart)
* We are running a database query inside a class definition and we don't necessarily have a guarantee that the database connection is even established at that point.

What we need is a lookup table that calculates its results on demand.  Ruby has a structure for that: `lambda`

```ruby
DEFAULT_COUNTRIES = ['US','UK','IE']
CARD_TYPE_COUNTRIES = Hash.new { |key,value|
  DEFAULT_COUNTRIES
}.tap { |new_hash|
  new_hash['discover']         = lambda { ['US'] }
  new_hash['maestro']          = lambda { ['UK'] }
  new_hash['american_express'] = lambda { 
    DEFAULT_COUNTRIES - Continent.find("Africa").countries 
  }
}

def countries_usable_in
  CARD_TYPE_COUNTRIES[self.card_type].call
end
```

I find this to be a pretty clean solution.  We have all the benefits of a table-driven approach, but only need to specify special
cases (thanks to our default block), and have the ability to calcualte our results on demand, based on the current state of the system (thanks to using lambdas and static values).  Not too bad.

Let's take this concept even further.  We often write code using an `if..elsif..else..end` structure that essentially tries
various conditions to find one that holds, and returns a value based on that condition.  

As an example, we'll switch domains to my favorite: [command line apps][clibook].  Suppose I need to determine the size of the user's terminal so I can properly format output.  My algorithm will be:

* If the environment variable `COLUMNS` is a number, use that
* Otherwise, if the command `tput` exists, run `tput lines` and return its output
* Otherwise, if the command `stty` exists, run `stty size` and parse its output for the value
* Otherwise, return a sensible default.

How does this apply to our lookup table?  Essentially we want a table of conditions and, for the first one that holds, perform
the calculation to figure out the size.  For the sake of clarity, we'll assume some helper methods, which gives us this code:

```ruby
def terminal_columns
  if ENV['COLUMNS'] =~ /^\s+$/
    ENV['COLUMNS']
  elsif command_exists?("tput")
    `tput lines`.chomp.to_i
  elsif command_exists?("stty")
    parse_stty
  else
    DEFAULT_COLUMNS
  end
end
```

This is a pretty complex routine.  What if we need to add Windows support?  Another `elsif`.  Lets use our newfound lookup table
powers, but instead of using a static key for lookup, we'll use a dynamic one, based on our conditions:

```ruby
TERMINAL_SIZES = [
  { :test => lambda { ENV['COLUMNS'] =~ /^\s+$/ }, :val => lambda { ENV['COLUMNS'] },
  { :test => lambda { command_exists?("tput") },   :val => lambda { `tput lines`.chomp.to_i },
  { :test => lambda { command_exists?("stty") },   :val => lambda { parse_stty },
  { :test => lambda { true },                      :val => lambda { DEFAULT_COLUMNS },
]
```

Note that we're using an array to keep things ordered, but we're using an `Array` of `Hash` so that our client code will be
fairly readable (we'll see that in a second).

Recall that we want the first expression that returns true, and to return the value associated with that expression.  This is a
one-liner, thanks to Ruby's aweomse collections:

```ruby
def terminal_columns
  TERMINAL_SIZES.find { |size| size[:test].call }.first[:val].call
end
```

Not bad.

Now, if you come across something like this, but didn't derive it as we have done here, is it really better?  I would argue that
it is, especially if you are comfortable with the general concept of table-driven algorithms.  In the case of our credit card
example, you can see a clear mapping between special cases and the results.  For the terminal lines example here, we again have a
clean mapping between test and result, and it's not muddied up amongst control structures.  

These tables are also more easily changed: new cases can be added to our credit card type table, and we can easily re-order our
terminal size calculation if we decide on a better strategy.

If you find yourself writing an `elsif` or a `case` statement; consider using a table-driven method.  Ruby provides excellent
tools to make this easy to do for any use case.


[code_complete]: http://www.amazon.com/Code-Complete-Practical-Handbook-Construction/dp/0735619670
[clibook]: http://www.pragprog.com/titles/dccar
