---
layout: post
title: "&#10106;&#10144; Production is all that matters"
date: 2013-06-16 12:53
comments: true
categories: 
---
This is important.  It has to do with your treatment and reaction to how your software runs in production. How your software runs in production is **all that matters**.  The most amazing abstractions, cleanest code, or beautiful algorithms are meaningless if your code doesn't run well on production.

If you have no way to understand how your code runs in production, you are more typist than engineer.  It's not necessarily your fault - many organizations don't allow developers any real access to production - but you need to do something about it, and I'm gonna show you how.

<!-- more -->

Let's get a few terms straight:

* *Production* - the environment where your app runs and users are using it.  It could be a server, or a series of servers, or a browser, or an iPhone, or a desktop computer.
* *Access* - access isn't necessarily a login to the production server.  Access means you have the ability to observe aspects of how your application is running: logs, performance, statistics.  It could include the ability to easily make changes to production, but doesn't necessarily need to.
* *Error* - anything that goes wrong on production.  Anything from excessive 404s, to a 500, to bad data, to a crash, an error is something that happens on production that your application is unable to handle.

Here's how we're gonna attack this problem:

1. Understand why handling production errors is important
2. Learn to detect production errors
3. Learn how to fix production errors
4. Starting writing code to avoid production errors

## Why handling production errors matters

Your application serves a purpose.  It meets the needs of its users.  When it encounters a problem, it fails to meet that need.  When your application fails to meet the need of a user, revenue could be lost.  In other words, when your application experiences a failure, you are putting the business at risk.

Let's take an example.  Suppose that every time a user signs up, they must activate their account by clicking on a link sent by an automated email from your application.  Suppose a user signs up and, at the exact moment the welcome email is to be sent, there is a network error and the email isn't sent.

The user will never get their activation email unless steps are taken.  If no steps are taken,
this customer won't use your service, which means you aren't making money from them.  This user *could* have
been a happy customer, even one that was an advocate for your company, one who could drive
many more customers to you but, because of an un-handled error on production, we'll never
know.

Now, this customer could call up customer service and ask why they didn't get their sign-up
email?  Customer service could manually activate them, but this has a cost, too.  Handling this
means not handling something else. If it piles up, you'll need more customer
service people and that costs money.

All because a very basic production error wasn't handled.

<div class='has-pullquote'>
You may think that a few missing users won't matter in the grand scheme of things.  That's bad customer service, but it's also foolish and lazy thinking.  Every customer matters.  Someone wants to pay the company money, your job as a developer is to  <span class='pullquote'> make sure there's no software standing in their way </span> .  And don't think it doesn't matter for internal users.  If their jobs are inefficient because of buggy software, they will cost more, and the business will be less successful.
</div>

Dismissing errors like this sets a dangerous precedent.  You must begin to make judgement calls.
Which production errors *matter*?  How many failures is "too many"?  How much loss of revenue/increase in cost is it OK for the engineering team to create before something needs to be done?

I'm here to tell you that *all* failures matter, *one* is too many, and that the engineering team should not tolerate loss of revenue or increased costs due to software issues.  Engineers are paid a lot of money to solve problems, and should treat losses in revenue seriously.

The way we do that is by detecting, handling, and preventing errors in our production
applications.

The way to do **that** is to build fault-tolerant software.  This means thinking a bit harder
about what you're doing than maybe you would otherwise.  This means being a bit more paranoid
about what might happen.  Mostly, however, it means gaining an understanding of how your
application behaves in production, and making it a priority to improve its behavior.

The first step to fault-tolerant software is to detect errors in production.

## Detecting production errors

A software application is nothing more than a complex input/output device.  Information comes in, processing happens, and output is returned.  Inexperienced developers primarily focus on input from and output to the software's users.  You need to do more.  You need, at the very least, some output that is just for you, the developer, to understand how the software is running.

The most basic developer-targeted output is the application log.  

### Your Application Log

Making use of this log requires two things:

* Sensible & judicious logging of useful information throughout your application
* A searchable, durable location for those logs

#### Useful logging messages

Your log statements should have, at a minimum:

* **Timestamp**
* **Severity** (error/warning/info/debug)
* **Process identifier** - this allows you to know which messages come from which servers and processes
* **Request identifier** - this allows you to associate multiple log messages with a particular request.  Often, your web server can handle this, although you could use the currently-logged-in user id as a proxy.
* **Some information** - a description of what you'd like to know if things go wrong.  Likely, you'll want database identifiers and descriptions of what is happening or why.

<div class='has-pullquote'>
 <span class='pullquote'> Log every request and what the response was </span> , along with anything else that's relevant to what went on during the request.  Log edge cases in your logic, warnings, or other events that are outside the "happy path".  You might also log the results of complex calculations whose results are important (i.e. show your work).
