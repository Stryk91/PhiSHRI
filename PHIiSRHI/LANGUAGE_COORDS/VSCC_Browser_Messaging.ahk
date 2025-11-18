; VSCC_Browser_Messaging.ahk - AutoHotkey v2 Script for VSCC ↔ Browser AI Communication
; Version 1.0 - File-based coordination for code and content exchange

#Requires AutoHotkey v2.0

; Configuration
global VSCCMessagePath := A_ScriptDir . "\config\vscc_msg.json"
global BrowserMessagePath := A_ScriptDir . "\config\browser_msg.json"
global ContentCachePath := A_ScriptDir . "\cache\content"
global CoordinationDelay := 200
global MaxContentSize := 1000000 ; 1MB limit

; Initialize directories
if !DirExist(A_ScriptDir . "\config")
    DirCreate(A_ScriptDir . "\config")
if !DirExist(A_ScriptDir . "\cache")
    DirCreate(A_ScriptDir . "\cache")
if !DirExist(ContentCachePath)
    DirCreate(ContentCachePath)

; Initialize logging
global LogFilePath := A_ScriptDir . "\logs\vscc_browser_messaging.log"
if !DirExist(A_ScriptDir . "\logs")
    DirCreate(A_ScriptDir . "\logs")

LogMessage(message) {
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    logEntry := timestamp . " - [VSCC-Browser] " . message . "`n"
    FileAppend(logEntry, LogFilePath)
}

; VSCC to Browser messaging - send code for web execution
SendToBrowser(messageType, data) {
    LogMessage("VSCC sending to Browser: " . messageType)
    
    message := {
        from: "VSCC",
        to: "Browser",
        type: messageType,
        timestamp: FormatTime(, "yyyy-MM-ddTHH:mm:ssZ"),
        priority: "normal",
        data: data
    }
    
    ; Handle large content by caching
    if (data.content && StrLen(data.content) > 10000) {
        cacheFile := ContentCachePath . "\content_" . A_TickCount . ".txt"
        FileAppend(data.content, cacheFile)
        message.data.content_file := cacheFile
        message.data.content := "[CONTENT_CACHED]"
    }
    
    ; Write message file
    messageFile := A_ScriptDir . "\config\browser_msg_vscc_" . A_TickCount . ".json"
    FileAppend(JSON.Stringify(message, false), messageFile)
    
    ; Also try to inject into browser if VSCode is active
    if WinActive("ahk_exe Code.exe") {
        InjectCodeToBrowser(message)
    }
    
    LogMessage("VSCC message sent to Browser")
    return messageFile
}

