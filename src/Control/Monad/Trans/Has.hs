{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE KindSignatures #-}
module Control.Monad.Trans.Has where

import "transformers" Control.Monad.Trans.Class

-- |
-- class Has t m where
--   liftH :: t Identity a -> m a

{- | The transformer stack @m@ contains the transformer @t@.

Explicitly, @m = t1 (t2 (t3 ... (tN m)...))@,
and @t@ is one of these @t1, t2, ...@s.
-}
class Has (t :: (* -> *) -> * -> *) m where
  {- | Insert an action of this transformer into an arbitrary position in the stack.

  This will apply 'lift' as many times as necessary to insert the action.
  The higher-rank type involving @forall n@ basically says:
  "The action to lift must only use the structure of the _transformer_,
  not of a specific monad,
  and is thus definable for any monad @n@".
  -}
  liftH :: (forall n . Monad n => t n a) -> m a

-- | If the transformer is outermost,
--   the action can be inserted as-is.
instance Monad m => Has t (t m) where
  liftH = id
  {-# INLINE liftH #-}

-- | If the target transformer @t@ is under a different layer @t1@, 'lift' once.
instance {-# Overlappable #-} (Monad m, MonadTrans t1, Has t m) => Has t (t1 m) where
  liftH action = lift $ liftH action
  {-# INLINE liftH #-}