</div>

Don't worry about performance - you can remove logging if you need to, but your primary duty is to understand how your application is working, and the log is a great place to do that.

These logs must be aggregated somewhere where, at the very least, you can `grep` them.  

#### A searchable location for logs

Without the ability to search logs, they are useless.  If they are sitting on a disk you have
access to, open up the man page for `grep` and have at it.  More likely, you'll need them in some
sort of log aggregator like Splunk, Loggly, or PaperTrail.  These allow sophisticated searches in
a web interface.

The main advantage of these systems over `grep` is that you can easily share log results with
others, including nontechnical but technically-minded folks who may be involved in diagnosing a
production error.

Your log aggregator can also be hooked into your second developer output stream, which is
alerting.

### Alerting

Alerting is a push notification that an event has occurred that requires some action.  

If you do not fully comprehend every piece of that sentence, you will have bad alerting, and your
ability to detect and fix production errors will be severely hampered, so let's break down each
part of it:

* *push notification* - you get an email, a popup, an SMS, a page, a siren, whatever.  Something you can't ignore that is sent to you.  This isn't something you must remember to check.  The form might be related to its severity (e.g. the site being down might page you, but an un-handled exception will email you).
* *an event has occurred* - something has happened that shouldn't have.  This could be a particular branch of complex logic (e.g. `// this should never happen`), or it could be the result of an external process checking for system invariants.  
* *requires some action* - because of this event, you must take action or loss of revenue/increase in cost will occur.  This means that you don't alert on non-actionable events.  By all means log them, but do not alert if no action needs to, or can, be taken.

For proper alerting, you need three things:

* A system to manage sending and cataloging alerts
* A way in your application code to trigger an alert
* A way to trigger alerts from outside your application code

An example of an alerting system is Airbrake.  Another example is `/bin/mail`.  You might need multiple systems. For example, you may use Pager Duty for application alerting, but use PingDom for general website availability alerting.  The fewer the better, but you need all alertable events covered.

Triggering an alert depends on the system you are using, but, at the very least, you need a catch-all exception handler that triggers an alert whenever an exception occurs that your code doesn't handle.

Finally, you need an easy way to write monitoring scripts that trigger your alerting system.  This is because you should start writing scripts that assert invariants about your environment, and alert when those invariants are no longer true.

For example, your database might store records of customer purchases.  You might further store, for successful purchases, what the credit card authorization code was.  If you have a successful purchase, but no credit card authorization code, something is wrong.  That should never happen.

You should then write a script that checks all successful purchases for an
authorization code - any purchase that has been in a successful state for more than, say, a few minutes, but that doesn't have an authorization code, should trigger an alert.  Someone might be getting something for free.  Loss of revenue.

<div class='has-pullquote'>
One final note:  <span class='pullquote'> do not ignore alerts </span> .  If you are filtering out or ignoring alerts, you are
not doing your job.  You are ignoring your system telling you that you might be losing revenue.
If you have so many alerts that you are overwhelmed with them, you either have a terrible system, or you are alerting for non-actionable things.  Fix those issues before reaching for your email filters.  Fix them before adding features, because your business is starting to tank.
</div>

There is a third output stream, and it's related to the aggregation of non-alertable system
events.  For example, a 404 is not an alertable event, however 5,000 over the course of 2 minutes
might be.  You need statistics.

### Application statistics

Application statistics represent a set of vital signs for your application.  They indicate, at a
high level, what's going on.  Such statistics might be the number of 404 response, the number of
broken builds, the number of purchases made, or the number of user logins.  Anything and
everything.

To set up this output stream, you need three things:

* A system to manage your statistics
* A way to send statistics to this system from your application without negatively impacting performance *or* causing production errors
* A way to send statistics from outside your application code

A common tool for managing statistics is Graphite.  A common tool for sending them is Statsd.
You could also use specially-formatted log messages and `grep`.

With these tools, you "stat" information inside your application, and write external scripts that
run periodically to stat other things as well.  The more the merrier, because you don't know what
you're going to need.

Note that this isn't like tracking website activity, conversions, or A/B test results.  Those
things are important, but they are not what we're talking about.

Once you have some statistics set up, you can then observe your application's "rhythm" over time.  Hopefully, you'll see a "normal" usage pattern.  For example, at Stitch Fix, I can see a spike in processing returned merchandise every day when the USPS truck arrives at our warehouse.

Once you have *this*, you can then **alert** if certain statistics are out of whack.  This is definitely "Advanced Band", but can be really useful.  For example, if you see a drastic drop in purchases, or a spike in CSR tickets - something's wrong.

Now that we know how to identify these problems, the next step is how to fix them.  And fix them, we must.

## Fixing production errors

