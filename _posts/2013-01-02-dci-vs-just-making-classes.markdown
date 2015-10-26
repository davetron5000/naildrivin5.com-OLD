---
layout: post
title: "DCI vs Just Making Classes"
date: 2013-01-02 15:11
feature: true
---

There's been lots of talk about [DCI] in the Ruby community lately.  As I mentioned, I am only partway through Jim
Gay's [unfinished book on the subject][cleanruby], but I ran across a blog post that had a more substantial example in it.

Titled [Why DCI Contexts?][whydci], someone named [rebo], shows a starting point of "normal" code, then "DCIzes" it, then walks through adding new features to the system.  It's a bit long, but his explanation is great, and it shows a *lot* more than just calling `.extend` on an object - he clearly demonstrates how roles and contexts are used to implement specific use cases.

Despite the deftness of his explalnation, I find the result code entirely too complex, thanks to confusing abstractions, a
needless DSL and leaky abstractions.  It would all have been a lot simpler if he Just Used Classes&reg;

Let's see why.

<!-- more -->

In rebo's post, he has a basic domain of a `User`, a `Product`, an `Invoice`, and `Accounts` (which groups invoices).  The classes he creates for them are reasonable structs - they just hold data and have no real methods.  He then shows the implementation of a basic use case - when someone buys something an invoice is created and added to their accounts.  Here's the code.

```ruby
class PurchasingProcess
  include AliasDCI::Context
  def initialize(user, product, accounts)
    assign_named_roles(:customer            => user,
                       :selected_product    => product,
                       :accounts_department => accounts)
  end

  def call
    in_context do
      customer.buy_product
      accounts_department.generate_invoice
    end
  end

  role :customer do
    def buy_product
      purchases << selected_product
    end
  end

  role :selected_product do
    def invoice_desc
      "#{name} - #{description} @ #{price} ea."
    end
  end

  role :accounts_department do
    def generate_invoice
      invoice =  Invoice.new(customer.address, selected_product.invoice_desc, total )
      invoices << invoice
    end
  end
end
```

My first thought looking at this was "WTF?"  This is *entirely* too complex for the task at hand.  It looks like it would be hard
to write, hard to test, and hard to read (not to mention [hard to execute][tonypost]).

Why?

Let's start with the definition of `call`, and let's assume that we understand that `in_context` runs the code inside our "DCI
Container" that enables the DSL.  This is a big assumption, but I'll make it.  The first call:

```ruby
customer.buy_product
```

What is `customer`?  Where is it defined?  I see no method with that name.  I'll need to understand that the hash given to
`assign_named_roles` renames the object given to the constructor.  OK, what about `buy_product`, the method that's being called?

It's not a method on `User`, so I'll need to hunt down inside my class to find a definition, making sure to note if it is, or
is not, defined inside a `role :customer` block - presumably I could do `role :foobar` and define a method `buy_product` and that
would *not* be what I'm looking for.

Looking at that method, I see that it's mutating an array called `purchases`, giving it the value of `selected_product`.
`purchases` is *not* a role, nor was it passed to `assign_named_roles`, so where is *it* coming from?

Turns out, it's an attribute of `User` and that the method definition we are reading is being executed inside the binding of the `User` instance passed to the constructor.  Finally, we see that that `selected_product` *is* a role, an instance of `Product`.

One line down, one to go.  Whew!

```ruby
accounts_department.generate_invoice
```

Again, we confirm that `accounts_department` is not a method defined locally, but is an instance of `Accounts` set up in the constructor. The method `generate_invoice` is a method defined at the bottom of our class presumably added to the `Accounts` instance by the DSL.  As before, `invoices` is an attribute of `Accounts`, and our method is executing inside that binding, which we just have to remember to piece together.

And this is for a *two line method* in a *very simplified domain*.  Exactly **how** is this supposed to make my job of reading
and writing code easier?!  And how the heck do we test all this?  *More* DSLs?

rebo states his case for this complexity and insanity by showing some "fat model" code as well as some unscoped "glue code" that
implements this use case.  This code is, indeed bad, too.  It puts logic on the models that really don't belong there.  Can we do better?  Yes.

```ruby
class PurchasingProcess
  def purchase_product(customer,product,accounts)
    customer.purchases << product
    invoice_desc = "#{invoice.name} - #{invoice.description} @ #{invoice.price} ea."
    accounts.invoices << Invoice.new(customer.address,invoice_desc, invoice.total)
  end
end
```

Yup. Instead of bringing in a complex framework, confusing monkeypatching, and dynamic methods created in non-obvious bindings, I
just *made a class* that implements the *business logic*, and write the requisite three lines of code.

I didn't have to change the core business objects, nor should I have - the format of `invoice_desc` is, so far, particular to
this use case, and needn't be part of the `Invoice` class.  To understand this, we don't need to leap too far: the `customer` is a
customer that we know contains `purchases`.  We add the passed `Purchase` instance, `purchases`, to that, then construct a
description of the invoice before adding a new invoice to the `accounts` instance we were given.

The method that implements our business logic is all based on parameters or local variables - there is no global or class-level
state to worry about, and each object is named for the type of class it is - no need to mentally translate when reading the code.
Assuming you understand what the core domain objects are, you can read and comprehend this entire business process on a VT100
terminal (if you had to).

If this business process needs to get more complex, we can use method extraction as a first step to fight complexity, and could
just *make more classes* if it gets worse. If it turns out that *another* business process needs to share some of this logic *by
design*, we can just apply [other methods of re-use][reusepost] to deal with it then.

So, what is so wrong with this that we need some complex container to manage what should be just a few lines of code?  I do not
know.  I'm willing to concede this as a straw man argument, to a certain degree, but I'm still waiting to see how DCI is an
improvement over basic structured programming.

[whydci]: http://rebo.ruhoh.com/why-dci-contexts/
[DCI]: http://en.wikipedia.org/wiki/Data,_Context,_and_Interaction
[cleanruby]: http://clean-ruby.com
[rebo]: http://rebo.ruhoh.com/about/
[tonypost]: http://tonyarcieri.com/dci-in-ruby-is-completely-broken
[reusepost]: http://www.naildrivin5.com/blog/2012/12/19/re-use-in-oo-inheritance.html
