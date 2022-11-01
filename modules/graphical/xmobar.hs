{-# LANGUAGE NumericUnderscores #-}
import Data.List (find, isPrefixOf)
import Data.List.Split (splitOn)
import Data.Maybe
import System.Clock
import System.Process
import Text.Printf
import Xmobar
import Debug.Trace

-- Check which SSID we're connected with (if any)
wifi :: String -> IO (Maybe String)
wifi device = do
  stdout <- readProcess "iwgetid" ["-r", device] []
  return $ extractFrom $ lines stdout
    where
      extractFrom [ssid] = Just ssid
      extractFrom _      = Nothing

-- Read /proc/net/dev and take the first line matching a given prefix
fieldsForPrefix :: String -> IO [String]
fieldsForPrefix prefix = do
  proc_net_dev <- readFile "/proc/net/dev"
  let line = fromJust $ find (isPrefixOf prefix) $ lines proc_net_dev
  return $ words line

type NetState = (Integer, Integer, TimeSpec)

-- Perform IO to fetch the current network state
currentNetState:: String -> IO NetState
currentNetState prefix = do
  time   <- getTime MonotonicCoarse
  fields <- fieldsForPrefix prefix
  let rx = read $ fields !! 1
      tx = read $ fields !! 9
  return (rx, tx, time)

data NetInfo = NetInfo String String Int
    deriving (Read, Show)

instance Exec NetInfo where
  alias (NetInfo _ a _) = a
  start (NetInfo p _ r) = netinfo p r

netinfo :: String -> Int -> (String -> IO ()) -> IO ()
netinfo device rate callback = do 
  callback "Loading..."
  state <- currentNetState device
  tenthSeconds rate
  loop state
    where
      loop :: NetState -> IO ()
      loop (prx, ptx, ptime) = do
        state'@(crx, ctx, ctime) <- currentNetState device
        let drx = crx - prx
            dtx = ctx - ptx
            dt  = toNanoSecs $ ctime - ptime
            rx  = (drx * 1_000_000_000) `div` dt
            tx  = (dtx * 1_000_000_000) `div` dt
            str = formatRxTx rx tx
        callback str
        tenthSeconds rate
        loop state'

formatRxTx :: Integer -> Integer -> String
formatRxTx rx tx = printf "%s %s" symbol troughput
  where
    sum = rx + tx
    troughput = humanReadableBytes sum
    rx' = fromInteger rx :: Double
    tx' = fromInteger tx :: Double
    ratio = tx' / rx'
    symbol
      | ratio > 10.0 = "⬆"
      | ratio < 0.10 = "⬇"
      | otherwise    = "⬍"


humanReadableBytes :: Integer -> String
humanReadableBytes size = uncurry (printf "%.1f%sB") $ fit pairs
  where
    units = ["","Ki","Mi","Gi","Ti","Pi","Ei","Zi"]
    size' = fromIntegral size :: Double
    pairs = zip (iterate (/1024) size') units
    fit ((n, unit):xs)
      | null xs   = (n, unit)
      | n < 1000  = (n, unit)
      | otherwise = fit xs

config :: Config
config = defaultConfig
  { font = "Fira Code 18px"
  , commands = [ Run $ Battery
    [ "-t", "<acstatus> <left>%", "--",
      "-o", "🔋", "-O", "🔌", "-i", "🔌" ]
      600
      , Run $ Date "%a %d %b %H:%M" "date" 100
      , Run $ StdinReader
      --, Run $ Wireless "wlp114s0" [] 100
      , Run $ NetInfo "wlp114s0" "wlan" 50
    ]
  , sepChar = "%"
  , alignSep = "}{"
  , template = "%StdinReader% }{ WiFi: %wlan% | %battery% | %date% "
  , position = TopH 30
  }

main :: IO ()
main = xmobar config
