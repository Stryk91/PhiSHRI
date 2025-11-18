# PhiVector MCP Quickstart Guide

## Immediate Setup (15 Minutes)

### 1. Directory Structure Creation
```bash
# Create the main directory structure
mkdir -p phivector_mcp/agents/{dc,vscc,kalic,webc,ninja,stryk}/{inbox,outbox,processed}
mkdir -p phivector_mcp/shared_resources/{context_cache,task_queue,cost_tracker}
mkdir -p phivector_mcp/tools
mkdir -p phivector_mcp/logs

# Copy MCP bridge components
cp -r mcp_bridge/* phivector_mcp/
```

### 2. Test Message Router
```bash
cd phivector_mcp

# Test basic message routing
python3 -c "
from mcp_bridge.message_router import MCPMessageRouter
router = MCPMessageRouter('.')

# Send test message from DC to VSCC
msg_id = router.send_message('dc', 'vscc', {
    'method': 'tools/call',
    'params': {
        'name': 'code_analysis',
        'arguments': {'file_path': 'test.py', 'analysis_type': 'security'}
    }
})
print(f'Sent message: {msg_id}')

# Check VSCC inbox
messages = router.check_inbox('vscc')
print(f'VSCC received {len(messages)} messages')
"
```

### 3. Initialize Capability Manager
```bash
python3 -c "
from mcp_bridge.capability_manager import CapabilityManager
manager = CapabilityManager('.')
overview = manager.get_system_overview()
print('System initialized with', overview['total_agents'], 'agents')
"
```

### 4. Configure Cost Optimizer
```bash
python3 -c "
from mcp_bridge.cost_optimizer import CostOptimizer
optimizer = CostOptimizer()

# Test provider selection
provider = optimizer.get_available_provider()
print(f'Available provider: {provider}')

# Set current provider
optimizer.current_provider = provider if provider else 'anthropic'
"
```

## Agent Integration Templates

### DesktopClaude (DC) Integration
```powershell
# dc_agent.ps1 - AutoHotkey integration for DesktopClaude
Add-Type -AssemblyName System.Web.Extensions

$json = New-Object System.Web.Script.Serialization.JavaScriptSerializer

function Send-MCPMessage {
    param(
        [string]$ToAgent,
        [hashtable]$Message
    )
    
    $messageData = @{
        jsonrpc = "2.0"
        id = "dc_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        method = $Message.method
        params = $Message.params
    } | ConvertTo-Json -Depth 3
    
    $outboxPath = "..\phivector_mcp\agents\dc\outbox"
    $inboxPath = "..\phivector_mcp\agents\$ToAgent\inbox"
    
    $filename = "$($messageData.id).json"
    $messageData | Out-File -FilePath "$inboxPath\$filename" -Encoding UTF8
    $messageData | Out-File -FilePath "$outboxPath\$filename" -Encoding UTF8
    
    return $messageData.id
}

function Check-MCPInbox {
    $inboxPath = "..\phivector_mcp\agents\dc\inbox"
    $messages = @()
    
    Get-ChildItem $inboxPath -Filter "*.json" | ForEach-Object {
        $content = Get-Content $_.FullName | ConvertFrom-Json
        $messages += $content
        Move-Item $_.FullName "..\phivector_mcp\agents\dc\processed&quot;
    }
    
    return $messages
}

# Example: Execute AutoHotkey macro via MCP
function Invoke-AutoHotkeyMacro {
    param([string]$MacroName, [hashtable]$Parameters)
    
    $message = @{
        method = "tools/call"
        params = @{
            name = "desktop_automation"
            arguments = @{
                macro = $MacroName
                parameters = $Parameters
            }
        }
    }
    
    return Send-MCPMessage -ToAgent "ninja" -Message $message
}
```