Production errors must be addressed immediately.  There are two reasons for this:

* It eliminates any judgement from your remediation procedure - production errors can lead to a loss of revenue or increased costs, so addressing them should be your highest priority.
* When fixing production errors interrupts your workflow, you eventually learn to write more fault-tolerant code, so that you have fewer production errors to interrupt you.  We'll get to that in the next section.

How do we address production errors?  It depends on the error, but I have a few rules of thumb:

* If the error is continuously happening, drop what you are doing and fix it.  The most common
example is rolling out a new version of the app to production, and things start breaking.
Rollback and stop the bleeding.
* If the error is a "one off" and has a clear remediation procedure (e.g. re-trying a background
job that failed due to intermittent issues), perform the procedure immediately.
* If the error is transient but has no obvious remediation procedure, you'll have to investigate:
  * Is the state of the system now invalid, e.g. bad data in the database?
  * What was the user's experience?  Is there some intent that we can capture and manually address? (for example, a customer makes a purchase, but the system fails - we could re-make that purchase on their behalf to ensure capturing the revenue)
  * Can the code that broke be enhanced to avoid this problem?  If so, do it.

<div class='has-pullquote'>
Your results might be different, but understand the theme here: restore service and then put the system back into a valid state.  ** <span class='pullquote'> Do not stop until the problem is fixed </span>  or you've handed it off to someone who will follow this rule**.  Sometimes, it takes a while to recover from a production error.  When you need a break, hand it off, but do not stop.
</div>

We had a problem once at LivingSocial where thousands of attempted purchases failed due
to issues with our promo code back-end service.  The users were all left with the impression they'd made a successful purchase discounted by the promo code they provided.  Because of proper logging and alerting, we saw the problem, fixed the systems so it would stop happening, and then re-created all the customer purchases behind the scenes without them ever knowing it.  We protected the revenue.

Reacting to buggy software is no fun.  The second reason we fix production errors immediately is to motivate us to write more fault tolerant software.  We want to avoid production errors entirely.

## Avoiding production errors

Networks are flaky.  Third-party APIs have bugs of their own.  These cause production errors, and
you *can* manually fix them.  But, flakiness and intermittent failures can be normal.  It's
entirely possible that your shipping vendor's API will never behave properly, and will always be
slow or non-responsive.  This means that your code is not handling normal, expected behavior.

Your alerting and history around production errors should be your guide to where to start
enhancing the fault-tolerance of your software.  Root-cause analysis will usually lead you to
where you want to start.

Let's take an example.  Suppose you have a background job that charges customers a monthly fee for your service:

```ruby
class MonthlyFeeChargingJob
  def self.perform(customer_id)
    customer = Customer.find(customer_id)
    charge_amount = MonthlyCharge.for_customer(customer)
    result = ThirdPartyCreditCardGateway.charge(customer_id,charge_amount)
    if result.declined?
      ChargeFailedMailer.mail(customer_id,result)
    end
  end
end
```

We handle the two expected cases: a successful charge, and a decline.  Suppose, though,
that every once in a while we get a "connection refused" exception from the call to `ThirdPartyCreditCardGateway.charge`.  This is a production error.

We fix it by re-trying the job, since the network is likely working and, in that case, the job succeeds (remember that the _job_ succeeds when it completes execution, regardless of the result of charging the customer).  This happens enough that we no longer want to fix it manually.  How can we make this code more fault-tolerant? 

Occasional network blips happen, and usually go away quickly, so we can simply automate the
manual retry procedure.

First, our job will take an optional argument to indicate how many retries there have been.  This
allows us to break out of the retry loop in the event of a serious and lengthly network outage.
Next, we catch the particular error and perform the retry (making sure to log what is going on in
case we need to investigate).

```ruby
class MonthlyFeeChargingJob
  def self.perform(customer_id,num_attempts=0)
    customer = Customer.find(customer_id)
    charge_amount = MonthlyCharge.for_customer(customer)
    begin
      result = ThirdPartyCreditCardGateway.charge(customer_id,charge_amount)
      if result.declined?
        ChargeFailedMailer.mail(customer_id,result)
      end
    rescue NetworkError => ex
      logger.warn("Got #{ex.message} charging #{customer_id}, #{charge_amount}")
      if num_attempts < 5
        perform(customer_id,num_attempts + 1)
      else
        raise
      end
    end
  end
end
```

Note that we are only rescuing one type of error from the one line of code that's causing the
problem.  This prevents us from applying the wrong fix to other errors that might happen (for
example, if we caught all exceptions, and the `ChargeFailedMailer` raised one, we could
potentially charge the customer a second time by retrying this job.  Not good).

I'll leave it as an exercise to the reader as to what happens here (and how to fix it) if we get a timeout, instead of an outright refusal (hint: loss of revenue due to potential lawsuits).

