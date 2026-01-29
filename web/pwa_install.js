// PWA Install Prompt Handler
let deferredPrompt;
let hasPromptedThisSession = false;

window.addEventListener('beforeinstallprompt', (e) => {
    // Prevent the mini-infobar from appearing on mobile
    e.preventDefault();
    // Store the event for later use
    deferredPrompt = e;

    // Check if user has already dismissed or installed
    const dismissed = localStorage.getItem('pwa_install_dismissed');
    const installed = localStorage.getItem('pwa_installed');

    if (!dismissed && !installed && !hasPromptedThisSession) {
        // Delay prompt slightly to let the app load first
        setTimeout(() => {
            showInstallPrompt();
        }, 2000);
    }
});

function showInstallPrompt() {
    if (deferredPrompt && !hasPromptedThisSession) {
        hasPromptedThisSession = true;

        // Trigger the install prompt
        deferredPrompt.prompt();

        // Wait for the user's response
        deferredPrompt.userChoice.then((choiceResult) => {
            if (choiceResult.outcome === 'accepted') {
                console.log('User accepted the install prompt');
                localStorage.setItem('pwa_installed', 'true');
            } else {
                console.log('User dismissed the install prompt');
                localStorage.setItem('pwa_install_dismissed', 'true');
            }
            deferredPrompt = null;
        });
    }
}

// Track when app is successfully installed
window.addEventListener('appinstalled', () => {
    console.log('Applyd was installed');
    localStorage.setItem('pwa_installed', 'true');
    deferredPrompt = null;
});

// Expose function to manually trigger install from Flutter if needed
window.triggerPwaInstall = function () {
    if (deferredPrompt) {
        showInstallPrompt();
        return true;
    }
    return false;
};
