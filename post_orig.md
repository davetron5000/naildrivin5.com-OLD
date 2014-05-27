# Rails Application Architecture, Testing, and Scalability

Rails is great until it isn't.  Many experienced Rails developers have run up against issues when a Rails app reaches certain
milestones, such as userbase, lines of code, size of team, etc.  By then, it is often very difficult to unwind the tangled web of
Rails many conveniences and DSLs.

Developers are left asking where it all went wrong?  Rails, unfortunately, encourages an application architecture that doesn't
suffer complexity or scale very well.

Consider a pretty standard Rails view:

```erb
<%= form_for(@user) do |f| %>
  <div class="field">
    <%= f.label :name %><br>
    <%= f.text_field :name %>
  </div>
  <div class="field">
    <%= f.label :age %><br>
    <%= f.number_field :age %>
  </div>
  <div class="field">
    <%= f.label :favorite_color %><br>
    <%= f.text_field :favorite_color %>
  </div>
  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>
```

`form_for` works because `@user` is an ActiveRecord (to be precise, it works because `@user` happens to respond to several
seemingly unrelated messages that also happen to be implemented by `ActiveRecord::Base`, *some* of which also happen to be
implemented by `ActiveModel::Model`).

If you need to change where your users are stored—a very reasonable thing to need to do under certain situations—you are going to
have a *very* bad time. This is because Rails internals are highly coupled to one another.  Changing how you store some of your
data breaks your HTML rendering.

While this application architecture enables very fast interation initially, it creates a situation where the significant changes
needed to grow a business are extremely difficult.

I speak from experience.  I spent several months modifying an ActiveRecord object to use a RESTful API instead of ActiveRecord.
The sheer size of the API, and the dynamic nature of it made it extremely difficult.  Any test that used this class had to
essentially be rewritten from scratch.

This is likely not new information for anyone with real Rails experience.  That experience has led us to various rules of thumb
about Rails and how to work with it.  When we start on a new Rails application, we swear to not make the same mistakes we did in
the past.

A big part of the problem has to do with a fundamental misunderstanding of the phrases "Domain-Drive Design", "Object-Oriented",
and "Model".

