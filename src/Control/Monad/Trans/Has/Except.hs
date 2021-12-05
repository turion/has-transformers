module Control.Monad.Trans.Has.Except
  ( module Control.Monad.Trans.Has.Except
  , module X
  ) where

import "transformers" Control.Monad.Trans.Except
  qualified as Except
import "transformers" Control.Monad.Trans.Except
  as X
  (ExceptT (..))

import "this" Control.Monad.Trans.Has
import qualified Control.Monad.Trans.Except as Control.Monad.Trans.Has

type HasExcept e m = Has (ExceptT e) m

throw :: HasExcept e m => e -> m ()
throw e = liftH $ ExceptT $ return $ Left e
