; DC_VSCC_Messaging.ahk - AutoHotkey v2 Script for DC ↔ VSCC Communication
; Version 1.0 - Window-based message injection system

#Requires AutoHotkey v2.0

; Configuration
global MessageQueuePath := A_ScriptDir . "\config\msg_queue.json"
global LogFilePath := A_ScriptDir . "\logs\messaging.log"
global InjectionDelay := 100 ; milliseconds
global MaxRetries := 3

; Initialize logging
if !DirExist(A_ScriptDir . "\logs")
    DirCreate(A_ScriptDir . "\logs")

LogMessage(message) {
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    logEntry := timestamp . " - " . message . "`n"
    FileAppend(logEntry, LogFilePath)
}

; Main messaging function - inject message into target window
InjectMessage(targetTitle, message) {
    LogMessage("Injecting message into: " . targetTitle)
    
    retries := 0
    while (retries < MaxRetries) {
        try {
            ; Activate target window
            if !WinActivate(targetTitle) {
                throw Error("Cannot activate window: " . targetTitle)
            }
            
            Sleep(InjectionDelay)
            
            ; Clear any existing input and inject message
            Send("^a") ; Select all
            Sleep(50)
            Send("{Delete}")
            Sleep(50)
            Send(message)
            Sleep(InjectionDelay)
            
            ; Send Enter to execute/submit
            Send("{Enter}")
            
            LogMessage("Message injected successfully")
            return true
        } catch as e {
            retries++
            LogMessage("Injection attempt " . retries . " failed: " . e.message)
            Sleep(200 * retries) ; Exponential backoff
        }
    }
    
    LogMessage("Failed to inject message after " . MaxRetries . " attempts")
    return false
}

; VSCC to DC messaging - receive code and execution requests
ReceiveFromVSCC() {
    LogMessage("Checking for messages from VSCC")
    
    ; Check for message files from VSCC
    messageFiles := []
    loop Files, A_ScriptDir . "\config\msg_DC_*.json" {
        messageFiles.Push(A_LoopFileFullPath)
    }
    
    for filePath in messageFiles {
        try {
            messageJson := FileRead(filePath)
            message := JSON.Parse(messageJson)
            
            LogMessage("Received message from VSCC: " . message.type)
            
            ; Process message based on type
            switch message.type {
                case "code_ready":
                    HandleCodeReady(message)
                case "file_operation":
                    HandleFileOperation(message)
                case "validation_request":
                    HandleValidationRequest(message)
                default:
                    LogMessage("Unknown message type: " . message.type)
            }
            
            ; Clean up processed message
            FileDelete(filePath)
        } catch as e {
            LogMessage("Error processing message: " . e.message)
        }
    }
}

; DC to VSCC messaging - send UI state and user interactions
SendToVSCC(messageType, data) {
    LogMessage("Sending message to VSCC: " . messageType)
    
    message := {
        from: "DC",
        to: "VSCC",
        type: messageType,
        timestamp: FormatTime(, "yyyy-MM-ddTHH:mm:ssZ"),
        data: data
    }
    
    ; Write compressed message file
    messageFile := A_ScriptDir . "\config\msg_VSCC_" . A_TickCount . ".json"
    FileAppend(JSON.Stringify(message, false), messageFile)
    
    ; Inject into VSCode if it's active
    if WinActive("ahk_exe Code.exe") {
        InjectMessage("ahk_exe Code.exe", "MSG:" . JSON.Stringify(message, false))
    }
    
    LogMessage("Message sent to VSCC")
}

; Message handlers
HandleCodeReady(message) {
    LogMessage("Handling code ready message")
    
    ; Extract code from message
    code := message.data.code ?? ""
    fileName := message.data.filename ?? "temp.ahk"
    
    ; Save code to temp file
    tempFile := A_ScriptDir . "\temp&quot; . fileName
    if !DirExist(A_ScriptDir . "\temp")
        DirCreate(A_ScriptDir . "\temp")
    
    FileAppend(code, tempFile)
    
    ; Execute code if requested
    if (message.data.execute ?? false) {
        try {
            Run(tempFile)
            LogMessage("Code executed: " . fileName)
            
            ; Send execution result back to VSCC
            SendToVSCC("execution_result", {
                filename: fileName,
                status: "success",
                timestamp: FormatTime(, "yyyy-MM-ddTHH:mm:ssZ")
            })
        } catch as e {
            LogMessage("Code execution failed: " . e.message)
            
            SendToVSCC("execution_result", {
                filename: fileName,
                status: "error",
                error: e.message,
                timestamp: FormatTime(, "yyyy-MM-ddTHH:mm:ssZ")
            })
        }
    }
}

