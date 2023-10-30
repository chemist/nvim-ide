module Main (main) where

-- | main 
main :: IO ()
main = do
  putStrLn "hello world"

-- | simple example evaluate
--- >>> hello "hello " "wo"
-- WAS "hello world"
-- NOW "hello wo"
hello :: String -> String -> String
hello x y = x ++ y


