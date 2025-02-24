#Persistent
#SingleInstance Force

; 🔹 Default Key Selections, Delays, and Hold Times
DefaultKey1 := "e"
DefaultDelay1 := 11000
DefaultHold1 := 500
DefaultEnabled1 := true

DefaultKey2 := "lbutton"
DefaultDelay2 := 550
DefaultHold2 := 790
DefaultEnabled2 := false

DefaultKey3 := "c"
DefaultDelay3 := 1000
DefaultHold3 := 500
DefaultEnabled3 := false

DefaultKey4 := "6"
DefaultDelay4 := 1000
DefaultHold4 := 500
DefaultEnabled4 := false

; 🔹 Variables for toggling automation (Loaded from Defaults)
KeyEnabled1 := DefaultEnabled1
KeyEnabled2 := DefaultEnabled2
KeyEnabled3 := DefaultEnabled3
KeyEnabled4 := DefaultEnabled4
Running := false  

; Key options list
KeyOptions := "|up|down|left|right|f1|f2|f3|f4|f5|f6|f7|f8|f9|f10|f11|f12|lbutton|rbutton|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|0|1|2|3|4|5|6|7|8|9"

; GUI Setup
Gui, Add, Text, x20 y20 w200 h20, Press F8 to start/stop key presses:

Loop, 4 {
    yOffset := 40 + (A_Index - 1) * 140  

    ; 🔹 Key Selection
    Gui, Add, Text, x20 y%yOffset% w100 h20, Select Key %A_Index%:
    Gui, Add, DropDownList, vKeyChoice%A_Index% x120 y%yOffset% w100, % KeyOptions

    yOffset += 30
    ; 🔹 Delay Input
    Gui, Add, Text, x20 y%yOffset% w100 h20, Delay %A_Index% (ms):
    Gui, Add, Edit, vDelayInput%A_Index% x120 y%yOffset% w100 h20, % DefaultDelay%A_Index%

    yOffset += 30
    ; 🔹 Hold Time Input
    Gui, Add, Text, x20 y%yOffset% w100 h20, Hold Time %A_Index% (ms):
    Gui, Add, Edit, vHoldTime%A_Index% x120 y%yOffset% w100 h20, % DefaultHold%A_Index%

    yOffset += 30
    ; 🔹 Enable/Disable Button
    Gui, Add, Button, gToggleKey%A_Index% vButton%A_Index% x120 y%yOffset% w100 h20, % (KeyEnabled%A_Index% ? "Enabled" : "Disabled")

    yOffset += 20
    ; 🔹 Extra Spacing Before Next Key Section
    yOffset += 10  

    if (A_Index < 4) {
        Gui, Add, Text, x10 y%yOffset% w280 h1 +0x10  ; Horizontal Line
    }
}

Gui, Add, CheckBox, vRepeatCheckBox x20 y600 w150 h20 Checked, Repeat Continuously

; **Status Box (Larger & Bold)**
Gui, Font, s16 Bold
Gui, Add, Text, vStatusField x110 y630 w100 h40 +Center, Stopped
Gui, Font

Gui, Add, Button, gResetDefaults x120 y680 w100 h30, Reset Defaults
Gui, Show, w300 h730, Key Press Automation  

; 🔹 **Set Default Key Selections AFTER GUI Creation**
Loop, 4 {
    GuiControl, ChooseString, KeyChoice%A_Index%, % DefaultKey%A_Index%
}

; F8 Key Toggle (Starts/Stops Script)
F8::  
    Running := !Running  
    GuiControl, , StatusField, % Running ? "Started" : "Stopped"

    if (Running) {
        Gosub, StartAutomation
    } else {
        Gosub, StopAutomation
    }
return

StartAutomation:
    Loop, 4 {
        GuiControlGet, KeyChoice%A_Index%
        GuiControlGet, DelayInput%A_Index%
        GuiControlGet, HoldTime%A_Index%
    }
    GuiControlGet, RepeatState, , RepeatCheckBox
    RepeatEnabled := (RepeatState = 1)

    Loop, 4 {
        if (KeyEnabled%A_Index%) {
            SetTimer, KeyPress%A_Index%, % DelayInput%A_Index%
        }
    }
return

StopAutomation:
    Running := false  
    GuiControl, , StatusField, Stopped

    Loop, 4 {
        SetTimer, KeyPress%A_Index%, Off
        GuiControlGet, keyChoice, , KeyChoice%A_Index%
        if (keyChoice != "")
            Send, {%keyChoice% up}  
    }
return

; 🔹 Key Press Handlers
KeyPress1:
KeyPress2:
KeyPress3:
KeyPress4:
    thisKey := A_ThisLabel
    StringTrimLeft, keyNum, thisKey, 8

    if (!Running || !KeyEnabled%keyNum%) {
        SetTimer, % thisKey, Off
        return
    }

    GuiControlGet, keyChoice, , KeyChoice%keyNum%
    GuiControlGet, holdTime, , HoldTime%keyNum%

    if (keyChoice != "") {
        Send, {%keyChoice% down}
        Sleep, % holdTime
        Send, {%keyChoice% up}
    }

    if (!RepeatEnabled) {
        SetTimer, % thisKey, Off  
    }
return

; Toggle Key Functions
ToggleKey1:
ToggleKey2:
ToggleKey3:
ToggleKey4:
    thisToggle := A_ThisLabel
    StringTrimLeft, keyNum, thisToggle, 9

    KeyEnabled%keyNum% := !KeyEnabled%keyNum%
    GuiControl, , Button%keyNum%, % KeyEnabled%keyNum% ? "Enabled" : "Disabled"

    if (Running) {
        if (KeyEnabled%keyNum%) {
            SetTimer, KeyPress%keyNum%, % DelayInput%keyNum%
        } else {
            SetTimer, KeyPress%keyNum%, Off
        }
    }
return

; Reset Defaults Button
ResetDefaults:
    Loop, 4 {
        GuiControl, ChooseString, KeyChoice%A_Index%, % DefaultKey%A_Index%  
        GuiControl, , DelayInput%A_Index%, % DefaultDelay%A_Index%
        GuiControl, , HoldTime%A_Index%, % DefaultHold%A_Index%
        GuiControl, , Button%A_Index%, % DefaultEnabled%A_Index% ? "Enabled" : "Disabled"
        KeyEnabled%A_Index% := DefaultEnabled%A_Index%
    }
    GuiControl, , RepeatCheckBox, 1
    GuiControl, , StatusField, Stopped
    Running := false  
    Gosub, StopAutomation
return

GuiClose:
    ExitApp
return
