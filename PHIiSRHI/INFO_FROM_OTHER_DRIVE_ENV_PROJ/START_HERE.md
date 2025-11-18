# START HERE — PhiWave Guides and Quick Links

If you're looking for "the guide", start with this page.

What do you want to do?

- Set up and run PhiWave (GUI/CLI)
  - See: README.md (top-level overview and how to run)
- Use the Agent Messaging/Relay system (Junie/TERMC)
  - See: docs/AGENT_MESSAGING_SYSTEM.md (concepts), AGENT_HUB_README.md (hub details)
  - Quick Start below
- Work with the MCP HTTP server for the hub
  - See: mcp_agent_hub.py (tools: post_message, get_messages, search_messages, get_stats)
- Junie QA guidelines and testing workflow
  - See: .junie/guidelines.md (if present) and docs/JUNIE_PHASE4_TASKS.md

Quick Start — JSONL-based Agent Relay (Junie auto-consume)

Follow these steps in Windows PowerShell from the project root: E:\\PythonProjects\\PhiWave

1) Prepare the environment
- pip install -r requirements_all.txt
- Ensure you are in the repo root so both sender and client share docs\\agent-feed.jsonl

2) Start the Junie agent client (Terminal A)
- python mcp_agent_client.py junie
- Expect: "🚀 junie agent started" and periodic idle polling without errors

3) Send a direct message (Terminal B)
- python send_agent_message.py Junie "Check your next task"
- Expect in Terminal A: an incoming message printed and an acknowledgment like "✓ Acknowledged"; the message is then marked processed

4) Verify the feed
- PowerShell: Get-Content docs\\agent-feed.jsonl -Tail 10
- You should see the new line appended by send_agent_message.py; after processing, mark_processed updates the corresponding entry’s processed flag in the file

5) Send via Python API helper (alternative to step 3)
- python -c "from agent_hub import post_direct_message; print(post_direct_message('TERMC','Junie','Start your next task'))"
- Expect: Terminal A prints acknowledgment as above; the printed dict shows status: posted

6) Negative test: recipient filtering
- python send_agent_message.py TERMC "This is for TERMC"
- Expect: Terminal A (Junie) ignores this message; it remains unprocessed until a TERMC agent consumes it

7) Programmatic unread check (for Junie only)
- python -c "from agent_hub import get_messages; import json; print(json.dumps(get_messages(recipient='Junie', unread_only=True), indent=2))"
- Expect: [] after Junie processes prior messages

8) Optional: task overview helper
- python check_my_tasks.py Junie --tail 100
- Shows recent entries in the feed that target Junie

9) Log the test result (optional, per project guidelines)
- python -c "from phiwave.agent_feed import log_action; log_action('test_complete', {'task':'Agent relay E2E','status':'PASS','notes':'Junie auto-consumed direct messages'}, agent='Junie')"

Troubleshooting
- Ensure both terminals run in the same project folder; they must share docs\\agent-feed.jsonl
- Recipient matching is case-insensitive (Junie/junie both work)
- Verify send_agent_message.py actually appended: Get-Content docs\\agent-feed.jsonl -Tail 5
- Close editors that might lock the JSONL file before testing
- If the feed is noisy or very large, temporarily move docs\\agent-feed.jsonl aside and re-run the test to see new entries clearly

Next step (when ready): MCP server testing
- Start MCP HTTP server: python mcp_agent_hub.py
- Use a compatible MCP client to call tools (post_message, search_messages, get_stats, etc.).

Other helpful files
- AGENT_QUICK_START.md — condensed agent instructions
- AGENT_HUB_README.md — hub overview and formats
- docs/AGENT_MESSAGING_SYSTEM.md — detailed messaging system design
- README.md — project overview, running GUI/CLI, features
- check_my_tasks.py — quick script to view tasks targeted to an agent
