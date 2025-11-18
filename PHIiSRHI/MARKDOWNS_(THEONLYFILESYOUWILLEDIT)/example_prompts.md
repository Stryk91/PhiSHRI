# Example Prompts for PhiLaunch MCP Screen Control

Try these prompts with Claude after installing the MCP server:

## Screenshot & Analysis

```
"Take a screenshot of my current screen and tell me what you see"

"Capture the top-left quarter of my screen and analyze it"

"Take a screenshot and identify all clickable buttons"

"Show me what's currently on my screen and describe the layout"
```

## Finding & Clicking Elements

```
"Find and click the 'Submit' button on my screen"

"Look for text that says 'Continue' and click it"

"Find the search box and click on it"

"Locate and click the close button (X) in the top-right"

"Find any button with 'OK' in the text and click it"
```

## OCR & Text Reading

```
"Read all the text visible on my screen right now"

"What text is in the notification that just appeared?"

"Read the error message showing on screen"

"Extract all the text from the current window"

"Find and read the text in the upper-right corner"
```

## Typing & Input

```
"Type 'Hello World' at the current cursor position"

"Fill in 'john.doe@example.com' in the email field"

"Type my name: John Smith"

"Enter the text 'Test Message' slowly, one character at a time"
```

## Keyboard Shortcuts

```
"Press Ctrl+C to copy the selected text"

"Use Ctrl+V to paste"

"Press Alt+Tab to switch windows"

"Hit Ctrl+S to save"

"Press Enter key"

"Use Ctrl+Shift+T to reopen closed tab"
```

## Clipboard Operations

```
"What's currently on my clipboard?"

"Copy 'https://example.com' to clipboard"

"Read the clipboard and tell me what's there"

"Put this text on clipboard: [your text]"

"Copy the clipboard content and show it to me"
```

## Complex Workflows

```
"Find the username field, click it, then type 'admin'"

"Take a screenshot, find the login button, click it, and take another screenshot"

"Read the text 'Error:', then copy that error message to clipboard"

"Find the search box, click it, type 'MCP servers', and press Enter"

"Locate the 'Save As' dialog, type 'document.pdf' in the filename field, then click Save"
```

## Form Filling

```
"Help me fill out this form:
1. Click on 'Name' field
2. Type 'John Doe'
3. Press Tab
4. Type 'john@example.com'
5. Press Tab
6. Type '555-1234'
7. Find and click Submit"

"Fill in the registration form with:
Name: Alice Smith
Email: alice@example.com
Password: [don't actually enter real passwords]"
```

## Monitoring & Analysis

```
"Watch my screen for 5 seconds and tell me if anything changes"

"Take screenshots every 2 seconds for 10 seconds and describe what changed"

"Monitor the screen and tell me when you see a notification appear"

"Keep taking screenshots until you see the word 'Complete'"
```

## Debugging & Testing

```
"Take a screenshot and check if there are any error messages visible"

"Look for red text on the screen that might indicate an error"

"Find any dialog boxes or popups currently showing"

"Check if there's a loading spinner still visible"
```

## Accessibility

```
"Read all visible text in large font (accessibility mode)"

"Find all clickable elements and list their text"

"Describe the screen layout in detail for a visually impaired user"

"What are the tab order of interactive elements?"
```

## Multi-Step Automation

```
"Automate this workflow:
1. Take initial screenshot
2. Find and click 'New Document'
3. Wait 2 seconds
4. Find title field
5. Type 'My Document'
6. Press Ctrl+S to save
7. Take final screenshot
8. Compare before and after"
```

## Screen Navigation

```
"What window is currently active?"

"List all the menu items you can see in the menu bar"

"What applications have windows open right now?"

"Describe the taskbar/dock showing on screen"
```

## Verification

```
"Verify that the form was submitted successfully by checking for a confirmation message"

"Check if the file download started (look for download indicator)"

"Confirm the settings were saved by checking for a success notification"

"Verify the popup closed by taking a screenshot"
```

## Safety Testing

```
"Show me your action history for the last 10 operations"

"What safety zones are currently configured?"

"What's the current rate limit status?"

"List all actions you've performed in the last minute"
```

---

## Tips for Best Results

1. **Be Specific**: "Click the blue Submit button in the bottom-right" is better than "click Submit"

2. **Verify Actions**: Ask Claude to take before and after screenshots

3. **Use Fuzzy Matching**: If exact text isn't found, enable fuzzy search

4. **Chain Actions**: Break complex tasks into smaller steps

5. **Monitor First**: Ask Claude to screenshot and analyze before taking action

6. **Use Confirmation**: Keep confirmation enabled for important operations

7. **Test Safety**: Try edge cases with safety features enabled

## Error Handling Examples

```
"Try to click 'Submit' but if you can't find it, tell me what buttons you can see"

"Look for either 'OK' or 'Confirm' and click whichever you find"

"If the screenshot shows an error, read it to me; otherwise proceed with the task"

"Search for the element, and if confidence is low, take another screenshot with OCR overlay"
```

## Debugging MCP Server

```
"List all the tools you have access to"

"What's your current screen resolution?"

"Can you see the screen right now? Take a screenshot to confirm"

"Test the OCR by reading this text: [point to visible text]"

"What's the current mouse position?"
```

---

Remember: Always run the oversight GUI when experimenting with new automation to maintain control!