### VS Claude Code (VSCC) Integration
```javascript
// vscc_agent.js - VS Code extension integration
const fs = require('fs').promises;
const path = require('path');

class VSCCMCPAgent {
    constructor() {
        this.basePath = path.join(__dirname, '../phivector_mcp');
        this.inboxPath = path.join(this.basePath, 'agents/vscc/inbox');
        this.processedPath = path.join(this.basePath, 'agents/vscc/processed');
    }
    
    async sendMessage(toAgent, method, params) {
        const message = {
            jsonrpc: "2.0",
            id: `vscc_${Date.now()}`,
            method: method,
            params: params
        };
        
        const messageStr = JSON.stringify(message, null, 2);
        const filename = `${message.id}.json`;
        
        // Write to target inbox and our outbox
        const targetInbox = path.join(this.basePath, `agents/${toAgent}/inbox`);
        const outboxPath = path.join(this.basePath, 'agents/vscc/outbox');
        
        await Promise.all([
            fs.writeFile(path.join(targetInbox, filename), messageStr),
            fs.writeFile(path.join(outboxPath, filename), messageStr)
        ]);
        
        return message.id;
    }
    
    async checkInbox() {
        const messages = [];
        const files = await fs.readdir(this.inboxPath);
        
        for (const file of files.filter(f => f.endsWith('.json'))) {
            const content = await fs.readFile(path.join(this.inboxPath, file), 'utf8');
            const message = JSON.parse(content);
            messages.push(message);
            
            // Move to processed
            await fs.rename(
                path.join(this.inboxPath, file),
                path.join(this.processedPath, file)
            );
        }
        
        return messages;
    }
    
    async requestCodeAnalysis(filePath, analysisType) {
        return this.sendMessage('ninja', 'tools/call', {
            name: 'code_analysis',
            arguments: {
                file_path: filePath,
                analysis_type: analysisType
            }
        });
    }
    
    async broadcastCapabilityUpdate(capabilities) {
        const message = {
            method: "notifications/tools/list_changed",
            params: capabilities
        };
        
        // Send to all agents except self
        const agents = ['dc', 'kalic', 'webc', 'ninja', 'stryk'];
        const promises = agents.map(agent => 
            this.sendMessage(agent, message.method, message.params)
        );
        
        return Promise.all(promises);
    }
}

// Example VS Code command integration
const vscode = require('vscode');
const mcpAgent = new VSCCMCPAgent();

function activate(context) {
    let disposable = vscode.commands.registerCommand('phivector.analyzeCurrentFile', async () => {
        const editor = vscode.window.activeTextEditor;
        if (editor) {
            const filePath = editor.document.fileName;
            const analysisType = await vscode.window.showQuickPick(['security', 'performance', 'style', 'logic']);
            
            if (analysisType) {
                const messageId = await mcpAgent.requestCodeAnalysis(filePath, analysisType);
                vscode.window.showInformationMessage(`Analysis requested: ${messageId}`);
            }
        }
    });
    
    context.subscriptions.push(disposable);
}

module.exports = { activate, mcpAgent };
```

