#Requires AutoHotkey v2
SetWorkingDir(A_ScriptDir)

global pToken := 0  ; Initialize global token
global clickX := 0  ; To store F1 position X
global clickY := 0  ; To store F1 position Y
global redDotGui := ""  ; GUI for persistent red dot
global isSearching := false  ; Blocks repeated Space presses in manual mode
global isF1Set := false       ; Tracks if F1 position is set
global isLooping := false     ; Tracks if auto-loop (F8) is running

; 🔍 Search Variables (Range with decimals)
global searchText1 := "magic find increased by %:"
global searchRange1 := [15.0, 60.0]
global searchText2 := "chance to dodge %:"
global searchRange2 := [15.0, 60.0]

; Fixed coordinates for screen capture
global startX := 497, startY := 1
global endX := 1909, endY := 977

; 📁 Create imgcheck folder if it doesn't exist (using double backslash)
global imgcheckPath := A_ScriptDir . "\\imgcheck"
if !DirExist(imgcheckPath)
    DirCreate(imgcheckPath)

; Overlay GUI
ShowOverlay()

; Load GDIPlus.dll from System32
gdiplusPath := "C:\Windows\System32\Gdiplus.dll"
hModule := DllCall("LoadLibrary", "Str", gdiplusPath, "Ptr")
if (!hModule) {
    errorCode := DllCall("GetLastError")
    MsgBox("❌ Failed to load Gdiplus.dll.`nError Code: " errorCode, "Error", 16)
    ExitApp()
}

; Initialize GDI+
GdiplusStartupInput := Buffer(16, 0)
NumPut("UInt", 1, GdiplusStartupInput, 0)  ; Set GDI+ version to 1
initResult := DllCall("gdiplus\GdiplusStartup", "Ptr*", &pToken, "Ptr", GdiplusStartupInput, "Ptr", 0)
if (initResult != 0) {
    MsgBox("❌ Failed to initialize GDI+. Error Code: " initResult, "Error", 16)
    ExitApp()
}

; Bind shutdown function to exit (which will also delete captured files)
OnExit(ShutdownGDI)

; ---------- HOTKEYS ----------
F1::SetClickPosition()      ; Set F1 position

Space:: {  ; Spacebar triggers click + OCR in manual mode
    global isLooping, isSearching
    if (!isLooping && isSearching)
        return
    if (!isLooping)
        isSearching := true
    PerformClickAndOCR()
}

F8::StartAutoLoop()         ; F8 starts auto-loop
F9::StopAutoLoop()          ; F9 stops auto-loop
^Esc::ExitApp()             ; CTRL+ESC exits the script

; ---------- OVERLAY GUI ----------
ShowOverlay() {
    global overlayGui
    overlayGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Info Overlay")
    overlayGui.BackColor := "000000"  ; Black background
    WinSetTransparent(102, overlayGui.Hwnd)
    overlayGui.SetFont("s10 cFFFFFF", "Segoe UI")
    
    overlayText :=
    "
    (
    📋 **Reroller OCR Script**
    -------------------------------
    🔍 Searching for:
    - Magic find Increased By %: 15.0-60.0
    - Chance to Dodge %: 15.0-60.0

    🖱️ Controls:
    - F1: Set Button Press
    - SPACE: Start Single Search (manual mode blocks repeated presses until completion)
    - F8: Start Auto Loop
    - F9: Stop Auto Loop
    - CTRL+ESC: Exit
    )"
    
    overlayGui.Add("Text", "w210 h200", overlayText)
    overlayGui.Show("x10 y10")
}

; ---------- SET CLICK POSITION ----------
SetClickPosition() {
    global clickX, clickY, redDotGui, isF1Set
    MouseGetPos(&clickX, &clickY)
    isF1Set := true
    if (IsObject(redDotGui))
        redDotGui.Destroy()
    redDotGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Red Dot")
    redDotGui.BackColor := "FF0000"
    redDotGui.Show("x" clickX + 15 " y" clickY - 5 " w10 h10 NoActivate")
    WinSetTransparent(150, redDotGui.Hwnd)
    WinSetExStyle(0x20, "ahk_id " redDotGui.Hwnd)
}

