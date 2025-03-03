#Requires AutoHotkey v2
SetWorkingDir(A_ScriptDir)

; ---------- GLOBAL VARIABLES ----------
global pToken := 0           ; Initialize global token
global hModule := 0          ; Initialize hModule to prevent unassigned variable error
global clickX := 0           ; To store F1 position X
global clickY := 0           ; To store F1 position Y
global redDotGui := ""       ; GUI for persistent red dot
global redDotIsVisible := true  ; Track red dot's visible state
global isSearching := false  ; Blocks repeated Space presses in manual mode
global isF1Set := false      ; Tracks if F1 position is set
global isLooping := false    ; Tracks if auto-loop (F8) is running

; 🔍 Search Variables (Range with decimals)
global searchText1 := "melee damage increased by %:"
global searchRange1 := [50.0, 180.0]
global searchText2 := "chance to dodge %:"
global searchRange2 := [150.0, 600.0]

; Global: Maximum allowed failed searches
global failedSearchLimit := 100

; Global: Track failed search count
global failedSearchCount := 0

; For the red info box that displays the failed count:
global failedCountGui := ""
global failedCountTextControl := ""

; For the 20×20 space bar indicator (far right of screen, only in non-loop mode)
global spaceBarIndicatorGui := ""

; Global: Original mouse position at start of auto-loop
global loopOriginX := 0, loopOriginY := 0

; Fixed coordinates for screen capture
global startX := 497, startY := 1
global endX := 1909, endY := 977

; 📁 Create imgcheck folder if it doesn't exist
global imgcheckPath := A_ScriptDir . "\\imgcheck"
if !DirExist(imgcheckPath)
    DirCreate(imgcheckPath)

; ---------- OVERLAY GUI ----------
ShowOverlay()
; ---------- FAILED COUNT GUI ----------
ShowFailedCountGui()
; ---------- SPACE BAR INDICATOR (default visible in non-loop mode) ----------
ShowSpaceBarIndicator()

; ---------- LOAD GDI+ ----------
if (pToken != 0) {
    DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
    pToken := 0
}
if (hModule != 0) {
    DllCall("FreeLibrary", "Ptr", hModule)
    hModule := 0
}
Sleep(100)

attempts := 0
maxAttempts := 3
Loop {
    attempts++
    gdiplusPath := "C:\Windows\System32\Gdiplus.dll"
    hModule := DllCall("LoadLibrary", "Str", gdiplusPath, "Ptr")
    if (!hModule) {
        errorCode := DllCall("GetLastError")
        if (attempts >= maxAttempts) {
            MsgBox("❌ Failed to load Gdiplus.dll after " maxAttempts " attempts. Error Code: " errorCode, "Error", 16)
            ExitApp()
        }
        Sleep(200)
        continue
    }
    GdiplusStartupInput := Buffer(16, 0)
    NumPut("UInt", 1, GdiplusStartupInput, 0)
    initResult := DllCall("gdiplus\GdiplusStartup", "Ptr*", &pToken, "Ptr", GdiplusStartupInput, "Ptr", 0)
    if (initResult == 0)
        break
    if (attempts >= maxAttempts) {
        MsgBox("❌ Failed to initialize GDI+ after " maxAttempts " attempts. Error Code: " initResult, "Error", 16)
        ExitApp()
    }
    Sleep(200)
}

OnExit(ShutdownGDI)

; ---------- HOTKEYS ----------
F1::SetClickPosition()      ; Set F1 position
Space::SpacebarAction()
F8::StartAutoLoop()         ; F8 starts auto-loop
F9::StopAutoLoop()          ; F9 stops auto-loop
^Esc::ExitApp()             ; CTRL+ESC exits the script

; ------------------- FUNCTIONS -------------------

; --- OVERLAY GUI ---
ShowOverlay() {
    global overlayGui, searchText1, searchRange1, searchText2, searchRange2
    overlayGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Info Overlay")
    overlayGui.BackColor := "000000"
    overlayGui.SetFont("s10 cFFFFFF", "Segoe UI")
    WinSetTransparent(102, overlayGui.Hwnd)
    
    overlayText := "📋 Saddle Roller v1`n" 
        . "-------------------------------`n"
        . "🔍 Default Searching for:`n"
        . "   - " . searchText1 . " " . searchRange1[1] . " - " . searchRange1[2] . "`n"
        . "   - " . searchText2 . " " . searchRange2[1] . " - " . searchRange2[2] . "`n"
        . "(Can change in script)`n`n"
        . "🖱️ Controls:`n"
        . "   - F1: Set Click Position`n"
        . "   - SPACE: Start Single Search`n"
        . "   - F8: Start Auto Loop`n"
        . "   - F9: Stop Auto Loop`n"
        . "   - CTRL+ESC: Exit"
    
    overlayGui.Add("Text", "w260 h250", overlayText)
    overlayGui.Show("x10 y10")
}