### Kali Linux (KALIC) Integration
```bash
#!/bin/bash
# kalic_agent.sh - Security tools integration for Kali Linux

MCP_BASE_PATH="/workspace/phivector_mcp"
KALIC_INBOX="$MCP_BASE_PATH/agents/kalic/inbox"
KALIC_OUTBOX="$MCP_BASE_PATH/agents/kalic/outbox"
KALIC_PROCESSED="$MCP_BASE_PATH/agents/kalic/processed"

send_mcp_message() {
    local to_agent=$1
    local method=$2
    local params=$3
    
    local message_id="kalic_$(date +%s)"
    local message=$(cat <<EOF
{
  "jsonrpc": "2.0",
  "id": "$message_id",
  "method": "$method",
  "params": $params
}
EOF
)
    
    # Write to target inbox and our outbox
    echo "$message" > "$MCP_BASE_PATH/agents/$to_agent/inbox/${message_id}.json"
    echo "$message" > "$KALIC_OUTBOX/${message_id}.json"
    
    echo "$message_id"
}

check_inbox() {
    local messages=()
    
    for file in "$KALIC_INBOX"/*.json; do
        if [ -f "$file" ]; then
            messages+=("$(cat "$file")")
            mv "$file" "$KALIC_PROCESSED/"
        fi
    done
    
    echo "${messages[@]}"
}

execute_security_scan() {
    local target=$1
    local scan_type=$2
    local to_agent=${3:-"dc"}
    
    local params=$(cat <<EOF
{
  "target": "$target",
  "scan_type": "$scan_type",
  "options": {}
}
EOF
)
    
    send_mcp_message "$to_agent" "tools/call" '{"name": "security_scan", "arguments": '"$params"'}'
}

# Example: Run nmap scan and report results
run_nmap_scan() {
    local target=$1
    local scan_options=$2
    
    echo "Starting nmap scan of $target..."
    local scan_result=$(nmap $scan_options "$target" 2>/dev/null)
    
    # Send results to DC for analysis
    local params=$(cat <<EOF
{
  "operation": "process_scan_results",
  "scan_type": "nmap",
  "target": "$target",
  "results": $(echo "$scan_result" | jq -R -s .)
}
EOF
)
    
    send_mcp_message "dc" "tools/call" '{"name": "file_operations", "arguments": '"$params"'}'
}

# Message processing loop
process_messages() {
    while true; do
        local messages=($(check_inbox))
        
        for message in "${messages[@]}"; do
            local method=$(echo "$message" | jq -r '.method')
            local params=$(echo "$message" | jq '.params')
            
            case $method in
                "tools/call")
                    local tool=$(echo "$params" | jq -r '.arguments.name // ""')
                    case $tool in
                        "security_scan")
                            local target=$(echo "$params" | jq -r '.arguments.target')
                            local scan_type=$(echo "$params" | jq -r '.arguments.scan_type')
                            execute_security_scan "$target" "$scan_type" "ninja"
                            ;;
                        "network_tools")
                            local command=$(echo "$params" | jq -r '.arguments.command')
                            echo "Executing network command: $command"
                            eval "$command"
                            ;;
                    esac
                    ;;
            esac
        done
        
        sleep 5
    done
}

# Start message processing in background
if [ "$1" = "--daemon" ]; then
    process_messages
fi
```

## Resource Optimization Examples

