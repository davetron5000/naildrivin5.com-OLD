---
layout: post
title: "&#10106;&#10144; Self vs Professional Publishing"
date: 2013-10-14 13:13
comments: true
categories: 
---
I get asked occasionally about the self-publishing process and how it compares to the "professional" publishing process, since I have done both.  I thought it might be interesting to compare and contrast these two approaches.  The professional approach is regimented, organized, and carries many advantages, while self-publishing allows total freedom, at the cost of doing a lot more work for a lot less money.

<!-- more -->

During the promotion of my first book, I [wrote a post][bookpost] about the experience of working with a professional
publisher:

> I know that working with John [editor of my book] and the Prags [Pragmatic Programmers, the publishers] has made me a better writer, but would I be confident enough to "go it alone"? Given my lack of notability, I feel I benefit greatly from having my work published and distributed by the Prags. Further, knowing my writing style and abilities as I do, my work will be much higher quality with a team of professionals in my corner.

The post is very "pro professional", and I had a great experience.  I also sold (and continue to sell) a good number of copies.  As of now, I've sold over 6,000 copies of [Build Awesome Command Line Apps With Ruby][rubybook].  I'm happy with those results, especially considering what a niche topic it is.

I conclude with

> That being said, I'd still love to try self-publishing at some point…

With [my current book][swengbook], I got my chance.  I proposed it to the Pragmatic Programmers, however they didn't feel it
was a good fit for them.  The topic of the book is broad—what every programmer needs to know besides coding—and they have at
least three titles that could overlap with the subject matter.  

I wanted the book to be written, so I soldiered on alone, deciding to self-publish.   I have not sold *nearly* as many copies
as I had with my first book at this point, but I'm still happy with the results, and certainly not done promoting the new
book.

Having gone through both a professional publishing and a self-publishing process, I thought it might be interesting to shed
some light on how these two processes work.  These are only two data
points, so your mileage may vary.

## Working with Professionals

My original post contains a good deal of information about what it's like to work with a team of publishing professionals.  Obviously, it's only one datapoint, but my experience jibes with most other tech authors I've talked to.  The basic process is:

1. Proposal accepted
2. Development editor assigned
3. Write a chapter
4. Editor reviews
5. Revise chapter based on feedback
6. Repeat from step 4 until chapter is good
7. Repeat from step 3 until about 25% done
8. Managing editor review
9. Revise as needed, then back to step 3 until half done
10. Publisher review
11. Revise as needed, then back to step 3 until mostly done
12. Tech reviews (these might happen earlier)
13. Copy-editing, indexing, and typesetting
14. Release!

Let's delve a bit deeper into some of these, because they are relevant to the self-publishing process.

{% pullquote %}
The day-to-day writing and revising is done by me, the author, with the help of a _development editor_.  The development
editor isn't concerned with commas, spelling, or grammar. Instead, they're charged with ensuring that the quality of the writing is high.  They will focus on flow, consistency and general "interestingness".  {" The development editor is the only person you can be sure will read your book in great detail "}, which is a handy person to have around.
{% endpullquote %}

So, if the development editor isn't worried about commas and grammar, who does?  The answer is the copy-editor.  God bless
these people, because it sounds like an awful job.  They comb through the manuscript fixing all of the typos the author has
made.  This is done at the end because a) typos and missing commas aren't important to the creative process and b) the text is
likely to change during development, so there's no sense in copy-editing more than once.

Similarly, indexing and typesetting are saved until the end as well.  Indexing is what it sounds like—making the index.
Typesetting is a bit more involved.

In the old school, the author might produce the book in Word or some other electronic format designed for editing and commentary (or perhaps even
a typed/written manuscript in the *real* old school).  Once the work is done, the text
is transferred to a system like Quark or FrameMaker to be set for printing.  Many publishers still work this way.  The Pragmatic Programmers, however, pioneered a better way.  They have a toolchain whereby you write your book in text that can be converted into a beautifully typeset PDF (as well as various e-reader formats).  They even have a build server set up to build your book whenever you commit changes.

Despite the automation, there is still some manual tweaking that must happen before the book can be printed, and so there is a final
stage of manually adjusting the typography to ensure words are hyphenated in the correct place, there are no words on pages by
themselves, etc.

