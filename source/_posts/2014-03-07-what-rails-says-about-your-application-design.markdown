---
layout: post
title: "&#10106;&#10144; What Rails says about your application design"
date: 2014-03-07 09:43
comments: true
categories: 
---

Rails isn’t the only part of your application where design decisions are made. The developers of Rails aren’t the only developers whose past experience can be used to make design decisions. You have experience, too.  And it's that experience that must drive your design process.

<!-- more --> 

So, let's talk about design.  What is it? 

Design is about making decisions. Deciding what to do and what not to do.  What color should I use?
Where does the power button go?  What copy do I use for this link?  What is the name of this class?  What type should I
use for this variable?  What *name* should I use for this variable?

The act of creation naturally requires doing design, making decisions.  It is this decision-making process that makes the
creative process unpredictable and lengthy—it's not clear up front what decisions we might have to face.   In my experience,
understanding the problem to solve is rarely difficult (even if some developers forget to do it :).  It's much more challenging
to figure out how to best *solve* the problem.

Fortunately, the more experience we gain in the act of creation, the more familiar some of the decisions we face appear to be.  We start to see patterns of design.  When we see those patterns enough, we develop techniques that make these decisions for us.

Typographers, for example, have rules of thumb about line length and font size.  Rarely would a typographer begin with a blank
page and start setting the text at different font-sizes and line-lengths until it "looked right".  Although a gifted typographer
might be able to do this quickly, most typographers will simply adjust the font-size and line-length to a particular ratio that
is known to produce a readable layout, based on years of collected experience.

Graphic designers don't typically begin each task with a blank screen and move elements around until they "work together".
Instead, they'll employ a grid system and align all objects somewhere on that grid.  Years of collected design experience have taught them that designs organized around a grid will look good and be quicker and easier to produce.

Software engineers, too, employ these types of tools and techniques.  For example, few developers, when faced with creating a
way for two applications to communicate, would invent a wire-protocol from scratch.  Most developers would use an HTTP-based
approach, with JSON or XML as the encoding mechanism.

From these techniques, it's often convenient to develop tooling.  LaTeX is a tool that typographers can use to make basic
decisions about page layout, leading, kerning, and font choice.  A boilerplate CSS file is a tool a designer can use to keep objects
aligned to a grid.  JSON serializers and HTTP libraries are tools a developer can use to build inter-application communication.

Some techniques are so general as to be accepted practice—the grid system, for example.  Others are only relevant in a particular
context, for a particular purpose—a hand-held game programmer will have little need of a JSON-based app-to-app communication protocol.

## What does this have to do with Rails?

Rails is a tool that embodies many accepted techniques for the design of web-based, SQL-database-backed applications, such as:

* Use the controller or command pattern to map URLs to code
* Consistently name your URLs and controllers (e.g. `/users` is serviced by `UsersController`)
* Consistently name fields in your database (e.g. `ID` is the primary key, `FOO_ID` is the foreign key) and their method of
access in the code (e.g. `user.first_name` gets the value of the `FIRST_NAME` field of the `USERS` table).

Rails further embodies other techniques that are less universal but—if accepted—can yield great productivity:

* All interaction is via HTTP verbs, based around resource manipulation (i.e. REST).
* Emails are views, just like web views.
* Declarative validations on database-backed objects can be used to generate highly usable web forms for user interaction.

These decisions, baked into the tool called Rails, don't make sense for every application.  But they make sense for a large class
of applications.

But because this class of applications is broad, Rails can't make every design decisions about *every* application.  This means
that there are still decisions we must make.  And so we make them.

## Design Decisions to Make

It's not always easy to know what the right decisions are.  There are a lot of factors to balance when
writing software: how easy is it to test, how easy is it to understand or modify, how easy will it be to _write_?

As you build each feature, you do your best to make the right design decisions, and produce clean,
understandable code.  Alone, you have a good chance of producing a well-designed codebase.

A team of developers, however, will encounter trouble.  Given any problem, there are many possible design decisions that can be
made to solve it.  Rarely is one decision so obviously correct that every competent developer would arrive at it independently.
Instead, developers will make design decisions based on their experience, the problem, or even their mood.

