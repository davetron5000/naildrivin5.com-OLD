--- 
title: In "Offense" of Scala's Option class; a guarded defense of Cédric's rant
layout: post
---

In a [recent blog entry][cedricoption], Cédric Beust calls out scala's <code>Option</code> class as nothing more significant than null checks.  Commenters rightly set him straight that the thesis of his blog post was marred by an ignorance of idiomatic use of the class.

But, it's hard to really blame Cédric, when you look at what he had to go on.  Odersky's book states that one should use pattern matching with <code>Option</code>, and the scaladoc for Option is just abysmal:

> This class represents optional values. Instances of Option are either instances of case class Some or it is case object None.

That is the *entire* description of the class, no examples, nothing.  Worse, the method that commenters called out as idiomatic, <code>flatMap</code>, has the following description:

> If the option is nonempty, return a function applied to its value. Otherwise return None.

This is *not* what <code>Option#flatMap</code> actually appears to do (nor is documented to do; it's documented to return an <code>Option[B]</code>!):

{% highlight scala %}
scala> val s:Option[String] = Some("foo")
scala> val n:Option[String] = None
scala> val f = { (x:String) => Some(x + "bar") }
scala> s.flatMap(f)
Some(foobar)
scala> n.flatMap(f)
None
scala> val result = s.flatMap(f)
r: Option[java.lang.String] = Some(foobar)
scala> r.getClass
res6: java.lang.Class[_] = class scala.Some
{% endhighlight %}

It certainly doesn't call itself out as "the way" to use Option.  A simple example in the scaladoc could have gone a long way.

So, angry post + helpful commenters == problem solved, right?

Wrong.

The <code>Option</code> class is, really, an implementation of the [NullObject][nullobject] pattern, and a more elegant way to handle optional values.  In scala, we might have this method signature:

{% highlight scala %}

/**
 * Updates the full name
 * @param lastName the last name
 * @param firstName the first name
 */
def updateName(lastName:String, firstName:Option[String])

{% endhighlight %}

This means "update my name; lastName is required and firstName is optional".  In java, this method might look like this:

{% highlight java %}
/**
 * Updates the full name
 * @param lastName the last name, may not be null
 * @param firstName the first name, may be null
 */
public void updateName(String lastName, String firstName) {
    if (lastName == null) {
        throw new IllegalArgumentException("lastName required");
    }
    StringBuffer b = new StringBuffer(lastName);
    if (firstName != null) {
        b.append(", ");
        b.append(firstName);
    }
    this.fullName = b.toString();
}
{% endhighlight %}

So, what's the right way to do it in Scala?  According to the commentors:

{% highlight scala %}
def updateName(lastName:String, firstName:Option[String]):Unit = {
  val b = new StringBuffer(lastName)
  firstName.foreach( (name) => b.append(", "); b.append(firstName) )
}
{% endhighlight %}

Yech.  Does anyone else think that calling a method called "foreach" on our "optional value" is just nonsensical?  Or that the *idiomatic way* to treat an optional value is *as a collection*, e.g. by using the <code>for</code> comprehension?  This just feels hacky.  Naming is one of the most important (and challenging) things in software engineering, and <code>Option</code>'s API is an utter failure (even its name is wrong; when one has _an option_, one typicaly has many choices, not just one or nothing.  _Optional_ is really what is meant here, so why are we afraid of adding a few more letters?  Especially given how "precise" some of the documentation is, mathematically speaking, why are we not being precise with English?). If <code>Option</code> is just shorthand for a "list of zero or one elements", and we get no better methods than what comes with <code>List</code>, then what's even the point of the class?

I'm not saying we remove all the collection methods from <code>Option</code>, but how about a throwing us a bone to make our code readable and learnable without running to the scaladoc (or REPL) to see what's going on?  I mean, there's a method on <code>Option</code> called <code>withFilter</code> whose documented purpose (I'm not making this up) is: "Necessary to keep Option from being implicitly converted to Iterable in for comprehensions".  Am I expected to believe that it's ok to have *this* hacky pile of cruft, but we can't get a readable method for "do something to the contents if they are there"?

{% highlight scala %}
class Option[A] { 
  def ifValue[U]( f: (A) => U ):Unit = foreach(f)
  def unlessValue[U]( f: () => U):Unit = if (self.isEmpty) f
}

def updateName(lastName:String, firstName:Option[String]):Unit = {
  val b = new StringBuffer(lastName)
  firstName.ifValue( (name) => b.append(", "); b.append(firstName) )
}
{% endhighlight %}

Which would be less surprising?  Couple this with some better scaladoc:

{% highlight scala %}
/** This class represents an optional value.  
 *
 * To use as a null object:
 * val optional = getSomePossiblyOptionalValue
 * <pre>
 * option.ifValue { (actualValue) => 
 *   // do things with the value, if it was there
 * }
 * </pre>
 * or
 * <pre>
 * optional.unlessValue { log.debug("missing optional value") }
 * </pre>
 * 
 * To use as a Monad or collection:
 * <pre>
 * val first8upper = option.flatMap( (y) => Some(y.toUpperCase) ).
 *                          flatMap( (y) => Some(y.substring(0,8)) )
 * </pre>
 */
class Option[T] {
  // etc.
}
{% endhighlight %}

With these examples, you cover the two main uses of this class, show newcomers how to use it, and demonstrate its superiority over null checks.

It's frustrating to see this, because Scala has so much potential to be a lucid, accessible, readable language, but API usability and learnability are just not prioties.  Scala needs to take some lessons from Ruby in terms of API design (and Java in terms of API documentation).

Of course, none of this *does* save you from null, because Scala is perfectly happy to assign null to anything.  It kinda makes the whole thing seem a bit pointless.

[cedricoption]: http://beust.com/weblog/2010/07/28/why-scalas-option-and-haskells-maybe-types-wont-save-you-from-null/
[nullobject]: http://en.wikipedia.org/wiki/Null_Object_pattern