The real power of this system is that they can typeset the book for more than just print.  While the PDF looks like the
printed book, readers also get an ePUB  and a MOBI for reading on a wide variety of e-readers.  I don't know how much manual
tweaking they do to this part, but given my experience with these formats (below), they've created some powerful tools that
produce really great e-reader formats.

{% pullquote left %}
If this sounds like a lot of process, it *is*!  {" It's all focused on producing the best book you can, in terms of both content and presentation. "}  Since the publisher is fronting the money to pay the staff and produce the book before any copies are sold, they rightly want regular check-ins that progress is being made and that the quality is sufficient.  In other words, this process makes a lot of sense to me.
{% endpullquote %}

Let's talk about what's good and what's bad with this process.

### The Good

Getting eyes on your book as you write is awesome.  There's no doubt in my mind that my book was markedly better for having worked with this team of professionals.  Getting feedback from the publisher was also something that can't be underestimated.  Their feedback was borderline brutal, but it came from the right place and was what I needed to hear to do my best work.

In terms of presentation, the end product looks beautiful on paper, and looks great on all the various electronic reading formats that permeate today's technical landscape.  I never once had to worry about formatting, fonts, the Kindle DX, or anything.

They also have the setup to get your book into stores, listed on Amazon, etc.  As we'll see later, this is no small feat and while most of my sales were from the Pragmatic Programmers website, I still sold over 1400 copies from "somewhere else".

{% pullquote %}
Finally, the publisher is a known entity that people look to for technical books.  The same book listed on their website vs only on an author's website is going to sell far more, simply because it becomes known to many more people.  {" Having a book published by a real publisher is a form of promotion that can be hard to match. "}  And it's the detailed process I've just described that creates that reputation for quality.
{% endpullquote %}

### The Bad

Firstly, all of this costs money, so my royalty per copy is roughly 50% of what the publisher collects from buyers.  Although we are in the "The Bad" section, let me be clear that *a 50% royalty is far above average*.  No other publisher that I know of is paying this high a rate.  To be honest, 50% seems way too generous, given what's provided for me and the support I get.  But, as great as their royalty rate is, it's still a cost—the wonderful staff and tools don't come free, and this is the price.

{% pullquote left %}
Secondly, all the check-ins and reviews are forms of gate-keeping.  Editor approvals, copy-editing, indexing, and typesetting are gate-keeping activities, meaning that my ability to work on, promote, and sell the book is _dependent on others_.  {" In effect, I need permission to work on the book. "} I learned very quickly that working on Chapter 4 while Chapter 3 was still being reviewed and revised was a Very Bad Idea™.  Changes in one affect the other, and so while my work is being reviewed, there isn't a whole lot I can do while I'm waiting.  Remember, the vast majority of the time spent creating a book is in revising and editing, not "getting it down".
{% endpullquote %}

Intellectually, I know that these gatekeepers are there for a reason, and that we are all on the same team, and that this process is designed to produce great results.  And it *does* do that, however it can still be frustrating. Particularly because I do this in my free time, which has to be carefully managed and budgeted.  If I have time to write, but feel unable to do so, it feels like a waste.  It also made the entire process _feel_ slow.  Even if it really needed to take that long, the feeling of slowness can be de-motivating.

A more serious downside to the gate-keeping is that these gatekeepers must share your vision, or be convinced of it.  I agreed wholeheartedly with the vast majority of feedback I got from the editors and publisher, however there were times were I felt their advice was just wrong.  Not "wrong" as in "how to sell books" or "how English works", but "that is not what I want to say".  And so you have to convince someone to let you say what you want, or you have to compromise.  It
never once got adversarial, but it _was_ frustrating to have to convince someone that my vision was correct.  I can only imagine how painful this is for
books that aren't as objective as technology books.

The final downside is that not anyone can engage with a publisher.  They only take on so many books at once, and so you have to propose a book and convince them to help you develop it.  It is this process that ensures the publisher's reputation for quality books, and provides the "instant promotion" you get by publishing with them.

As I mentioned, the proposal for my current book was turned down, so I decided to do all of this myself.

## Going it Alone

Given the process I outlined when working with a publisher, you might be thinking that self-publishing is completely freeing
and reduces the process to:

1. Write Book
2. Put on Website

Nope.  Turns out it's *more* work.