; ---------- CLICK, RETURN, AND OCR ----------
PerformClickAndOCR() {
    global clickX, clickY, isF1Set, isLooping
    if (!isF1Set) {
        ToolTip("⚠️ Set F1 Position First (Press F1)")
        Sleep(1500)
        ToolTip()
        return
    }
    local origX := 0, origY := 0
    MouseGetPos(&origX, &origY)
    Sleep(100)
    DllCall("SetCursorPos", "Int", clickX, "Int", clickY)
    Sleep(100)
    DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0)
    Sleep(50)
    DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0)
    DllCall("SetCursorPos", "Int", origX, "Int", origY)
    Sleep(200)
    DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0)
    Sleep(50)
    DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0)
    Sleep(1000)
    CaptureScreenAndRunOCR()
}

; ---------- SCREEN CAPTURE AND OCR ----------
CaptureScreenAndRunOCR() {
    global startX, startY, endX, endY, pToken, imgcheckPath
    x := startX, y := startY
    width := endX - startX, height := endY - startY
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

; ---------- RUN TESSERACT OCR ----------
RunTesseractOCR(imagePath, pBitmap) {
    global searchText1, searchRange1, searchText2, searchRange2, imgcheckPath, isLooping, isSearching
    outputBase := imgcheckPath . "\\Captured_Image"
    ocrOutput := outputBase . ".txt"
    RunWait("tesseract.exe " . '"' . imagePath . '" "' . outputBase . '" --psm 6 --oem 1', , "Hide")
    if FileExist(ocrOutput) {
        extractedText := Trim(FileRead(ocrOutput, "UTF-8"))
        foundMatch := false
        resultMessage := ""
        if RegExMatch(extractedText, "(?i)" . searchText1 . "\s*(\d+(\.\d+)?)", &match1) {
            value1 := match1[1]
            if (value1 >= searchRange1[1] && value1 <= searchRange1[2]) {
                foundMatch := true
                resultMessage .= "Magic Find matched with value: " value1 ". "
            }
        }
        if RegExMatch(extractedText, "(?i)" . searchText2 . "\s*(\d+(\.\d+)?)", &match2) {
            value2 := match2[1]
            if (value2 >= searchRange2[1] && value2 <= searchRange2[2]) {
                foundMatch := true
                resultMessage .= "Chance to Dodge matched with value: " value2 "."
            }
        }
        if (foundMatch) {
            ShowResultBox("00FF00", 5000)
            if (isLooping) {
                DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0)
                Sleep(50)
                DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0)
                Sleep(500)
                Send("t")
                Sleep(200)
                DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0)
                Sleep(50)
                DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0)
                Sleep(1000)
                if (isLooping)
                    PerformClickAndOCR()
            } else {
                Sleep(5000)
                isSearching := false
            }
        } else {
            ShowResultBox("FF0000", 2000)
            if (isLooping) {
                Sleep(2000)
                PerformClickAndOCR()
            } else {
                isSearching := false
            }
        }
    } else {
        MsgBox("❌ Tesseract OCR failed or returned no text.", "Error", 16)
        if (!isLooping)
            isSearching := false
    }
}

; ---------- SHOW RESULT BOX ----------
ShowResultBox(color, duration) {
    resultGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Result Indicator")
    resultGui.BackColor := color
    xPos := A_ScreenWidth - 230, yPos := 200
    resultGui.Show("x" xPos " y" yPos " w210 h30 NoActivate")
    SetTimer(() => resultGui.Destroy(), -duration)
}

; ---------- START AUTO LOOP (F8) ----------
StartAutoLoop() {
    global isLooping, isF1Set
    if (!isF1Set) {
        ToolTip("⚠️ Set F1 Position First (Press F1)")
        Sleep(1500)
        ToolTip()
        return
    }
    if (isLooping) {
        ToolTip("🔄 Loop already running...")
        Sleep(1500)
        ToolTip()
        return
    }
    isLooping := true
    ToolTip("🔄 Auto Loop Started (Press F9 to stop)")
    Sleep(1500)
    ToolTip()
    PerformClickAndOCR()
}

; ---------- STOP AUTO LOOP (F9) ----------
StopAutoLoop() {
    global isLooping
    isLooping := false
    ToolTip("⛔ Auto Loop Stopped")
    Sleep(1500)
    ToolTip()
}

; ---------- SHUTDOWN HANDLER ----------
ShutdownGDI(*) {
    global pToken, redDotGui, imgcheckPath
    if (pToken != 0) {
        DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
    }
    if (IsObject(redDotGui))
        redDotGui.Destroy()
    if FileExist(imgcheckPath . "\\Captured_Image.png")
        FileDelete(imgcheckPath . "\\Captured_Image.png")
    if FileExist(imgcheckPath . "\\Captured_Image.txt")
        FileDelete(imgcheckPath . "\\Captured_Image.txt")
    ExitApp()
}
