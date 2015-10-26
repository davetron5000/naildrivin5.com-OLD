---
layout: post
title: "DHH on Hypermedia Hype"
date: 2012-12-20 12:45
link: http://37signals.com/svn/posts/3373-getting-hyper-about-hypermedia-apis
---

The ever-opinionated DHH, [on the "hype" about "hypermedia" APIs][dhhpost]:


> The recurrent hoopla over hypermedia APIs is completely overblown. Embedding URLs instead of IDs is not going to guard you from breakage, it’s not going to do anything materially useful for standardizing API clients, and it doesn’t do much for discoverability.

Couldn't agree more. Just getting developers to consume an API that isn't all POSTs is hard enough.  If "hypermedia" has
demonstrable benefits, I certainly have never seen proof of this, outside of a lot of exasperated flailing.

Remember when "Hypermedia APIs" were called REST?  I do.  From [my post][restcompliance] about this in _2009_:

> <strong>Rest Compliance Officer</strong>: Is there exactly one endpoint, from which any and all resource locators are discoverable?<br>
> <strong>Me</strong>: Um, no, that puts undue burden on the client libraries, and over-complicates what we were trying to accomp&hellip;.<br>
> <strong>RCO</strong>: YOU ARE NOT RESTFUL! READ FIELDING’S DISSERTATION, THE HTTP SPEC AND IMPLEMENT AN RFC-COMPLIANT URI PARSER IN THREE DIFFERENT LANGUAGES. NEXT!<br>

Using HTTP methods for their intention is great, as is sane URL design, but the fantasy of a generic client that can discover and
navigate every possible operation of a web UI seems like just that&hellip;fantasy.

[dhhpost]: http://37signals.com/svn/posts/3373-getting-hyper-about-hypermedia-apis
[restcompliance]: http://www.naildrivin5.com/blog/2009/03/17/mustbecompliant.html