; --- FAILED COUNT GUI ---
ShowFailedCountGui() {
    global failedCountGui, failedCountTextControl, failedSearchCount
    
    if (IsObject(failedCountGui))
        failedCountGui.Destroy()
    
    ; Create a 80×60 GUI with red background
    failedCountGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Failed Count")
    failedCountGui.BackColor := "FF0000"
    
    ; Font size 40 (4× the original size 10)
    failedCountGui.SetFont("s40 c000000", "Segoe UI")
    
    ; Add a text control that displays the failedSearchCount
    ; 80×60 box with center alignment so we can show 3 digits
    failedCountTextControl := failedCountGui.Add("Text", "w80 h60 Center", failedSearchCount)
    
    ; Show it below the main overlay (the main overlay is at x10 y10, height 250 -> let's place this at y265)
    failedCountGui.Show("x10 y265")
}

UpdateFailedCountGui() {
    global failedCountTextControl, failedSearchCount
    if (IsObject(failedCountTextControl)) {
        failedCountTextControl.Text := failedSearchCount
    }
}

; --- Make the red box flash green for success ---
FlashGreenCountGui(duration := 4000) {
    global failedCountGui
    if (!IsObject(failedCountGui))
        return
    failedCountGui.BackColor := "00FF00"  ; Turn the box green
    ; After 'duration' ms, revert to red
    SetTimer(() => failedCountGui.BackColor := "FF0000", -duration)
}

; --- SPACE BAR INDICATOR (20×20 box at far right) ---
ShowSpaceBarIndicator() {
    global spaceBarIndicatorGui
    if (!IsObject(spaceBarIndicatorGui)) {
        spaceBarIndicatorGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "SpaceBarIndicator")
        ; Start as green to show user can press space
        spaceBarIndicatorGui.BackColor := "00FF00"
        spaceBarIndicatorGui.Add("Text", "w20 h20")  ; blank text
        spaceBarIndicatorGui.Show("x" (A_ScreenWidth - 1000) " y120")
    } else {
        spaceBarIndicatorGui.Show()
    }
}

HideSpaceBarIndicator() {
    global spaceBarIndicatorGui
    if (IsObject(spaceBarIndicatorGui))
        spaceBarIndicatorGui.Hide()
}

SetSpaceBarIndicatorColor(color) {
    global spaceBarIndicatorGui
    if (IsObject(spaceBarIndicatorGui))
        spaceBarIndicatorGui.BackColor := color
}

; --- HOTKEY HANDLER FOR SPACE ---
SpacebarAction() {
    global isLooping, isSearching
    ; If user is spamming SPACE in manual mode, block extra presses
    if (!isLooping && isSearching)
        return
    
    if (!isLooping) {
        isSearching := true
        ; Turn the 20×20 indicator red to show SPACE is busy
        SetSpaceBarIndicatorColor("FF0000")
    }
    PerformClickAndOCR()
    
    if (!isLooping) {
        ; Turn it back to green once done
        SetSpaceBarIndicatorColor("00FF00")
    }
}

; --- SET CLICK POSITION ---
SetClickPosition() {
    global clickX, clickY, redDotGui, redDotIsVisible, isF1Set

    MouseGetPos(&clickX, &clickY)
    isF1Set := true
    
    if (IsObject(redDotGui))
        redDotGui.Destroy()
    ; Create red dot centered at the F1 position (10×10, offset by 5)
    redDotGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Red Dot")
    redDotGui.BackColor := "FF0000"
    redDotGui.Show("x" (clickX - 5) " y" (clickY - 5) " w10 h10 NoActivate")
    redDotIsVisible := true
    
    SetTimer(RedDotMonitor, 100)
    WinSetExStyle(0x20, "ahk_id " redDotGui.Hwnd)
}

