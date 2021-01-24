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
            str = printf "rx: %d tx: %d" rx tx
        callback str
        tenthSeconds rate
        loop state'

humanReadableBytes :: Integer -> String
humanReadableBytes size
  | abs size < 1024 = printf "%dB" size
  | null pairs      = printf "%.0fZiB" (size'/1024^7)
  | otherwise       = printf "%.1f%sB" n unit
    where
      (n, unit) = head pairs
      pairs = zip (iterate (/1024) size') units
      size' = fromIntegral size :: Double
      units = ["","Ki","Mi","Gi","Ti","Pi","Ei","Zi"]

config :: Config
config = defaultConfig
  { font = "xft:Monospace:pixelsize=18,Symbola:pixelsize=18"
  , commands = [ Run $ Battery
    [ "-t", "<acstatus> <left>%", "--",
      "-o", "🔋", "-O", "🔌", "-i", "🔌" ]
      600
      , Run $ Date "%a %d %b %H:%M" "date" 100
      , Run $ StdinReader
      , Run $ Wireless "wlp114s0" [] 100
      --, Run $ NetInfo "wlp" "wlan" 50
    ]
  , sepChar = "%"
  , alignSep = "}{"
  , template = "%StdinReader% }{ %wlp114s0wi% | %battery% | %date% "
  }

main :: IO ()
main = xmobar config
