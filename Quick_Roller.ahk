#Persistent
#SingleInstance, Force
SetBatchLines, -1

; Global variables to store positions
savedX := 0
savedY := 0

; F1 sets the mouse position
F1::
MouseGetPos, savedX, savedY
Gui, Destroy
Gui, +AlwaysOnTop +ToolWindow -Caption
Gui, Color, Red
xPos := savedX + 3
yPos := savedY + 3
Gui, Show, x%xPos% y%yPos% w5 h5 NoActivate  ; Offset the dot slightly
return

; Spacebar clicks at saved position and returns
Space::
if (savedX = 0 && savedY = 0) {
    return
}

MouseGetPos, origX, origY  ; Store original position
MouseMove, savedX, savedY   ; Move to saved position
Click                        ; Perform click
MouseMove, origX, origY     ; Return to original position
return

; Ctrl + Esc to exit script
^Esc::
Gui, Destroy
ExitApp
return
