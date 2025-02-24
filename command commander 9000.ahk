#Persistent
#SingleInstance Force

; GUI Setup
Gui, Add, Text, x20 y20 w200 h20, Select First Key:
Gui, Add, DropDownList, vFirstKey x150 y20 w120, `|1|2|3|4|5|6|7|8|9|0|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|enter|tab|space|shift|ctrl|alt|esc

Gui, Add, Text, x20 y60 w200 h20, Enter Text to Type:
Gui, Add, Edit, vInputText x150 y60 w200 h20

Gui, Add, Text, x20 y100 w200 h20, Select Second Key:
Gui, Add, DropDownList, vSecondKey x150 y100 w120, enter|1|2|3|4|5|6|7|8|9|0|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|tab|space|shift|ctrl|alt|esc

Gui, Add, Text, x20 y140 w200 h20, Press F8 to Execute the Sequence

Gui, Show, w400 h180, Key Press Automation
return

; F8 Key to Trigger the Sequence
F8::
    GuiControlGet, FirstKey
    GuiControlGet, InputText
    GuiControlGet, SecondKey

    if (FirstKey = "") {
        MsgBox, Please select the first key.
        return
    }
    if (SecondKey = "") {
        MsgBox, Please select the second key.
        return
    }

    ; Press First Key
    Send, {%FirstKey% down}
    Sleep, 50
    Send, {%FirstKey% up}

    Sleep, 150

    ; Type Input Text
    SendInput, %InputText%

    Sleep, 150

    ; Press Second Key
    Send, {%SecondKey% down}
    Sleep, 50
    Send, {%SecondKey% up}
return

GuiClose:
    ExitApp
