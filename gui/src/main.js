// PhiSHRI Installer - Enhanced Main JS
// Terminal Panel with Persistent Display
// =====================================

const { invoke } = window.__TAURI__.core;
const { listen } = window.__TAURI__.event;

// State
let selectedMethod = 'Auto';
let isInstalling = false;

// DOM Elements
const elements = {
    statusDot: document.getElementById('status-dot'),
    statusText: document.getElementById('status-text'),
    statusDetails: document.getElementById('status-details'),
    methodSection: document.getElementById('method-section'),
    // Terminal elements
    terminalPanel: document.getElementById('terminal-panel'),
    terminalIndicator: document.getElementById('terminal-indicator'),
    terminalStatus: document.getElementById('terminal-status'),
    terminalProgress: document.getElementById('terminal-progress'),
    terminalOutput: document.getElementById('terminal-output'),
    terminalPath: document.getElementById('terminal-path'),
    progressBar: document.getElementById('progress-bar'),
    progressText: document.getElementById('progress-text'),
    progressStep: document.getElementById('progress-step'),
    // Buttons
    installBtn: document.getElementById('install-btn'),
    uninstallBtn: document.getElementById('uninstall-btn'),
    methodCards: document.querySelectorAll('.method-card'),
    progressContainer: document.querySelector('.progress-bar-container')
};

// Idle terminal content
const IDLE_CONTENT = `╔══════════════════════════════════════════════════════════════╗
║  PhiSHRI MCP Server Installer                                ║
║  Knowledge Management System                                 ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  ► Select installation method above                         ║
║  ► Click [Install PhiSHRI] to begin                         ║
║                                                              ║
║  Status: Awaiting user input...                             ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝`;

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
    setupMethodSelection();
    setupButtons();
    setupKeyboardNavigation();
    await checkInstallation();
    setupProgressListener();
});

// Method selection with accessibility
function setupMethodSelection() {
    elements.methodCards.forEach(card => {
        card.addEventListener('click', () => selectMethod(card));
    });
}

function selectMethod(card) {
    if (isInstalling) return;
    
    elements.methodCards.forEach(c => {
        c.classList.remove('selected');
        c.setAttribute('aria-checked', 'false');
    });
    
    card.classList.add('selected');
    card.setAttribute('aria-checked', 'true');
    selectedMethod = card.dataset.method;
    
    // Update terminal to show selected method
    updateTerminalIdle(`Method selected: ${selectedMethod}`);
    
    // Subtle feedback animation
    card.style.transform = 'scale(0.98)';
    setTimeout(() => {
        card.style.transform = '';
    }, 100);
}

// Keyboard navigation for method cards
function setupKeyboardNavigation() {
    const methodGrid = document.querySelector('.method-grid');
    
    methodGrid.addEventListener('keydown', (e) => {
        const cards = Array.from(elements.methodCards);
        const currentIndex = cards.findIndex(c => c.classList.contains('selected'));
        let nextIndex;
        
        switch(e.key) {
            case 'ArrowRight':
            case 'ArrowDown':
                nextIndex = (currentIndex + 1) % cards.length;
                break;
            case 'ArrowLeft':
            case 'ArrowUp':
                nextIndex = (currentIndex - 1 + cards.length) % cards.length;
                break;
            case 'Enter':
            case ' ':
                e.preventDefault();
                selectMethod(cards[currentIndex]);
                return;
            default:
                return;
        }
        
        e.preventDefault();
        selectMethod(cards[nextIndex]);
        cards[nextIndex].focus();
    });
}

// Button handlers
function setupButtons() {
    elements.installBtn.addEventListener('click', runInstall);
    elements.uninstallBtn.addEventListener('click', runUninstall);
}

