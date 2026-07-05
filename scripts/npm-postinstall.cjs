/**
 * npm postinstall script for maestro
 * 
 * The npm package contains only the CLI wrapper. The full agent files
 * are deployed from ~/Git/maestro via `maestro update`.
 * 
 * Note: Writes directly to /dev/tty to bypass npm's output suppression.
 * Falls back to stderr if tty is not available (e.g., CI environments).
 */

const fs = require('fs');
const os = require('os');
const path = require('path');

const agentsDir = path.join(os.homedir(), '.maestro', 'agents');
const versionFile = path.join(agentsDir, 'VERSION');

// Try to open tty synchronously to bypass npm's output suppression
let ttyFd = null;
try {
    ttyFd = fs.openSync('/dev/tty', 'w');
} catch {
    // tty not available (CI, non-interactive, Windows)
}

const log = (msg = '') => {
    const line = msg + '\n';
    if (ttyFd !== null) {
        try {
            fs.writeSync(ttyFd, line);
        } catch {
            // TTY write failed. Fall back to stderr for this and subsequent calls.
            try { fs.closeSync(ttyFd); } catch { /* best effort to close */ }
            ttyFd = null;
            process.stderr.write(line);
        }
    } else {
        process.stderr.write(line);
    }
};

// Check current installed version
let installedVersion = 'not installed';
if (fs.existsSync(versionFile)) {
    installedVersion = fs.readFileSync(versionFile, 'utf8').trim();
}

// Get package version
const packageJson = require('../package.json');
const packageVersion = packageJson.version;

log('');
log('maestro CLI installed successfully!');
log('');
log(`  CLI version:    ${packageVersion}`);
log(`  Agents version: ${installedVersion}`);
log('');

if (installedVersion === 'not installed') {
    log('To complete installation, run:');
    log('');
    log('  maestro update');
    log('');
    log('This will clone the repository and deploy agents to ~/.maestro/agents/');
} else if (installedVersion !== packageVersion) {
    log('To update agents to match CLI version, run:');
    log('');
    log('  maestro update');
    log('');
} else {
    log('CLI and agents are in sync. Ready to use!');
    log('');
    log('Quick start:');
    log('  maestro status    # Check installation');
    log('  maestro init      # Initialize in a project');
    log('  maestro help      # Show all commands');
}
log('');

// Clean up
if (ttyFd !== null) {
    try {
        fs.closeSync(ttyFd);
    } catch {
        // Ignore errors on close, as there's nothing more to do.
    }
}
