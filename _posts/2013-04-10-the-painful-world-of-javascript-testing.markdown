---
layout: post
title: "The Painful World of JavaScript Testing"
date: 2013-04-10 10:40
comments: true
categories: 
---
One of the main reasons I like working test-first is because I'm lazy.  I don't want to fire
up a browser, log in as the right person, navigate to just the right piece of data (which I
had to set up manually in the database), and click around to see if things are working.

Don't get me wrong, I *do* do that, but only when the code is working according to my tests.  Or, when I have to write
JavaScript.  

At my [current job][stitchfix], I'm doing a lot more front-end than I had been, and so more
JavaScript.  The app I'm working on is a Rails app, and so I looked into the current state of
the art with testing JavaScript.

In *can* be done, and it's painful.

<!-- more -->

I have a few constraints or requirements for testing:

* I want to write CoffeeScript.  Every time I have to type `function() { }` is a part of my
  life I won't get back.
* I want the tests to run from `rake` without having to open a browser or navigate to some
  magic page that happens to run tests.
* I want to test every bit of logic I can, including logic involving JQuery.  Basically, I
  want to know from my tests if the JavaScript code has broken.

The tools exist to do all of this, however they are amazingly degenerate compared to what was
available in Java 10 years ago.  We'll get to that.

## Jasmine

The current state-of-the art seems to be [Jasmine].  Our Rails app uses RSpec, and Jasmine is
very much along those lines.  You write your "spec" and then call assertions in the form
`expect(foo).toBe(bar)`:

```coffeescript
describe 'my math library', ->
  describe 'can add', ->
    it "should handle 0", ->
      expect(SuperMath.add(9,0)).toBe(9)
    it "can handle negatives", ->
      expect(SuperMath.add(9,-5)).toBe(4)
```

Wonderful!  There's lots of useful matchers and, with CoffeeScript, the code is pretty
readable.  The output is very RSpec-like.

The first step to get this working is [jasmine-rails][jasminerails].  Jasmine-rails is mostly a
wrapper around the Jasmine JS code, and a simple engine you can mount to run the tests
in-browser.

```ruby
gem 'jasmine-rails'
```

This will bootstrap a configuration file for you, and this is where the pain starts.  The
configuration is not well documented or well designed, so it's hard to understand exactly
where Jasmine is going to look for files.  Further, Jasmine itself provides zero help when
things don't work. Basically, it just shows 0 specs and declares success.  Add in the asset
pipeline and if things don't "just work", it's no fun.

I eventually got something working through trial and error.  I would highly recommend starting
with a spec that doesn't require any of your actual JS files to work, e.g.
`expect(true).toBe(true)` and so forth.  Once that's working, make assertions about the
_existence_ of your actual JS code before going ahead with real tests.

Painful setup is annoying, but it's a one-time thing.  Once I had this going, I needed to
write some tests.

I have a feature where entering a number into a text field and hitting return causes certain behavior
to happen on the page.  If the number is "valid", a radio button gets checked, and if it's not, an error
message gets shown.

Implementing this is pure JQuery, and I immediately felt frozen - how the heck am I gonna test this?
Mock JQuery?  And if I *do*, I'd just end up testing the implementation, e.g. "assert that JQuery
called `hide()` on an element with selector 'foo'" and so on.  Not good.

Enter jasmine-jquery.

## Fixtures with jasmine-jquery

[Jasmine-jquery][Jasminejquery] includes a bunch of matchers that help with JQuery-specific behavior, things
like `expect($("#whatever")).toBeHidden()`.  This is useful, but I'd still need to find some
way to load up the page and execute the JQuery-based code on a DOM.

I could certainly do that in a Capybara test, but those are slow and flaky.  I need a better way to control the markup that my
JQuery executes on during a test.

A bit of code has inputs, which we arrange as part of our test, and we check the outputs of the code to see that it's working.
The fewer the inputs, the easier it is to test something.  This is why functional programming is so appealing - functions tend
to have fewer inputs than methods on an object (which have both their arguments and the internal state of the object as inputs).  Well, JQuery-based JavaScript basically has "every piece of markup on the Internet" as its input.