The key to fault-tolerant code is to take a step back from your code and re-cast the concept of success.  Many devs conflate non-happy-path code with actual errors.  Any time you see an API that uses exceptions for control flow, you can be sure the developer of that API doesn't understand the difference. 

<div class='has-pullquote'>
A "negative case" in business logic is normal - it is a success when it happens.  Failure is the
code's inability to complete execution.  This should be your mindset when creating fault-tolerant code.  Every line of code is a ticking time-bomb.   <span class='pullquote'> Your job is to figure out how likely it is to go off, and how much damage it will do if it does. </span> 
</div>

Consider a bit of code to read the current user's name out of the database in order to display it
in the upper-right corner when they're logged in.  A network outage could prevent this database
query from succeeding.  In most normal configurations, this is highly unlikely.  The consequence
of this failure is also minimal - we are unlikely to lose revenue if we can't include the user's
name on the screen for a small period of time.  So don't worry about it.

Now, suppose that a user has registered for our website, and we store their email address before
sending them an email.  Sending the email could fail, though it's unlikely.  The consequences,
however, are far more dire.  The user not only won't get their welcome email, but we'll have
their email recorded in the database, preventing them from fixing the issue themselves by signing
up again.  In this case, I'd be proactive in my code.

<div class='has-pullquote'>
 <span class='pullquote'> Fault-tolerant code is ugly.  It requires conditionals.  </span>  It won't look like code in programming books, screencasts, or blog entries.  This is the way it has to be, I'm sorry.
</div>

If you can't outright prevent a production error, you can often find a way to turn it into a
production error that's easier to resolve.  For example, consider this Rails code:

```ruby
def update_prefs(email,best_time)
  customer.email_preferences   = email
  cutomer.best_time_to_contact = best_time
  customer.save!
end
```

If `save!` blows up, we have a production error, and not much to go on.  It will likely be the
error message straight from the database, which won't be useful.  If the success of this code is crucial, we can
make its failure easier to deal with:

```ruby
def update_prefs(email,best_time)
  customer.email_preferences   = email
  cutomer.best_time_to_contact = best_time
  customer.save!
rescue => ex
  raise "Saving customer #{customer.id}'s preferences " +
        "to #{email}, #{best_time} failed: #{ex.message"
end
```

Now, if something goes wrong, we can recreate the effects of this code manually.  We know which customer was affected, and what the system was trying to do when the failure occurred.

Here's a few rules of thumb that help me know when to take extra care:

* Network connections to third-parties should be assumed flaky - code with this in mind.
* Responses from third-parties should be assumed to be garbled, unparseable, or invalid 10% of the time - log exactly what you get and exactly what you sent so you can help them improve their service, and improve your code as well.
* Never ignore return values or status codes - log things if you don't know how to handle them, raise explicit errors if you *really* don't know how to handle them.
* Returning a boolean for "success" is almost always wrong
* When you log a warning or an error, it should include the context of what was being attempted, an explanation of what went wrong, and steps for remediation.  I don't care if it wraps in your editor.

### Don't overdo it

Fault-tolerant code is about *balance*.  Don't go crazy with abstractions, DSLs, frameworks, or otherwise over-the-top paranoia.  Think.  Observe.  Know your system, and strike a balanced approach.  A week of developer time to avoid a production error that happens every other day might not be worth it.  Your time fixing this stuff is an increased cost, too.

## Not my job

Many organizations set up a wall between operations and development.  Developers are typists who
put code into black rectangular windows and use a version control system.  Operations are people
who scratch their head at bizarre logs and end up ignoring entire classes of errors that they
don't know how to handle.

The fact is, it's nearly impossible to maintain an application in production that you didn't have
a hand in writing.  The author of the code is the *best* person to understand how it's working,
how to improve it, and how to support it.

The best use of an operations team is to have them maintaining the environment in which your
application runs, and to assist you with setting up the tools *you* need to maintain your
production system.  I guarantee they'd love to help you with this rather than sort through your
terrible log files.

## Conclusion

I know this was a long one, but the bottom line is that you need to take an *active*  interest in
how your application behaves in production.  Not only will you learn a ton about programming that
you can't learn any other way, but you will be aligned with the goals of your employers and be
seen as a valuable member of the team instead of a typist.

If you want to read more about this, by someone who is more an expert than me, you should purchase and read [Release It!][releaseit], by Michael Nygard.  It's well-written and practice.

_If you enjoyed this post, I've written [an entire book][sweng] about being a production-oriented developer called "The Senior
Software Engineer".  Pick up a copy - it's only $25_

[releaseit]: http://pragprog.com/book/mnee/release-it
[sweng]: http://www.theseniorsoftwareengineer.com
