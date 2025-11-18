; DC_Browser_Messaging.ahk - AutoHotkey v2 Script for DC ↔ Browser AI Communication
; Version 1.0 - Window injection for browser automation coordination

#Requires AutoHotkey v2.0

; Configuration
global BrowserMessagePath := A_ScriptDir . "\config\browser_msg.json"
global BrowserTitles := ["Chrome", "Firefox", "Edge", "Brave", "Opera"]
global InjectionDelay := 150
global MessageTimeout := 5000 ; milliseconds

; Window class patterns for different browsers
global BrowserClasses := {
    "Chrome": "Chrome_WidgetWin_1",
    "Firefox": "MozillaWindowClass",
    "Edge": "Chrome_WidgetWin_1",
    "Brave": "Chrome_WidgetWin_1",
    "Opera": "Chrome_WidgetWin_1"
}

; Initialize logging
global LogFilePath := A_ScriptDir . "\logs\browser_messaging.log"
if !DirExist(A_ScriptDir . "\logs")
    DirCreate(A_ScriptDir . "\logs")

LogMessage(message) {
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    logEntry := timestamp . " - [Browser] " . message . "`n"
    FileAppend(logEntry, LogFilePath)
}

; Find active browser window
FindActiveBrowser() {
    for title in BrowserTitles {
        for windowClass in BrowserClasses {
            windowTitle := title . " - " ; Common browser title pattern
            
            ; Try exact match first
            if WinExist(windowTitle . "ahk_class " . windowClass) {
                return {title: windowTitle, class: windowClass, browser: title}
            }
            
            ; Try partial match
            if WinExist("ahk_class " . windowClass) {
                WinGetTitle, currentTitle, "ahk_class " . windowClass
                if InStr(currentTitle, title) {
                    return {title: currentTitle, class: windowClass, browser: title}
                }
            }
        }
    }
    
    ; Try to find any browser window
    if WinExist("ahk_class Chrome_WidgetWin_1") {
        WinGetTitle, title, "ahk_class Chrome_WidgetWin_1"
        return {title: title, class: "Chrome_WidgetWin_1", browser: "Chrome"}
    }
    
    if WinExist("ahk_class MozillaWindowClass") {
        WinGetTitle, title, "ahk_class MozillaWindowClass"
        return {title: title, class: "MozillaWindowClass", browser: "Firefox"}
    }
    
    return false
}

; Inject message into browser console/developer tools
InjectBrowserMessage(browserInfo, message) {
    LogMessage("Injecting message into " . browserInfo.browser . ": " . message.type)
    
    try {
        ; Activate browser window
        if !WinActivate(browserInfo.title . " ahk_class " . browserInfo.class) {
            throw Error("Cannot activate browser: " . browserInfo.title)
        }
        
        Sleep(InjectionDelay)
        
        ; Open developer tools (F12)
        Send("{F12}")
        Sleep(500)
        
        ; Switch to console tab if needed
        Send("^`") ; Switch to console in dev tools
        Sleep(200)
        
        ; Clear console and inject message
        Send("{LCtrl down}{l down}{LCtrl up}{l up}") ; Clear console
        Sleep(100)
        
        ; Format message as JavaScript
        jsMessage := Format('window.agentMessages = window.agentMessages || []; window.agentMessages.push({}); console.log("AGENT_MSG: {}");', 
                           JSON.Stringify(message), message.type)
        
        Send(jsMessage)
        Sleep(InjectionDelay)
        Send("{Enter}")
        
        LogMessage("Browser message injected successfully")
        return true
    } catch as e {
        LogMessage("Browser injection failed: " . e.message)
        return false
    }
}

; Send message to Browser AI
SendToBrowser(messageType, data) {
    LogMessage("Preparing message for Browser AI: " . messageType)
    
    message := {
        from: "DC",
        to: "Browser",
        type: messageType,
        timestamp: FormatTime(, "yyyy-MM-ddTHH:mm:ssZ"),
        turn: A_TickCount,
        data: data
    }
    
    ; Find active browser
    browserInfo := FindActiveBrowser()
    if !browserInfo {
        LogMessage("No active browser found")
        return false
    }
    
    ; Inject message
    return InjectBrowserMessage(browserInfo, message)
}

; Receive messages from Browser AI (via JavaScript bridge)
ReceiveFromBrowser() {
    LogMessage("Checking for browser messages")
    
    ; Check for browser-generated message files
    messageFiles := []
    loop Files, A_ScriptDir . "\config\browser_msg_*.json" {
        messageFiles.Push(A_LoopFileFullPath)
    }
    
    for filePath in messageFiles {
        try {
            messageJson := FileRead(filePath)
            message := JSON.Parse(messageJson)
            
            LogMessage("Received browser message: " . message.type)
            
            ; Process browser message
            switch message.type {
                case "page_loaded":
                    HandlePageLoaded(message)
                case "element_found":
                    HandleElementFound(message)
                case "interaction_complete":
                    HandleInteractionComplete(message)
                case "navigation_complete":
                    HandleNavigationComplete(message)
                case "error":
                    HandleBrowserError(message)
                default:
                    LogMessage("Unknown browser message type: " . message.type)
            }
            
            ; Clean up processed message
            FileDelete(filePath)
        } catch as e {
            LogMessage("Error processing browser message: " . e.message)
        }
    }
}

; Message handlers for browser communications
HandlePageLoaded(message) {
    LogMessage("Page loaded: " . message.data.url)
    
    ; Update shared context with page info
    pageInfo := {
        url: message.data.url ?? "",
        title: message.data.title ?? "",
        timestamp: message.timestamp,
        elements: message.data.elements ?? {}
    }
    
    ; Send page info to VSCC for processing
    SendToVSCC("page_info", pageInfo)
}

