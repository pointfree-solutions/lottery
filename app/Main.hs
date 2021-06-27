{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Applicative
import Crypto.Hash.SHA512 as SHA
import qualified Crypto.Random as Rnd (Seed, seedToInteger, seedFromBinary)
import qualified Crypto.Error as CE (eitherCryptoError)

import Data.Csv (FromNamedRecord(..), (.:), decodeByName)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BL
import Data.Either.Combinators
import qualified Data.Text as DT
import qualified Data.Vector as V hiding ((++))
import Data.Vector ((!))
import Codec.Binary.UTF8.String as Codec

data Result = Result
  { resultName :: String
  , resultEmail :: String
  }
instance Show Result where
  show (Result name email) = name ++ " - " ++ email

data Entry = Entry
  { entryTimestamp :: !String
  , entryName :: !String
  , entryEmail :: !String
  , entryDescription :: !String
  , entryRandomness :: !String
  } deriving Show

instance FromNamedRecord Entry where
    parseNamedRecord r =
      Entry
        <$> r .: "Timestamp"
        <*> r .: "Name"
        <*> r .: "Email"
        <*> r .: "Please describe your interest in FP and Haskell?"
        <*> r .: "Give us some random text to help us generate randomness"

runLottery :: String -> Either String Result
runLottery csvContent =
  do
    let csvBytes = BL.pack $ Codec.encode csvContent
    decodeOutput <- decodeByName csvBytes
    let entries = snd decodeOutput
    winnerIndex <- pickWinner csvBytes $ V.length entries
    let (Entry _ name email _ _)  = entries ! winnerIndex
    return $ Result name email


pickWinner :: BL.ByteString -> Int -> Either String Int
pickWinner rngBytesSeed maxIndex =
  (\i -> fromInteger i  `mod` maxIndex)
  <$> Rnd.seedToInteger
  <$> rngSeed

  where
    -- this is required by seedFromBinary
    requiredSeedLength = 40

    rngSeed :: Either String Rnd.Seed
    rngSeed =
      mapLeft show
      $ CE.eitherCryptoError
      $ Rnd.seedFromBinary
      $ BS.take requiredSeedLength
      $ SHA.hashlazy rngBytesSeed

main :: IO ()
main = do
  contents <- getContents
  putStrLn
    $ either
      (\err -> "There was an error: " ++ err)
      (\winner -> "The winner is: " ++ show winner)
      (runLottery contents)
