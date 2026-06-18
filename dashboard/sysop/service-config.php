<?php

session_start();

function finish($message, $ok = true)
{
    $safe = htmlspecialchars($message, ENT_QUOTES);
    $color = $ok ? '#66ff66' : '#ff6666';

    echo "<!doctype html><html><head><meta charset=\"utf-8\"><title>Service Configuration</title></head>";
    echo "<body style=\"background:#0b1118;color:#fff;font-family:Arial,sans-serif;padding:25px;\">";
    echo "<div style=\"background:#162231;border:1px solid #2d425c;border-radius:10px;padding:20px;\">";
    echo "<h2 style=\"color:$color;\">$safe</h2>";
    echo "<p>This window will close automatically.</p>";
    echo "<script>";
    echo "if (window.opener) { window.opener.location.reload(); }";
    echo "setTimeout(function(){ window.close(); }, 1200);";
    echo "</script>";
    echo "</div></body></html>";
    exit;
}

function known_ham_radio_services()
{
    return [
        'mmdvm_bridge.service',
        'analog_bridge.service',
        'md380-emu.service',
        'dvswitch.service',
        'ysfgateway.service',
        'nxdngateway.service',
        'p25gateway.service',
        'ircddbgateway.service',
        'dstargateway.service',
        'dstarrepeater.service',
        'mmdvmhost.service',
        'direwolf.service',
        'svxlink.service',
        'allstarlink.service',
        'asterisk.service',
        'aprx.service',
        'ax25.service',
        'pat.service',
        'bpq32.service',
        'linbpq.service',
    ];
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    finish('Invalid request method', false);
}

$csrf = $_POST['csrf'] ?? '';

if (
    empty($_SESSION['service_control_csrf']) ||
    !hash_equals($_SESSION['service_control_csrf'], $csrf)
) {
    finish('Security check failed', false);
}

$action = $_POST['action'] ?? '';
$selected = $_POST['services'] ?? [];

if ($action !== 'save') {
    finish('Invalid action', false);
}

if (!is_array($selected)) {
    $selected = [];
}

$known = array_flip(known_ham_radio_services());
$valid = [];

foreach ($selected as $unit) {
    $unit = trim((string)$unit);

    if (!isset($known[$unit])) {
        finish('Invalid service selected', false);
    }

    if (!preg_match('/^[A-Za-z0-9_.@-]+\.service$/', $unit)) {
        finish('Invalid service unit selected', false);
    }

    $valid[] = $unit;
}

$sudo = trim((string)shell_exec('command -v sudo 2>/dev/null'));

if ($sudo === '') {
    finish('sudo not found on this system.', false);
}

$args = array_map('escapeshellarg', $valid);
$cmd = escapeshellcmd($sudo) . ' /usr/local/bin/urfd-service-config save ' . implode(' ', $args) . ' 2>&1';

exec($cmd, $output, $rc);

if ($rc === 0) {
    finish('Saved selected service(s).', true);
}

finish('Failed to save selected service(s): ' . implode(' ', $output), false);
