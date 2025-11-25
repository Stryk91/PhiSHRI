// PhiSHRI Installer - Main JS

const { invoke } = window.__TAURI__.core;
const { listen } = window.__TAURI__.event;

// State
let selectedMethod = 'Auto';
let isInstalling = false;

// DOM Elements
const statusDot = document.getElementById('status-dot');
const statusText = document.getElementById('status-text');
const statusDetails = document.getElementById('status-details');
const methodSection = document.getElementById('method-section');
const progressSection = document.getElementById('progress-section');
const progressBar = document.getElementById('progress-bar');
const progressText = document.getElementById('progress-text');
const progressStep = document.getElementById('progress-step');
const logContainer = document.getElementById('log-container');
const installBtn = document.getElementById('install-btn');
const uninstallBtn = document.getElementById('uninstall-btn');

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
    setupMethodSelection();
    setupButtons();
    await checkInstallation();
    setupProgressListener();
});

// Method selection
function setupMethodSelection() {
    const methodCards = document.querySelectorAll('.method-card');

    methodCards.forEach(card => {
        card.addEventListener('click', () => {
            methodCards.forEach(c => c.classList.remove('selected'));
            card.classList.add('selected');
            selectedMethod = card.dataset.method;
        });
    });
}

// Button handlers
function setupButtons() {
    installBtn.addEventListener('click', runInstall);
    uninstallBtn.addEventListener('click', runUninstall);
}

// Check current installation status
async function checkInstallation() {
    try {
        const result = await invoke('check_installation');

        if (result.installed) {
            statusDot.className = 'status-dot installed';
            statusText.textContent = 'PhiSHRI is installed';
            statusDetails.innerHTML = `
                <div>${result.door_count} doors available</div>
                <div style="font-size: 11px; margin-top: 4px; color: var(--text-muted);">
                    ${result.platform.os} ${result.platform.arch} | ${result.paths.root}
                </div>
            `;
            installBtn.innerHTML = '<span class="btn-icon">+</span> Reinstall PhiSHRI';
        } else {
            statusDot.className = 'status-dot not-installed';
            statusText.textContent = 'PhiSHRI not installed';
            const platform = result.platform || { os: 'unknown', arch: 'unknown' };
            statusDetails.innerHTML = `
                <div>Click Install to get started</div>
                <div style="font-size: 11px; margin-top: 4px; color: var(--text-muted);">
                    Platform: ${platform.os} ${platform.arch}
                </div>
            `;
        }
    } catch (e) {
        statusDot.className = 'status-dot error';
        statusText.textContent = 'Error checking installation';
        statusDetails.textContent = e.toString();
    }
}

// Progress listener
function setupProgressListener() {
    listen('install-progress', (event) => {
        const { step, status, message, progress } = event.payload;

        // Update progress bar
        progressBar.style.width = `${progress}%`;
        progressText.textContent = `${progress}%`;
        progressStep.textContent = step;

        // Add log line
        addLogLine(message, status);

        // Check completion
        if (progress >= 100) {
            setTimeout(() => {
                isInstalling = false;
                updateButtonStates();
                checkInstallation();
            }, 1000);
        }
    });
}

// Add log line
function addLogLine(message, status) {
    const line = document.createElement('div');
    line.className = `log-line ${status}`;
    line.textContent = message;
    logContainer.appendChild(line);
    logContainer.scrollTop = logContainer.scrollHeight;
}

// Run installation
async function runInstall() {
    if (isInstalling) return;

    isInstalling = true;
    updateButtonStates();

    // Show progress section
    progressSection.classList.remove('hidden');
    logContainer.innerHTML = '';
    progressBar.style.width = '0%';
    progressText.textContent = '0%';
    progressStep.textContent = 'Starting...';

    try {
        await invoke('run_installer', {
            options: { method: selectedMethod }
        });
    } catch (e) {
        addLogLine(`Error: ${e}`, 'error');
        isInstalling = false;
        updateButtonStates();
    }
}

// Run uninstall
async function runUninstall() {
    if (isInstalling) return;

    if (!confirm('Are you sure you want to uninstall PhiSHRI?')) {
        return;
    }

    isInstalling = true;
    updateButtonStates();

    progressSection.classList.remove('hidden');
    logContainer.innerHTML = '';
    progressBar.style.width = '0%';
    progressStep.textContent = 'Uninstalling...';

    try {
        await invoke('run_uninstaller');
        addLogLine('PhiSHRI has been uninstalled', 'ok');
    } catch (e) {
        addLogLine(`Error: ${e}`, 'error');
    } finally {
        isInstalling = false;
        updateButtonStates();
        await checkInstallation();
    }
}

// Update button states
function updateButtonStates() {
    installBtn.disabled = isInstalling;
    uninstallBtn.disabled = isInstalling;

    if (isInstalling) {
        installBtn.innerHTML = '<span class="btn-icon">...</span> Installing...';
    } else {
        installBtn.innerHTML = '<span class="btn-icon">+</span> Install PhiSHRI';
    }
}
