module Control.Monad.Trans.Has.State
  ( module Control.Monad.Trans.Has.State
  , module X
  ) where

import "transformers" Control.Monad.Trans.State.Strict
  qualified as State
import "transformers" Control.Monad.Trans.State.Strict
  as X (StateT(..))

import "this" Control.Monad.Trans.Has

type HasState s m = Has (StateT s) m

get :: HasState s m => m s
get = liftH State.get

put :: HasState s m => s -> m ()
put s = liftH $ State.put s
