(local log (hs.logger.new :mouse-grid))

;; --- Configuration ---
;; Define the grid dimensions for the first and second stages.
;; Both are set to 3x3, meaning 9 cells per stage.
(local GRID-SIZE-LARGE {:w 10 :h 4})
(local GRID-SIZE-SMALL {:w 10 :h 4})

;; Key hints for selecting cells in the grid.
;; These correspond to a 3x3 layout (top-left to bottom-right).
;; NOTE: These MUST be strings for hs.hotkey, not keywords.
(local HINTS ["1" "2" "3" "4" "5" "6" "7" "8" "9" "0"
              "q" "w" "e" "r" "t" "y" "u" "i" "o" "p"
              "a" "s" "d" "f" "g" "h" "j" "k" "l" ";"
              "z" "x" "c" "v" "b" "n" "m" "," "." "/" ])

;; Colors for the grid overlay and text.
(local OVERLAY-COLOR {:red 0.2 :green 0.2 :blue 0.2 :alpha 0.5}) ;; Semi-transparent dark gray for grid cells
(local HIGHLIGHT-COLOR {:red 1.0 :green 0.8 :blue 0.0 :alpha 0.8}) ;; Not used in this version, but good for highlighting
(local TEXT-COLOR {:red 1.0 :green 1.0 :blue 1.0 :alpha 1.0})    ;; White text for hints
(local FONT-NAME nil) ;; Font for the key hints
(local FONT-SIZE 50) ;; Font size for the key hints

;; --- Global State ---
;; Variables to keep track of the current state of the grid selection process.
(var current-screen nil)              ;; The screen where the grid is displayed
(var large-grid-rects nil)            ;; List of hs.geometry.rect objects for the large grid cells
(var large-grid-overlay nil)          ;; List of hs.drawing objects for the large grid visual
(var small-grid-overlay nil)          ;; List of hs.drawing objects for the small grid visual
(var selected-large-cell-rect nil)    ;; The hs.geometry.rect of the cell selected in the first stage
(var interactive-mode nil)            ;; The currently selected mouse interaction mode.
(var first-stage-modal nil)           ;; The hs.hotkey.modal for the first selection stage
(var second-stage-modal nil)          ;; The hs.hotkey.modal for the second selection stage
(var init-fn nil)

;; --- Helper Functions ---

(fn hide-overlays [overlays]
  "Hides and deletes a list of hs.drawing objects.
   Args:
     overlays (table): A list of hs.drawing objects to hide and delete."
  (when overlays
    (each [_ drawing (ipairs overlays)]
      (drawing:hide)
      (drawing:delete))))

(fn next-interaction-mode []
  (let [mode (case interactive-mode
    :click :move
    :move :click)]
    (set interactive-mode mode)
    (hs.alert.show (.. "mode: " mode))))

(fn reset-mouse-grid []
  (hide-overlays small-grid-overlay)
  (second-stage-modal:exit)
  (hide-overlays large-grid-overlay)
  (first-stage-modal:exit)
  (init-fn))