{% pullquote %}
Although the gate-keeping aspects of the professional process are frustrating at times, the process itself is a good one.  Even though I wouldn't have a team helping me, I still wanted to produce a book of comparable quality.  That means {" I had to play the role of development editor, managing editor, publisher, copy-editor and typesetter all on my own. "} 
{% endpullquote %}

At this point, I had a first draft done, so I decided on this process:

1. Cobble a toolchain together to validate I could generate the needed formats.
2. Revise and edit a chapter.
3. Sleep on edits and revise again.
4. Repeat step 3 as necessary.
5. Repeat step 2 until done with all chapters.
6. Re-read book, looking for flow and consistency.  Revise as needed.
7. Sleep on edits and repeat step 6 as needed.
8. Get a tech review from trusted friends and colleagues.
9. Revise, then go to step 6 as needed.
10. Set up needed accounts for distribution and payment processing.
11. Design cover for printed book.
12. Design website for book.
13. Copy-edit
14. Finish off toolchain.
15. Done!

The role of development editor was played by me after a night's sleep, along with removing the words "this", "very", and "thing" from my dictionary (so
they would show up as mis-spelled and I could eliminate them for better words).  The role of copy-editor was played by a Ruby script.  I had it look for
common mistakes that I personally make and don't catch while reading.  It turns out, I use a *lot* of commas.  We'll get to the typesetting in a moment.

The hope was that by replicating the process in a disciplined fashion, I could produce something of quality without needing
the other individuals to be involved (and, therefore, paid).  For the creative aspects of the book, this is hard to gage.  I feel like the writing in my
book is pretty good, but there's no way to know how much better it could be, or what affect that would have on sales.

Other than actually getting the book written, I needed to handle typesetting it, distributing it, and getting paid for it.

### Distribution and Payment Processing

I created a spreadsheet of about six different ways I could distribute the eBook and collect payments.  I actually did this before I got too far into the writing, because [LeanPub] was one of my options, and they provide a tool-chain along with distribution and payments.  Not surprisingly, they were by far the most expensive, costing 10% of the sale price plus 50 cents per copy sold{% fn_ref 1 %}.  Still, *way* cheaper than professional publishing, but for going on your own (and being willing to deal with the toolchain yourself—no small task as we'll see), any other way is going to be cheaper.

{% pullquote left %}
I looked at Square Space, Shopify, Fetch App, Digital Delivery (now called Send Owl), and DPD.  They were all comparable in price, charging small monthly fees for distribution, with the payment processor (in most cases, Stripe), charging around 3% of the sale.  I went with Send Owl as they had the cheapest monthly rate, a good variety of coupon and discounting options, and the nicest looking default UI for the buying experience.  {" Setting up accounts with Send Owl and Stripe was incredibly simple, and the integration worked flawlessly. "}
{% endpullquote %}

If only the toolchain would've been that easy.

### Toolchain

The toolchain takes the source material—your writing—and produces electronic formats for distribution.  The three most common
are PDF, ePub, and MOBI.  There are various tools that can help and they are all pretty terrible, especially when you care as
much about the typography of the end-result as I do.  I wanted the PDF version to look professionally typeset.  The output of
a word processor is *not* what I wanted, and the PDFs generated by asciidoc and pandoc look horrendous to me.

That meant LaTeX.  The Pragmatic Programmers toolchain appeared to me to be based on LaTeX, and I had experience with it
during grad school, so I knew I could use it to get the desired output.  LaTeX is not for the faint-of-heart and while its
output is nothing short of beautiful, it is not a tool designed around ease of use.

LaTeX also doesn't have a good way to produce e-reader formats from LaTeX source, and it is not enjoyable to write or edit in LaTeX's arcane markup language.  I wrote the rough draft in Markdown, however Markdown doesn't support cross references, which I knew I would need, so I went with Asciidoc. 

I then set up a basic toolchain like so:

1. Asciidoc fed into pandoc
2. pandoc generated LaTeX and ePub
3. LaTeX generated PDF
4. Calibre generated the MOBI from the ePub

I spent quite a bit of time customizing the PDF output, but I think it was worth it.  I used the [memoir] LaTeX package, which
makes it significantly easier to set margins, font sizes, headers, and footers, so that I could create a look that was unique,
and that would also fit the page size I planned to use for the print version.  It came out great, although was incredibly
painful and time-consuming to get right.  The world of TeX and LaTeX is not well-traveled, and so documentation is hard to
come by.

{% pullquote %}
{" Other than Memoir and LaTeX, I ended up being incredibly disappointed with every other element of the toolchain "}.  pandoc
stripped out all the cross-references and any other feature that its internal representation didn't support (I added them
back via some *very* hacky Ruby scripts).  pandoc's epub was bare-bones and underwhelming, despite the power of the format (at least on iPad).
Calibre's Kindle output was downright awful.
{% endpullquote %}

