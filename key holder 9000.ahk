#Persistent
#SingleInstance Force

; ----- Default Setting -----
DefaultKey := "e"
Running := false

; ----- GUI Setup -----
Gui, Add, Text, x20 y20 w200 h20, Select Key to Hold Down:
Gui, Add, DropDownList, vKeyChoice x20 y50 w140, |up|down|left|right|f1|f2|f3|f4|f5|f6|f7|f8|f9|f10|f11|f12|lbutton|rbutton|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|0|1|2|3|4|5|6|7|8|9
Gui, Add, Button, gResetDefaults x170 y50 w60 h20, Reset
Gui, Add, Text, vStatusField x20 y90 w200 h30, Stopped
Gui, Show, w250 h150, Key Hold Automation

; Set the default key in the dropdown.
GuiControl, ChooseString, KeyChoice, %DefaultKey%

; ----- F8 Hotkey: Toggle Hold/Release -----
F8::
    ToggleHold()
return

ToggleHold() {
    global Running
    Running := !Running
    GuiControl, , StatusField, % Running ? "Holding Key" : "Stopped"
    GuiControlGet, selectedKey, , KeyChoice
    if (selectedKey = "")
    {
        MsgBox, Please select a key first.
        Running := false
        GuiControl, , StatusField, Stopped
        return
    }
    if (Running) {
        ; Send the key down (simulate holding it)
        Send, {%selectedKey% down}
    } else {
        ; Release the held key
        Send, {%selectedKey% up}
    }
}

; ----- Reset Button: Revert back to default key -----
ResetDefaults:
    GuiControl, ChooseString, KeyChoice, %DefaultKey%
return

; ----- Ensure the held key is released on exit -----
GuiClose:
    GuiControlGet, selectedKey, , KeyChoice
    if (Running && selectedKey != "")
        Send, {%selectedKey% up}
    ExitApp
return
