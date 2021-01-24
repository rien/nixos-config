import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Util.Run
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet        as W
import qualified Data.Map               as M
import qualified XMonad.Actions.CycleWS as A

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    -- launch a terminal
  [ ((modm,               xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "exe=`@dmenu@/bin/dmenu_path | @dmenu@/bin/dmenu` && eval \"exec $exe\"")

    -- launch passmenu
    , ((modm .|. shiftMask, xK_p     ), spawn "@pass@/bin/passmenu")

    -- launch firefox
    , ((modm,               xK_f     ), spawn "@firefox@/bin/firefox")

      -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

      -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

      --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

      -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

      -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

      -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

      -- Move focus to the master window
    --, ((modm,               xK_m     ), windows W.focusMaster  )

      -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_Return), windows W.swapMaster)

      -- Swap the focused window with the next window
    --, ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

      -- Swap the focused window with the previous window
    --, ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

      -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

      -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

      -- Push window back into tiling
    --, ((modm,               xK_t     ), withFocused $ windows . W.sink)

      -- Increment the number of windows in the master area
    --, ((modm              , xK_comma ), sendMessage (IncMasterN 1))

      -- Deincrement the number of windows in the master area
    --, ((modm              , xK_period), sendMessage (IncMasterN (-1)))

      -- Toggle the status bar gap
      -- Use this binding with avoidStruts from Hooks.ManageDocks.
      -- See also the statusBar function from Hooks.DynamicLog.
      --
      , ((modm              , xK_b     ), sendMessage ToggleStruts)

      -- Cycle one workspace to the left
      , ((modm              , xK_Left  ), A.prevWS)

      -- Shift window one workspace to the left
      , ((modm .|. shiftMask , xK_Left  ), A.shiftToPrev >> A.prevWS)

      -- Cycle one workspace to the right
      , ((modm              , xK_Right ), A.nextWS)

      -- Shift window one workspace to the right
      , ((modm .|. shiftMask , xK_Right  ), A.shiftToNext >> A.nextWS)

      -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

      -- Recompile xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    ] ++

    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

main = do
  xmproc <- spawnPipe "@xmobar@"
  xmonad $ docks def
    { modMask    = mod4Mask
    , terminal   = "@kitty@/bin/kitty"
    , keys       = myKeys
    , manageHook = manageDocks <+> manageHook def
    , layoutHook = avoidStruts $ layoutHook def
    , logHook    = dynamicLogWithPP $ def
      { ppOutput = hPutStrLn xmproc
      }
    , focusedBorderColor = "#004433"
    }
