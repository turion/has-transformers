module Control.Monad.Trans.Has.Accum
  ( module Control.Monad.Trans.Has.Accum
  , module X
  ) where

import "transformers" Control.Monad.Trans.Accum
  qualified as Accum
import "transformers" Control.Monad.Trans.Accum
  as X
  (AccumT (..))

import "this" Control.Monad.Trans.Has

type HasAccum w m = Has (AccumT w) m

add :: HasAccum w m => w -> m ()
add w = liftH $ Accum.add w
