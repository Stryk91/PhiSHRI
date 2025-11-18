# AGENT_COORDINATION_CHEATSHEET.md

---

## 1. AGENT ROLE MATRIX

 Agent  Primary Function                          Best For                                                        Avoid Using For                                  
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
 DC     Director  Orchestrator                   Multi-step workflows, agent routing, stateful task management   Heavy compute, raw web access, direct shell      
 VSSC   Coding  Systems  Static Analysis        Codegen, refactors, infra as code, config diffs, script review  Live web research, running commands, OS telemetry
 KALIC  Security  Compliance  Policy Guardrail  Threat modeling, hardening, policy checks, secret scanning      General coding, browsing, long creative tasks    
 WEBC   Web  Docs  External Intelligence        Targeted research, docs lookup, URL summarization, fact checks  Local file ops, shell, internal-only reasoning   
 CMDC   Command  Terminal Executor               Running commands, file ops, processnetwork checks, log tailing Complex planning, code design, internet research 

---

## 2. COORDINATION PATTERNS (TOP 10)

Legend Sequence = `DC ? WEBC ? VSSC ? KALIC ? CMDC` (subset as needed)

 Pattern                   When to use                                             Agent sequence                     Example command (from DC)                                 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 1. Research ? Implement   Need specs from web then code                           DC ? WEBC ? VSSC                   `implement feature X using latest docs and commit diff` 
 2. Fix Bug Live           Reproduce, patch, validate via logs                     DC ? CMDC ? VSSC ? CMDC            `diagnose and fix error in service-A using logs`          
 3. Secure Implementation  Security-sensitive feature or infra change              DC ? VSSC ? KALIC ? CMDC           `add OIDC auth, have KALIC review before deploy`          
 4. Web Intel ? Hardening  Respond to new CVE with mitigation                      DC ? WEBC ? KALIC ? VSSC ? CMDC    `check CVE-XXXX, propose and apply mitigations`           
 5. Data Pipeline Task     Movetransform files, validate outputs                  DC ? CMDC ? VSSC ? CMDC            `ETL logs from in to out, add validation script`        
 6. Infra Drift Repair     Detect config drift, align to desired state             DC ? CMDC ? VSSC ? CMDC ? KALIC    `detect drift vs repo terraform, reconcile safely`        
 7. Compliance Check       Verify stack against policy  standard                  DC ? KALIC ? CMDC                  `audit Linux host for CIS controls, produce report`       
 8. Incident Triage        Rapid root cause from metricslogs                      DC ? CMDC ? WEBC ? VSSC ? KALIC    `triage high CPU alert on node-1 and propose fix`         
 9. Bulk Refactor          Large code change, staged & safety-checked              DC ? VSSC ? KALIC                  `refactor legacy auth module; ensure no new vulns`        
10. Doc-Driven Change      Change behavior per external specstandard              DC ? WEBC ? VSSC ? KALIC           `align password policy with NIST guidelines`              

---

## 3. FILE-BASED IPC COMMANDS

 Adjust paths to your PhiVector IPC layout (examples use `CagentsAGENT...`)

3.1 Queue command to agent