Imagine a hotel where the electricity always worked, the water was always running, check-in smooth and efficient, but where each
room was laid out differently.  Each shower operated by a different type of knob, each electrical outlet oriented a different
way, each bed with a different set of pillows.  Is this a well-designed hotel?  Would it be easy to work there?

## Hotel Rails

At the absolute most optimistic, a Rails application created by a team of developers deferring all design decisions not made by Rails to the moment of implementation could be described as "cleanly inconsistent".  Each controller action, model method, and mailer, hand-crafted by a conscientious developer clean and perfect in and of itself, but different from its brethren elsewhere in the system.  At its most optimistic.

A designer with nothing but an eye for design *could* produce something beautiful.  A typographer, staring at a blank
page, armed with a typeface and good taste *can* produce a readable document.  Is this the best way for them to work?  *Should* they be working this way?

When developing a feature for a Rails application, do we *really* need to make these decisions *every* time:

* Which part of my application logic is a controller concern?  
* Which part belongs to the model?  
* Which model does this code most naturally go in?  
* Is this controller too big and messy and now needs refactoring?  
* Is the code I want in another model and I have to extract something they can share?

None of these decisions have anything to do with the problem we are solving.  Much like the decision around the name of the
primary key of a database table, these decisions are not specific to the purpose of our
application.  Ideally, we shouldn't have to make these decisions at all, or at least very often.  

Even if our
team is comprised of the smartest developers with a keen eye for design, who can quickly decompose a problem into the perfect
set of changes, it feels like we are doing unnecessary work by revisiting the same decisions again and again.

So why doesn't Rails address this?

## There are some things even Rails can't do

Rails doesn't know what kind of application we want to make, so it remains silent as to how to organize business logic.  Don't mistake this silence for direction, however.  Just because Rails provides controllers, models, and mailers for us does
not mean that we are intended to put every bit of code into them.  Just as a grid system makes no prescription
on typeface, LaTeX none regarding the Oxford Comma, and HTTP none on the encoding of information, Rails prescribes nothing for the organization of your application logic.

So what do we do?

We accept these facts.  We are building applications to solve problems.  We've chosen Rails as a tool to make some design
decisions for us so that we can focus our effort on solving those problems.  But, in the context of the team we have, the
problems we must solve, and other realities that Rails cannot account for, it's perfectly OK to make some design decisions of our
own.  

Rails isn't the only part of our app where design decisions are made.  And the developers of Rails aren't the only developers
whose past experience can be used to make design decisions.  We have experience, too.

My current team has made some design decisions, based on our experience as developers, the business problems at hand, and our experience with Rails.  _Our_ experience. As _developers_. Solving the _problems at hand_.

One of our decisions was that no business logic goes in a model, mailer, controller, or
background job.  That doesn't mean _you_ should also make that decision or that Rails should be extended to make that decision, or that any Rails codebase that puts business logic in a model is a priori wrong.  But it was the right decision for us, given the problems we face, the team we have, and the way we want to work.
           
The result is that I spend very little time making decisions about where code should go.  It is rare in a code
review to discuss what may or may not be a "model concern", for example.  Instead, I make decisions about how best to solve the problem at hand, and our code reviews focus on the correctness and completeness of those solutions.  

Sure, the code _could_ be organized somewhat cleanly across a series of controllers, models, and mailers, but what would that gain us?  Could that code have been produce more quickly?  Would it be easier to understand?  Would it solve the problems at hand better or sooner?  

Would finding a way to put all code in a controller or model improve any reasonable metric of code quality other than "misunderstood compliance to The Rails Way"?

The team made these design decisions early—we knew that we'd be living with the applications for a long time.
We decided that instead of cleaning up a mess in the controllers and models of our apps _when_ they became messy, we
would simply not ever make a mess there.  This is impossible to achieve without the application of tools and techniques that
automate design decisions away.  It's also impossible to achieve if your willingness to make design decisions ends at the Rails
API. And it's extremely difficult to achieve if you ignore your own experience as a developer and "don't fight Rails".

So don't let anyone tell you that your code is overly complex, or that you've "prematurely extracted" something or that you
"could just do it in the model" or that it's a "controller concern".  

Design is about making decisions, so don't be afraid to make them.

