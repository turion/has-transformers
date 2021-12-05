module Control.Monad.Trans.Has.Writer
  ( module Control.Monad.Trans.Has.Writer
  , module X
  ) where

import "transformers" Control.Monad.Trans.Writer.Strict
  qualified as Writer
import "transformers" Control.Monad.Trans.Writer.Strict
  as X
  (WriterT (..))

import "this" Control.Monad.Trans.Has

type HasWriter w m = Has (WriterT w) m

tell :: HasWriter w m => w -> m ()
tell w = liftH $ Writer.tell w
