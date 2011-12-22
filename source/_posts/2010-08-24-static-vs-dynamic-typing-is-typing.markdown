--- 
title: "Static vs. Dynamic Typing: A matter of keystrokes?"
layout: post
---

In Java, I almost *never* make type errors.  The type errors that are possible in Java fall roughly into two categories:

1.  Using an object of the wrong type (this is caught by the compiler)
2.  Casting an object to a more specific type at runtime (this can only be caught by tests or users :)

I'd make error #1 on occasion, but the compiler catches it.  As to #2, before generics, I can count on my hands the number of times I got a bona-fide <code>ClassCastException</code> at runtime.  After generics?  Never.  

I don't mean just that I didn't experience these runtime type errors, but that they *didn't even make it to the compiler*.  If you think about how Java syntax works, it's no wonder:

{% highlight java %}
List<String> someList = new ArrayList<String>();
someList.add("Foo");
someList.add("Bar");
{% endhighlight %}

I had to type almost the exact same thing twice.  After about 2 days of using generics, my muscle memory literally *prevents* me from making type errors.  To even simulate one requires a pre-generics library call, or some herculean efforts.  An arguable win for static typing, if at the price of verbosity.

Of course, in Ruby, I make type errors all the time, especially when using new libraries I'm not familiar with.  Ruby libraries rarely document the types of things (though they are frequently liberal with what they will accept).  The solution here is just better unit tests.  And that's a pretty good thing.  So, a slight negative for dynamic typing that leads us to a better tested system, reduced verbosity, and better productivity once the learning curve is dealth with.

This pretty well illustrates the tradeoffs between dynamic and static typing.  Case closed, right?

Enter Scala.  With Scala, I make type errors just as much as I do with Ruby.  The only difference is that the compiler catches them.   Here's the Scala equivalent to the Java code above

{% highlight scala %}
var list = List("foo","bar")
{% endhighlight %}

Notce how I haven't specified a *single* type?  It's nearly identical to the Ruby version:

{% highlight ruby %}
list = ["foo","bar"]
{% endhighlight %}

These examples are obviously simplistic, but in a more complex system, Scala's type inferencer tends to be one
step ahead of me.  While it's handy that I have a compiler to catch these type errors, the fact remains that, despite Scala being a statically typed language, *I'm making far more type errors than I would in Java*.

This seems kindof odd, but I think it's ultimately a win: I get the brevity and productivity of a dynamically typed language, but the safety of the compiler catching my type errors for me.

Scala puts a subtle spin on the "static vs. dynamic" debate, because you aren't annotating your types *nearly* as much as with Java, but you still get all the benefits.  I've certainly heard many criticisims of static typing, but having the compiler check types for you wasn't one of them.

Of course, sometimes you *do* need to tell Scala what your types are, but, they seem to be exactly where you'd want them anyway:

{% highlight scala %}
/** get users with the given name and age */
def getUsers(name:String,age:Option[Int]):List[User]
{% endhighlight %}

This says that we take a requires <code>String</code> and an optional <code>Int</code> and will return a list of <code>User</code> objects.  To give the same information in Ruby, you'd need to:

{% highlight ruby %}
# Gets the users with the given name and age
#
# name - a String
# age - an Int or nil if not searching by age
#
# Returns an array of User objects
def get_users(name,age=nil)
    ...
end
{% endhighlight %}

_(Sure, you could leave off the comment, but do you really hate your fellow developers (*and* future you) that much?)_

*Now* which language is more verbose?  Perhaps the static/dynamic typing debate is really just about entering text?
