#Persistent
#SingleInstance Force

; GUI Setup
Gui, Add, Text, x20 y20 w200 h20, Select First Key:
Gui, Add, DropDownList, vFirstKey x150 y20 w200 Choose1, grave|1|2|3|4|5|6|7|8|9|0|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|enter|tab|space|shift|ctrl|alt|esc|f1|f2|f3|f4|f5|f6|f7|f8|f9|f10|f11|f12|up|down|left|right|home|end|pgup|pgdn|insert|delete|backspace|capslock|numlock|scrolllock|printscreen|pause|appskey|browser_back|browser_forward|browser_refresh|browser_stop|browser_search|browser_favorites|browser_home|volume_mute|volume_down|volume_up|media_next|media_prev|media_stop|media_play_pause|launch_mail|launch_media|launch_app1|launch_app2
Gui, Add, Text, x20 y60 w200 h20, Enter Text to Type:
Gui, Add, Edit, vInputText x150 y60 w200 h20, Your Text Here.
Gui, Add, Text, x20 y100 w200 h20, Select Second Key:
Gui, Add, DropDownList, vSecondKey x150 y100 w200 Choose1, enter|1|2|3|4|5|6|7|8|9|0|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|tab|space|shift|ctrl|alt|esc|f1|f2|f3|f4|f5|f6|f7|f8|f9|f10|f11|f12|up|down|left|right|home|end|pgup|pgdn|insert|delete|backspace|capslock|numlock|scrolllock|printscreen|pause|appskey|browser_back|browser_forward|browser_refresh|browser_stop|browser_search|browser_favorites|browser_home|volume_mute|volume_down|volume_up|media_next|media_prev|media_stop|media_play_pause|launch_mail|launch_media|launch_app1|launch_app2
Gui, Add, Text, x20 y140 w200 h20, Select Trigger Key (Default F8):
Gui, Add, DropDownList, vTriggerKey1 x150 y140 w200 Choose1, F8|F1|F2|F3|F4|F5|F6|F7|F9|F10|F11|F12
Gui, Add, Text, x20 y180 w360 h20, Press Selected Key to Execute the First Sequence

; Second Sequence
Gui, Add, Text, x20 y220 w200 h20, Select First Key:
Gui, Add, DropDownList, vFirstKey2 x150 y220 w200 Choose1, grave|1|2|3|4|5|6|7|8|9|0|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|enter|tab|space|shift|ctrl|alt|esc|f1|f2|f3|f4|f5|f6|f7|f8|f9|f10|f11|f12|up|down|left|right|home|end|pgup|pgdn|insert|delete|backspace|capslock|numlock|scrolllock|printscreen|pause|appskey|browser_back|browser_forward|browser_refresh|browser_stop|browser_search|browser_favorites|browser_home|volume_mute|volume_down|volume_up|media_next|media_prev|media_stop|media_play_pause|launch_mail|launch_media|launch_app1|launch_app2
Gui, Add, Text, x20 y260 w200 h20, Enter Text to Type:
Gui, Add, Edit, vInputText2 x150 y260 w200 h20, Your Text Here.
Gui, Add, Text, x20 y300 w200 h20, Select Second Key:
Gui, Add, DropDownList, vSecondKey2 x150 y300 w200 Choose1, enter|1|2|3|4|5|6|7|8|9|0|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|tab|space|shift|ctrl|alt|esc|f1|f2|f3|f4|f5|f6|f7|f8|f9|f10|f11|f12|up|down|left|right|home|end|pgup|pgdn|insert|delete|backspace|capslock|numlock|scrolllock|printscreen|pause|appskey|browser_back|browser_forward|browser_refresh|browser_stop|browser_search|browser_favorites|browser_home|volume_mute|volume_down|volume_up|media_next|media_prev|media_stop|media_play_pause|launch_mail|launch_media|launch_app1|launch_app2
Gui, Add, Text, x20 y340 w200 h20, Select Trigger Key:
Gui, Add, DropDownList, vTriggerKey2 x150 y340 w200 Choose1, F9|F1|F2|F3|F4|F5|F6|F7|F8|F10|F11|F12
Gui, Add, Text, x20 y380 w360 h20, Press Selected Key to Execute the Second Sequence

