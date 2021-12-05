# This library `Has` transformers

## What?

A very slim library for first-order effects based on monad transformers
(and nearly nothing else).

### What exactly?

Given a transformer stack `t1 (t2 (t3 (... m))) a`,
you can automatically lift any function `thing :: tN m a` into the stack with a single function,
[`liftH`](https://hackage.haskell.org/package/has-transformers/docs/Control-Monad-Trans-Has.html#v:liftH).

### What features does it have?

* _Final encoding_:
  There is a type class [`Has t m`](https://hackage.haskell.org/package/has-transformers/docs/Control-Monad-Trans-Has.html#t:Has) that says that the transformer `t` is in the stack `m`.
* _Extensibility_:
  Standard [`transformers`](https://hackage.haskell.org/package/transformers/) are supported out of the box.
  You can add any further transformers to your stack.
* _No runtime overhead_:
  There is no runtime overhead related to handling effects.
  Your code is as fast as if you had written it just with a lot of manual [`lift`](https://hackage.haskell.org/package/transformers/docs/Control-Monad-Trans-Class.html#v:lift)s.
  (No benchmarks yet though.)

### What features does it not have?

* _Higher-order effects_:
  For example, you cannot encode in the `Has` typeclass:
  * [`catchE`](https://hackage.haskell.org/package/transformers/docs/Control-Monad-Trans-Except.html#v:catchE): Exception handling
  * [`local`](https://hackage.haskell.org/package/mtl-2.2.2/docs/Control-Monad-Reader-Class.html#v:local): Modify a reader computation
* Separation of effect _signatures_ and effect _carriers_.
  For example, you cannot have one signature of writer effects,
  and then later decide whether you want to interpret them as strict `WriterT`, lazy `WriterT`, CPS-style `WriterT`, an `IO`-based log, and so on.
  You have to choose one transformer that represents your effect.

## Why?

Imagine you have a rather complex transformer stack,
say `ReaderT r (ExceptT e (AccumT a (StateT s m)))`.
To write programs in it, you would have to do yoga exercises like `lift $ lift $ lift $ put s` all over your business logic code.
And at some point you maybe want to add logging to your stack,
thus insert a `WriterT w`,
and then discover that your `ExceptT e` is sitting in the wrong place after all.
You change your stack, and all your business logic is broken.
Even those modules that didn't even need to know anything about logging and error handling.

Wouldn't it be nice to
save yourself writing all these repetitive `lift`s,
avoid spelling out the complete stack in all your code,
separate concerns, invert dependencies, have clean architecture,
and be able to change your monad stack without breaking existing code?

Then simply use the [`Has`](https://hackage.haskell.org/package/has-transformers/docs/Control-Monad-Trans-Has.html#t:Has) typeclass,
and replace all your `lift` orgies with its one function, `liftH`.

But isn't this a solved problem, you ask?
Read on.

### Why not `mtl`, `fused-effects`, `freer-simple`, `operational`, `polysemy`, `eff`, `rio`, ...?

Because `has-transformers` has some advantages over each of these libraries.
It also has some disadvantages over each.
The usual advantage is that `has-transformers` is fast and simple,
and the disadvantage is that it doesn't have higher order effects.

#### `mtl`

Historically, `mtl` solves the same problem like `has-transformers`,
but declares a type class manually for each transformer:
`MonadReader` for `ReaderT`, `MonadState` for `StateT`, and so on.
Which means that one has to implement `MonadReader` for _every_ transformer you want to use.
And if you want to add your custom transformer `FooT`,
not only do you have to implement `MonadReader` etc. for all the classes you need,
you also have to invent your own `MonadFoo`,
and implement instanes for all transformers for it.
This is well-known, and called the "quadratic instance problem".
If you or someone else has written a good blog post or article about this topic, let me know,
I'll link to it.
The gist is that `mtl` is practically not extensible.

`has-transformers` doesn't have this problem.
You don't have to invent your own `MonadFoo`, because you get `Has FooT` for free,
together with all relevant instances.

As a downside, `has-transformers` doesn't have higher-order effects,
so you cannot lift operations like [`catchE`](https://hackage.haskell.org/package/transformers/docs/Control-Monad-Trans-Except.html#v:catchE) through it.
You can of course still use them, at the cost of either using `mtl` or some other higher-order library,
or explicitly declaring the monad stack at the calling site.

#### `fused-effects`

If you wish, you can think of `has-transformers` as a miniature version of `fused-effects`,
or of `fused-effects` as the fully-featured, well-researched version of `has-transformers`.
In particular, both are "fused" in that type classes are used to insert effects,
and a transformer stack chosen at compile time to interpret them.
This is great for performance.

`fused-effects` has two big features in comparison:

* _Higher order effects_:
  You can declare and handle e.g. exceptions,
  [`MonadPlus`](https://hackage.haskell.org/package/base-4.16.0.0/docs/Control-Monad.html#t:MonadPlus),
  backtracking, and so on,
  within the framework.
* _Separation of signatures and effects_:
  You can define one type operator representing only your effect interface,
  and decide in a different place what transformer stack
  (or other kind of monad) you use to interpret the effect.

But `has-transformers` also has some advantages which may appeal to you:

* _No separation of signatures and effects_:
  You don't _need_ to define a signature separately.
* _No complicated type class_:
  You don't need to implement the impressive [`Algebra`](https://hackage.haskell.org/package/fused-effects/docs/Control-Algebra.html#t:Algebra) type class for your transformer.
* _Fewer language extensions_:
  `fused-effects` [needs a lot of language extensions](https://github.com/fused-effects/fused-effects#required-compiler-extensions),
  most of them modern but benign,
  but also the slightly vexing `UndecidableInstances` when defining your own effect carrier.

#### `freer-simple`, `freer-effects`, `freer`, `operational`, `polysemy`, `eff`, ...

I expect `has-transformers` to be more performant,
because there is no runtime overhead associated to effect handling.
(Although the overhead is expected to be small in `eff` when/if delimited continuations are merged in GHC.)
How big this overhead is, I can't judge, but it's probably smaller than you'll care about in production.
Also see https://github.com/fused-effects/fused-effects#benchmarks and https://github.com/polysemy-research/polysemy#what-about-performance-tldr.

On the other hand, all these libraries support higher-order effects.
(`operational` is not really extensible out of the box.
  (But extensibility could be added with sum types, which is another story for another day.)
)
And they also separate effect signatures from interpreters.

#### `RIO`

The [`RIO`](https://hackage.haskell.org/package/rio/docs/RIO.html#t:RIO) monad also offers first-order extensible effects via a `ReaderT` that holds all handlers.
The big disadvantage of `RIO` is that it is tied to `IO`,
so you cannot e.g. do algebraic reasoning,
guarantee determinism or absence of side effects,
`IO`-free mocking, and so on.

(Note that this is not about of [`rio`](https://hackage.haskell.org/package/rio)-the-library,
but [`RIO`](https://hackage.haskell.org/package/rio/docs/RIO.html#t:RIO)-the-monad),
which of course is the heartpiece of the aforementioned library.)

### Is it compatible with all these? Or do I have to choose?

Yes, `has-transformers` is to some extent compatible with all these other effect libraries!
No, you don't have to choose one and discard all the others!

* Any transformer stack can also be adressed with `fused-effects`,
  or to some extent with `mtl`.
* The bottom monad of your stack can be `Eff` from `freer-simple` & co, or `RIO`, or any other `Monad` or `MonadIO`.
* Effect signatures can be added to your stack with a free monad like `ProgramT`.

#### Can you please give us a feature matrix?

| Library | Extensible | Higher order effects | "Fusion" / no runtime interpretation | Arbitrary base monads |
| --- | --- | --- | --- | --- |
| [`has-transformers`](https://www.github.com/turion/has-transformers/) | ✅ | ❌ | ✅ | ✅ |
| [`mtl`](https://hackage.haskell.org/package/mtl) | ❌ | ✅ | ✅ | ✅ |
| [`fused-effects`](https://hackage.haskell.org/package/fused-effects) | ✅ | ✅ | ✅ | ✅ |
| [`polysemy`](https://hackage.haskell.org/package/polysemy), [`freer-simple`](https://hackage.haskell.org/package/freer-simple), ... | ✅ | ❌ | ✅ | ✅ |
| [`rio`](https://hackage.haskell.org/package/rio) | ✅ | ❌ | ✅ | ❌ |

Let me know if other features & libraries are important to you.

### What are these higher order effects you keep talking about?

A good example is `mtl`'s [`MonadError`](https://hackage.haskell.org/package/mtl/docs/Control-Monad-Error-Class.html#t:MonadError) class.
It has two methods:

* `throwError :: e -> m a`
* `catchError :: m a -> (e -> m a) -> m a`

A transformer stack `m` containing `ExceptT e`
(which is based on the `Either e` monad)
can use `throwError` to insert a (properly lifted) `Left e` value into the stack (an "exception"),
and `catchError` to handle any such exception.

Such a stack satisfies `Has (ExceptT e) m`,
and you can use `liftH` to define [`throw :: HasExcept e m => e -> m ()`](https://www.github.com/turion/has-transformers/src/Control/Monad/Trans/Has/Except.hs),
but nothing like `catchError`.

The reason is that the type signature of `catchError` is _higher order_ in the monad `m`:
It appears on the left-hand side of the final `->`.
In other words, `catchError` does not only return something of type `m a`,
it also _expects inputs_ related to the type `m`.
But if you look at the type signature of `liftH`,
you will notice that `m` only appears on the right hand side of the `->`,
so it is not possible to implement a function like `catchError` with `liftH`.

This excludes many advanced operations on effects that you might be interested in,
e.g. continuation passing, error handling, logic backtracking, and others.
If you need these, you either have to make the transformer stack explicit
(which somewhat defeats the purpose of an effect library),
or use another library to address these effects.

## How?

The central insight is that a transformer `t` is not only an effect handler,
but at the same time an effect _signature_.

For example, `StateT s m a` is always inhabited by `put` and `get` no matter the base monad `m`,
and these form a complete signature for this transformer.

So we simply need to lift the effects of a transformer into arbitrary stacks.
This is done with the `Has` typeclass.
`Has t m` says that `m` is composed of transformers and a base monad,
and that `t` is one of these transformers,
i.e. `t` is in the monad stack `m`.

### How do I separate effect signatures and handlers?

First of all, note that you don't always have to, and that can be a simplification:
Your transformer `t` also serves as an effect signature.
If you still want to separate them, and interpret them,
you can still use a free monad such as [`FreeT`](https://hackage.haskell.org/package/free/docs/Control-Monad-Trans-Free.html#t:FreeT)
or [`ProgramT`](https://hackage.haskell.org/package/operational/docs/Control-Monad-Operational.html#t:ProgramT) to make your effect signature into a monad transformer,
and then use this transformer in your stack.
Of course, this will incur a runtime penalty when interpreting the effect.
An example is found in [`StateSig`](https://www.github.com/turion/has-transformers/examples/Examples/TwoReaders.hs).

Relatedly, if you want to re-interpret one transformer (say, lazy `StateT`) as another with the same API (say, strict `StateT`),
you can do a similar procedure.

### Can I use two `ReaderT`, two `StateT`, etc., in the same stack?

Yes. See the [`TwoReaders`](https://github.com/turion/has-transformers/blob/master/examples/Examples/TwoReaders.hs) example.
You might have to add some type signatures here and there to help GHC figure it out.

### Does this work with _any_ transformer?

Most transformers.
[`ContT`](https://hackage.haskell.org/package/transformers/docs/Control-Monad-Trans-Cont.html#t:ContT)
(and other continuation based transformers like [`LogicT`](https://hackage.haskell.org/package/logict/docs/Control-Monad-Logic.html#t:LogicT))
don't work,
but any transformer that is strictly positive in its monad works
(i.e., `ReaderT`, `WriterT`, `StateT`, `ExceptT`, `AccumT`, and so on).

The issue with `ContT` & co. is that their interface is inherently higher order.
Consider, for example,
[`callCC :: MonadCont m => ((a -> m b) -> m a) -> m a`](https://hackage.haskell.org/package/mtl/docs/Control-Monad-Cont-Class.html#v:callCC),
or [`msplit :: MonadLogic m => m a -> m (Maybe (a, m a))`](https://hackage.haskell.org/package/logict/docs/Control-Monad-Logic-Class.html#t:MonadLogic),
which each define the minimal interface for their respective `mtl`-style class.
They need `m` on the left hand side of the final arrow,
and thus cannot be encoded in the form of `liftH`.

## (Why) `Has`n't this been done before?

I'm not sure, to be honest.
It seems such a simple idea that I guess someone must have had it before.
If you know who and where, please let me know, and I'll link here.