MOBI is fairly terrible and inflexible, and Calibre generated a pretty awful-looking book.  If you look at any bullet-list in
my book on a real Kindle, you'll see what I mean.  It looks terrible.  And I didn't realize it until I was completely done and
had no energy left to figure it out.

If I do this again, I will write my own ePub and MOBI generator, possibly by using Docbook or HTML as the source and
generating LaTeX, ePub, and MOBI from that, using all the power those formats offer.  LeanPub's toolchain looks _decent_, but
the typography of the PDFs is not very good, in my opinion. It's better than a word processor export, but still not amazing.

When I was mostly done with the book, I discovered [Tablo], which is a cloud-based toolchain aimed at getting your book into Amazon and the iBookstore.  I do not like writing in degenerate web-based editors without version control, and they provide no PDF option that I can see, so I would not use this service.   They are a better option than exporting from a word processor, though.


{% pullquote left %}
To make a longer story short, this is a rathole.  {" Do not underestimate the amount of effort required to produce a nicely typeset book. "}  But please,
   do not produce a poorly typeset book.  They are a chore to read.
{% endpullquote %}

### The Print Version

I knew I wanted to do a print run, so once I had the PDF output how I liked it, I ordered a copy from [LuLu], the only print-on-demand service provider I
could find. One copy is $7, and
it arrived in a few days.  It looks and feels like a real book.  The cover and paper are quite nice, and because of the typesetting, it looks great.  The
color on the cover is a bit more variable than I would like, but for the price and convenience of not having to order in bulk, this works really well.

Integrating them into my store was not so easy.

### The Buying Experience

Send Owl is very straightforward: you upload whatever you are selling, set a price, and they give you a URL.  You configure payment methods and you are off to the races.

They also have the concept of a "package" where you can sell multiple items at once for a total reduced cost.  Once I had the print stuff ready to go, I wanted to create a package that gets you the ebook and the print book for a collective discount.  This is where I ran into trouble.  Send Owl doesn't do fulfillment.  To get LuLu to fulfill, readers would need to buy from them direct, but LuLu provides no discount code mechanism, so I couldn't offer the book, fulfilled from LuLu, at a reduced price to eBook buyers.

I also couldn't do it the other way around, because LuLu will not provide you with the email addresses of buyers (or any way to contact them), so there was no way to get buyers of the physical book a discount code on the ebook!  

So, I ordered 20 copies at cost and decided to fulfill them myself.  Of course, Send Owl has no way to calculate shipping, so I had to set a price that
included shipping, but still appeared to be a good deal.  To date, I've made $135 on the package deal, and spent $35 on shipping.  Not good.

{% pullquote %}
Interestingly, once I started offering the package, it required buyers to make a choice: do they get the ebook or the package?
It turns out that many of them decide to get neither.  {" The extra step of requiring a decision hurt conversion"}, so I killed the package.
Now, readers who buy the ebook get an email to buy direct form LuLu, at a reduced price.  That link is good for anyone, so
anyone with the link can get the book for that price, making it not really that "reduced".  And now I have 17 books sitting in my
closet.
{% endpullquote %}

That covers direct sales, but what about other channels?

### Other Sales Channels

Early on, I looked at Kindle Direct Publishing (KDP).  This seemed like a pretty easy way to get listed on Amazon, and at least be a place where reviews could be written and found.  Unfortunately, Amazon reserves the right to change the price of your book, for any reason, for any length of time, without warning.  I even confirmed this with their customer support, because I thought it was too ludicrous to be true.  This means that Amazon could decide to sell my book for 99 cents, and the only thing I could do about it was remove it from the store.  Those were not terms I was comfortable with.

The Apple iBookStore is quite the opposite.  You set the price, Apple gets 30%, and that's all she wrote.  Your book as to be approved, but it also has to have an ISBN, which can cost up to $200.  I may still try this, but I'd need to sell 13 copies to people who would otherwise never know about the book to make it break even.  And given how un-remarkable it looks on iPad (it looks fine, just not amazing), I'm not sure I'd want to list it there.

