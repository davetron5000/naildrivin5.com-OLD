---
layout: post
title: "Bad Programming in Java is Dangerous"
date: 2013-01-20 10:04
comments: true
categories: 
---

Saw a blog post this morning titled [Why Functional Programming in Java is Dangerous][op].  Author Elliotte Rusty Harold sets up
the world's worst straw man I've seen.  He talks about [Uncle Bob's post][bobpost] on the advantages of functional programming.
Elliotte's thesis is that Java and JVM just can't handle this sort of thing, and then sets out to prove this with some terrible code that, unsurprisingly, is terrible.  He takes this bit of Clojure

```clojure
(take 25 (squares-of (integers)))
```

And "re-implements" it in Java.  He does this by implementing `integers` to just allocate an array of all the integers.  

Yeah.

<!-- more -->

That's bad enough, but really, that line of Clojure isn't functional *per se*, it's just that aspects of a functional programming
language (namely first-class functions and lazy evaluation) make it really easy to implement that code in an efficient way.

Elliotte is just flat wrong that you can't do this in Java.  I will now present the Java version of the Clojure version.

## As always, laziness is the key to success

The key to making it work is to use a lazy list which, in Java, is called `Iterator`.  If you have never used Java before,
`Iterator` is basically this:

```java
public interface Iterator<T> {
  public boolean hasNext(); // true if there are more elements
  public T next();          // get the next element
  public void remove();     // remove the element you just got (optional)
}
```

First, let's make a list of all the integers.  The top of the collection food chain in Java is `Iterable`, which has one method
that just returns an `Iterator`.  We'll make an `Iterator` of all the integers and wrap it up in an anonymous `Iterable` for use by anyone:

```java
private static class IntegersIterator implements Iterator<Integer> {
  private int nextInt = 0;
  public boolean hasNext() {
    return nextInt < Integer.MAX_VALUE;
  }
  public Integer next() {
    if (!hasNext()) {
      throw new NoSuchElementException();
    }
    nextInt++;
    return nextInt - 1;
  }
  public void remove() {
    throw new UnsupportedOperationException();
  }
}

private static Iterable<Integer> integers() {
  return new Iterable<Integer>() {
    public Iterator<Integer> iterator() {
      return new IntegersIterator();
    }
  };
}
```

This is almost all there is to it.  To make the `squares-of` function, we need to maintain the "laziness" of our implementation.
To do this, we'll create a squaring `Iterator` that proxies{% fn_ref 1 %} through to another `Iterator`:

```java
private static class SquaringIterator implements Iterator<Integer> {
  private Iterator<Integer> original;
  public SquaringIterator(Iterator<Integer> iter) {
    original = iter;
  }
  public boolean hasNext() {
    return original.hasNext();
  }
  public Integer next() {
    int value = original.next();
    return value * value;
  }
  public void remove() {
    original.remove();
  }
}

private static Iterable<Integer> squaresOf(final Iterable<Integer> seq) {
  return new Iterable<Integer>() {
    public Iterator<Integer> iterator() {
      return new SquaringIterator(seq.iterator());
    }
  };
}
```

We *are* starting to see some of Java's warts here.  Because we're creating an anonymous inner class, that class cannot access
parameters or local variables unless we declare them `final` - we've declared the parameter to `squaresOf` as such.  This is because Java doesn't support real closures.  We could've
made a class that implements `Iterable<Integer>` just for our `squaresOf` function, but that feels like overkill for this
increasingly contrived example.

OK, now that we have a way to get *all* the integers *and* square them without *actually instantiating* all the integers, we can
just take the first 25 off:

```java
public static void main(String args[]) {
  System.out.println(take(25,squaresOf(integers())));
}

private static List<Integer> take(int numToTake, Iterable<Integer> seq) {
  List<Integer> results = new ArrayList<Integer>();
  Iterator<Integer> iterator = seq.iterator();
  for(int i=0;i<numToTake;i++) {
    if (iterator.hasNext()) {
      results.add(iterator.next());
    }
  }
  return results;
}
```

Running this code sure enough works quickly and without incident (full listing [here][functional1]):

```
> java -cp . Functional
[0, 1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225, 256, 289, 324, \
361, 400, 441, 484, 529, 576]
```

So, it's certainly possible to create lazy data structures in Java. There are a few things bad about this, however:

* It's very special purpose - if we needed a `doublesOf` or `squareRootsOf`, we'd create a lot of duplicate code
* It's not very OO - we'd expect our code to be something like `squaresOf(integers).take(25)`.

Let's fix it!

## Functions to the rescue

*Now* we're going to need a `Function` interface:

```java
private static interface Function1<A,R> {
  public R apply(A a);
}
```

Think of `A` is "argument" and `R` as "return value".

With this, we can genericize our `SquaringIterator` into a `TransformingIterator` that takes a function for transformation and
the `Iterator` to transform:

```
private static class TransformingIterator<A,R> implements Iterator<R> {
  private Iterator<A> original;
  private Function1<A,R> function;

  public TransformingIterator(Function1<A,R> function, Iterator<A> iter) {
    this.original = iter;
    this.function = function;
  }
  public boolean hasNext() {
    return this.original.hasNext();
  }
  public R next() {
    A value = this.original.next();
    return this.function.apply(value);
  }
  public void remove() {
    original.remove();
  }
}
```

*Now*, we can make our `squaresOf` method like so:

```java
private static Iterable<Integer> squaresOf(final Iterable<Integer> seq) {
  return new Iterable<Integer>() {
    public Iterator<Integer> iterator() {
      Function1<Integer,Integer> square = new Function1<Integer,Integer>() {
        public Integer apply(Integer i) {
          return i * i;
        }
      };
      return new TransformingIterator<Integer,Integer>(square, seq.iterator());
    }
  };
}
```

Using `TransformingIterator`, we could make a `doublesOf` method like so:

```java
private static Iterable<Integer> doublesOf(final Iterable<Integer> seq) {
  return new Iterable<Integer>() {
    public Iterator<Integer> iterator() {
      Function1<Integer,Integer> square = new Function1<Integer,Integer>() {
        public Integer apply(Integer i) {
          return i + i;
        }
      };
      return new TransformingIterator<Integer,Integer>(square, seq.iterator());
    }
  };
}
```

Yes, creating a function in Java is messy, but it's not impossible, and doesn't affect the runtime performance of our
application.  This ability to extract structure and code vs. logic is the true power of functional programming.

## Making it more OO

Now, what about that pesky `take` method?  We can handle that pretty easily by creating an implementation of `Iterable` that adds
the necessary methods:

```java
private abstract static class RichIterable<T> implements Iterable<T> {

  public static <T> RichIterable<T> fromIterable(Iterable<T> seq) {
    return new ProxyRichIterable<T>(seq);
  }

  public RichIterable<T> take(int numToTake) {
    List<T> results = new ArrayList<T>();
    Iterator<T> iterator = this.iterator();
    for(int i=0;i<numToTake;i++) {
      if (iterator.hasNext()) {
        results.add(iterator.next());
      }
    }
    return fromIterable(results);
  }

  public List<T> toList() {
    List<T> list = new ArrayList<T>();
    for(T t: this) {
      list.add(t);
    }
    return list;
  }
}

private static class ProxyRichIterable<T> extends RichIterable<T> {
  private Iterable<T> seq;
  public ProxyRichIterable(Iterable<T> seq) {
    this.seq = seq;
  }
  public Iterator<T> iterator() {
    return seq.iterator();
  }
}
```

Notice that we create a means of converting any `Iterable` (i.e. any Java collection) into our `RichIterable`, and also provide a
way to turn it back into a vanilla list.  We replace all use of `Iterable` in our code with `RichIterable` and our `main` method looks more "OO":

```java
public static void main(String args[]) {
  System.out.println(squaresOf(integers()).take(25).toList());
}
```

And, it still runs great (updated source [here][functional2]):

```
> java -cp . Functional
[0, 1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225, 256, 289, 324, \
361, 400, 441, 484, 529, 576]
```

So, what did we learn?  We learned that you can't just write shitty code in Java and then say Java and the JVM can't handle
functional programming.  Java can *absolutely* handle functional programming, even though Java's syntax makes it a bit painful.

---

{% footnotes %}
  {% fn See how I used the name of a design pattern instead of painfully explaining to you what a proxy is?  Handy, isn't it? %}
{% endfootnotes %}
[op]: http://cafe.elharo.com/programming/java-programming/why-functional-programming-in-java-is-dangerous/
[functional1]: https://gist.github.com/4579317
[functional2]: https://gist.github.com/4579399
[bobpost]: http://pragprog.com/magazines/2013-01/functional-programming-basics