HandleElementFound(message) {
    LogMessage("Element found: " . message.data.selector)
    
    elementInfo := {
        selector: message.data.selector ?? "",
        element_type: message.data.element_type ?? "",
        visible: message.data.visible ?? false,
        interactive: message.data.interactive ?? false
    }
    
    ; Send element info to STRYK for decision making
    SendToSTRYK("element_discovery", elementInfo)
}

HandleInteractionComplete(message) {
    LogMessage("Interaction completed: " . message.data.action)
    
    interactionResult := {
        action: message.data.action ?? "",
        element: message.data.element ?? "",
        success: message.data.success ?? false,
        result: message.data.result ?? ""
    }
    
    ; Send result to appropriate agent based on action type
    if (InStr(interactionResult.action, "click") || InStr(interactionResult.action, "type")) {
        SendToDC("ui_result", interactionResult)
    } else if (InStr(interactionResult.action, "extract") || InStr(interactionResult.action, "scrape")) {
        SendToVSCC("data_result", interactionResult)
    }
}

HandleNavigationComplete(message) {
    LogMessage("Navigation complete: " . message.data.destination)
    
    navResult := {
        destination: message.data.destination ?? "",
        success: message.data.success ?? false,
        load_time: message.data.load_time ?? 0
    }
    
    ; Send navigation result to STRYK for workflow continuation
    SendToSTRYK("navigation_result", navResult)
}

HandleBrowserError(message) {
    LogMessage("Browser error: " . message.data.error)
    
    errorInfo := {
        error_type: message.data.error_type ?? "unknown",
        error_message: message.data.error ?? "",
        url: message.data.url ?? "",
        timestamp: message.timestamp
    }
    
    ; Send error to STRYK for recovery
    SendToSTRYK("browser_error", errorInfo)
}

; Send message to other agents
SendToVSCC(messageType, data) {
    messageFile := A_ScriptDir . "\config\msg_VSCC_browser_" . A_TickCount . ".json"
    message := {
        from: "Browser",
        to: "VSCC",
        type: messageType,
        timestamp: FormatTime(, "yyyy-MM-ddTHH:mm:ssZ"),
        data: data
    }
    FileAppend(JSON.Stringify(message), messageFile)
}

SendToSTRYK(messageType, data) {
    messageFile := A_ScriptDir . "\config\msg_STRYK_browser_" . A_TickCount . ".json"
    message := {
        from: "Browser",
        to: "STRYK",
        type: messageType,
        timestamp: FormatTime(, "yyyy-MM-ddTHH:mm:ssZ"),
        data: data
    }
    FileAppend(JSON.Stringify(message), messageFile)
}

SendToDC(messageType, data) {
    messageFile := A_ScriptDir . "\config\msg_DC_browser_" . A_TickCount . ".json"
    message := {
        from: "Browser",
        to: "DC",
        type: messageType,
        timestamp: FormatTime(, "yyyy-MM-ddTHH:mm:ssZ"),
        data: data
    }
    FileAppend(JSON.Stringify(message), messageFile)
}

; Hotkeys for manual browser interaction testing
^!b:: ; Ctrl+Alt+B - Send test message to browser
{
    testMessage := {
        type: "test",
        content: "Test browser message from DC",
        action: "console_log",
        data: {test: true}
    }
    browserInfo := FindActiveBrowser()
    if browserInfo {
        InjectBrowserMessage(browserInfo, testMessage)
        MsgBox("Test message sent to " . browserInfo.browser)
    } else {
        MsgBox("No active browser found")
    }
}

^!d:: ; Ctrl+Alt+D - Check for browser messages
{
    ReceiveFromBrowser()
    MsgBox("Browser message queue processed")
}

^!f:: ; Ctrl+Alt+F - Find and focus browser
{
    browserInfo := FindActiveBrowser()
    if browserInfo {
        WinActivate(browserInfo.title . " ahk_class " . browserInfo.class)
        MsgBox("Found and activated: " . browserInfo.browser)
    } else {
        MsgBox("No browser window found")
    }
}

; Background message monitoring
SetTimer(ReceiveFromBrowser, 1500) ; Check every 1.5 seconds

; JavaScript bridge for browser communication
CreateBrowserBridge() {
    bridgeCode := '
    (;
        // Browser AI Message Bridge
        if (!window.agentBridge) {
            window.agentBridge = {
                messages: [],
                
                send: function(type, data) {
                    const message = {
                        from: "Browser",
                        to: "DC",
                        type: type,
                        timestamp: new Date().toISOString(),
                        turn: Date.now(),
                        data: data
                    };
                    
                    // Send to AutoHotkey via file system
                    fetch("/api/browser-message", {
                        method: "POST",
                        headers: {"Content-Type": "application/json"},
                        body: JSON.stringify(message)
                    }).catch(err => console.log("Bridge error:", err));
                    
                    this.messages.push(message);
                    console.log("Agent message sent:", type, data);
                },
                
                onMessage: function(callback) {
                    window.addEventListener("message", function(event) {
                        if (event.data && event.data.type === "agent_message") {
                            callback(event.data);
                        }
                    });
                }
            };
            
            console.log("Agent bridge initialized");
        }
    ;)'
    
    ; Save bridge code for injection
    FileAppend(bridgeCode, A_ScriptDir . "\config\browser_bridge.js")
}

; Initialize system
LogMessage("DC-Browser Messaging system initialized")
CreateBrowserBridge()
MsgBox("DC-Browser Messaging System Ready`n`nHotkeys:`nCtrl+Alt+B - Send test message`nCtrl+Alt+D - Process messages`nCtrl+Alt+F - Find browser")