```powershell
# Write job JSON
$cmd = @{
  id      = [guid]NewGuid().ToString()
  created = (Get-Date).ToString(o)
  type    = task
  intent  = implement feature X
  payload = @{ detail = ... }
}  ConvertTo-Json -Depth 6
$cmd  Out-File CagentsVSSCqueuejob_$((Get-Date).ToFileTimeUtc()).json -Encoding UTF8

4. HANDOFF DECISION TREE

Core rules (from DC or operator perspective):

    IF web docs, news, API references, external facts needed ? WEBC
    ELSE continue.

    IF code / scripts / IaC / config design or change ? VSSC
        IF security-sensitive / auth / crypto / secrets ? handoff result to KALIC for review.

    IF security audit / policy / compliance / threat model ? KALIC
        IF remediation requires code ? send remediations to VSSC then to CMDC to apply.

    IF multi-step workflow / multi-agent routing / strategy ? DC
        DC decomposes: web ? code ? security ? terminal.

    IF OS / terminal / filesystem / processes / network commands ? CMDC
        IF command design / script authoring needed first ? VSSC, then execute via CMDC.

Practical mapping:

    New feature needing docs: DC ? WEBC ? VSSC
    Change in prod: DC ? VSSC ? KALIC (optional) ? CMDC
    Security incident: DC ? CMDC (gather) ? WEBC (intel) ? KALIC (assessment) ? VSSC/CMDC (fix)

5. TROUBLESHOOTING QUICK FIXES
Common issue	Diagnostic command (from CMDC)	Fix / Action
Agent not consuming queue	Get-ChildItem C:\agents\VSSC\queue	Check agent process; restart service; verify queue path permissions
No responses in out folder	`Get-ChildItem C:\agents\VSSC\logs -Filter *.log	Select -Last 5
CMDC commands hang	`Get-Process	Where-Object Name -like "cmd*"`
WEBC failing lookups	Test-NetConnection "example.com" -Port 443	Check proxy/DNS; update WEBC config; provide mirror URLs
KALIC overblocking changes	Get-Content C:\agents\KALIC\logs\policy.log -Tail 50	Tweak policy config; mark low-risk paths; re-submit with justification
VSSC producing invalid scripts	`Get-Content C:\agents\VSSC\out*.json	Select-String "error"`
High latency on large tasks	`Get-ChildItem C:\agents*\queue	Measure-Object`
Permission denied in CMDC	whoami; Get-Acl <path>	Run CMDC as elevated; adjust ACLs; use temp working directory
Duplicate jobs / double execution	`Get-ChildItem C:\agents\DC\queue	Sort LastWriteTime`
Logs growing too large	`Get-ChildItem C:\agents*\logs	Sort Length -Descending
6. PERFORMANCE OPTIMIZATION

6.1 Parallel vs Sequential

    Use parallel when:
        Tasks are independent (e.g., per-service lint, per-dir scan).
        No shared state or race on same files/DB rows.
    Use sequential when:
        Order matters (migrations, deploys).
        Same resources modified (same repo/module).

powershell

# Example: parallel per-service checks via CMDC
$services = "svc-a","svc-b","svc-c"
$services | ForEach-Object -Parallel {
  & "C:\agents\CMDC\run_check.ps1" $_
} -ThrottleLimit 3

6.2 Load Balancing Across Instances

    Run multiple agent instances per type; shard by:
        Queue directory (VSSC1\queue, VSSC2\queue).
        Job label (e.g., repo name, environment).
    Simple round-robin from DC:

powershell

$targets = "C:\agents\VSSC1\queue","C:\agents\VSSC2\queue"
$i = 0
function Queue-VSSCJob($jobJson) {
  $path = $targets[$script:i % $targets.Count]
  $script:i++
  $file = Join-Path $path ("job_{0}.json" -f [guid]::NewGuid())
  $jobJson | Out-File $file -Encoding UTF8
}

6.3 Timeout Handling

    Always wrap long-running ops with timeout:

powershell

# From CMDC
$job = Start-Process "powershell.exe" -ArgumentList "-File task.ps1" -PassThru
if(-not $job.WaitForExit(600000)){ # 600s
  $job.Kill()
}

    At DC level, track created time; mark stale jobs and requeue or abort.

6.4 Retry Strategies

    Use idempotent operations where possible.
    Implement bounded retries with backoff:

powershell

function Invoke-WithRetry {
  param([scriptblock]$Action,[int]$Max=3)
  for($i=1;$i -le $Max;$i++){
    try { & $Action; return } catch {
      Start-Sleep -Seconds ([math]::Pow(2,$i))
      if($i -eq $Max){ throw }
    }
  }
}

    For WEBC: retry on network/transient errors only (HTTP 5xx, timeouts).
    For CMDC: avoid retries on destructive commands unless fully safe.
Get-ChildItem "C:\agents\VSSC\out" -Filter "*.json" |
  Sort-Object LastWriteTime |
  Select-Object -Last 1 |
  Get-Content | ConvertFrom-Json

Get-ChildItem "C:\agents\VSSC\status" -Filter "*.json" |
  Sort-Object LastWriteTime |
  Select-Object -Last 1 |
  Get-Content | ConvertFrom-Json | Select-Object id,state,progress,message

Get-Content "C:\agents\VSSC\logs\agent.log" -Wait -Tail 50

Remove-Item "C:\agents\VSSC\queue\*.json" -Force