; Third Sequence
Gui, Add, Text, x20 y420 w200 h20, Select First Key:
Gui, Add, DropDownList, vFirstKey3 x150 y420 w200 Choose1, grave|1|2|3|4|5|6|7|8|9|0|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|enter|tab|space|shift|ctrl|alt|esc|f1|f2|f3|f4|f5|f6|f7|f8|f9|f10|f11|f12|up|down|left|right|home|end|pgup|pgdn|insert|delete|backspace|capslock|numlock|scrolllock|printscreen|pause|appskey|browser_back|browser_forward|browser_refresh|browser_stop|browser_search|browser_favorites|browser_home|volume_mute|volume_down|volume_up|media_next|media_prev|media_stop|media_play_pause|launch_mail|launch_media|launch_app1|launch_app2
Gui, Add, Text, x20 y460 w200 h20, Enter Text to Type:
Gui, Add, Edit, vInputText3 x150 y460 w200 h20, Your Text Here.
Gui, Add, Text, x20 y500 w200 h20, Select Second Key:
Gui, Add, DropDownList, vSecondKey3 x150 y500 w200 Choose1, enter|1|2|3|4|5|6|7|8|9|0|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|tab|space|shift|ctrl|alt|esc|f1|f2|f3|f4|f5|f6|f7|f8|f9|f10|f11|f12|up|down|left|right|home|end|pgup|pgdn|insert|delete|backspace|capslock|numlock|scrolllock|printscreen|pause|appskey|browser_back|browser_forward|browser_refresh|browser_stop|browser_search|browser_favorites|browser_home|volume_mute|volume_down|volume_up|media_next|media_prev|media_stop|media_play_pause|launch_mail|launch_media|launch_app1|launch_app2
Gui, Add, Text, x20 y540 w200 h20, Select Trigger Key:
Gui, Add, DropDownList, vTriggerKey3 x150 y540 w200 Choose1, F10|F1|F2|F3|F4|F5|F6|F7|F8|F9|F11|F12
Gui, Add, Text, x20 y580 w360 h20, Press Selected Key to Execute the Third Sequence

Gui, Show, w500 h620, Key Press Automation
return

; Sequence Handlers
#IfWinActive
$F8::
    GuiControlGet, FirstKey
    GuiControlGet, InputText
    GuiControlGet, SecondKey
    if (FirstKey = "grave")
        FirstKey := "``"
    if (SecondKey = "grave")
        SecondKey := "``"
    Send, {%FirstKey% down}
    Sleep, 50
    Send, {%FirstKey% up}
    Sleep, 150
    SendInput, %InputText%
    Sleep, 150
    Send, {%SecondKey% down}
    Sleep, 50
    Send, {%SecondKey% up}
return

$F9::
    GuiControlGet, FirstKey2
    GuiControlGet, InputText2
    GuiControlGet, SecondKey2
    if (FirstKey2 = "grave")
        FirstKey2 := "``"
    if (SecondKey2 = "grave")
        SecondKey2 := "``"
    Send, {%FirstKey2% down}
    Sleep, 50
    Send, {%FirstKey2% up}
    Sleep, 150
    SendInput, %InputText2%
    Sleep, 150
    Send, {%SecondKey2% down}
    Sleep, 50
    Send, {%SecondKey2% up}
return

$F10::
    GuiControlGet, FirstKey3
    GuiControlGet, InputText3
    GuiControlGet, SecondKey3
    if (FirstKey3 = "grave")
        FirstKey3 := "``"
    if (SecondKey3 = "grave")
        SecondKey3 := "``"
    Send, {%FirstKey3% down}
    Sleep, 50
    Send, {%FirstKey3% up}
    Sleep, 150
    SendInput, %InputText3%
    Sleep, 150
    Send, {%SecondKey3% down}
    Sleep, 50
    Send, {%SecondKey3% up}
return

GuiClose:
    ExitApp
