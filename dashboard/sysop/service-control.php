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

$allowed = [
    'urfd-tcd' => 'URFD/TCD',
];

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

if ($action !== 'restart') {
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

$cmd = escapeshellcmd($sudo) . ' /usr/local/bin/urfd-service-control ' . escapeshellarg($service) . ' 2>&1';
exec($cmd, $output, $rc);

if ($rc === 0) {
    log_action($service, $action, 'success');
    redirect_back($allowed[$service] . ' restarted successfully.', true);
}

log_action($service, $action, 'failed-rc-' . $rc);
redirect_back($allowed[$service] . ' restart failed.', false);
