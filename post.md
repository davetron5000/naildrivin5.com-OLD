# Rails Application Architecture is not Object-Oriented

There have been debates raging about the "proper" internal architecture of a Rails application.  "The Rails Way" is a strict
adherence to Models, Views, and Controllers:

![MVC](https://www.evernote.com/shard/s71/sh/eafcb80b-70ce-4c58-a5a7-c30149b26ba5/bbd75cd6de137017ec17533e98d51ed8/deep/0/Untitled-2.png)

The problem is that Rails HTML rendering is highly coupled to how Rails interacts with the database, namely that methods like
`form_for` require their arguments to implements a set of undocumented and seemingly unrelated methods that happen to be provided
by `ActiveRecord::Base` (a subset of which are provided by `ActiveModel::Model` as of Rails 4).

This coupling encourages users to send Active Records to the view layer, which encourages users to place the vast majority of
their application logic in those models.  The design of these models is not object-oriented.  Instead, a "Rails Way" model is a
collection of *many* unrelated methods, at varying levels of abstraction (application logic sits right alongside
framework-provided methods), along with the complete exposure of the object's internal data (namely, the fields from the
database).

This is bad because any code using a "Rails Way" model is unnecessarily complex.  The "model" isn't modeling any one concept, but
is modeling several different concepts, all at the same time.  As the application's complexity and size increases, the models
take on more and more concepts.  

But Rails actively discourages doing it any other way.

This isn't about the "Single Responsibility Principle", the "Law of Demeter", or "designing for testability". It's about being
honest about what an application architecture consisting solely of highly mutable objects with a kitchen-sink of methods on them
is. Not good.

Let's take a simple example:

```ruby
# the users table has:
# - id
# - given_name
# - surname
# - country_of_birth
# - birthdate
class User < ActiveRecord::Base
end
```

The _object_ `User` is a repository of user records.  _Instances_ of the `User` class *are* these records.  This seems good and
useful.  We have a very simple way to manipulate data in our data store, and pass around a database row in our code.

Now suppose we need to format a person's name.

```ruby
class User < ActiveRecord::Base
  def display_name
    if country_of_birth == 'US'
      "#{given_name} #{surname}"
    else
      "#{surname} #{given_name}"
    end
  end
end
```

Does this belong here?  Now imagine 50 more methods like this.  What if we made a class instead?

```ruby
class DisplayName
  def initialize(user)
    @country_of_birth = user.country_of_birth
    @given_name       = user.given_name
    @surname          = user.surname
  end

  def to_s
    if @country_of_birth == 'US'
      "#{@given_name} #{@surname}"
    else
      "#{@surname} #{@given_name}"
    end
  end
end
```

This is a few lines of code longer than the "Rails Way" version, but it carries a lot of advantages.  The main logic is simpler
to understand: `to_s` has only three inputs: country of birth, given name, and surname.  `display_name` has the entirety of the
person record as inputs.  Also, we can test this logic pretty easily.

Of course, Rails does not encourage this sort of design.  How would you use it?

```erb
<h1>Hello there <%= DisplayName.new(@user) %>!</h1>
```

or

```ruby
class UsersController
  def show
    @user         = User.find(params[:id])
    @display_name = DisplayName.new(@user)
  end
end
```

What about this?

```ruby
class UserPresenter
  def initialize(user)
    @user = user
  end

  User.attribute_names.each do |attribute_name|
    delegate attribute_name, to: :@user
  end

  def display_name
    DisplayName.new(@user)
  end
end
```

These are all pretty terrible, and it's no wonder we never end up just throwing such logic into the Active Record—Rails makes it
difficult to do any other way^^[It's amazing that Rails hasn't provided a good solution for this.  The only other "Rails Way" of handling this is to use a helper, but those create massive problems in large codebases, since they essentially share the same namespace.].

And from here, we end up with terribly-architected applications.  Rails encourages it.  Given that the mere discussion of the
problem and possible solutions is disparaged by Rails creator, what can we do?

The best way I've found to deal with this is to give up on object-orientation, and design the application internals around
records, which hold data, and "service objects", which implement functionality.   For the "display name" issue, I would probably
create a simple struct just for the view in question:

```ruby
class UserPresenter
  def self.from_user(user)
    self.new(
      id: user.id,
      name: user.name,
      birth_date: user.birth_date,
      display_name: DisplayName.new(user)
    )
  end

  attr_reader :id, :name, :birth_date, :display_name
  def initialize(attributes={})
    @id           = attributes[:id]
    @name         = attributes[:name]
    @birth_date   = attributes[:birth_date]
    @display_name = attributes[:display_name]
  end
end
```

This is not wonderful, but I feel its advantages outweigh its disadvantages.  Primarily, it's a lot more code.  But, it was
relatively painless to write, and it has the virtue of being extremely simple to understand: `from_user` creates a
`UserPresenter` given a `User` instance, but you can always create one directly using the initializer.

It also provides a clean level of isolation between the view layer and the data layer.  I can make significant changes in where a
user's attributes come from, and I won't have to touch my views.  An architecture with this feature is worth a few extra minutes
of writing this boilerplate.

Could Rails do something better here?  One could imagine something like:

```ruby
class UsersController
  def show
    user = User.find(params[:id])
    @user = present @user, display_name: DisplayName
  end
end
```

or something like that.  You could also imagine a more sophisticated templating system:

```ruby
<h1>Hello <%= @user | DisplayName %>!</h1>
<h2>You were born on <%= @user.birthdate %></h2>
```

Either way, to create a well-architected Rails application is often an uphill battle, as even moderate levels of complexity
require deviation from "The Rails Way" in order to keep a system changeable and understandable.

