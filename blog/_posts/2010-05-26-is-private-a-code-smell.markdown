--- 
title: Are private methods code smells?
layout: post
---

Having had discussions with co-workers on the utility of private methods and [recently on the scala mailing list](http://scala-programming-language.1934581.n4.nabble.com/Just-curious-why-public-as-default-visibility-td2228941.html), there's been the notion that private methods (or even protected methods) are code smells -- indicators that there is something wrong with the design of your code.  I believe in many cases they can be, but that private (and protected) methods still have their uses, especially in maintaining a clean design under constraints of getting things done.  First, we need to know what we are talking about.

## Definitions

While the technical meaning of access modifiers varies with the language, the _intent_ these concepts communicate is what we're talking about here.  I assert that the _intent_ of public/protected/private is (and/or should be) as follows:

* *public* - this method is part of the published API and will not change within major versions of the class
* *protected* - this method is a hook for modifying the behavior of this class using subclasses.  It, too, will not change within major versions of the class (of course, it also might exist for code-reuse internal to the class hierarchy).
* *private* - this method was _refactored out of a well tested public or protected method_ for reasons of clarity or internal re-use.  This method may absolutely change, even in patch releases, and should not be relied upon to even exist
* *package private* (bonus for Java) - this method was written by someone lazy or ingorant, *or* by someone who acknowledges that this code should be pulled out into its own class, but hasn't done so, yet still wants to test it seperately, thus breaking encapsulation.

## Why would private methods be code smells?

The most concise argument is that private methods could indicate that the class that contains them is doing too many things.  Consider this code from shorty, my URL shortener:

{% highlight scala %}
override def contextInitialized(event:ServletContextEvent) = {
  event.getServletContext.log("Initializing our hasher/DB")
  val dirName = event.getServletContext.getInitParameter(
    ShortyServlet.DB_DIR_PARAM)
  if (dirName != null) {
    val dir = new File(dirName)
    if (dir.exists()) {
      if (dir.isDirectory()) {
        val hasher = URIHasher(DB(dir))
        hasher.start
        uriHasher = hasher
        event.getServletContext.setAttribute(
          ShortyServlet.URI_HASHER_ATTRIBUTE,uriHasher)
      }
      else {
        throw new ServletException(dir.getAbsolutePath 
          + " is not a directory")
      }
    }
    else {
      throw new ServletException(dir.getAbsolutePath + " doesn't exist")
    }
  }
  else {
    throw new ServletException("You must supply a value for " 
      + ShortyServlet.DB_DIR_PARAM)
  }
}
{% endhighlight %}

Is it totally clear what this method does?  If not, it basically checks that the directory configured for our database exists and is a directory, giving us a specific error message if not.  It's a bit long and full of error checking, so the meat where it creates our URI hasher and gives it to the servlet is somewhat obscured.  Here's a cleaned up version:

{% highlight scala %}
override def contextInitialized(event:ServletContextEvent) = {
  event.getServletContext.log("Initializing our hasher/DB")
  getDBDir(event) match {
    case Right(dir) => {
      val hasher = URIHasher(DB(dir))
      hasher.start
      uriHasher = hasher
      event.getServletContext.setAttribute(
        ShortyServlet.URI_HASHER_ATTRIBUTE,uriHasher)
    }
    case Left(errorMessage) => 
      throw new ServletException(errorMessage)
  }
}

private def getDBDir(event:ServletContextEvent) = {
  val dirName = event.getServletContext.getInitParameter(
    ShortyServlet.DB_DIR_PARAM)
  if (dirName != null) {
    val dir = new File(dirName)
    if (dir.exists()) {
      if (dir.isDirectory()) {
        Right(dir)
      }
      else {
        Left(dir.getAbsolutePath + " is not a directory")
      }
    }
    else {
      Left(dir.getAbsolutePath + " doesn't exist")
    }
  }
  else {
    Left("You must supply a value for " + ShortyServlet.DB_DIR_PARAM)
  }
}
{% endhighlight %}

We've added lines of code, but our public method is a lot clearer: we get the dir for our DB; if we get a "right", we have a usable dir, and if we get a "left" (the Scala convention for an error), we have the error message to use for our exception.

So, is <code>getDBDir</code> now a code smell?  This is a private method and, this  means that <code>contextInitialized</code> was tested and we extracted the private method as step three of the TDD "Test/Fix/Refactor" cycle.

Of course, <code>getDBDir</code> has nothing to do with the <code>ServletContextListener</code> and is really all about checking for a valid path.  So, we should extract it to a new class, right?

Well, if we *did* do that, we've now actually added a public API to our codebase.  Unless we make the new class completely private to the enclosing class, we've now introduced a new public class that must be tested and managed as part of our system's public API.

I don't see the benefit to doing that.  I don't particularly *want* this method to be in the public API (at least not *now*).  So, what about making it a private inner class?  That doesn't seem to be much different than what we have now, though it might save a few minutes on a future extraction.

## When IS this a code smell?

This was a simple example.  Consider a class like [<code>SignedUrl</code> in my Gliffy Ruby client](http://github.com/davetron5000/gliffy/blob/master/lib/gliffy/url.rb).  This class has a fair number of private methods and, overall, is pretty large.  The private methods are vague things like <code>handle_params</code> and <code>get_signing_key</code>.  The private methods aren't really the problem, however; They are a symptom of the fact that this class is just doing too many things.  A better design would be to split this class up into something like a <code>UrlParams</code>, <code>UrlSigner</code> and <code>UrlAssembler</code> (just off the top of my head).  The result would be more smaller classes, each with fewer public *and* private methods.

## What about protected methods?

In Ruby, you don't see a lot of protected methods.  In well-designed Java frameworks (such as [Spring](http://www.springframework.org)), you'll see them as I've described above: hooks into a helper class that allow you to customize how that class behaves via subclassing.  In non-library code, protected methods tend to get used for code-reuse in narrowly-focused class hierarchies.  For example, the project I'm working on has a <code>BaseController</code> that provides common methods to the actual web controllers.  Having used protected methods for both of these purposes, I think that, honestly, both _can_ be code smells.  

### Protected methods as hooks

In the case of providing "hooks", I think it's clear that by providing them at all, you are acknowledging that your class _might_ be poorly designed (or that your language lacks the expressiveness to better design it).  Consider the venerable (and now deprecated) [<code>SimpleFormController</code>](http://static.springsource.org/spring/docs/2.5.x/api/org/springframework/web/servlet/mvc/SimpleFormController.html), a Spring MVC class that provides *many* protected-method hooks, one of which is <code>protected Map referenceData(HttpServletRequest request)</code>.  This is called during the lifecycle of the controller to get any data needed by the form that should be available to the view (for example, a list of U.S. states from the database).  Your subclass of <code>SimpleFormController</code> overrides this to provide the data as a map.

Why not create an interface called <code>ServletRequestToReferenceData</code> that contains this method, and inject an instance into <code>SimpleFormController</code>?  This would be very Spring-like.  My guess as to why this *isn't* the case is that there is simply too much overhead in making yet another one-method interface and the designer of <code>SimpleFormController</code> just felt this was a reasonable tradeoff.

In Scala, however, this could simply take a function:

{% highlight scala %}
  def referenceData[A]((HttpServletRequest) => Map[String,A]);

  // ...


  controller.referenceData{ request => 
    // create our map based on the request
  }
{% endhighlight %}

In Ruby, the overhead of creating a new class isn't nearly as onerous, and we could still inject a block as we do in Scala.

Ultimately, I would say that you have to make a tradeoff here, and it *has* to take the language and frameworks into account; a class with many, many hooks might be a code smell, but using it as a means to avoid language ceremony in the name of OO purity is probably a reasonable design tradeoff.

### Protected methods as code sharing

This use of protected methods is harder to justify, but incredibly handy.  Still, this could be another case of Java (e.g.) not providing the necessary language features to make class extraction more straightforward.  As mentioned, in my current application, I have a <code>BaseController</code>.  It has a helper method as follows:

{% highlight java %}
protected Person getAndValidateLoggedInPerson() {
  Person p = this.personService.getPerson(
    this.authenticationService.loggedInUserId());
  if (p == null) {
    throw new NotFoundException;
  }
  return p;
}
{% endhighlight %}

Because of Spring MVC, we have specialized exceptions for HTTP errors, such as "NOT_FOUND".  Here we contain the logic to identify the id of the logged-in person as well as the check for existence.  Having this available to all controllers in the entire system is very handy.

But, is this a code smell?

We could make a class that does this, turning this code:

{% highlight java %}
Person p = getAndValidateLoggedInPerson();
{% endhighlight %}

into this:

{% highlight java %}
Person p = this.personValidatorAndGetter.getPerson();
{% endhighlight %}

creating a one method class that has many lines of injected dependeicies and other boilerpalte with a few actual lines of code.

I think this is yet another case of pragmatically dealing with language ceremony.  In Scala or Ruby, the overhead of creating re-usable bits of code like this is far lower than for Java; In Scala one could envision a simple function, possibly with some implicit parameters.   Ultimateley, "too much" of this sort of thing *should* be a code smell, but small bits of this, in the name of simplicity, clarity, and simply keeping the codebase smaller isn't an automatic red flag.

## Conclusions

So, are non-public methods code smells?  If we take the [wikipedia definition](http://en.wikipedia.org/wiki/Code_smell), which is clear that a code smell indicates merely the _possibility_ of deeper problems in your code, then, yes, private and protected methods *are* code smells.

But, should they be avoided at all costs?  Absolutely not.  There's many valid reasons to use them, and they do not deserve the blame for an ill-concieved class.  Coding in the real world is about tradeoffs; we have to do the best thing we can with the time, resources, and tools at our disposal.  These tradeoffs may not result in an [According-to-Hoyle](http://en.wikipedia.org/wiki/Edmond_Hoyle) OO (or functional) design, but we're not writing code to provide examples of programming paradigms or design patterns; we're writing it to accomplish something and provide value.  And, as professionals, we need to do it at a predictable rate that doesn't incur too much technical debt.
