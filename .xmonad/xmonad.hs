import XMonad
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen, nextWS, prevWS, shiftToPrev, shiftToNext)
import XMonad.Actions.MouseResize
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Actions.FloatSnap
import qualified XMonad.Actions.ConstrainedResize as Sqr

import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import qualified Data.Map as M

import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isInProperty, isDialog, isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.SetWMName

import XMonad.Layout.Accordion
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ResizableTile
import XMonad.Layout.IfMax
import XMonad.Layout.Grid
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

import Graphics.X11.ExtraTypes.XF86


myModMask :: KeyMask
myModMask = mod4Mask

myTerminal :: String
myTerminal = "alacritty"

myBorderWidth :: Dimension
myBorderWidth = 2

myNormColor :: String
myNormColor   = "#00787a"

myFocusColor :: String
myFocusColor  = "#46d9ff"

myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 ", " 0 "]

myStartupHook :: X ()
myStartupHook = do
    setWMName "LG3D"
    spawnOnce "xsetroot -cursor_name left_ptr"
    spawnOnce "xmodmap -e \"keysym Menu = Super_R\""
    spawnOnce "killall lxsession; lxsession"

myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..]

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myShowWNameTheme :: SWNConfig
myShowWNameTheme = def {
    swn_font = "xft:Ubuntu:bold:size=60"
    , swn_fade = 0.5
    , swn_bgcolor = "#1c1f24"
    , swn_color = "#ffffff"
}

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

tall = renamed [Replace "tall"]
    $ withBorder myBorderWidth
    $ smartBorders
    $ subLayout [] (smartBorders Simplest)
    $ limitWindows 12
    $ mySpacing 2
    $ ResizableTall 1 (3/100) (1/2) []

floats = renamed [Replace "floats"]
    $ withBorder myBorderWidth
    $ smartBorders
    $ limitWindows 20 
    $ simplestFloat

wide = renamed [Replace "wide"]
    $ withBorder myBorderWidth
    $ smartBorders
    $ subLayout [] (smartBorders Simplest)
    $ limitWindows 12
    $ mySpacing 1
    $ Mirror Accordion

grid = renamed [Replace "grid"]
    $ withBorder myBorderWidth
    $ smartBorders
    $ subLayout [] (smartBorders Simplest)
    $ limitWindows 12
    $ mySpacing 1
    $ IfMax 2 (Tall 1 (3/100) (1/2)) Grid

