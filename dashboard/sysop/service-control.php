<?php

session_start();

function redirect_back($message, $ok = false)
{
    $code = $ok ? 'success' : 'error';
    header('Location: index.php?service_control_' . $code . '=' . urlencode($message));
    exit;
}

function log_action($service, $action, $result)
{
    $log = '/var/log/urfd-dashboard-actions.log';
    $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $user = $_SERVER['REMOTE_USER'] ?? 'unknown';
    $time = date('Y-m-d H:i:s T');

    $line = sprintf(
        "%s user=%s ip=%s service=%s action=%s result=%s\n",
        $time,
        $user,
        $ip,
        $service,
        $action,
        $result
    );

    @file_put_contents($log, $line, FILE_APPEND | LOCK_EX);
}

function read_custom_service_controls()
{
    $conf = '/etc/urfd-dashboard/service-controls.conf';
    $services = [];

    if (!is_readable($conf)) {
        return $services;
    }

    $currentName = '';

    foreach (file($conf, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);

        if ($line === '' || $line[0] === '#') {
            continue;
        }

        if (preg_match('/^\[(.+)\]$/', $line, $m)) {
            $currentName = trim($m[1]);
            continue;
        }

        if ($currentName !== '' && strpos($line, 'service=') === 0) {
            $serviceUnit = trim(substr($line, 8));

            if (preg_match('/^[A-Za-z0-9_.@-]+\.service$/', $serviceUnit)) {
                $services[$serviceUnit] = $currentName;
            }

            $currentName = '';
        }
    }

    return $services;
}

$allowed = [
    'urfd-tcd' => 'URFD/TCD',
];

foreach (read_custom_service_controls() as $unit => $name) {
    $allowed[$unit] = $name;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    redirect_back('Invalid request method');
}

$service = $_POST['service'] ?? '';
$action = $_POST['action'] ?? '';
$csrf = $_POST['csrf'] ?? '';

if (
    empty($_SESSION['service_control_csrf']) ||
    !hash_equals($_SESSION['service_control_csrf'], $csrf)
) {
    log_action($service, $action, 'rejected-csrf');
    redirect_back('Security check failed');
}

if (!in_array($action, ['start', 'stop', 'restart'], true)) {
    log_action($service, $action, 'rejected-invalid-action');
    redirect_back('Invalid action');
}

if (!isset($allowed[$service])) {
    log_action($service, $action, 'rejected-invalid-service');
    redirect_back('Invalid service');
}

$sudo = trim((string)shell_exec('command -v sudo 2>/dev/null'));

if ($sudo === '') {
    log_action($service, $action, 'failed-sudo-not-found');
    redirect_back('sudo not found on this system.', false);
}

$cmd = escapeshellcmd($sudo) . ' /usr/local/bin/urfd-service-control ' . escapeshellarg($action) . ' ' . escapeshellarg($service) . ' 2>&1';
exec($cmd, $output, $rc);

if ($rc === 0) {
    log_action($service, $action, 'success');
    redirect_back($allowed[$service] . ' ' . $action . ' completed successfully.', true);
}

log_action($service, $action, 'failed-rc-' . $rc);
redirect_back($allowed[$service] . ' ' . $action . ' failed.', false);