(fn get-current-frame []
  "Gets the window or screen frame, whichever is selected."
  (if (pcall #(current-screen:role))
      (current-screen:frame)
      (current-screen:fullFrame)))

(fn get-current-screen []
  "Gets the active screen if a window is currently selected"
  (if (pcall #(current-screen:role))
    (do (set current-screen (hs.screen.mainScreen)) nil)
    current-screen))

(fn prev-screen []
  (when (get-current-screen)
    (set current-screen (current-screen:previous)))
  (reset-mouse-grid))

(fn next-screen []
  (when (get-current-screen)
    (set current-screen (current-screen:next)))
  (reset-mouse-grid))

(fn get-cell-center [rect]
  "Calculates the center point of an hs.geometry rect.
   Args:
     rect (hs.geometry.rect): The rectangle to find the center of.
   Returns:
     hs.geometry.point: The center point of the rectangle."
  (hs.geometry.point (+ (. rect :x) (/ (. rect :w) 2))
                     (+ (. rect :y) (/ (. rect :h) 2))))

(fn calculate-grid-cells [parent-rect grid-size]
  "Calculates the hs.geometry.rects for each cell in a grid within a given parent rectangle.
   Args:
     parent-rect (hs.geometry.rect): The bounding box for the grid.
     grid-size (table): A table with :w (width/columns) and :h (height/rows) for the grid.
   Returns:
     table: A list of hs.geometry.rect objects representing each cell."
  (let [cell-w (/ (. parent-rect :w) (. grid-size :w))
        cell-h (/ (. parent-rect :h) (. grid-size :h))
        cells []]
    ;; FIX: Loop from 0 to n-1, not 0 to n.
    (for [y 0 (- (. grid-size :h) 1)]
      (for [x 0 (- (. grid-size :w) 1)]
        (table.insert cells
                      (hs.geometry.rect
                        (+ (. parent-rect :x) (* x cell-w))
                        (+ (. parent-rect :y) (* y cell-h))
                        cell-w
                        cell-h))))
    cells))

(fn draw-grid-overlay [cells hints]
  "Draws the grid lines and key hints as hs.drawing objects.
   Args:
     cells (table): A list of hs.geometry.rect objects for the cells to draw.
     hints (table): A list of strings to use as key hints for each cell.
   Returns:
     table: A list of hs.drawing objects created."
  (let [drawings []]
    ;; FIX: Use ipairs to get a 1-based index, which matches the HINTS table.
    (each [idx cell-rect (ipairs cells)]
      ;; Draw cell rectangle
      (let [rect-drawing (hs.drawing.rectangle cell-rect)]
        (rect-drawing:setFillColor OVERLAY-COLOR)
        (rect-drawing:setStrokeColor {:red 0.5 :green 0.5 :blue 0.5 :alpha 0.8})
        (rect-drawing:setStrokeWidth 2)
        (rect-drawing:show)
        (table.insert drawings rect-drawing))

      ;; Draw hint text
      ;; FIX: Simplified text drawing using built-in alignment and proper font settings.
      (let [hint (or (. hints idx) (tostring idx)) ;; Fallback if not enough hints
            label-size (if (< FONT-SIZE (. cell-rect :w)) FONT-SIZE (math.floor (* (. cell-rect :w) 0.8)))
            center-y (- (/ (. cell-rect :h) 2) (/ label-size 2))
            text-rect (hs.geometry.rect (. cell-rect :x) (+ (. cell-rect :y) center-y) (. cell-rect :w) center-y)
            text-drawing (hs.drawing.text text-rect hint)]
        (text-drawing:setTextStyle { :alignment "center"
                                     :color TEXT-COLOR
                                     :font FONT-NAME
                                     :size label-size })
        (text-drawing:show)
        (table.insert drawings text-drawing)))
    drawings))

(fn exit-first-stage []
  "Exits the first stage modal and cleans up all overlays."
  (log.i "Exiting first stage modal.")
  (hide-overlays large-grid-overlay)
  (set large-grid-overlay nil)
  (set selected-large-cell-rect nil)
  (first-stage-modal:exit))

(fn exit-second-stage-and-return-to-first []
  "Exits the second stage modal and returns to the first stage, re-showing the large grid."
  (log.i "Returning to first stage modal.")
  (hide-overlays small-grid-overlay)
  (set small-grid-overlay nil)

  ;; Re-show the large grid overlay. It must be recreated because it was
  ;; deleted when the first stage was exited.
  (let [screen-frame (get-current-frame)]
    (set large-grid-overlay (draw-grid-overlay large-grid-rects HINTS))
    (log.i "Re-showing large grid overlay"))

  ;; Transition back to the first stage modal
  (second-stage-modal:exit)
  (first-stage-modal:enter))

;; --- Modal Callbacks ---

(fn table-find [tbl term]
  (each [i val (ipairs tbl)]
    (if (= term val)
      (lua "return i"))))

(fn handle-interaction [point]
  (when point
    (hs.mouse.absolutePosition point)
    (case interactive-mode
      :click (hs.eventtap.leftClick point)))

  ;; Clean up and exit all modals
  (hide-overlays small-grid-overlay)
  (set small-grid-overlay nil)
  (set selected-large-cell-rect nil)
  (second-stage-modal:exit)
  (log.i "Mouse moved and modals exited."))

(fn handle-center-selection []
  (let [frame selected-large-cell-rect
        center-point (get-cell-center frame)]
    (handle-interaction center-point)))

(fn handle-first-stage-selection [key]
  "Handles key presses in the first stage modal.
   Selects a large grid cell, hides the large grid, and shows the small grid."
  (let [index (table-find HINTS key)]
    (when index
      ;; A key corresponding to a hint was pressed.
      (set selected-large-cell-rect (. large-grid-rects index))
      (log.i (string.format "Selected large cell: %s" (hs.inspect selected-large-cell-rect)))

      ;; Hide and delete the large grid overlay
      (hide-overlays large-grid-overlay)

      ;; Calculate and draw the small grid within the selected large cell's bounds
      (let [small-cells (calculate-grid-cells selected-large-cell-rect GRID-SIZE-SMALL)]
        (set small-grid-overlay (draw-grid-overlay small-cells HINTS))
        (log.i "Showing small grid overlay"))

      ;; Transition from the first stage modal to the second stage modal
      (first-stage-modal:exit)
      (second-stage-modal:enter))))

(fn handle-second-stage-selection [key position]
  "Handles key presses in the second stage modal.
   Selects a small grid cell, moves the mouse, and cleans up."
  (let [index (table-find HINTS key)]
    (when index
      ;; Calculate the final cell's rectangle within the selected large cell
      (let [final-cell-rect (. (calculate-grid-cells selected-large-cell-rect GRID-SIZE-SMALL) index)
            center-point (get-cell-center final-cell-rect)
            half-height (/ (- (. center-point :y) (. final-cell-rect :y)) 2)
            offset (case position
                     1 (- 0 half-height)
                     2 0
                     3 half-height)
            click-point (center-point:move { :x 0 :y offset})]
        (handle-interaction click-point)

        (log.i (string.format "Selected final cell: %s" (hs.inspect final-cell-rect)))
        (log.i (string.format "Moving mouse to: %s" (hs.inspect click-point)))
        ))))

(fn setup-modals []
  "Initializes the two hotkey modals and binds their common keys (escape and selection hints)."
  (set first-stage-modal (hs.hotkey.modal.new))
  (set second-stage-modal (hs.hotkey.modal.new))

  ;; Bind escape key for first stage to exit completely
  (first-stage-modal:bind [] "escape" exit-first-stage)
  (first-stage-modal:bind [] "tab" next-screen)
  (first-stage-modal:bind ["shift"] "tab" prev-screen)
  (first-stage-modal:bind [] "space" next-interaction-mode)
  ;; Bind escape key for second stage to go back to the first stage
  (second-stage-modal:bind [] "escape" exit-second-stage-and-return-to-first)
  (second-stage-modal:bind [] "tab" next-screen)
  (second-stage-modal:bind ["shift"] "tab" prev-screen)
  (second-stage-modal:bind [] "space" next-interaction-mode)
  (second-stage-modal:bind [] "return" handle-center-selection)

  ;; Bind selection keys for both stages using the HINTS table
  ;; FIX: Use a `let` block to create a new scope for `hint` on each iteration.
  ;; This ensures the closure for the callback function captures the correct key.
  (each [_ hint (ipairs HINTS)]
    (let [captured-hint hint]
      (first-stage-modal:bind [] captured-hint (fn [] (handle-first-stage-selection captured-hint)))
      (second-stage-modal:bind ["shift"] captured-hint (fn [] (handle-second-stage-selection captured-hint 1)))
      (second-stage-modal:bind [] captured-hint (fn [] (handle-second-stage-selection captured-hint 2)))
      (second-stage-modal:bind ["ctrl"] captured-hint (fn [] (handle-second-stage-selection captured-hint 3)))
      )))

;; --- Main Entry Point ---

(fn start-mouse-grid [screen]
  "Initiates the two-stage mouse grid selection process.
   Gets the frontmost screen, calculates and draws the large grid, and enters the first modal."
  (log.i "Starting mouse grid selection.")
  (if (= nil current-screen)
    (set current-screen (hs.window.frontmostWindow)))
  (when current-screen
    ;; The error "attempt to index a function value" suggests that :frame is being
    ;; returned as a function, not a table. This can happen if an API expects a
    ;; method call (:) but receives property access (.). We change to a method call
    ;; to resolve the error.
    (let [screen-frame (get-current-frame)]
      ;; Calculate large grid cells once when starting
      (set large-grid-rects (calculate-grid-cells screen-frame GRID-SIZE-LARGE))
      ;; Draw the initial large grid overlay
      (set large-grid-overlay (draw-grid-overlay large-grid-rects HINTS))
      (log.i "Showing large grid overlay"))
      ;; Sets the default interaction mode
      (set interactive-mode :click)

    ;; Enter the first stage modal to await user input
    (first-stage-modal:enter)))

;; --- Initialization ---
;; Set up the modals and their key bindings when the script loads.
(setup-modals)
(set init-fn #(start-mouse-grid nil))

(log.i "hs.mouse-grid loaded. Press Cmd-Alt-G to activate the mouse grid.")

;; Return the module (optional, but good practice for Hammerspoon modules)
{ :start-mouse-grid init-fn }