; Browser to VSCC messaging - send extracted data and page info
ReceiveFromBrowser() {
    LogMessage("VSCC checking for Browser messages")
    
    ; Check for browser message files
    messageFiles := []
    loop Files, A_ScriptDir . "\config\vscc_msg_browser_*.json" {
        messageFiles.Push(A_LoopFileFullPath)
    }
    
    for filePath in messageFiles {
        try {
            messageJson := FileRead(filePath)
            message := JSON.Parse(messageJson)
            
            LogMessage("VSCC received from Browser: " . message.type)
            
            ; Process message based on type
            switch message.type {
                case "page_info":
                    HandlePageInfo(message)
                case "extracted_data":
                    HandleExtractedData(message)
                case "dom_content":
                    HandleDOMContent(message)
                case "form_data":
                    HandleFormData(message)
                case "api_response":
                    HandleAPIResponse(message)
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

; Message handlers for VSCC
HandlePageInfo(message) {
    LogMessage("Processing page info from Browser")
    
    pageInfo := message.data
    processedInfo := {
        url: pageInfo.url ?? "",
        title: pageInfo.title ?? "",
        timestamp: message.timestamp,
        meta_tags: pageInfo.meta_tags ?? {},
        links_count: pageInfo.links_count ?? 0,
        images_count: pageInfo.images_count ?? 0
    }
    
    ; Create analysis script for page
    analysisScript := CreatePageAnalysisScript(processedInfo)
    
    ; Send analysis script to VSCode
    InjectToVSCode(analysisScript, "page_analysis.js")
    
    ; Also send to DC for UI coordination
    SendToDC("page_ready", processedInfo)
}

HandleExtractedData(message) {
    LogMessage("Processing extracted data from Browser")
    
    extractedData := message.data
    processedData := {
        source_url: extractedData.source_url ?? "",
        extraction_method: extractedData.method ?? "",
        content: extractedData.content ?? "",
        structured_data: extractedData.structured ?? {},
        timestamp: message.timestamp
    }
    
    ; Create data processing script
    processingScript := CreateDataProcessingScript(processedData)
    
    ; Send to VSCode for review and execution
    InjectToVSCode(processingScript, "data_processor.js")
    
    ; Save extracted content to file
    if (processedData.content) {
        contentFile := A_ScriptDir . "\extracted_data_" . A_TickCount . ".json"
        FileAppend(JSON.Stringify(processedData, true), contentFile)
        LogMessage("Extracted data saved to: " . contentFile)
    }
}

HandleDOMContent(message) {
    LogMessage("Processing DOM content from Browser")
    
    domData := message.data
    
    ; Create DOM analysis and manipulation script
    domScript := CreateDOMScript(domData)
    
    ; Send to VSCode
    InjectToVSCode(domScript, "dom_manipulator.js")
}

HandleFormData(message) {
    LogMessage("Processing form data from Browser")
    
    formData := message.data
    
    ; Create form handling script
    formScript := CreateFormScript(formData)
    
    ; Send to VSCode
    InjectToVSCode(formScript, "form_handler.js")
    
    ; Send form info to DC for interaction
    SendToDC("form_detected", formData)
}

HandleAPIResponse(message) {
    LogMessage("Processing API response from Browser")
    
    apiData := message.data
    
    ; Create API response processing script
    apiScript := CreateAPIScript(apiData)
    
    ; Send to VSCode
    InjectToVSCode(apiScript, "api_processor.js")
}

; Code generation functions
CreatePageAnalysisScript(pageInfo) {
    script := '
    (;
        // Page Analysis Script - Generated by VSCC
        const pageInfo = ' . JSON.Stringify(pageInfo, true) . ';
        
        console.log("=== PAGE ANALYSIS ===");
        console.log("URL:", pageInfo.url);
        console.log("Title:", pageInfo.title);
        console.log("Links:", pageInfo.links_count);
        console.log("Images:", pageInfo.images_count);
        
        // Additional analysis functions
        function analyzeSEO() {
            const meta = pageInfo.meta_tags;
            return {
                hasTitle: !!meta.title,
                hasDescription: !!meta.description,
                titleLength: meta.title ? meta.title.length : 0,
                descriptionLength: meta.description ? meta.description.length : 0
            };
        }
        
        function analyzeContent() {
            return {
                estimatedWords: pageInfo.content ? pageInfo.content.split(/\s+/).length : 0,
                hasImages: pageInfo.images_count > 0,
                hasLinks: pageInfo.links_count > 0
            };
        }
        
        // Export for use in browser
        window.pageAnalysis = {
            seo: analyzeSEO(),
            content: analyzeContent(),
            rawData: pageInfo
        };
        
        console.log("SEO Analysis:", window.pageAnalysis.seo);
        console.log("Content Analysis:", window.pageAnalysis.content);
    ;)'
    return script
}

CreateDataProcessingScript(data) {
    script := '
    (;
        // Data Processing Script - Generated by VSCC
        const extractedData = ' . JSON.Stringify(data, true) . ';
        
        console.log("=== DATA PROCESSING ===");
        
        function processData(data) {
            const processed = {
                wordCount: data.content ? data.content.split(/\s+/).length : 0,
                charCount: data.content ? data.content.length : 0,
                lineCount: data.content ? data.content.split(/\n/).length : 0,
                urls: extractUrls(data.content),
                emails: extractEmails(data.content)
            };
            
            return processed;
        }
        
        function extractUrls(text) {
            const urlRegex = /https?:\/\/[^\s]+/g;
            return text.match(urlRegex) || [];
        }
        
        function extractEmails(text) {
            const emailRegex = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/g;
            return text.match(emailRegex) || [];
        }
        
        // Process and export
        window.processedData = processData(extractedData);
        console.log("Processed Data:", window.processedData);
        
        // Send back to VSCC
        window.agentBridge.send("data_processed", {
            processed: window.processedData,
            source: extractedData.source_url
        });
    ;)'
    return script
}

CreateDOMScript(domData) {
    script := '
    (;
        // DOM Manipulation Script - Generated by VSCC
        const domInfo = ' . JSON.Stringify(domData, true) . ';
        
        console.log("=== DOM ANALYSIS ===");
        
        function highlightElements(selector) {
            const elements = document.querySelectorAll(selector);
            elements.forEach(el => {
                el.style.border = "2px solid red";
                el.style.backgroundColor = "rgba(255, 0, 0, 0.1)";
            });
            return elements.length;
        }
        
        function getElementInfo(selector) {
            const el = document.querySelector(selector);
            if (!el) return null;
            
            return {
                tagName: el.tagName,
                id: el.id,
                classes: el.className,
                text: el.innerText?.substring(0, 100),
                visible: el.offsetParent !== null,
                rect: el.getBoundingClientRect()
            };
        }
        
        // Export DOM utilities
        window.domUtils = {
            highlight: highlightElements,
            getInfo: getElementInfo,
            rawData: domInfo
        };
        
        console.log("DOM utilities loaded");
    ;)'
    return script
}

CreateFormScript(formData) {
    script := '
    (;
        // Form Handling Script - Generated by VSCC
        const formInfo = ' . JSON.Stringify(formData, true) . ';
        
        console.log("=== FORM ANALYSIS ===");
        
        function fillForm(data) {
            const form = document.querySelector(formInfo.selector || "form");
            if (!form) return false;
            
            Object.keys(data).forEach(key => {
                const field = form.querySelector(`[name="${key}"], [id="${key}"]`);
                if (field) {
                    if (field.type === "checkbox" || field.type === "radio") {
                        field.checked = data[key];
                    } else {
                        field.value = data[key];
                    }
                }
            });
            
            return true;
        }
        
        function submitForm() {
            const form = document.querySelector(formInfo.selector || "form");
            if (form) {
                form.submit();
                return true;
            }
            return false;
        }
        
        // Export form utilities
        window.formUtils = {
            fill: fillForm,
            submit: submitForm,
            info: formInfo
        };
        
        console.log("Form utilities loaded");
    ;)'
    return script
}

CreateAPIScript(apiData) {
    script := '
    (;
        // API Processing Script - Generated by VSCC
        const apiResponse = ' . JSON.Stringify(apiData, true) . ';
        
        console.log("=== API ANALYSIS ===");
        
        function processAPIResponse(response) {
            const processed = {
                status: response.status || "unknown",
                size: JSON.stringify(response.data).length,
                dataType: Array.isArray(response.data) ? "array" : typeof response.data,
                timestamp: new Date().toISOString()
            };
            
            if (response.data && typeof response.data === "object") {
                processed.keys = Object.keys(response.data);
                processed.count = Array.isArray(response.data) ? response.data.length : processed.keys.length;
            }
            
            return processed;
        }
        
        // Process and export
        window.apiData = processAPIResponse(apiResponse);
        console.log("API Data Processed:", window.apiData);
        
        // Send processed data back to VSCC
        window.agentBridge.send("api_processed", {
            processed: window.apiData,
            original: apiResponse
        });
    ;)'
    return script
}

; Communication helper functions
InjectToVSCode(code, fileName) {
    LogMessage("Injecting code into VSCode: " . fileName)
    
    if !WinActive("ahk_exe Code.exe") {
        LogMessage("VSCode not active - cannot inject code")
        return false
    }
    
    try {
        ; Create new file in VSCode
        Send("^n") ; New file
        Sleep(CoordinationDelay)
        
        ; Type or paste the code
        Send(code)
        Sleep(CoordinationDelay)
        
        ; Save the file
        Send("^s")
        Sleep(CoordinationDelay)
        Send(fileName)
        Send("{Enter}")
        
        LogMessage("Code injected and saved: " . fileName)
        return true
    } catch as e {
        LogMessage("VSCode injection failed: " . e.message)
        return false
    }
}

InjectCodeToBrowser(message) {
    LogMessage("Injecting code to browser from VSCC")
    
    ; Try to find active browser
    if WinExist("ahk_class Chrome_WidgetWin_1") || WinExist("ahk_class MozillaWindowClass") {
        browserInfo := FindActiveBrowser()
        if browserInfo {
            ; Send message to DC-Browser script for injection
            messageFile := A_ScriptDir . "\config\msg_DC_browser_inject_" . A_TickCount . ".json"
            FileAppend(JSON.Stringify(message), messageFile)
        }
    }
}

SendToDC(messageType, data) {
    messageFile := A_ScriptDir . "\config\msg_DC_vscc_" . A_TickCount . ".json"
    message := {
        from: "VSCC",
        to: "DC",
        type: messageType,
        timestamp: FormatTime(, "yyyy-MM-ddTHH:mm:ssZ"),
        data: data
    }
    FileAppend(JSON.Stringify(message), messageFile)
}

FindActiveBrowser() {
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

; Hotkeys for testing
^!c:: ; Ctrl+Alt+C - Send test code to browser
{
    testCode := "console.log('Test code from VSCC'); window.testVar = {test: true, timestamp: new Date().toISOString()};"
    SendToBrowser("code_execution", {
        code: testCode,
        filename: "test.js",
        execute_immediately: true
    })
    MsgBox("Test code sent to Browser")
}

^!v:: ; Ctrl+Alt+V - Check for browser messages
{
    ReceiveFromBrowser()
    MsgBox("VSCC processed browser messages")
}

^!i:: ; Ctrl+Alt+I - Inject sample script into VSCode
{
    sampleScript := CreatePageAnalysisScript({url: "test.com", title: "Test Page"})
    InjectToVSCode(sampleScript, "sample_analysis.js")
    MsgBox("Sample script injected into VSCode")
}

; Background message monitoring
SetTimer(ReceiveFromBrowser, 1200) ; Check every 1.2 seconds

; Simple JSON implementation
class JSON {
    static Parse(jsonString) {
        obj := {}
        jsonString := Trim(jsonString)
        if (SubStr(jsonString, 1, 1) = "{" && SubStr(jsonString, -1) = "}") {
            content := SubStr(jsonString, 2, -1)
            Loop Parse, content, "`n"
            {
                line := Trim(A_LoopField)
                if (line && !InStr(line, "//")) {
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
LogMessage("VSCC-Browser Messaging system initialized")
MsgBox("VSCC-Browser Messaging System Ready`n`nHotkeys:`nCtrl+Alt+C - Send test code`nCtrl+Alt+V - Process messages`nCtrl+Alt+I - Inject to VSCode")