myLayoutHook = showWName' myShowWNameTheme 
    $ avoidStruts
    $ mouseResize 
    $ windowArrange
    $ T.toggleLayouts floats 
    $ T.toggleLayouts wide
    $ T.toggleLayouts grid
    $ mkToggle (NBFULL ?? NOBORDERS ?? EOT)
    $ tall ||| floats ||| wide ||| grid

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll [
    isDialog --> doCenterFloat
    , isFullscreen --> doFullFloat
    , isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_MENU" --> doCenterFloat
    , isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH" --> doCenterFloat
    , isInProperty "_NET_WM_WINDOW_TYPE" "_KDE_NET_WM_WINDOW_TYPE_OVERRIDE" --> doCenterFloat
    , isInProperty "_NET_WM_STATE" "_NET_WM_STATE_ABOVE" --> doCenterFloat
    ] <+> manageDocks

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X())
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $ [
    ((modm, xK_Return), spawn $ XMonad.terminal conf)
    , ((modm .|. shiftMask, xK_r), spawn "xmonad --restart")
    , ((modm .|. shiftMask, xK_q), io exitSuccess)
    , ((modm, xK_p), spawn "rofi -show drun -show-icons")
    , ((modm, xK_e), spawn "rofi -show emoji -modi emoji")
    , ((modm, xK_Tab), spawn "rofi -modi \"clipboard:greenclip print\" -show clipboard -run-command '{cmd}'")
    , ((modm .|. shiftMask, xK_p), spawn "rofi-pass")
    , ((modm .|. shiftMask, xK_c), kill1)
    , ((modm .|. shiftMask, xK_a), killAll)
    , ((modm, xK_f), sendMessage (T.Toggle "floats"))
    , ((modm, xK_w), sendMessage (T.Toggle "wide"))
    , ((modm, xK_g), sendMessage (T.Toggle "grid"))
    , ((modm, xK_t), withFocused $ windows . W.sink)
    , ((modm .|. shiftMask, xK_t), sinkAll)
    , ((modm, xK_m), windows W.focusMaster)
    , ((modm, xK_j), windows W.focusDown)
    , ((modm, xK_k), windows W.focusUp)
    , ((modm .|. shiftMask, xK_j), windows W.swapDown)
    , ((modm .|. shiftMask, xK_k), windows W.swapUp)
    , ((modm, xK_h), sendMessage Shrink)
    , ((modm, xK_l), sendMessage Expand)
    , ((modm, xK_minus), prevWS)
    , ((modm, xK_equal), nextWS)
    , ((modm .|. shiftMask, xK_minus), shiftToPrev)
    , ((modm .|. shiftMask, xK_equal), shiftToNext)
    , ((modm, xK_bracketleft), decWindowSpacing 1)
    , ((modm, xK_bracketright), incWindowSpacing 1)
    , ((modm, xK_space), sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)
    , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)
    , ((modm, xK_Print), spawn "scrot ~/Pictures/Screenshots/%Y-%m-%d-%T-screenshot.png")
    , ((modm .|. shiftMask, xK_Print), spawn "scrot -d 3 -F  ~/Pictures/Screenshots/%Y-%m-%d-%T-screenshot.png")
    , ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute 0 toggle")
    , ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume 0 -5%")
    , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume 0 +5%")
    , ((0, xF86XK_MonBrightnessUp), spawn "brightnessctl s +2%")
    , ((0, xF86XK_MonBrightnessDown), spawn "brightnessctl s 2-%")
    ] ++ [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1, xK_2, xK_3, xK_4, xK_5, xK_6, xK_7, xK_8, xK_9, xK_0]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
    ] ++ [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_F1, xK_F2, xK_F3] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $ [
    ((modm, button1) ,(\w -> focus w
        >> mouseMoveWindow w
        >> ifClick (snapMagicMove (Just 50) (Just 50) w)
        >> windows W.shiftMaster))
    , ((modm .|. shiftMask, button1), (\w -> focus w
        >> mouseMoveWindow w
        >> ifClick (snapMagicResize [L,R,U,D] (Just 50) (Just 50) w)
        >> windows W.shiftMaster))
    , ((modm, button3), (\w -> focus w
        >> mouseResizeWindow w
        >> ifClick (snapMagicResize [R,D] (Just 50) (Just 50) w)
        >> windows W.shiftMaster))
    , ((modm .|. shiftMask, button3), (\w -> focus w
        >> Sqr.mouseResizeWindow w True
        >> ifClick (snapMagicResize [R,D] (Just 50) (Just 50) w)
        >> windows W.shiftMaster ))
    ]

main :: IO()
main = do
    xmproc <- spawnPipe "xmobar ~/.xmonad/xmobar/xmobarrc"
    xmonad $ docks $ ewmh def {
        manageHook = myManageHook
        , modMask = myModMask
        , terminal = myTerminal
        , startupHook = myStartupHook
        , layoutHook = myLayoutHook
        , workspaces = myWorkspaces
        , borderWidth = myBorderWidth
        , normalBorderColor = myNormColor
        , focusedBorderColor = myFocusColor
        , keys = myKeys
        , mouseBindings = myMouseBindings
        , logHook = dynamicLogWithPP $ xmobarPP {
            ppOutput = hPutStrLn xmproc
            , ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]"
            , ppVisible = xmobarColor "#c792ea" "" . clickable
            , ppHidden = xmobarColor "#ecbe7b" "" . clickable
            , ppHiddenNoWindows = xmobarColor "#82AAFF" "" . clickable
            , ppTitle = xmobarColor "#d0d0d0" "" . shorten 65
            , ppSep =  "<fc=#666666> | </fc>"
            , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"
            , ppExtras  = [windowCount]
            , ppOrder  = \(w:l:t:e) -> [w,concat([l, ": "]++e),t]
       }
    }


