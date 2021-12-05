module Control.Monad.Trans.Has.Reader
  ( module Control.Monad.Trans.Has.Reader
  , module X
  ) where

import "transformers" Control.Monad.Trans.Reader
  qualified as Reader
import "transformers" Control.Monad.Trans.Reader
  as X (ReaderT(..))

import "this" Control.Monad.Trans.Has

type HasReader r m = Has (ReaderT r) m

ask :: HasReader r m => m r
ask = liftH Reader.ask