// Check current installation status
async function checkInstallation() {
    try {
        const result = await invoke('check_installation');
        const platform = result.platform || { os: 'unknown', arch: 'unknown' };
        
        if (result.installed) {
            setStatus('installed', 'PhiSHRI is installed');
            elements.statusDetails.innerHTML = `
                <div><span style="color: var(--accent-primary);">${result.door_count}</span> doors available</div>
                <div style="margin-top: 4px;">
                    ${platform.os} ${platform.arch} │ ${result.paths.root}
                </div>
            `;
            elements.installBtn.innerHTML = '<span class="btn-icon">↻</span> Reinstall PhiSHRI';
            elements.terminalPath.textContent = result.paths.root;
            
            // Update terminal with installed info
            updateTerminalInstalled(result);
        } else {
            setStatus('not-installed', 'PhiSHRI not installed');
            elements.statusDetails.innerHTML = `
                <div>Select a method and click Install to begin</div>
                <div style="margin-top: 4px;">
                    Platform: ${platform.os} ${platform.arch}
                </div>
            `;
            elements.terminalPath.textContent = '~';
        }
    } catch (e) {
        setStatus('error', 'System check failed');
        elements.statusDetails.innerHTML = `
            <div style="color: var(--error);">${formatError(e)}</div>
        `;
        terminalError(formatError(e));
    }
}

// Update terminal to show installed state
function updateTerminalInstalled(result) {
    const doorCount = result.door_count || 0;
    const rootPath = result.paths?.root || '~';
    
    elements.terminalOutput.innerHTML = `
        <div class="terminal-line system">╔══════════════════════════════════════════════════════════════╗</div>
        <div class="terminal-line system">║  PhiSHRI MCP Server - ACTIVE                                 ║</div>
        <div class="terminal-line system">╠══════════════════════════════════════════════════════════════╣</div>
        <div class="terminal-line system">║                                                              ║</div>
        <div class="terminal-line ok">  ✓ MCP Server configured and ready</div>
        <div class="terminal-line info">  Doors available: ${String(doorCount).padEnd(42)}</div>
        <div class="terminal-line info">  Root: ${rootPath.substring(0, 52).padEnd(52)}</div>
        <div class="terminal-line system">║                                                              ║</div>
        <div class="terminal-line system">║  Actions:                                                    ║</div>
        <div class="terminal-line system">║  • Reinstall to update configuration                        ║</div>
        <div class="terminal-line system">║  • Uninstall to remove MCP server entry                     ║</div>
        <div class="terminal-line system">║                                                              ║</div>
        <div class="terminal-line system">╚══════════════════════════════════════════════════════════════╝</div>
    `;
}

// Update terminal idle state with custom message
function updateTerminalIdle(customLine = null) {
    let content = IDLE_CONTENT;
    if (customLine) {
        content = content.replace(
            'Status: Awaiting user input...',
            `Status: ${customLine}`
        );
    }
    
    elements.terminalOutput.innerHTML = content.split('\n').map(line => 
        `<div class="terminal-line system">${line}</div>`
    ).join('');
}

// Set status indicator
function setStatus(state, text) {
    elements.statusDot.className = `status-dot ${state}`;
    elements.statusText.textContent = text;
}

// Set terminal status
function setTerminalStatus(status) {
    elements.terminalStatus.textContent = status;
    elements.terminalStatus.className = 'terminal-status';
    
    if (status === 'ACTIVE') {
        elements.terminalStatus.classList.add('active');
        elements.terminalIndicator.classList.add('active');
    } else if (status === 'COMPLETE') {
        elements.terminalStatus.classList.add('complete');
        elements.terminalIndicator.classList.remove('active');
    } else if (status === 'ERROR') {
        elements.terminalStatus.classList.add('error');
        elements.terminalIndicator.classList.remove('active');
    } else {
        elements.terminalIndicator.classList.remove('active');
    }
}

// Progress listener
function setupProgressListener() {
    listen('install-progress', (event) => {
        const { step, status, message, progress } = event.payload;

        // Update progress bar
        updateProgress(progress);
        if (elements.progressStep) {
            elements.progressStep.textContent = step;
        }

        // Add log line
        addTerminalLine(message, status);

        // Check completion
        if (progress >= 100) {
            setTimeout(async () => {
                isInstalling = false;
                updateButtonStates();
                setTerminalStatus('COMPLETE');
                addTerminalLine('Installation complete', 'ok');
                addTerminalLine('─'.repeat(60), 'system');
                await checkInstallation();
            }, 800);
        }
    });
}

