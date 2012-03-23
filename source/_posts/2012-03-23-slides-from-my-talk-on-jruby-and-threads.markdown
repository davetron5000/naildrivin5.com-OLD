---
layout: post
title: "Slides from my Talk on JRuby and Threads"
date: 2012-03-23 11:49
comments: true
categories: 
---

If you missed it, or just want a copy, [here's my slides][slides] from my talk on JRuby and Threads.

If you just want the "exercises", here they are:

<!-- more -->

## Echo Server

* Listen on a port
* Respond to each request in a new Thread
* **Extra Credit**: Record stats on requests in a shared data structure

## Connection Pool

* Allow N clients to access X shared instances of, say, Redis (where N > X)
* Clients "check out" a connection and get exclusive access
* Clients "check in" when done
* Instances get re-used


[slides]: https://github.com/davetron5000/jruby-and-threads-talk