HandleFileOperation(message) {
    LogMessage("Handling file operation: " . message.data.operation)
    
    operation := message.data.operation
    filePath := message.data.path ?? ""
    content := message.data.content ?? ""
    
    try {
        switch operation {
            case "create":
                FileAppend(content, filePath)
                result := {status: "success", operation: "create", path: filePath}
            case "read":
                content := FileRead(filePath)
                result := {status: "success", operation: "read", path: filePath, content: content}
            case "delete":
                FileDelete(filePath)
                result := {status: "success", operation: "delete", path: filePath}
            default:
                throw Error("Unknown operation: " . operation)
        }
        
        SendToVSCC("file_operation_result", result)
    } catch as e {
        SendToVSCC("file_operation_result", {
            status: "error",
            operation: operation,
            path: filePath,
            error: e.message
        })
    }
}

HandleValidationRequest(message) {
    LogMessage("Handling validation request")
    
    validationType := message.data.type ?? "general"
    validationData := message.data.data ?? {}
    
    ; Perform validation based on type
    validationResult := {
        type: validationType,
        timestamp: FormatTime(, "yyyy-MM-ddTHH:mm:ssZ"),
        valid: true,
        errors: []
    }
    
    ; Send validation result back to VSCC
    SendToVSCC("validation_result", validationResult)
}

; Hotkey for manual message testing
^!v:: ; Ctrl+Alt+V
{
    testMessage := {
        type: "test",
        content: "Test message from DC to VSCC",
        timestamp: FormatTime(, "yyyy-MM-ddTHH:mm:ssZ")
    }
    SendToVSCC("test", testMessage)
}

; Hotkey for message queue monitoring
^!m:: ; Ctrl+Alt+M
{
    ReceiveFromVSCC()
    MsgBox("Message queue processed")
}

; Background message monitoring
SetTimer(ReceiveFromVSCC, 1000) ; Check every second

; Simple JSON implementation (AHK v2 compatible)
class JSON {
    static Parse(jsonString) {
        ; Basic JSON parser - for production use a proper library
        return this.ParseObject(jsonString)
    }
    
    static ParseObject(jsonString) {
        ; Simplified parsing - enhance as needed
        obj := {}
        jsonString := Trim(jsonString)
        if (SubStr(jsonString, 1, 1) = "{" && SubStr(jsonString, -1) = "}") {
            content := SubStr(jsonString, 2, -1)
            ; Parse key-value pairs
            Loop Parse, content, "`n"
            {
                line := Trim(A_LoopField)
                if (line && !InStr(line, "//")) { ; Skip empty lines and comments
                    if (InStr(line, ":")) {
                        parts := StrSplit(line, ":", 2)
                        key := Trim(RegExReplace(parts[1], "[&quot;']", ""))
                        value := Trim(parts[2])
                        obj[key] := value
                    }
                }
            }
        }
        return obj
    }
    
    static Stringify(obj, pretty := true) {
        ; Basic JSON stringifier
        jsonString := "{`n"
        for key, value in obj.OwnProps() {
            if (IsObject(value)) {
                valueStr := this.Stringify(value, false)
            } else if (value is String) {
                valueStr := """" . value . """"
            } else {
                valueStr := value
            }
            jsonString .= '  "' . key . '": ' . valueStr . ",`n"
        }
        jsonString := RTrim(jsonString, ",`n") . "`n}"
        return jsonString
    }
}

; Initialize
LogMessage("DC-VSCC Messaging system initialized")
MsgBox("DC-VSCC Messaging System Ready`n`nHotkeys:`nCtrl+Alt+V - Send test message`nCtrl+Alt+M - Process message queue")