Practically speaking, it has as input "all the markup on the page", which is still a lot of inputs.  I needed a way to both specify the inputs, but also to clearly document what parts of any page are the *real* inputs. Fixtures is a way to do that.  Essentially, fixtures in jasmine-jquery are bits of HTML that will be available to JQuery as the DOM during your test.

At first, I attempted to place the fixtures in external files.  This seems logical, but it
requires the application to serve them up.  Outside of the fact that our application requires
authentication to every page, the headless version (below) just didn't work at all when fixtures were in external files.

Carrying on the tradition of Jasmine and JavaScript in general, when things didn't work, they
just silently didn't work, with no way of diagnosing what was going on.

So, inline fixtures it is.  In other words, big strings of HTML.

First, we set up the spec:

```coffeescript
describe 'returns', ->
  describe 'show', ->
    describe 'doing an item lookup', ->
```

Next, we set up our fixture in a `beforeEach` block using CoffeeScript's handy multi-line
string syntax.  This keeps things fairly readable, despite the fact that we're building a
giant string of HTML:
``` coffeescript
beforeEach ->
  fixture = """
  <div id="returns-fixture">
    <div id="flash-alert" class="alert" style="display: none;">
      <div class="msg"></div>
    </div>
    <div id="flash-notice" class="alert" style="display: none;">
      <div class="msg"></div>
    </div>
    <form id="item-id-lookup">
    <input type="text" id="item-id-field" name="item_id" autofocus="autofocus">

    <input id="item-1-in" type="radio" name="return[items][1][status]" value="In">
    <input id="item-1-out" type="radio" name="return[items][1][status]" value="Out">
    <input id="item-1-dmg" type="radio" name="return[items][1][status]" value="Damaged - Reparable">

    <input id="item-2-in" type="radio" name="return[items][2][status]" value="In">
    <input id="item-2-out" type="radio" name="return[items][2][status]" value="Out">
    <input id="item-2-dmg" type="radio" name="return[items][2][status]" value="Damaged - Reparable">
    </form>
  </div>
  """
  jasmine.getFixtures().set(fixture)
  window.StitchFix.controllers.returns.show()
```

(When editing this article,I noticed that Pygments highlighted the inline HTML.  I wish Vim did that, it makes the fixture
 pretty readable!)

The second-to-last line instructs Jasmine to magically do some magic and make the HTML available to
JQuery.  I don't know what part of this is Jasmine and what part is
jasmine-jquery, but it works.  The last line is some setup that gets called by our global JS for the particular page this JS is
for.

This markup is somewhat duplicated from the actual ERB templates, but what can you do?  If
someone changed the ids on me, my tests will pass, but the app breaks.  It's all about
compromise, and this seems like a decent compromise.  These are unit tests, and I have to have
some assumptions about the inputs.

```coffeescript
describe 'should check the proper radio button when the id is submitted', ->
  beforeEach ->
    $("#item-id-field").val("1")

  it 'when there was no previous alert message', ->
    $("#item-id-lookup").submit()
    expect($("#item-1-in")).toBeChecked()
    expect($("#item-id-field")).toHaveValue("")
    waitForAnimations ->
      expect($("#flash-notice")).toBeVisible()
      expect($("#flash-notice .msg")).toHaveText("Item 1 marked as 'In'")
```

That last bit was really fun.  We changed the hiding logic to do an animation.  When we did
that, our expectations fired before the animations had completed, making the test fail.  So,
  we have to litter our test with this crud to get consistency.  Here's *that* function:

```javascript
var waitForAnimations = function(andThen) {
  $(":animated").promise().done(andThen)
};
```

Yup, it's in JavaScript, because a) I don't know how to make global functions in CoffeeScript
that works in this weird context of running tests and b) a class created here to hold the
function wasn't visible to my specs.  I'm sure this is a CoffeeScript thing, but it's still
annoying.

*But*, things are working. Now, let's get it running headless.  

## No browser was used in the execution of this test

Jasmine-rails includes [jasmine-headless-webkit][jasmineheadlesswebkit] which, if you install QT properly on your Mac, will run these tests
without a browser, on the command line, via `rake`, just like you're supposed to in the 21st
century.  It even sets up the rake task: `rake jasmine:headless`.  Not much of a name, but it works.