Getting the print version into Amazon and other stores is something LuLu can do, but it looks a bit onerous. You need an ISBN (and can't use the same one for print and iBookStore—each format has to have its own), and your book must meet a laundry list of requirements before having to be approved.

These may turn into viable options, but for now, I'm holding off.

Now that I had a way for people to buy, I needed to get the word out.  I didn't have the publishers website and marketing
channels, so I was on my own.

### Marketing and Promotion

On launch day, I posted a link on my blog, posted twice on Twitter (once in the morning, once in the afternoon), and submitted links to both Hacker News and Reddit.

{% pullquote left %}
Hacker News generated some discussion about how awful my website was (it was awful, since redesigned by a very kind friend), but didn't generate many conversions (nor did Reddit).  Almost all traffic and purchases were from my blog or Twitter.  {" I sold about 100 copies on day 1, which was a good feeling"}.  After that, I've been getting a handful of sales every week in steady fashion.
{% endpullquote %}

I posted coupon codes on Facebook and LinkedIn for $10 off.  This resulted in exactly one sale.

Initially I didn't accept PayPal, as I didn't want to deal with them.  After some feedback that I might be losing sales, I
turned it on, and most of my sales are now via PayPal.  I've had no problems thusfar.

I've written posts on my blog related to the book, with links, however these never generated a noticeable bump in sales.  I did a sale on "National Programmer's Day", which DID result in a bump (and was clearly worth it, since many of those sales would never have been made).  This is one thing that's nice about going it on your own—you can change course like this any time, and do sales, or change the price pretty much on a whim.

What all this said to me was that I had "tapped out" my social network.  I'm proud of the sales I've made essentially based on my Twitter followers and blog audience, but I need to do something more to reach a new audience.  This is where I'm a bit stumped.

I plan to speak at more conferences, although I have my doubts that this is ultimately worth it, considering the cost of travel.  I've considered purchasing advertising, however the channels I would find most effective are places that I myself hate seeing ads, so I'm not sure how I feel about that.

## Which is better?

As you can see, this is not so straightforward.  Going it on my own, I have a lot of freedom, can switch directions, and have complete control over all aspects of the book.  The downside, other than *having* to control those things, is that my personal reach is orders of magnitude lower than the reach of an established publisher.

The downside of a publisher is that I must first choose a topic they wish to publish a book on, and then deal with the process and gate-keeping that goes along with it.  But, that process produces a higher quality result.  How *much* higher is unknown.

{% pullquote %}
It's worth mentioning that {" it doesn't seem feasible to make a living entirely on writing tech books"}.  While I've made some
good money on both efforts, neither would pay the rent or sustain even a modest lifestyle.  To do so, I would have to produce
very popular books on a frequent schedule.  There are very few tech books one would consider "seminal", and their authors tend to
either have day jobs or a more diversified offering of services beyond writing.
{% endpullquote %}

All that to say that writing books for me is a side project; something I do in my free time. Because of that, the
self-publishing route _felt_ better.  It felt more agile, and much simpler.

That being said, I'm still getting royalties on my first book, which is going on two years old.  Will I be able to say the same about my current book two years from now?

## Too Long, DID Read

This is a long post, but I hope you enjoyed it.  For making it all the way down here, I'm giving you $5 off my book.  <a href="http://transactions.sendowl.com/products/24086/D8D2ED13/add_to_cart">Click here</a> and enter the code `TLDR5` in the space labeled "Promo Code" before you buy.  Thanks for reading!


----

{% footnotes %}
  {% fn LeanPub is somewhat interesting.  They aren't a traditional publisher, but it's possible that their name carries some weight with readers.  I was looking at them as a toolchain vendor, although they might be interesting to consider as an additional sales channel. %}
{% endfootnotes %}


[bookpost]: http://www.naildrivin5.com/blog/2012/04/24/five-months-of-ebook-sales.html
[rubybook]: http://pragprog.com/book/dccar/build-awesome-command-line-applications-in-ruby 
[swengbook]: http://theseniorsoftwareengineer.com/
[LeanPub]: http://leanpub.com
[memoir]: http://www.ctan.org/pkg/memoir
[Tablo]: http://tablo.io
[LuLu]: http://lulu.com

