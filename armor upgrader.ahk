#Requires AutoHotkey v2.0+

global targetX := 0, targetY := 0
global loopRunning := false

F1::{
    global
    MouseGetPos &targetX, &targetY
    ToolTip("Target position set!", targetX + 10, targetY + 10)
    SetTimer () => ToolTip(), -1000 ; Hide tooltip after 1s
}

F8::{
    global loopRunning
    loopRunning := !loopRunning
    if loopRunning {
        Notify("Loop Started")
        SetTimer StartClickLoop, 10
    } else {
        Notify("Loop Stopped")
        SetTimer StartClickLoop, 0 ; Stops the function
    }
}

^Esc:: {
    Notify("Script Exiting...")
    Sleep 1000
    ExitApp
}

StartClickLoop() {
    global loopRunning
    static originalX := 0, originalY := 0

    if (!loopRunning) {
        return ; Exit if loop is stopped
    }

    MouseGetPos &originalX, &originalY
    MouseMove targetX, targetY, 10

    ; Click 9 times with 1-second delay
    Loop 9 {
        if (!loopRunning) {
            return ; Stop mid-loop if F8 is pressed
        }
        Click
        Sleep 1500
    }

    ; Move back to original position
    MouseMove originalX, originalY, 10
    Sleep 500

    ; Press "T", wait 250ms, then left-click
    Send "T"
    Sleep 500
    Click

    ; Ensure delay before repeating
    Sleep 2000

    ; Re-run the function if loop is still active
    if (loopRunning) {
        SetTimer StartClickLoop, 10
    }
}

Notify(msg) {
    CoordMode "ToolTip", "Screen"
    ToolTip(msg, A_ScreenWidth / 2, A_ScreenHeight / 2)
    SetTimer () => ToolTip(), -1500 ; Hide after 1.5s
}