The Wikipedia page for [Domain-Driven Design](http://en.wikipedia.org/wiki/Domain-driven_design) is quite interesting:

> Entity: an object that is not defined by its attributes, but rather by a thread of continuity and its identity.
> Value Object: an object that contains attributes but has no conceptual identity.  They should be treated as immutable.

In no way is a Rails Active Record object *either* of these types of classes.

In terms of "object-oriented", Active Record objects fail here as well.  One great thing about OO code is encapsulation.  You
could hide implementation details and data behind methods.  An Active Record object, as encouraged by Rails, certainly does that,
but then just exposes its internal state anyway.  So, you end up with objects with very large surface area, that provide no
encapsulation.

Rails has "taught" us that a "model" is a record that also has a bunch of methods on it, that it must be a noun mapped to some
real-world object.

Setting aside the "Single Responsibility Principle", the "Law of Demeter", or "designing for testability", it seems really hard
to define an application architecture that is made up of a bunch of highly-mutable records that each contain a kitchen-sink worth
of methods, some of which are domain-specific (methods you write) and some of which are low-level features of the framework.

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
useful.

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

Does this belong here?  Now imagine 50 more methods like this.  Do we just move them to a `UserPresenter`?  What about making a
new class?

```ruby
class DisplayName
  def initialize(user)
    @string = if country_of_birth == 'US'
                "#{given_name} #{surname}"
              else
                "#{surname} #{given_name}"
              end
  end

  def to_s
    @string
  end
end
```

This class is not defined by its attributes, and it is immutable.  Bet this would be easy to test.

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

  delegate User.attribute_names, to: :@user

  def display_name
    DisplayName.new(@user)
  end
end




This is not an application architecture favorable to the complexities involved in a growing business.  A vanilla Rails
application architecture is geared almost entirely on quickly production an application.





Ruby on Rails gives use great tools to get started writing an application.  These tools heavily influence how our application is
designed and architected.  The problem is when things get complex (by which I mean necessarily complex).  When the team
maintaining a Rails application encounters scalability problems, be they team size, data storage, performance, or product demand,
we often find ourselves hamstrung by the choices we made early on—the choices Rails nudges us toward.

In the second "Is TDD Dead?" hangout between DHH, Martin Fowler and Kent Beck, Kent posed a question to DHH regarding a gist that
showed an overcomplex design for a feature in Rails.  He asked DHH "What do you need to do to this code that this design makes
difficult?".  This is *precisely* the question developers are asking themselves when they realize they've painted themselves into
a corner.

The reason to avoid callbacks, use service objects, factor logic out of Active Record objects, etc. are all to allow changes to
the application to be as simple as possible.

I want to show an example of how "The Rails Way" can get in the way of delivery when a team encounters a fairly routine problem.

Let's suppose we have a simple form for creating and editing users:

```erb
<%= form_for(@user) do |f| %>
  <% if @user.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(@user.errors.count, "error") %> prohibited this user from being saved:</h2>

      <ul>
      <% @user.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= f.label :name %><br>
    <%= f.text_field :name %>
  </div>
  <div class="field">
    <%= f.label :age %><br>
    <%= f.number_field :age %>
  </div>
  <div class="field">
    <%= f.label :favorite_color %><br>
    <%= f.text_field :favorite_color %>
  </div>
  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>
```

This is what is generated by the Rails scaffold and it's pretty typical.  Because `@user` is an `ActiveRecord` object, `form_for`
and all the other stuff we see here makes the problem of dealing with forms and validation super simple.  It's one of the reasons
we love Rails.

Now, suppose that our application has grown, and for reasons of scalability we must now store our users in a different way.  We
can no longer allow the front-end web application to access them via SQL.  There are many, many reasons why we may  need to solve
this problem and why we might choose to solve it this way.

Because all our access to users is done via `User`, this *should* be a matter of re-implementing the `User` class to use the new
data store.  Generally, our `User` _objects_ are going to be dumb structs, with some class methods on them to stand-in for what
ActiveRecord provides.

```ruby
class User
  attr_accessor :id, :name, :age, :favorite_color

  def initialize(attributes={})
    id             = attributes[:id]
    name           = attributes[:name]
    age            = attributes[:age]
    favorite_color = attributes[:favorite_color]
  end

  def self.all
    # query the real data store
  end

  def self.create!
    # etc
  end

  # and so forth

end
```

Let's set aside how difficult just this much would be.  If our app has been around, it'l be littered with `create`, `create!`,
`update_attributes`, `where`, `joins`, and the like.  But let's charitably say that it's not, and that our new data store makes
it pretty easy to implement basic `where` type stuff and so we can swap our the `User` interface for one that uses the new data
store.

Let's load up our index page.

```
Started GET "/users" for 127.0.0.1 at 2014-05-18 16:41:15 -0400
Processing by UsersController#index as HTML
  Rendered users/index.html.erb within layouts/application (0.9ms)
Completed 500 Internal Server Error in 4ms

ActionView::Template::Error (undefined method `model_name' for User:Class):
    16:         <td><%= user.name %></td>
    17:         <td><%= user.age %></td>
    18:         <td><%= user.favorite_color %></td>
    19:         <td><%= link_to 'Show', user %></td>
    20:         <td><%= link_to 'Edit', edit_user_path(user) %></td>
    21:         <td><%= link_to 'Destroy', user, method: :delete, data: { confirm: 'Are you sure?' } %></td>
    22:       </tr>
  app/views/users/index.html.erb:19:in `block in _app_views_users_index_html_erb__3553815775621370956_70312511258820'
  app/views/users/index.html.erb:14:in `each'
  app/views/users/index.html.erb:14:in `_app_views_users_index_html_erb__3553815775621370956_70312511258820'
```

OK then.  It seems that the URL helpers need to know the model name of our `User` class.  This is brought in via
`ActiveRecord::Base` by means of the `ActiveModel::Naming` module.

![No Help here](https://www.evernote.com/shard/s71/sh/0634be49-4e4e-41b9-b216-185cfc52f9fa/51ea800023943498feefea3997c94332/deep/0/"activemodel--naming"-site-guides.rubyonrails.org---Google-Search.png)

The only reason we know about this is from searching the API docs, otherwise, we'd have no idea what this method is even suppose
to return.  Let's mix in `ActiveModel::Naming` and hope it does the right thing.

```ruby
class User
  extend ActiveModel::Naming

  # ...

end
```

We can now list users without an exception.   While the fix for this is easy, let's take a moment to understand what just
happened.

When we changed how we store our data, our views broke.

This is not a good feature of an architecture designed for scalability.  Let's keep going and try to create a user.

```
Started GET "/users/new" for 127.0.0.1 at 2014-05-18 16:49:21 -0400
Processing by UsersController#new as HTML
  Rendered users/_form.html.erb (1.0ms)
  Rendered users/new.html.erb within layouts/application (1.9ms)
Completed 500 Internal Server Error in 5ms

ActionView::Template::Error (undefined method `to_key' for #<User:0x007fe5cd429c48>):
    1: <%= form_for(@user) do |f| %>
    2:   <% if @user.errors.any? %>
    3:     <div id="error_explanation">
    4:       <h2><%= pluralize(@user.errors.count, "error") %> prohibited this user from being saved:</h2>
  app/views/users/_form.html.erb:1:in `_app_views_users__form_html_erb__2204836256017138651_70312483823140'
  app/views/users/new.html.erb:3:in `_app_views_users_new_html_erb__3362026653591844719_70312483916420'
```

A search of the API docs for `to_key` yields two locations.  One is in `ActiveRecord::AttributeMethods::PrimaryKey`, while the
other is in `ActiveModel::Conversions`.  If we didn't know better, we'd probably think to use the `ActiveRecord` one, because
that's what we're replacing.  That would be a mistake:

```
undefined local variable or method `sync_with_transaction_state' for #<User:0x007fe5d10c8d98>
```

`sync_with_transaction_state` must be private, because it doesn't show up in the API documentation.  A Google search reveals it
to be on the `ActiveRecord::Core` method, meaning `ActiveRecord::AttributeMethods::PrimaryKey` must depend on that somehow.  This
feels like a rathole, so let's try the other module that implements `to_key`.  

Remember, "Active Model" isn't documented in the
guides, and the module `ActiveModel` has no documentation.  We've been given no information about who is calling `to_key`, why,
or what is expected. Finally, the documentation for this module is "Handles default conversions: #to_model, #to_key, #to_param, and to_partial_path.".  We have no idea that we are converting anything, so we're flying blind by just throwing in code to make exceptions stop.

```ruby
class User
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  # ...

end
```

Sure enough, this gets us past our current issue, and we have a new problem:

```
Started GET "/users/new" for 127.0.0.1 at 2014-05-18 16:55:00 -0400
Processing by UsersController#new as HTML
  Rendered users/_form.html.erb (1.2ms)
  Rendered users/new.html.erb within layouts/application (1.8ms)
Completed 500 Internal Server Error in 5ms

ActionView::Template::Error (undefined method `persisted?' for #<User:0x007fe5d0aaf2e0>):
    1: <%= form_for(@user) do |f| %>
    2:   <% if @user.errors.any? %>
    3:     <div id="error_explanation">
    4:       <h2><%= pluralize(@user.errors.count, "error") %> prohibited this user from being saved:</h2>
  app/views/users/_form.html.erb:1:in `_app_views_users__form_html_erb__2204836256017138651_70312483823140'
  app/views/users/new.html.erb:3:in `_app_views_users_new_html_erb__3362026653591844719_70312483916420'
```

`persisted?` is implemented on both `ActiveRecord::Persistence` and `ActiveModel::Model`.  Since we now know better than to go
down the Active Record path, let's look at `ActiveModel::Model`, which sounds like what we've been looking for all this time.

> Includes the required interface for an object to interact with ActionPack, using different ActiveModel modules. It includes model name introspections, conversions, translations and validations. Besides that, it allows you to initialize the object with a hash of attributes, pretty much like ActiveRecord does.

Well, that sounds nice!  Let's give it a try.

```ruby
class User
  include ActiveModel::Model

  # ...

end
```

*Now* we can render the create user form.  Of course, going back to our index page reveals that we've broken something:

```
Started GET "/users" for 127.0.0.1 at 2014-05-18 17:03:14 -0400
Processing by UsersController#index as HTML
  Rendered users/index.html.erb within layouts/application (0.8ms)
Completed 500 Internal Server Error in 3ms

ActionView::Template::Error (No route matches {:action=>"edit", :controller=>"users", :id=>nil} missing required keys: [:id]):
    17:         <td><%= user.age %></td>
    18:         <td><%= user.favorite_color %></td>
    19:         <td><%= link_to 'Show', user %></td>
    20:         <td><%= link_to 'Edit', edit_user_path(user) %></td>
    21:         <td><%= link_to 'Destroy', user, method: :delete, data: { confirm: 'Are you sure?' } %></td>
    22:       </tr>
    23:     <% end %>
  app/views/users/index.html.erb:20:in `block in _app_views_users_index_html_erb__3553815775621370956_70312511258820'
  app/views/users/index.html.erb:14:in `each'
  app/views/users/index.html.erb:14:in `_app_views_users_index_html_erb__3553815775621370956_70312511258820'
```

A google search doesn't help, so let's dig into the source code.  This error is coming from `lib/action_dispatch/routing/route_set.rb`, specifically this method:

```ruby
def raise_generation_error(args, missing_keys) 
  constraints = Hash[@route.requirements.merge(args).sort] 
  message = "No route matches #{constraints.inspect}" 
  message << " missing required keys: #{missing_keys.sort.inspect}" 

  raise ActionController::UrlGenerationError, message 
end 
```

No help there.  Fortunately, I happen to know what might be the problem.  I happen to know that the url builders call `to_param`
on an object to figure out how to build urls, and going into console, I can see that any `User` object returns `nil` for
`to_param`.   This is because the default implementation is to call `persisted?` which returns false by default.  Figuring this
out would not be easy if you didn't already have some inkling of how this all works.

So, we override `persisted?` to return true if we have an id and we're back in business.

```ruby
class User
  def persisted?
    @id.present?
  end
end
```

Let's recap, again, what happened here.  

When we changed how we store our data, our views broke.

The reason is that `form_for` and the various URL builders rely very heavily on a lot of different methods scattered throughout
Rails.  Many, but not all, can be provided by `ActiveModel::Model`, but nowhere was it made clear—not even in error messages—what
the expectation was.  

Here's a diagram of the interactions we discovered:

![Uh](https://www.evernote.com/shard/s71/sh/a719fe39-b4a0-44e4-bba1-f279b636e56d/2b241d585d5306bffa5042e9e221d5d5/deep/0/Untitled-2.png)

Clearly, `form_for` and the url-builders expect the objects given to them to implement some interface.  In no way do they check
for that interface, rather they just blow up whenever the code gets there.  Although it's nice that `ActiveModel::Model` exists
and sorta does what we need, all of this feels like hacking private APIs.

And this is the conceit of Rails.  It *really* wants your models to be Active Record objects.  It wants this so bad that the
tools it gives you for generating HTML have an almost direct dependency on how you store your data.

What *this* means is that certain changes you need to make to your application or your overall architecture are made *very*
difficult by the application architecture Rails wants you to have.  And lets not forget how I hand-waved over the
re-implementation of ActiveRecord's enormous surface area.

So, we're left with a few questions:

## Is this scenario realistic or is it just a straw man?  

I've personally done this twice, and it was far worse than what I've shown
here.  We're talking months and months of grepping, production rollbacks, manual QA and log analysis.

It is *entirely* realistic that a business could grow to the point where data needs to be segregated, and that data might
be best made available via a non-SQL interface.  That such a decision might be impacted *because of how Rails generates HTML*
should give us pause.

## What do we do about it?

There's a very small part of this that isn't Rails fault.  Ruby doesn't have interfaces.  There's no easy or canonical way to
document what messages a given parameter is expected to handle, and so very few Ruby developers think in terms of interfaces.
That we only got `ActiveModel::Model` in Rails 4 proves this.

Because of this mindset and high coupling between areas of Rails, we are essentially doomed.  There's no reason that Rails power
around form handling and HTML generation needs to be coupled to ActiveRecord, but there's not really an alternative.  ActiveModel
is a nice effort, but it's clearly not something that's encouraged.

As _users_ of Rails, we're obviously required to learn something about the internals that we can't get from the documentation,
but we should carefully consider exactly *how* we are using Rails.  

Not every app going to scale in the same way, and no team can predict with 100% certainty *what* is going to need to scale or how
that might be done.  In a sense, you'd have to not use Rails at all to be absolutely sure.  But would we even get our work done
by re-implementing whatever parts of Rails we need?  Using homegrown solutions makes scaling your development team very
difficult.  Any Rails developer knows what `form_for` does. 

All this to say, that conversations about Rails flaws have to be OK to have.  It has to be OK to consider *not* using certain
features of Rails because the gains aren't worth the risk.  Just because we can't say with 100% certainty how a business will
scale doesn't mean we make decisions as if it will never happen.  If there's a very high chance we need to segregate our data,
then the decision to make heavy use of ActiveRecord is a risky one.

As individual teams working on our own business problems and applications to solve them, it *has to be OK* to establish
conventions around how to use Rails, and it *has to be OK* to evaluate the current situation and make decisions about it.  And it
*has to be OK* to enact those conventions, idioms, and decisions early in the development of an application.  

I guess this is a long way of saying that the phrase "premature abstraction" is nothing more than begging the question, and is in
no way an argument.
