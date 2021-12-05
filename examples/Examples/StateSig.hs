module Examples.StateSig where

import "base" Control.Monad (when)

import "operational" Control.Monad.Operational

import "has-transformers" Control.Monad.Trans.Has
import "has-transformers" Control.Monad.Trans.Has.State

data StateSig s a where
  Put :: s -> StateSig s ()
  Get :: StateSig s s

type StateSigT s m a = ProgramT (StateSig s) m a

type HasStateSig s m = Has (ProgramT (StateSig s)) m

putS :: HasStateSig s m => s -> m ()
-- putS = liftH . singleton . Put
putS s = liftH $ singleton $ Put s

getS :: HasStateSig s m => m s
getS = liftH $ singleton Get

program :: (HasStateSig Bool m, Monad m) => m ()
program = do
  b <- getS
  when b $ putS False

interpretStateSig :: HasState s m => StateSig s a -> m a
interpretStateSig (Put s) = put s
interpretStateSig Get = get

interpretStateSigT :: (HasState s m, Monad m) => StateSigT s m a -> m a
interpretStateSigT = interpretWithMonadT interpretStateSig
