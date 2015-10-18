---
layout: post
title: "What Dependency Injection Really Is"
date: 2013-01-07 08:55
comments: true
categories: 
---
Both [DHH][dhhpost] and [Tim Bray][timpost] make great points about "dependency injection" and its issues regarding Ruby and
testing.  My colleague [Adam Keys][adampost] makes a similar point, though doesn't call his anti-pattern "dependency injection".

The scare quotes are because neither DHH nor Tim are accurately representing the purpose of dependency injection.  Dependency
Injection is not about a framework, XML, factories, or testing.  It's about simplifying code.  Let's see how.

<!-- more -->

I'm going to ignore Rails for the moment, and just talk about designing classes in Ruby<a name="back-1"></a><sup><a href="#1">1</a></sup>.  Let's take the example
domain from [my previous post][dcipost], and expand it a bit.  We start with a class that implements purchasing logic:

```ruby
class PurchaseProcess
  def purchase_product(customer,product)
    customer.charge(product.price) if product.price > 0
    customer.invoices << Invoice.new(product)
  end
end
```

I've simplified things a bit, but basically we charge the customer, create an invoice, and add it to their invoices.  This class
gets used as part of the regular purchase flow of our website.  Suppose that we want to run a promotion such that, whenever
someone signs up for our mailing list, they get a free keychain.  They'll get this keychain the same as if they bought it, but
it's a special product with a price of zero, so they get it for free.

Let's make a class for this.

```ruby
class KeychainPromotion
  def sign_up_for_mailing_list(customer)
    MailingList.add(customer)
    keychain = Product.find("promo-keychain")
    PurchaseProcess.new.purchase_product(customer,keychain)
  end
end
```

This is straightforward, simple code.  We add the customer to the mailing list, find the promotional keychain, and "purchase" it.

What are the dependencies of this class?

* The `MailingList` object
* The `Product` object
* The `PurchaseProcess` object
* An instance of the `PurchaseProcess` class

Of those four dependencies, only three are directly related to the business process of our promotion. The `PurchaseProcess`
object is only needed to create an instance of that class so we can call `purchase_product` on it.  Let's inject this dependency
and see what happens.

```ruby
class KeychainPromotion
  def initialize(purchase_process)
    @purchase_process = purchase_process
  end

  def sign_up_for_mailing_list(customer)
    MailingList.add(customer)
    keychain = Product.find("promo-keychain")
    @purchase_process.purchase_product(customer,keychain)
  end
end
```

Our class is a bit longer, but it has fewer dependencies.  It also does fewer, things, making it more cohesive.  It's *only* about this promotion, and no longer about creating instances of a shared class.  If the way in which `PurchaseProcess` instances get created needs to change, we will not have to change this class, meaning its *fan out* is lower.  It is *simpler*, by any objective definition.

Other than simplicity, what are some advantages of this approach?

* We can use an alternate purchase process if we want.  Swapping purchase processes is certainly [YAGNI], but it's not hurting anything and it's a nice benefit.
* Flexibility in testing.  Since we no longer depend on the `PurchaseProcess` object, we have more options regarding how we test `KeychainPromotion`.  Before, our only option was to mock/stub `new`, but now we can just pass in anything that responds to `purchase_product`.  Our test will be simpler because of this.

Note that these are *side* benefits, not ends unto themselves.  Code that's easier to test isn't better because of that fact -
it's the other way around.  Code that's well designed is easier to test.  We have some [objective measures][codepost] of the
quality of code, and many of them lead to simpler testing.

This is the mistake that both DHH and Tim make in their posts - they assume that the reason for using dependency injection is to
make your code "easier" to test.  In DHH's (and Adam's) case, they rightly call out method-level injection as bad.  I would agree,
and, outside of the [mind-bending Scala collections framework][suicidenote], you don't see it much.  Tim asserts that DI is nothing but needless indirection, but that's not it at all.

Suppose we want to inject more dependencies into our `KeychainPromotion` class.  Let's replace the "hard-coded" dependency on
the `Product` object with an injected finder and see what happens.

```ruby
class KeychainPromotion
  def initialize(purchase_process,product_finder)
    @purchase_process = purchase_process
    @product_finder   = product_finder
  end

  def sign_up_for_mailing_list(customer)
    MailingList.add(customer)
    keychain = @product_finder.find("promo-keychain")
    @purchase_process.purchase_product(customer,keychain)
  end
end
```

Is this better?  We haven't reduced the *number* of dependencies on this class, even though we increased the complexity of the
constructor.  The `sign_up_for_mailing_list` method is also more complex because it now depends on a new ivar, `@product_finder`,
  which has a higher scope than a direct use of `Product`.  While it's true that `KeychainPromotion` is more flexible and we have more flexibility in testing it, we've made the code itself more complex.

I would argue that injecting this particular dependency is not an improvement, and that this code is worse than before.

Is that the fault of the *concept* of Dependency Injection? Of course not.  Dependency Injection, like any other pattern, technique, or tool, is only useful when it's used properly.  It's true that dynamic languages like Ruby provide many other tools that solve problems that Dependency Injection *can also solve*, and they often do it better.  But it doesn't mean that the entire
concept is worthless.

---

<footer class='footnotes'>
<ol>
<li>
<a name='1'></a>
<sup>1</sup>Rails <strong>is</strong> a container, and it manages our code for us, the same as Spring or Guice.  As such, coding "The Rails Way" has significant advantages that can outweigh those that we might see by using Dependency Injection<a href='#back-1'>↩</a>
</li>
</ol></footer>

[dhhpost]: http://david.heinemeierhansson.com/2012/dependency-injection-is-not-a-virtue.html
[timpost]: http://www.tbray.org/ongoing/When/201x/2013/01/06/Unit-testing-and-dependency-injection
[adampost]: http://weblog.therealadam.com/2013/01/03/design-for-test-vs-design-for-api/
[dcipost]: http://www.naildrivin5.com/blog/2013/01/02/dci-vs-just-making-classes.html
[YAGNI]: http://en.wikipedia.org/wiki/YAGNI
[codepost]: http://www.naildrivin5.com/blog/2012/06/27/what-is-better-code.html
[suicidenote]: http://stackoverflow.com/questions/1722726/is-the-scala-2-8-collections-library-a-case-of-the-longest-suicide-note-in-hist
