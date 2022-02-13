
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
		    Run DynNetwork ["-t", "<dev>: <tx> - <rx>  <fc=#666666><fn=1>|</fn></fc>", "-S", "True"] 10
            , Run Cpu ["-t", "cpu: <total>%  <fc=#666666><fn=1>|</fn></fc>","-H","60","--high","red"] 10
            , Run Com "/home/zuliz/.xmonad/script/actual-memory.sh" ["mem: ", "MB  <fc=#666666><fn=1>|</fn></fc>"] "actmem" 10
		    , Run Battery ["-t", "<acstatus>: <left>%  <fc=#666666><fn=1>|</fn></fc>", "--", "-i", "acp", "-O", "chr", "-o", "bat" , "-L", "20", "--low", "red"] 10
            , Run Date "%b %d %Y - %H:%M  <fc=#666666><fn=1>|</fn></fc>" "date" 50
            , Run Com "/home/zuliz/.xmonad/script/trayer-padding-icon.sh" [] "trayerpad" 20
            , Run UnsafeStdinReader
        ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = " <icon=haskell_20.xpm/>  <fc=#666666>|</fc> %UnsafeStdinReader% }{  <fc=#d0d0d0>%dynnetwork%</fc>  <fc=#ff6c6b>%cpu%</fc>  <fc=#ecbe7b>%actmem%</fc>  <fc=#98be65>%battery%</fc>  <fc=#46d9ff>%date%</fc>%trayerpad%"
       }
