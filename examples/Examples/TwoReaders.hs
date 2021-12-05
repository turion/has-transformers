module Examples.TwoReaders where

import "has-transformers" Control.Monad.Trans.Has.Reader

-- | Our "business logic" program using two 'ReaderT' effects.
--   Note that we use a type signature to help the type checker understand
--   which environment is which.
program ::
  (Monad m, HasReader Int m, HasReader Bool m) =>
  m (Int, Bool)
program = do
  envInt <- ask
  envBool <- ask
  return (envInt, envBool)

-- | The 'Int' environment we are going to supply
envInt :: Int
envInt = 23

-- | The 'Bool' environment we are going to supply
envBool :: Bool
envBool = True

-- | For documentation, this is the stack that will be handled.
--   (But we don't actually ever use this type alias.)
type Stack a = ReaderT Int (ReaderT Bool IO) a

-- | The 'program' with its environments supplied
handled :: IO (Int, Bool)
handled = program `runReaderT` envInt `runReaderT` envBool