; --- MONITOR RED DOT VISIBILITY ---
RedDotMonitor() {
    global redDotGui, redDotIsVisible, clickX, clickY
    local curX := 0, curY := 0
    MouseGetPos(&curX, &curY)
    local distance := Sqrt((curX - clickX)**2 + (curY - clickY)**2)
    if (distance < 10) {
        if redDotIsVisible {
            redDotGui.Hide()
            redDotIsVisible := false
        }
    } else {
        if (!redDotIsVisible) {
            redDotGui.Show()
            redDotIsVisible := true
        }
    }
}

; --- CLICK, RETURN, AND OCR ---
PerformClickAndOCR() {
    global clickX, clickY, isF1Set, isLooping, loopOriginX, loopOriginY

    if (!isF1Set) {
        ToolTip("⚠️ Set F1 Position First (Press F1)")
        Sleep(1000)
        ToolTip()
        return
    }
    
    ; Hide the red dot explicitly before moving the mouse to click
    if (IsObject(redDotGui))
        redDotGui.Hide()
    
    local origX := 0, origY := 0
    if (isLooping) {
        origX := loopOriginX
        origY := loopOriginY
    } else {
        MouseGetPos(&origX, &origY)
    }
    
    DllCall("SetCursorPos", "Int", clickX, "Int", clickY)
    Sleep(30)
    DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0)  ; Left Mouse Down
    Sleep(15)
    DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0)  ; Left Mouse Up
    
    DllCall("SetCursorPos", "Int", origX, "Int", origY)
    
    Sleep(1500)
    CaptureScreenAndRunOCR()
}

; --- SCREEN CAPTURE AND OCR ---
CaptureScreenAndRunOCR() {
    global startX, startY, endX, endY, pToken, imgcheckPath
    x := startX
    y := startY
    width := endX - startX
    height := endY - startY
    if (width <= 0 || height <= 0) {
        MsgBox("⚠️ Invalid region dimensions. Check coordinates.", "Error", 16)
        return
    }
    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    hdcMem := DllCall("gdi32.dll\CreateCompatibleDC", "Ptr", hdc, "Ptr")
    hbm := DllCall("gdi32.dll\CreateCompatibleBitmap", "Ptr", hdc, "Int", width, "Int", height, "Ptr")
    DllCall("gdi32.dll\SelectObject", "Ptr", hdcMem, "Ptr", hbm)
    DllCall("gdi32.dll\BitBlt", "Ptr", hdcMem, "Int", 0, "Int", 0, "Int", width, "Int", height, "Ptr", hdc, "Int", x, "Int", y, "UInt", 0x00CC0020)
    pBitmap := 0
    result := DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hbm, "Ptr", 0, "Ptr*", &pBitmap)
    if (result != 0 || !pBitmap) {
        MsgBox("❌ Failed to create GDI+ Bitmap. Error Code: " result, "Error", 16)
        DllCall("gdi32.dll\DeleteObject", "Ptr", hbm)
        DllCall("gdi32.dll\DeleteDC", "Ptr", hdcMem)
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
        return
    }
    capturedImagePath := imgcheckPath . "\\Captured_Image.png"
    CLSID := Buffer(16, 0)
    DllCall("ole32\CLSIDFromString", "WStr", "{557CF406-1A04-11D3-9A73-0000F81EF32E}", "Ptr", CLSID)
    saveResult := DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "WStr", capturedImagePath, "Ptr", CLSID, "Ptr", 0)
    if (saveResult != 0) {
        MsgBox("❌ Failed to save captured image. Error Code: " saveResult, "Error", 16)
    } else {
        RunTesseractOCR(capturedImagePath, pBitmap)
    }
    DllCall("gdi32.dll\DeleteObject", "Ptr", hbm)
    DllCall("gdi32.dll\DeleteDC", "Ptr", hdcMem)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
}

