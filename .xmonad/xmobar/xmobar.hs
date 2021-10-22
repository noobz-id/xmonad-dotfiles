
Config { font = "xft:Ubuntu:weight=bold:pixelsize=12:antialias=true:hinting=true"
       , additionalFonts = [ "xft:Mononoki:pixelsize=12:antialias=true:hinting=true"
                           , "xft:Font Awesome 5 Free Solid:pixelsize=13"
                           , "xft:Font Awesome 5 Brands:pixelsize=13"
                           ]
       , bgColor      = "#282c34"
       , fgColor      = "#ff6c6b"
       , position       = TopSize L 100 24
       , lowerOnStart = True
       , hideOnStart  = False
       , allDesktops  = True
       , persistent   = True
       , iconRoot     = ".xmonad/xmobar/"  -- default: "."
       , commands = [
		    Run DynNetwork ["-t", "<fn=2>\xf0dc</fn> <dev>: <tx> - <rx>", "-S", "True"] 10
            , Run Cpu ["-t", "<fn=2>\xf2db</fn> cpu: <total>%","-H","60","--high","red"] 10
            , Run Com "/home/zuliz/.xmonad/script/actual-memory.sh" ["<fn=2>\xf538</fn> mem: ", "MB"] "actmem" 10
		    , Run Battery ["-t", "<fn=2>\xf240</fn> <acstatus>: <left>%", "--", "-i", "acp", "-O", "chr", "-o", "bat" , "-L", "20", "--low", "red"] 10
            , Run Date "<fn=2>\xf017</fn> %b %d %Y - %H:%M" "date" 50
            , Run Com "/home/zuliz/.xmonad/script/trayer-padding-icon.sh" [] "trayerpad" 20
            , Run UnsafeStdinReader
        ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = " <icon=haskell_20.xpm/>  <fc=#666666>|</fc> %UnsafeStdinReader% }{  <fc=#d0d0d0>%dynnetwork%</fc>  <fc=#ff6c6b>%cpu%</fc>  <fc=#ecbe7b>%actmem%</fc>  <fc=#98be65>%battery%</fc>  <fc=#46d9ff>%date%</fc>%trayerpad%"
       }