It's slow, to be sure, but not nearly as slow as running it in the browser, *plus* it works on CI.  The planets must be aligned
inside my astrological sign.

It was a long, annoying trip to get here, but we finally have something sane to run tests in a pretty reasonable
way, and I only had to type `function() {}` *one time*, we don't have to mock JQuery and it's all happening
on the command line, where proper software development occurs.

Of course, all of this was done to code already written.  I want
to use my tests to drive the writing of code, and this is where the situation absolutely
sucks.

## Failure is the only option

One thing that's super-important about writing tests first is watching the code fail in a
specific way.  If I call the method `foobar`, I want my test failure to be because that method
doesn't exist.  This way, when the test *does* pass, I know that it had to correct affect on
the codebase.

In some cases, this works OK.  Let's change our spec above to expect `#item-id-field`  to have
the value "foo":

```coffeescript
expect($("#item-id-field")).toHaveValue("foo")
```

The test failure message is very nice:

```
Expected '<input type="text" id="item-id-field" name="item_id" autofocus="autofocus">' 
to have value 'foobar'. (line ~36)
```

The failure message is accurate, as is the line number.  So far, so good.  

Now, let's introduce a typo.  It happens, and, while annoying, is usually an easy problem to fix.
Not in the world of JavaScript unit testing:

```
(/Users/davec/Projects/spectre/spec/javascripts/returns_spec.coffee:33)
   TypeError: 'undefined' is not a function
```

Umm, OK?  I haven't shown you where the typo is, and in a potentially large codebase,
you might have a lot of code to look through.  Let's use **the only information we were
given** and head to line 33 of our spec:

```coffeescript
it 'when there was no previous alert message', ->
```

Not only is there no typo here, but this **isn't even the line of code that was
executed that resulted in the error!**   Basically, at this point, we have two problems,
one practical, and one more philosophical.  

Practically speaking, we now have to just read through our source code looking for the typo.  If we can't see one, we have to start commenting out code until we get a different
error message and then slowly comment it back in.  In 2013.  We put a man on the freakin' moon
in 1969, and JavaScript, the language of the web, has no stack traces.  This is why we can't
have nice things.

On a philosophical level, it also means my ability to test-drive my JavaScript code is
severely hampered.  When starting out a new bit of code, I'm gonna have a lot of typos and unknown functions.  With test failure messages that amount to "your code [a splode][asplode]", it's really hard to do that.

Want to see what the typo was?

```coffeescript
notifications.close_noow("alert")
notifications.close_now("notice")
```

I fat-fingered the function `close_now`.  So, not only did it not point me to *any relevant
line of code* (and I'd be happy with the line of code in the generated JavaScript), it **didn't
even tell me the name of the missing symbol**.

Yes, yes, I know that what it was trying to do was execute a function call on the value
`"close_noow"` from the `notifications` objects, which happened to be undefined.  But, can't we do
better?

Interestingly, Google's JavaScript runtime, V8, does a bit better, which isn't surprising
(thought it still *boggles my mind* that v8 has no readline support.  You can't even up
 arrow?!??!).  But, installing therubyracer and instructing Jasmine to use it (or Node) as the JS runtime
has no affect on the crappiness of this error message.

So, this is the state of things to my ability to find them.  I *hope* I've missed something,
but I fear I haven't.  Just piecing this together via various searches and form posts was tricky, which means 
that very few people are actually doing this in earnest. 

It's no wonder, because it's a huge pain in the neck.  I can only assume
that I've created a ticking time-bomb in my application and, six months from now, it's going
to go off and CI will just fail constantly with "undefined is not a function" or something.

I don't have a particular opinion on Node, but I can tell you that if developing Node is like
this, I would *never* do it.  This is no way to work.

[stitchfix]: http://www.naildrivin5.com/blog/2013/02/19/stitch-fix-slash.html 
[Jasmine]: http://pivotal.github.com/jasmine 
[jasminerails]: https://github.com/searls/jasmine-rails
[Jasminejquery]: https://github.com/velesin/jasmine-jquery
[jasmineheadlesswebkit]: http://johnbintz.github.io/jasmine-headless-webkit
[asplode]: http://www.urbandictionary.com/define.php?term=asplode