; --- RUN TESSERACT OCR (With Verification Pass) ---
RunTesseractOCR(imagePath, pBitmap) {
    global searchText1, searchRange1, searchText2, searchRange2
    global imgcheckPath, isLooping, isSearching
    global failedSearchCount, failedSearchLimit
    
    outputBase := imgcheckPath . "\\Captured_Image"
    ocrOutput := outputBase . "_1.txt"
    RunWait("tesseract.exe " . '"' . imagePath . '" "' . outputBase . '_1" --psm 6 --oem 1', , "Hide")
    
    if (FileExist(ocrOutput)) {
        extractedText := Trim(FileRead(ocrOutput, "UTF-8"))
        foundMatch := false
        
        if RegExMatch(extractedText, "(?i)" . searchText1 . "\s*(\d+(\.\d+)?)", &match1) {
            value1 := match1[1]
            if (value1 >= searchRange1[1] && value1 <= searchRange1[2]) {
                foundMatch := true
            }
        }
        if RegExMatch(extractedText, "(?i)" . searchText2 . "\s*(\d+(\.\d+)?)", &match2) {
            value2 := match2[1]
            if (value2 >= searchRange2[1] && value2 <= searchRange2[2]) {
                foundMatch := true
            }
        }
        
        if (foundMatch) {
            failedSearchCount := 0
            UpdateFailedCountGui()
            FlashGreenCountGui(4000)  ; Flash the red box green for 4 seconds
            
            ; "Success" actions:
            Sleep(1000)
            Sleep(300)
            Send("t")
            Sleep(500)
            DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0)
            Sleep(15)
            DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0)
            Sleep(1200)
        } else {
            if (isLooping) {
                failedSearchCount++  ; Increase only in loop mode
                UpdateFailedCountGui()
            }
        }
        
        if (failedSearchCount >= failedSearchLimit) {
            isLooping := false
            MsgBox("⚠️ Search failed " failedSearchLimit " times. Stopping auto loop.", "Loop Stopped", 16)
            return
        }
        
        Sleep(500)
        if (isLooping) {
            SetTimer(PerformClickAndOCR, -200)
        } else {
            isSearching := false
        }
    } else {
        MsgBox("❌ Tesseract OCR failed or returned no text.", "Error", 16)
        if (!isLooping)
            isSearching := false
    }
}

; --- COMPARE TWO OCR RESULTS ---
CompareOCRResults(text1, text2) {
    text1 := StrLower(RegExReplace(text1, "\s+", " "))
    text2 := StrLower(RegExReplace(text2, "\s+", " "))
    similarityThreshold := 0.85
    matchCount := 0
    
    wordList1 := StrSplit(text1, " ")
    wordList2 := Map()
    for word in StrSplit(text2, " ")
        wordList2[word] := true
    
    for word in wordList1 {
        if wordList2.Has(word)
            matchCount++
    }
    percentageMatch := matchCount / Max(1, wordList1.Length)
    return (percentageMatch >= similarityThreshold)
}

; --- START AUTO LOOP (F8) ---
StartAutoLoop() {
    global isLooping, isF1Set, loopOriginX, loopOriginY
    
    if (!isF1Set) {
        ToolTip("⚠️ Set F1 Position First (Press F1)")
        Sleep(1000)
        ToolTip()
        return
    }
    if (isLooping) {
        ToolTip("🔄 Loop already running...")
        Sleep(1000)
        ToolTip()
        return
    }
    ; Save the current mouse position as the loop origin
    MouseGetPos(&loopOriginX, &loopOriginY)
    isLooping := true
    ToolTip("🔄 Auto Loop Started (Press F9 to stop)")
    Sleep(1000)
    ToolTip()
    SetTimer(PerformClickAndOCR, -100)
    
    ; Hide the space bar indicator while in loop mode
    HideSpaceBarIndicator()
}

; --- STOP AUTO LOOP (F9) ---
StopAutoLoop() {
    global isLooping, failedSearchCount, loopOriginX, loopOriginY
    isLooping := false
    failedSearchCount := 0
    loopOriginX := 0
    loopOriginY := 0  ; Reset loop origin so manual positioning is used next
    UpdateFailedCountGui()
    
    ; Show the space bar indicator again in non-loop mode
    ShowSpaceBarIndicator()
    
    ToolTip("⛔ Auto Loop Stopped. Failed searches reset.")
    Sleep(1500)
    ToolTip()
}

; --- SHUTDOWN HANDLER ---
ShutdownGDI(*) {
    global pToken, redDotGui, imgcheckPath
    if (pToken != 0)
        DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
    if (IsObject(redDotGui))
        redDotGui.Destroy()
    if FileExist(imgcheckPath . "\\Captured_Image.png")
        FileDelete(imgcheckPath . "\\Captured_Image.png")
    if FileExist(imgcheckPath . "\\Captured_Image.txt")
        FileDelete(imgcheckPath . "\\Captured_Image.txt")
    ExitApp()
}