### Tool Synthesis Pattern
```python
# synthesis_examples.py - Maximize free-tier usage
import json
import time

class ToolSynthesizer:
    def __init__(self, mcp_router):
        self.router = mcp_router
        self.context_cache = {}
    
    def batch_file_analysis(self, file_paths, analysis_type="security"):
        """Analyze multiple files with shared context"""
        batch_id = f"batch_{int(time.time())}"
        
        # Accumulate common patterns first
        shared_context = self.accumulate_context(file_paths)
        
        # Single batched request
        synthesized_task = {
            "method": "tools/call",
            "params": {
                "name": "batch_code_analysis",
                "arguments": {
                    "batch_id": batch_id,
                    "files": file_paths,
                    "analysis_type": analysis_type,
                    "shared_context": shared_context,
                    "token_optimization": True
                }
            }
        }
        
        return self.router.send_message("vscc", "ninja", synthesized_task)
    
    def accumulate_context(self, file_paths):
        """Build shared context to avoid redundant processing"""
        cache_key = "_".join(sorted(file_paths))
        
        if cache_key in self.context_cache:
            return self.context_cache[cache_key]
        
        # Simulate context building (in real implementation, 
        # this would analyze file patterns, imports, etc.)
        context = {
            "common_libraries": [],
            "shared_patterns": [],
            "file_types": list(set(path.split('.')[-1] for path in file_paths)),
            "created_at": time.time()
        }
        
        self.context_cache[cache_key] = context
        return context
    
    def recursive_task_decomposition(self, complex_task):
        """Break down complex tasks into optimized subtasks"""
        if complex_task.get("complexity_score", 0) < 0.7:
            return [complex_task]  # Simple task, no decomposition needed
        
        # Decompose based on task type
        task_type = complex_task.get("task_type")
        if task_type == "project_analysis":
            return self.decompose_project_analysis(complex_task)
        elif task_type == "security_audit":
            return self.decompose_security_audit(complex_task)
        else:
            return [complex_task]
    
    def decompose_project_analysis(self, task):
        """Decompose project analysis into optimized phases"""
        project_path = task.get("project_path")
        
        phases = [
            {
                "phase": "discovery",
                "tool": "file_operations",
                "arguments": {
                    "operation": "list",
                    "path": project_path,
                    "recursive": True,
                    "pattern": "*.py,*.js,*.json"
                }
            },
            {
                "phase": "dependency_analysis",
                "tool": "code_analysis",
                "arguments": {
                    "analysis_type": "dependencies",
                    "files": [],  # Will be populated by discovery phase
                    "batch": True
                }
            },
            {
                "phase": "security_scan",
                "tool": "security_scan",
                "arguments": {
                    "scan_type": "static_analysis",
                    "target": project_path,
                    "batch": True
                }
            }
        ]
        
        return phases

# Usage example
def demonstrate_synthesis():
    from mcp_bridge.message_router import MCPMessageRouter
    
    router = MCPMessageRouter()
    synthesizer = ToolSynthesizer(router)
    
    # Example: Batch analyze multiple files
    files_to_analyze = [
        "src/main.py",
        "src/utils.py", 
        "src/config.py",
        "src/database.py"
    ]
    
    batch_id = synthesizer.batch_file_analysis(files_to_analyze, "security")
    print(f"Batch analysis initiated: {batch_id}")
    
    # Calculate estimated token savings
    individual_tokens = len(files_to_analyze) * 300  # Estimated per file
    batch_tokens = 400  # Estimated for batch
    savings = (individual_tokens - batch_tokens) / individual_tokens * 100
    
    print(f"Estimated token savings: {savings:.1f}%")

if __name__ == "__main__":
    demonstrate_synthesis()
```

## Deployment Script

