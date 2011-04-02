--- 
title: Why not use bash?
layout: post
---

At [RubyNation][rubynation], I gave a talk on [Making Awesome Command Line Applications in Ruby][awesome-cli-ruby], which I've done a few times, and is what led to my currently-in-progress book on the subject.  

One of the assertions I added to the talk, based on my work on the book is the specific advice to not start off in bash…use Ruby.  This was questioned by a member of the audience (who I realized later was [Blake Mizerany][bmizerany] of Heroku/Sinatra fame, i.e. someone far more knowledgable than me about CLI apps, Ruby, and shell programming).

My answer was about as eloquent as a middle-school debate team closing argument and amounted to “Me hate bash.”

Although I *do* dislike shell programming, it's not exactly fair of me to transfer my personal preferences into solid “advice,” nor is it fair to imply that shell programming is a lame or worthless skill; it's certainly not.

So, I thought about it a bit more and I have a *real* answer to the question “Why use Ruby instead of shell?”

Blake made the point that one of my examples (in Ruby) would've been very trivial in shell, and further that issues I was discussing could be easily avoided by simply better-wielding the shell.  His preference was to convert to Ruby only when things got complicated.

I would generally agree, for some definition of “when things get complicated.”

For me, things get complicated in shell *very* quickly…I'm just not a shell expert and likely won't ever be.  A lot of developers aren't shell experts, and are not going to be able to use the shell programming language *nearly* as effectively as they could Ruby.

So, rather than write _bad_ shell code and then port to Ruby later (once you've made a mess), my advice, assuming you aren't a shell expert and aren't looking to become one, is to just start off with Ruby.  

I say this because the average developer is much more likely to be able to write clean & idiomatic Ruby code than to write similarly idiomatic shell code.

That said, I probably should become *more* of an expert on shell programming and would love some resources if anyone has any.

[rubynation]: http://www.rubynation.org
[awesome-cli-ruby]: http://awesome-cli-ruby.heroku.com
[bmizerany]: http://twitter.com/bmizerany
