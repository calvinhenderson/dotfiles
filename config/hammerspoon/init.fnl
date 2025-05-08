; {{{ Configuration
; {{{ - Applications

; Configure host-agnostic bundle ids here.
; Host-specific configuration should go in local.fnl
(global apps {})

; Browser
(tset _G.apps :browser-bundleid "com.google.Chrome")
(tset _G.apps :browser-name "Google Chrome")
; Terminal
(tset _G.apps :terminal-name "kitty")
(tset _G.apps :terminal-bundleid "net.kovidgoyal.kitty")

; }}}
; {{{ - Commands/Hyperlinks

(local shortcut-uri {
  :dashboard "$WEB_DASHBOARD"
  :passwords  "-b com.apple.Passwords"
  :obsidian-tasks "obsidian://open?file=Tasks"
  })

; }}}
; {{{ - Clipboard settings

(local clipboard-max-entries 10)

; }}}
; {{{ - Default values

; whether the mouse moves to the focused window
(local mouse-follows-focus true)

; "main"
(set hs.window.animationDuration 0)

; the default global chooser callback seems to be incorrect:
; if a chooser is opened when one is already open, closing it doesn't properly
;   restore focus. Seems to work properly without?
(tset hs.chooser :globalCallback nil)

; }}}
; }}}
; {{{ Utilities

(fn hostname [ ]
  (let [hosts    (hs.host.names)
        islocal  (lambda [host] (host:match ".*%.local$"))
        fqdn     (hs.fnutils.find hosts islocal)
        hostname (fqdn:gsub "%.[^.]*$" "" 1)
        hostname (hostname:gsub "(\r|\n)" "")
        hostname (hostname:lower)]
    hostname)
  )

(fn shell-escape [str]
  (string.gsub (string.gsub str "\\" "\\\\") "'" "'\\''"))

; opens a file / folder using the default system application
(fn system-open [path] (os.execute (.. "source ~/.profile && "
                                       "open " (shell-escape path))))

(fn get-host-bundle-id [bundleid_s]
  "If the bundleid is a table, get the one for the specified host.
  Otherwise, return the string."
  (if (= "table" (type bundleid_s))
    (. bundleid_s (hostname))
    bundleid_s
  ))

; }}}
; {{{ Windows and Layouts
; {{{ - Default variables

(global layout [])
(global focus-groups [])
(global focus-actions [])

; }}}
; {{{ - Window helpers

(fn fuzzy-window-title [window-title layout-title]
  (when window-title (when layout-title
    (string.find (window-title:lower) (layout-title:lower)))))

; if the argument is a list, then perform the function on it. otherwise return it
(fn is-list [maybe-list do-if]
  (if (= (type maybe-list) "table") (do-if maybe-list) maybe-list))

(fn lookup-default [tbl key default]
  (if (= (. tbl key) nil) default (. tbl key)))

(fn window-layout [params]
  (let [
    layout-app (get-host-bundle-id (. params :app))
    bundleid   (hs.application.get layout-app)
    title      (. params :title)
    screen     (. params :monitor)
    frame      (. params :frame)
    ] [ bundleid title screen frame nil nil ]))

(fn layout-with-enhanced-interface-off [layout]
  ; https://github.com/Hammerspoon/hammerspoon/issues/3224
  (let [app (. layout 1)]
    (when app
      (let [el (hs.axuielement.applicationElement app)
            enhanced el.AXEnhancedUserInterface]
        (set el.AXEnhancedUserInterface false)
        (hs.layout.apply [layout] fuzzy-window-title)
        (set el.AXEnhancedUserInterface enhanced)
        ))))

(fn set-layout [ ]
  (each [_ params (ipairs (. _G.layout))]
    (layout-with-enhanced-interface-off (window-layout params))))

(fn set-window-fraction [app window screen x y w h]
  (let [coords [x y w h]
        layout [app window screen coords]]
    (layout-with-enhanced-interface-off layout)))

(fn move-active-window [screen x y w h]
  "Move the active window to the given dimensions"
  (let [app      (hs.application.frontmostApplication)
        window   (hs.window.focusedWindow)
        screen   (or screen (window:screen))
        frame    (screen:frame)
        vertical (< (. frame :w) (. frame :h))]
    (if vertical
      (set-window-fraction app window screen y x h w)
      (set-window-fraction app window screen x y w h)
      )))

(fn move-active-window-to-next-screen []
  (let [w (hs.window.focusedWindow)
        next-screen (: (w:screen) :next)
        layout [(w:application) w next-screen (w:frame)]]
    (layout-with-enhanced-interface-off layout)))

; }}}
; {{{ - Focus watcher

(var window-focus-watcher nil)
(fn app-matches [app gapp]
  (when app
    (let [app-bundle  (app:bundleID)
          host-bundle (get-host-bundle-id gapp)
          app-name    (app:name)]
      (or
        (fuzzy-window-title app-bundle host-bundle)
        (fuzzy-window-title app-name host-bundle)
      ))))

(fn window-matches [window gwin]
  (let [wapp   (window:application)
        wtitle (window:title)
        gtitle (. gwin :title)
        gapp   (. gwin :app)
        tmatch (and (and wtitle gtitle) (fuzzy-window-title wtitle gtitle))
        amatch (app-matches wapp gapp)]
    (or (and tmatch amatch) (and (not gtitle) amatch))))

(var last-focused-window nil)
(fn window-focused [_window _app-name _event]
  (let [window  (hs.window.focusedWindow)
        pressed (hs.mouse.getButtons)
        app     (window:application)
        windows (window-focus-watcher:getWindows)
        matched []
        frame (window:frame)
        cx (+ frame.x (/ frame.w 2))
        cy (+ frame.y (/ frame.h 2))
        ]
    ; make sure we only focus once?
    (if (= last-focused-window window) (lua "return"))
    (set last-focused-window window)
    ; move the mouse to the center of the focused window
    ; if the left mouse button was pressed, then don't move
    (if (and mouse-follows-focus (not (. pressed :left)))
      (hs.mouse.absolutePosition { :x cx :y cy }))

    ; find any matching focus groups
    (each [_ group (ipairs _G.focus-groups)]
      (each [_ gwin (ipairs group)]
        (if (and (not (. gwin :ignore)) (window-matches window gwin))
          (hs.fnutils.concat matched group))))
    ; raise windows in focus group
    (each [_ gwin (ipairs matched)]
      (each [_ gwindow (ipairs windows)]
        (when (and (not (window-matches window gwin)) (window-matches gwindow gwin))
          (gwindow:raise))
        ))
    ; find any matching focus actions
    (each [_ action (ipairs _G.focus-actions)]
      (if (window-matches window action) ((. action :fn) window)))
    ; we have to activate the application first
    ; otherwise, it won't always focus the correct window.
    (when (~= app (hs.application.frontmostApplication)) (app:activate))
    (window:becomeMain)
    (window:focus)
    ))

(set window-focus-watcher (hs.window.filter.new))
; TODO: Fix issue where focus does not return to the correct window.
(when window-focus-watcher
  (window-focus-watcher:subscribe hs.window.filter.windowFocused window-focused)
  (window-focus-watcher:setSortOrder hs.window.filter.sortByFocusedLast))

; }}}
; }}}
; {{{ Choosers
; {{{ - Utilities
(var chooser-focused-window nil)

(fn fuzzy [choices func]
  (set chooser-focused-window (hs.window.focusedWindow))
  (doto (hs.chooser.new func)
    (: :width 25)
    (: :searchSubText true)
    (: :choices choices)
    (: :show)))

; }}}
; {{{ - Selectors

(fn select-window [window]
  (when window (window.window:becomeMain) (window.window:focus)))

(fn show-window-fuzzy [app]
  (let [app-images {}
        focused-window (hs.window.focusedWindow)
        focused-id (when focused-window (focused-window:id))
        windows (if (= app nil) (hs.window.orderedWindows)
                  (= app true) (: (hs.application.frontmostApplication) :allWindows)
                  (= (type app) "string") (: (hs.application.open app) :allWindows)
                  (app:allWindows))
        choices #(icollect [_ window (ipairs windows)]
                  (let [win-app (window:application)]
                    (if (= (. app-images win-app) nil) ; cache the app image per app
                      (tset app-images win-app (hs.image.imageFromAppBundle (or (win-app:bundleID) ""))))
                    (let [text (window:title)
                          id (window:id)
                          active (= id focused-id)
                          subText (.. (win-app:title) (if active " (active)" ""))
                          image (. app-images win-app)
                          valid (= id focused-id)]
                      {: text : subText : image : valid : window})))]
    (fuzzy choices select-window)))

; }}}
; {{{ - Show/hide

(fn hide-focused-window [ ]
  (let [window (hs.window.focusedWindow)] (window:minimize)))

(fn focus-last-window [bundleid]
  "Focuses the previously active window."
  (let [app      (get-host-bundle-id bundleid)
        app      (hs.application.get app)
        windows  (hs.window.orderedWindows)]
    (when app
      (each [_ window (ipairs windows)]
        (when (app-matches app bundleid)
          (app:activate)
          (window:becomeMain)
          (window:focus)
          (lua "return true")
          )))
    false))

(fn focus-or-launch [bundleid]
  "Will try to focus a window or launch the application if no windows exist."
  (let [app (get-host-bundle-id bundleid)
        did-focus  (focus-last-window app)
        did-launch (hs.application.launchOrFocusByBundleID app)]
    (or did-focus did-launch)))

(fn show-app [bundleid func]
  "Activate app with bundleid.

  If already active, call (func or show-window-fuzzy)(app)"
  ; first make sure we have the correct bundle id
  (local bundleid (get-host-bundle-id bundleid))

  (let [focused-app (hs.application.frontmostApplication)]
    (if (not= bundleid (focused-app:bundleID))
      (focus-or-launch bundleid)
      ((or func show-window-fuzzy) focused-app))))

(fn toggle-window [new-window command]
  "Activates new-window. If new-window is already active, goes back to prior."
  (let [current-window (hs.window.focusedWindow)]
    (if (= new-window current-window)
      (let [last _G.last_window] (when last (last:focus)))
      (if new-window (new-window:focus) (command))
    (set _G.last_window current-window))))

; }}}
; {{{ - Switchers

(fn get-previous-window []
  "Returns a window object for the most-recent window"
  (let [windows (hs.window.orderedWindows)]
    (var found-one false) ; return the second "normal" window
    (for [i 1 (length windows)]
      (let [w (. windows i)]
        (when (not= (w:subrole) "AXUnknown")
          (if found-one (lua "return w") (set found-one true)))))))

(fn focus-previous-window []
  (: (get-previous-window) :focus))

(local window-switcher (hs.window.switcher.new nil))

; }}}
; {{{ - Audio
(fn select-audio [audio]
  (if audio
    (let [device (hs.audiodevice.findDeviceByUID audio.uid)]
      (hs.alert.show (.. "Setting " audio.subText " device: " (device:name)))
      (if (device:isOutputDevice)
        (device:setDefaultOutputDevice)
        (device:setDefaultInputDevice)))))

(fn show-audio-fuzzy []
  (let [devices (hs.audiodevice.allDevices)
        input-uid (: (hs.audiodevice.defaultInputDevice) :uid)
        output-uid (: (hs.audiodevice.defaultOutputDevice) :uid)
        choices #(icollect [_ device (ipairs devices)]
          (let [uid (device:uid)
                (active subText) (if (device:isOutputDevice)
                                  (values (= uid output-uid) "output")
                                  (values (= uid input-uid) "input"))
                text (device:name)
                subText (if active (.. subText " (active)") subText)
                uid (device:uid)
                valid (not active)]
            {: text : uid : subText : valid}))]
    (fuzzy choices select-audio)))
; }}}
; {{{ - Custom Clipboard

; track clipboard history
(local clipboard-menu (hs.menubar.new))
(local clipboard-history [])
(var clipboard-watcher nil)

(fn paste-clipboard-item [item]
  (when clipboard-watcher
  (local app (chooser-focused-window:application))
  (clipboard-watcher:stop)
  (hs.pasteboard.setContents item.value)
  (clipboard-watcher:start)
  (if (and chooser-focused-window
        (= _G.apps.windows-bundleid (app:bundleID)))
    (app:activate)
    (hs.eventtap.keyStroke [ "cmd" ] "v"))
  ))

(fn update-clipboard-title []
  "Updates the clipboard history menu title with the number of entries"
  (when clipboard-menu
    (doto clipboard-menu
      (: :setTitle (.. "📋 " "(" (length clipboard-history) ")")))))

(fn insert-clipboard-item [text]
  "Inserts an text in the clipboard history"
  (when text
    (var text text)
    (local pasteboard (require :hs.pasteboard))
    (local pattern "(%d+)/(%d+)/(%d+)")
    (if (string.find text (.. "^" pattern "$"))
      ; format copied dates from 01/01/25 to 01/01/2025
      (let [[month day year] (text:match pattern)]
        (if (= (length year) 2)
          (year (.. "20" year)))
        (set text (string.format "%02d/%02d/%d" month day year)))
      (doto pasteboard
        (: :setContents text)))
    (while (>= (length clipboard-history) clipboard-max-entries)
      (table.remove clipboard-history 1))
    (local label-length 25)
    (var label text)
    (if (> (length text) label-length)
        (set label (.. (text:gsub 0 label-length) "...")))
    (set label (label:gsub "\n" ""))
    (table.insert clipboard-history 1 { :label label :value text })
    (update-clipboard-title)))

(fn clipboard-contents-updated [item]
  (insert-clipboard-item item)
  (update-clipboard-title))

(fn on-clipboard-updated [item]
  (when clipboard-watcher
    (doto clipboard-watcher
      (: :stop))
    (clipboard-contents-updated item)
    (doto clipboard-watcher
      (: :start))
    ))

(set clipboard-watcher (hs.pasteboard.watcher.new on-clipboard-updated))

(when clipboard-menu
  (doto clipboard-menu
    (: :setTooltip "Clipboard History"))
  (update-clipboard-title))

(fn show-clipboard-fuzzy []
  (local choices [])
  (each [_ v (ipairs clipboard-history)]
      (table.insert choices { :text v.label :value v.value :valid true })
    (fuzzy choices paste-clipboard-item)))

; }}}
; }}}
; {{{ Keyboard shortcuts
; {{{ - Launchers

(hs.hotkey.bind hyper "b" #(show-app _G.apps.browser-bundleid))
(hs.hotkey.bind hyper "s" #(show-app _G.apps.terminal-bundleid))
(hs.hotkey.bind hyper "y" #(show-app _G.apps.music-bundleid focus-previous-window))
(hs.hotkey.bind hyper "m" #(show-app _G.apps.gmail-bundleid focus-previous-window))
(hs.hotkey.bind hyper "-" #(show-app _G.apps.calendar-bundleid focus-previous-window))
(hs.hotkey.bind hyper "c" #(show-app _G.apps.messages-bundleid focus-previous-window))
(hs.hotkey.bind hyper "w" #(show-app _G.apps.windows-bundleid focus-previous-window))
(hs.hotkey.bind hyper ";" #(show-app _G.apps.aichat-bundleid focus-previous-window))
(hs.hotkey.bind hyper "n" #(show-app _G.apps.notes-bundleid focus-previous-window))
(hs.hotkey.bind hyper "Space" #(show-window-fuzzy)) ; all windows
(hs.hotkey.bind hyper "." #(show-window-fuzzy true)) ; app windows
(hs.hotkey.bind hyper "a" #(show-audio-fuzzy))
(hs.hotkey.bind hyper "v" #(show-clipboard-fuzzy))
(hs.hotkey.bind hyper "h" #(system-open "~/"))
(hs.hotkey.bind hyper "d" #(system-open "~/Downloads"))
(hs.hotkey.bind hyper "t" #(system-open (. shortcut-uri :dashboard)))
(hs.hotkey.bind hyper "p" #(system-open (. shortcut-uri :passwords)))
(hs.hotkey.bind hyper "q" #(system-open (. shortcut-uri :obsidian-tasks)))

; }}}
; {{{ - Window management

(hs.hotkey.bind hyper "l" #(set-layout))
(hs.hotkey.bind hyper "g" #(move-active-window-to-next-screen))
(hs.hotkey.bind hyper "1" #(move-active-window nil 0    0    0.5  1))   ; first half
(hs.hotkey.bind hyper "2" #(move-active-window nil 0.5  0    0.5  1))   ; second half
(hs.hotkey.bind hyper "3" #(move-active-window nil 0    0    0.33 1))   ; first third
(hs.hotkey.bind hyper "4" #(move-active-window nil 0.33 0    0.33 1))   ; second third
(hs.hotkey.bind hyper "5" #(move-active-window nil 0.66 0    0.33 1))   ; third third
(hs.hotkey.bind hyper "6" #(move-active-window nil 0    0    0.66 1))   ; two-thirds, left
(hs.hotkey.bind hyper "7" #(move-active-window nil 0.33 0    0.66 1))   ; two-thirds, right
(hs.hotkey.bind hyper "8" #(move-active-window nil 0.17 0    0.66 1))   ; two-thirds, center
(hs.hotkey.bind hyper "9" #(move-active-window nil 0    0    1    1))   ; full screen
(hs.hotkey.bind hyper "=" #(move-active-window nil 0.1  0.05 0.8  0.9)) ; big picture
(hs.hotkey.bind hyper "0" #(focus-previous-window))    ; previous window (immediate)
(hs.hotkey.bind hyper "[" #(window-switcher:previous)) ; previous application window (chooser)
(hs.hotkey.bind hyper "]" #(window-switcher:next))     ; next application window (chooser)
(hs.hotkey.bind hyper "h" #(hide-focused-window))      ; minimize the current window
(set-layout)

; }}}
; }}}
; {{{ Imports / Exports

(require :local)

(global taskMenu (hs.menubar.new))
(global focusPreviousWindow focus-previous-window)

; }}}
