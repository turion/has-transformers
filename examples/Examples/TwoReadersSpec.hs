module Examples.TwoReadersSpec where

import "hspec" Test.Hspec

import Examples.TwoReaders

spec :: Spec
spec = do
  describe "two-Reader stack" $ do
    it "returns the environments" $ do
      handled `shouldReturn` (envInt, envBool)
