--- 
title: Are private methods code smells?
layout: post
---

Having had discussions with co-workers on the utility of private methods and recently on the scala mailing list, there's been the notion that private methods (or even protected methods) are code smells -- indicators that there is something wrong with the design of your code.  I believe in many cases they can be, but that private (and protected) methods still have their uses, especially in maintaining a clean design under constraints of getting things done.  First, we need to know what we are talking about.

## Definitions

While the technical meaning of access modifiers varies with the language, the _intent_ these concepts communicate is what we're talking about here.  I assert that the _intent_ of public/protected/private is (and/or should be) as follows:

* _public_ - this method is part of the published API and will not change within major versions of the class
* _protected_ - this method is a hook for modifying the behavior of this class using subclasses.  It, too, will not change within major versions of the class.
* _private_ - this method was _refactored out of a well tested public or protected method_ for reasons of clarity or internal re-use.  This method may absolutely change, even in patch releases, and should not be relied upon to even exist
* _package private_ (bonus for Java) - I'm either lazy or ingorant, *or* I acknolwedge that this code should be pulled out into its own class, but haven't done so, yet still want to test it seperately, thus breaking encapsulation.

## Why would private methods be code smells?

The most concise argument is that private methods could indicate that the class that containst hem is doing too many things.  Consider this code from shorty, my URL shortener:

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
        throw new ServletException(dir.getAbsolutePath + " is not a directory")
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

This was a simple example.  Consider a class like [<code>SignedUrl</code> in my Gliffy Ruby client](http://github.com/davetron5000/gliffy/blob/master/lib/gliffy/url.rb).  This class has a fair number of private methods and, overall, is pretty large.  The private methods are vague things like <code>handle_params</code> and <code>get_signing_key</code>.  The private methods aren't really the problem, they are a symptom of the fact that this class is just doing too many things.  A better design would be split this class up into something like a <code>UrlParams</code>, <code>UrlSigner</code> and <code>UrlAssembler</code> (just off the top of my head).  The result would be more smaller classes, each with fewer public *and* private methods.