### Complete System Setup
```bash
#!/bin/bash
# deploy_phivector_mcp.sh - Complete deployment in one script

set -e

echo "🚀 Deploying PhiVector MCP System..."

# 1. Create directory structure
echo "📁 Creating directory structure..."
mkdir -p phivector_mcp/{agents/{dc,vscc,kalic,webc,ninja,stryk}/{inbox,outbox,processed},shared_resources/{context_cache,task_queue,cost_tracker},tools,logs}

# 2. Copy MCP bridge components
echo "📋 Copying MCP bridge components..."
cp -r mcp_bridge/* phivector_mcp/

# 3. Initialize configurations
echo "⚙️ Initializing configurations..."
cd phivector_mcp

python3 -c "
from capability_manager import CapabilityManager
from cost_optimizer import CostOptimizer

# Initialize capability manager
manager = CapabilityManager('.')
overview = manager.get_system_overview()
print(f'✅ Initialized {overview[&quot;total_agents&quot;]} agents')

# Initialize cost optimizer
optimizer = CostOptimizer()
print(f'✅ Cost optimizer ready with {len(optimizer.provider_limits)} providers')

# Create basic agent configs
for agent in ['dc', 'vscc', 'kalic', 'webc', 'ninja', 'stryk']:
    import json
    with open(f'agents/{agent}/status.json', 'w') as f:
        json.dump({
            'status': 'initialized',
            'created_at': $(date +%s),
            'last_heartbeat': $(date +%s),
            'active_tasks': 0,
            'total_tasks': 0
        }, f)
print('✅ Agent status files created')
"

# 4. Create startup scripts
echo "🔧 Creating startup scripts..."

# Main bridge startup script
cat > start_mcp_bridge.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

echo "🔄 Starting PhiVector MCP Bridge..."

# Start message router daemon
python3 -c "
import time
import json
from message_router import MCPMessageRouter
from capability_manager import CapabilityManager
from cost_optimizer import CostOptimizer

router = MCPMessageRouter('.')
manager = CapabilityManager('.')
optimizer = CostOptimizer('.')

print('🎯 PhiVector MCP Bridge Active')
print(f'📊 Managing {len(manager.agent_capabilities)} agents')
print(f'💰 Cost optimizer tracking {len(optimizer.provider_limits)} providers')

# Main monitoring loop
while True:
    try:
        # Check for messages from all agents
        for agent in ['dc', 'vscc', 'kalic', 'webc', 'ninja', 'stryk']:
            messages = router.check_inbox(agent)
            if messages:
                print(f'📨 {agent}: Processed {len(messages)} messages')
        
        # Update agent heartbeats
        for agent in manager.agent_capabilities.keys():
            manager.update_agent_status(agent, {'last_heartbeat': time.time()})
        
        time.sleep(10)
    except KeyboardInterrupt:
        print('🛑 Shutting down MCP Bridge...')
        break
    except Exception as e:
        print(f'❌ Error: {e}')
        time.sleep(5)
"
EOF

chmod +x start_mcp_bridge.sh

# 5. Create monitoring dashboard
echo "📈 Creating monitoring dashboard..."
cat > monitor_dashboard.py << 'EOF'
#!/usr/bin/env python3
import json
import time
from pathlib import Path
from capability_manager import CapabilityManager
from cost_optimizer import CostOptimizer
from message_router import MCPMessageRouter

def show_dashboard():
    manager = CapabilityManager('.')
    optimizer = CostOptimizer('.')
    router = MCPMessageRouter('.')
    
    while True:
        os.system('clear')
        
        print("🎯 PhiVector MCP Dashboard")
        print("=" * 50)
        
        # System overview
        overview = manager.get_system_overview()
        print(f"📊 Active Agents: {overview['total_agents']}")
        
        # Cost optimization status
        if hasattr(optimizer, 'current_provider'):
            provider = optimizer.current_provider
            limits = optimizer.provider_limits[provider]
            usage_pct = (limits['used_today'] / limits['daily_limit']) * 100
            print(f"💰 Current Provider: {provider} ({usage_pct:.1f}% used)")
        
        print("\n🤖 Agent Status:")
        for agent_name, agent_info in overview['agents'].items():
            status = agent_info['status']
            if status.get('active_tasks', 0) > 0:
                indicator = "🟢"
            else:
                indicator = "🔵"
            print(f"  {indicator} {agent_name}: {status.get('active_tasks', 0)} active tasks")
        
        print(f"\n📨 Message Activity:")
        for agent in ['dc', 'vscc', 'kalic', 'webc', 'ninja', 'stryk']:
            agent_status = router.get_agent_status(agent)
            total_msgs = agent_status['total_messages']
            print(f"  📬 {agent}: {total_msgs} total messages")
        
        print(f"\n⏰ Last Updated: {time.strftime('%Y-%m-%d %H:%M:%S')}")
        print("Press Ctrl+C to exit...")
        
        time.sleep(30)

if __name__ == "__main__":
    show_dashboard()
EOF

chmod +x monitor_dashboard.py

echo "✅ PhiVector MCP System deployed successfully!"
echo
echo "🚀 Quick Start Commands:"
echo "  ./start_mcp_bridge.sh          # Start the MCP bridge"
echo "  python3 monitor_dashboard.py   # Monitor system status"
echo "  ../scripts/remote_mcp_admin.sh # Remote administration"
echo
echo "📚 Next Steps:"
echo "  1. Configure your agent-specific integration scripts"
echo "  2. Test message routing between agents"
echo "  3. Set up your cost optimization rules"
echo "  4. Deploy SSH keys for remote administration"