// Smooth progress update
function updateProgress(value) {
    const clampedValue = Math.min(100, Math.max(0, value));
    elements.progressBar.style.width = `${clampedValue}%`;
    elements.progressText.textContent = `${Math.round(clampedValue)}%`;
    
    // Update ARIA
    elements.progressContainer?.setAttribute('aria-valuenow', clampedValue);
}

// Clear terminal and prepare for logging
function clearTerminal() {
    elements.terminalOutput.innerHTML = '';
    elements.terminalProgress.classList.add('visible');
    setTerminalStatus('ACTIVE');
}

// Add line to terminal
function addTerminalLine(message, status = 'info') {
    const line = document.createElement('div');
    line.className = `terminal-line ${status}`;
    line.textContent = message;
    
    elements.terminalOutput.appendChild(line);
    
    // Smooth scroll to bottom
    requestAnimationFrame(() => {
        elements.terminalOutput.scrollTop = elements.terminalOutput.scrollHeight;
    });
}

// Show error in terminal
function terminalError(message) {
    setTerminalStatus('ERROR');
    elements.terminalOutput.innerHTML = `
        <div class="terminal-line system">╔══════════════════════════════════════════════════════════════╗</div>
        <div class="terminal-line system">║  ERROR                                                       ║</div>
        <div class="terminal-line system">╠══════════════════════════════════════════════════════════════╣</div>
        <div class="terminal-line error">${message}</div>
        <div class="terminal-line system">╚══════════════════════════════════════════════════════════════╝</div>
    `;
}

// Run installation
async function runInstall() {
    if (isInstalling) return;

    isInstalling = true;
    updateButtonStates();

    // Prepare terminal
    clearTerminal();
    updateProgress(0);
    
    addTerminalLine('─'.repeat(60), 'system');
    addTerminalLine(`PhiSHRI Installation - ${selectedMethod} Method`, 'command');
    addTerminalLine('─'.repeat(60), 'system');
    addTerminalLine(`Starting ${selectedMethod} installation...`, 'info');

    try {
        await invoke('run_installer', {
            options: { method: selectedMethod }
        });
    } catch (e) {
        addTerminalLine(`Error: ${formatError(e)}`, 'error');
        setTerminalStatus('ERROR');
        isInstalling = false;
        updateButtonStates();
    }
}

// Run uninstall
async function runUninstall() {
    if (isInstalling) return;

    if (!confirm('Uninstall PhiSHRI?\n\nThis will remove the MCP server configuration.')) {
        return;
    }

    isInstalling = true;
    updateButtonStates();

    clearTerminal();
    updateProgress(0);
    
    addTerminalLine('─'.repeat(60), 'system');
    addTerminalLine('PhiSHRI Uninstallation', 'command');
    addTerminalLine('─'.repeat(60), 'system');
    addTerminalLine('Removing PhiSHRI...', 'info');

    try {
        await invoke('run_uninstaller');
        updateProgress(100);
        addTerminalLine('PhiSHRI has been uninstalled', 'ok');
        addTerminalLine('─'.repeat(60), 'system');
        setTerminalStatus('COMPLETE');
    } catch (e) {
        addTerminalLine(`Error: ${formatError(e)}`, 'error');
        setTerminalStatus('ERROR');
    } finally {
        isInstalling = false;
        updateButtonStates();
        // Hide progress after a moment
        setTimeout(() => {
            elements.terminalProgress.classList.remove('visible');
        }, 1500);
        await checkInstallation();
    }
}

// Update button states
function updateButtonStates() {
    elements.installBtn.disabled = isInstalling;
    elements.uninstallBtn.disabled = isInstalling;

    if (isInstalling) {
        elements.installBtn.innerHTML = `
            <span class="btn-icon" style="animation: spin 1s linear infinite;">◐</span>
            Installing...
        `;
    } else {
        elements.installBtn.innerHTML = '<span class="btn-icon">+</span> Install PhiSHRI';
    }
}

// Error formatting helper
function formatError(error) {
    if (typeof error === 'string') return error;
    if (error?.message) return error.message;
    return String(error);
}

// Add spin animation for loading state
const style = document.createElement('style');
style.textContent = `
    @keyframes spin {
        to { transform: rotate(360deg); }
    }
`;
document.head.appendChild(style);
