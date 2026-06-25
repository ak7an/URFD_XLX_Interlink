<?php

session_start();

require_once __DIR__ . '/health.php';

if (empty($_SESSION['service_control_csrf'])) {
    $_SESSION['service_control_csrf'] = bin2hex(random_bytes(32));
}

function dashboard_timezone()
{
    $conf = '/etc/urfd-dashboard/dashboard.conf';
    $tz = 'UTC';

    if (is_readable($conf)) {
        foreach (file($conf, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
            $line = trim($line);
            if ($line === '' || $line[0] === '#') {
                continue;
            }
            if (strpos($line, 'TIMEZONE=') === 0) {
                $tz = trim(substr($line, 9));
                break;
            }
        }
    }

    if (!in_array($tz, timezone_identifiers_list(), true)) {
        $tz = 'UTC';
    }

    date_default_timezone_set($tz);
    return $tz;
}

$dashboardTimezone = dashboard_timezone();

function service_state($svc)
{
    $state = trim(shell_exec("systemctl is-active " . escapeshellarg($svc) . " 2>/dev/null"));
    return $state !== "" ? $state : "unavailable";
}

function service_running_since($svc)
{
    $since = trim(shell_exec("systemctl show " . escapeshellarg($svc) . " -p ActiveEnterTimestamp --value 2>/dev/null"));
    return $since !== "" ? $since : "Unavailable";
}

function service_uptime($svc)
{
    $ts = trim(shell_exec("systemctl show " . escapeshellarg($svc) . " -p ActiveEnterTimestampMonotonic --value 2>/dev/null"));

    if (!is_numeric($ts) || $ts <= 0) {
        return "Unavailable";
    }

    $boot_usec = trim(shell_exec("awk '{print int($1 * 1000000)}' /proc/uptime"));
    $diff_sec = intval(($boot_usec - intval($ts)) / 1000000);

    if ($diff_sec < 0) {
        return "Unavailable";
    }

    $days = intdiv($diff_sec, 86400);
    $diff_sec %= 86400;
    $hours = intdiv($diff_sec, 3600);
    $diff_sec %= 3600;
    $mins = intdiv($diff_sec, 60);

    $parts = [];
    if ($days > 0) $parts[] = $days . "d";
    if ($hours > 0) $parts[] = $hours . "h";
    $parts[] = $mins . "m";

    return implode(" ", $parts);
}

function cpu_temp()
{
    $temp = trim(shell_exec("sensors 2>/dev/null | awk '/Package id 0:/ {print $4; exit}'"));
    return $temp !== "" ? $temp : "Unavailable";
}

function udp_listener_state($port)
{
    $ss = shell_exec("ss -H -lun 2>/dev/null");
    if ($ss && preg_match('/[:.]' . preg_quote((string)$port, '/') . '\s/', $ss)) {
        return "active";
    }
    return "inactive";
}

function process_state($pattern)
{
    $cmd = "pgrep -f " . escapeshellarg($pattern) . " >/dev/null 2>&1 && echo active || echo inactive";
    return trim(shell_exec($cmd));
}

function dvsi_dongle_count()
{
    $out = trim(shell_exec("lsusb 2>/dev/null | grep -ci '0403:6015\\|DVSI\\|ThumbDV\\|Future Technology Devices'"));
    return is_numeric($out) ? intval($out) : 0;
}

function state_class($state)
{
    return ($state === "active" || $state === "ready" || $state === "online") ? "good" : "bad";
}

function health_status_class($status)
{
    if ($status === "PASS") {
        return "good";
    }
    if ($status === "WARN") {
        return "warn";
    }
    return "bad";
}

function dashboard_logo()
{
    $conf = '/etc/urfd-dashboard/dashboard.conf';

    if (!is_readable($conf)) {
        return '';
    }

    foreach (file($conf, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (strpos($line, 'DASHBOARD_LOGO=') === 0) {
            return trim(substr($line, 15));
        }
    }

    return '';
}

function read_dashboard_config()
{
    $conf = '/etc/urfd-dashboard/dashboard.conf';
    $out = [];

    if (!is_readable($conf)) {
        return $out;
    }

    foreach (file($conf, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#' || strpos($line, '=') === false) {
            continue;
        }

        [$key, $value] = array_map('trim', explode('=', $line, 2));
        $out[$key] = $value;
    }

    return $out;
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
                $services[] = [
                    'name' => $currentName,
                    'unit' => $serviceUnit,
                ];
            }

            $currentName = '';
        }
    }

    return $services;
}

function ham_radio_service_discovery()
{
    $known = [
        'MMDVM_Bridge'   => 'mmdvm_bridge.service',
        'Analog_Bridge'  => 'analog_bridge.service',
        'MD380 Emulator' => 'md380-emu.service',
        'DVSwitch'       => 'dvswitch.service',
        'YSFGateway'     => 'ysfgateway.service',
        'NXDNGateway'    => 'nxdngateway.service',
        'P25Gateway'     => 'p25gateway.service',
        'ircDDBGateway'  => 'ircddbgateway.service',
        'DStarRepeater'  => 'dstarrepeater.service',
        'MMDVMHost'      => 'mmdvmhost.service',
        'Dire Wolf'      => 'direwolf.service',
    ];

    $unitFiles = shell_exec('systemctl list-unit-files --type=service --no-legend 2>/dev/null');
    $found = [];

    foreach ($known as $name => $unit) {
        if ($unitFiles && preg_match('/^' . preg_quote($unit, '/') . '\s+/m', $unitFiles)) {
            $found[] = [
                'name' => $name,
                'unit' => $unit,
                'state' => service_state($unit),
            ];
        }
    }

    return $found;
}

function file_status($path)
{
    if ($path === '') {
        return 'not configured';
    }

    if (!file_exists($path)) {
        return 'missing';
    }

    $perms = substr(sprintf('%o', fileperms($path)), -4);
    $owner = function_exists('posix_getpwuid') ? posix_getpwuid(fileowner($path)) : null;
    $group = function_exists('posix_getgrgid') ? posix_getgrgid(filegroup($path)) : null;

    $ownerName = $owner['name'] ?? (string)fileowner($path);
    $groupName = $group['name'] ?? (string)filegroup($path);

    if ($perms === '0600' && $ownerName === 'root' && $groupName === 'root') {
        return "present / protected ($ownerName:$groupName $perms)";
    }

    return "present / review permissions ($ownerName:$groupName $perms)";
}

function file_timestamp($path)
{
    if ($path === '' || !is_readable($path)) {
        return 'Unavailable';
    }

    $value = trim((string)file_get_contents($path));
    return $value !== '' ? $value : 'Unavailable';
}


$combinedSvc = 'urfd-tcd.service';

$hostname = gethostname();
$time = date('Y-m-d H:i:s T');
$dashboardLogo = dashboard_logo();

$combinedState = service_state($combinedSvc);
$urfdState = process_state('/home/ed/urfd/reflector/urfd');
$tcdState = $combinedState;

$reflectorSince = service_running_since($combinedSvc);
$reflectorUptime = service_uptime($combinedSvc);

$dvsiCount = dvsi_dongle_count();
$dvsiStatus = $dvsiCount > 0 ? "ready" : "not found";
$transcoderStatus = ($combinedState === "active" && $dvsiCount > 0) ? "ready" : "not ready";

$dashboardConfig = read_dashboard_config();
$health = urfd_health();
$healthCounts = $health['counts'] ?? urfd_health_counts($health);
$healthProblems = urfd_health_problem_checks($health);
$customServiceControls = read_custom_service_controls();
$callingHomeEnabled = strtolower($dashboardConfig['CALLING_HOME_ENABLED'] ?? 'false');
$callingHomeState = $callingHomeEnabled === 'true' ? 'enabled' : 'disabled';
$callingHomeTimer = service_state('urfd-callinghome.timer');
$callingHomeReflectorName = $dashboardConfig['CALLING_HOME_REFLECTOR_NAME'] ?? 'Unavailable';
$callingHomeHashFile = $dashboardConfig['CALLING_HOME_HASH_FILE'] ?? '/var/lib/urfd/callinghome.hash';
$callingHomeLastFile = $dashboardConfig['CALLING_HOME_LAST_FILE'] ?? '/var/lib/urfd/lastcallhome';
$callingHomeResponseFile = $dashboardConfig['CALLING_HOME_RESPONSE_FILE'] ?? '/var/lib/urfd/callinghome.response';
$callingHomeInterlinkFile = $dashboardConfig['CALLING_HOME_INTERLINK_FILE'] ?? '';
$callingHomeResponseStatus = file_exists($callingHomeResponseFile) ? trim((string)file($callingHomeResponseFile)[1] ?? 'available') : 'missing';
$callingHomeHashStatus = file_status($callingHomeHashFile);
$callingHomeLastPublish = file_timestamp($callingHomeLastFile);
$callingHomeInterlinkStatus = file_exists($callingHomeInterlinkFile) ? 'present' : 'missing';

if ($combinedState !== "active") {
    $urfdState = $combinedState;
    $tcdState = $combinedState;
    $transcoderStatus = "not ready";
    $dvsiCount = 0;
    $dvsiStatus = "offline";
    $reflectorUptime = "offline";
    $reflectorSince = "offline";
}

$protocols = [
    ["DPlus", 20001],
    ["DExtra", 30001],
    ["DCS", 30051],
    ["DMR MMDVM", 62030],
    ["NXDN", 41400],
    ["YSF", 42000],
    ["P25", 41000],
    ["M17", 17000],
    ["XLX Interlink", 10002],
];

$serverUptime = trim(shell_exec("uptime -p"));
$load = sys_getloadavg();

$mem = trim(shell_exec("free -m | awk '/Mem:/ {print $3 \" / \" $2 \" MB\"}'"));
$disk = trim(shell_exec("df -h / | awk 'NR==2 {print $3 \" / \" $2 \" (\" $5 \")\"}'"));
$cpuTemp = cpu_temp();

?>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>URF277 Sysop Dashboard</title>
<style>
body{background:#0b1118;color:#fff;font-family:Arial,sans-serif;margin:0;}
header{
background:#162231;
padding:10px 40px;
display:flex;
align-items:center;
justify-content:space-between;
gap:30px;
box-sizing:border-box;
}
main{padding:20px 30px 40px 30px;}
.card{background:#162231;border:1px solid #2d425c;border-radius:10px;padding:20px 30px 40px 30px;margin-bottom:20px;max-width:900px;}
.good{color:#66ff66;font-weight:bold;}
.warn{color:#ffcc66;font-weight:bold;}
.bad{color:#ff6666;font-weight:bold;}
.status-dot{display:inline-block;width:0.7em;height:0.7em;border-radius:50%;margin-right:0.4em;vertical-align:middle;}
.status-dot.good{background:#66ff66;}
.status-dot.warn{background:#ffcc66;}
.status-dot.bad{background:#ff6666;}
table{border-collapse:collapse;}
td,th{padding:8px 15px;text-align:left;}
th{border-bottom:1px solid #2d425c;}

.logo{
flex:0 0 auto;
}

.logo img{
display:block;
height:180px;
width:auto;
max-height:180px;
max-width:360px;
}
</style>
</head>
<body>

<header>
<h1>URF277 Sysop Dashboard</h1>

<?php if ($dashboardLogo !== ''): ?>
<div class="logo">
<img src="<?= htmlspecialchars($dashboardLogo) ?>" alt="Dashboard Logo">
</div>
<?php endif; ?>

</header>

<main>

<?php if (isset($_GET['service_control_success'])): ?>
<div class="card">
<p class="good"><?= htmlspecialchars($_GET['service_control_success']) ?></p>
</div>
<?php endif; ?>

<?php if (isset($_GET['service_control_error'])): ?>
<div class="card">
<p class="bad"><?= htmlspecialchars($_GET['service_control_error']) ?></p>
</div>
<?php endif; ?>

<div class="card">
<h2>System Health</h2>
<table>
<tr>
<td>Overall Status</td>
<td class="<?= health_status_class($health['overall'] ?? 'WARN') ?>"><span class="status-dot <?= health_status_class($health['overall'] ?? 'WARN') ?>"></span><?= htmlspecialchars($health['overall'] ?? 'WARN') ?></td>
</tr>
<tr>
<td>Check Counts</td>
<td>
<span class="good"><span class="status-dot good"></span>PASS <?= htmlspecialchars((string)($healthCounts['PASS'] ?? 0)) ?></span>
&nbsp;
<span class="warn"><span class="status-dot warn"></span>WARN <?= htmlspecialchars((string)($healthCounts['WARN'] ?? 0)) ?></span>
&nbsp;
<span class="bad"><span class="status-dot bad"></span>FAIL <?= htmlspecialchars((string)($healthCounts['FAIL'] ?? 0)) ?></span>
</td>
</tr>
<?php if (empty($healthProblems)): ?>
<tr><td>Warnings / Failures</td><td class="good"><span class="status-dot good"></span>None</td></tr>
<?php else: ?>
<?php foreach ($healthProblems as $item): ?>
<tr>
<td class="<?= health_status_class($item['status'] ?? 'WARN') ?>"><span class="status-dot <?= health_status_class($item['status'] ?? 'WARN') ?>"></span><?= htmlspecialchars(($item['status'] ?? 'WARN') . ' ' . ($item['label'] ?? 'Health Check')) ?></td>
<td><?= htmlspecialchars($item['message'] ?? '') ?></td>
</tr>
<?php endforeach; ?>
<?php endif; ?>
</table>
</div>

<div class="card">
<h2>Reflector Status</h2>
<table>
<tr><td>URFD/TCD Service</td><td class="<?= state_class($combinedState) ?>"><?= htmlspecialchars($combinedState) ?></td></tr>
<tr><td>URFD Service State</td><td class="<?= state_class($urfdState) ?>"><?= htmlspecialchars($urfdState) ?></td></tr>
<tr><td>TCD Service State</td><td class="<?= state_class($tcdState) ?>"><?= htmlspecialchars($tcdState) ?></td></tr>
<tr><td>Transcoder Status</td><td class="<?= state_class($transcoderStatus) ?>"><?= htmlspecialchars($transcoderStatus) ?></td></tr>
<tr><td>DVSI Dongles Detected</td><td class="<?= state_class($dvsiStatus) ?>"><?= htmlspecialchars($dvsiCount . " detected") ?></td></tr>
<tr><td>D-Star Dongle</td><td class="<?= $dvsiCount >= 1 ? 'good' : 'bad' ?>"><?= htmlspecialchars($dvsiCount >= 1 ? 'present' : 'missing') ?></td></tr>
<tr><td>DMR/YSF Dongle</td><td class="<?= $dvsiCount >= 2 ? 'good' : 'bad' ?>"><?= htmlspecialchars($dvsiCount >= 2 ? 'present' : 'missing') ?></td></tr>
<tr><td>Reflector Uptime</td><td><?= htmlspecialchars($reflectorUptime) ?></td></tr>
<tr><td>Running Since</td><td><?= htmlspecialchars($reflectorSince) ?></td></tr>
</table>
</div>

<div class="card">
<h2>Protocol Status</h2>
<table>
<tr><th>Protocol</th><th>Port</th><th>Status</th></tr>
<?php foreach ($protocols as $p): ?>
<?php $state = udp_listener_state($p[1]); ?>
<tr>
<td><?= htmlspecialchars($p[0]) ?></td>
<td><?= htmlspecialchars($p[1]) ?></td>
<td class="<?= state_class($state) ?>"><?= htmlspecialchars($state) ?></td>
</tr>
<?php endforeach; ?>
</table>
</div>


<div class="card">
<h2>XLX Calling Home</h2>
<table>
<tr><td>Directory Publishing</td><td class="<?= $callingHomeState === 'enabled' ? 'good' : 'bad' ?>"><?= htmlspecialchars($callingHomeState) ?></td></tr>
<tr><td>Published Reflector</td><td class="good"><?= htmlspecialchars($callingHomeReflectorName) ?></td></tr>
<tr><td>Timer</td><td class="<?= state_class($callingHomeTimer) ?>"><?= htmlspecialchars($callingHomeTimer) ?></td></tr>
<tr><td>Last API Response</td><td class="<?= strpos($callingHomeResponseStatus, '200') !== false ? 'good' : 'bad' ?>"><?= htmlspecialchars($callingHomeResponseStatus) ?></td></tr>
<tr><td>Hash File</td><td class="<?= strpos($callingHomeHashStatus, 'protected') !== false ? 'good' : 'bad' ?>"><?= htmlspecialchars($callingHomeHashStatus) ?></td></tr>
<tr><td>Hash Path</td><td><?= htmlspecialchars($callingHomeHashFile) ?></td></tr>
<tr><td>Last Publish</td><td><?= htmlspecialchars($callingHomeLastPublish) ?></td></tr>
<tr><td>Interlink File</td><td class="<?= $callingHomeInterlinkStatus === 'present' ? 'good' : 'bad' ?>"><?= htmlspecialchars($callingHomeInterlinkStatus) ?></td></tr>
</table>
</div>


<div class="card">
<h2>Core Reflector Controls</h2>
<table>
<tr><th>Service</th><th>Status</th><th>Action</th></tr>
<tr>
<td>URFD/TCD</td>
<td class="<?= state_class($combinedState) ?>"><?= htmlspecialchars($combinedState) ?></td>
<td>
<div style="display:flex;gap:0.5rem;flex-wrap:wrap;">
<?php foreach (['start' => 'Start', 'stop' => 'Stop', 'restart' => 'Restart'] as $actionValue => $actionLabel): ?>
<form method="post" action="service-control.php" style="margin:0;">
<input type="hidden" name="service" value="urfd-tcd">
<input type="hidden" name="action" value="<?= htmlspecialchars($actionValue) ?>">
<input type="hidden" name="csrf" value="<?= htmlspecialchars($_SESSION['service_control_csrf']) ?>">
<button type="submit"><?= htmlspecialchars($actionLabel) ?></button>
</form>
<?php endforeach; ?>
</div>
</td>
</tr>
</table>
</div>

<div class="card">
<h2>Custom Service Controls</h2>

<?php if (empty($customServiceControls)): ?>
<p>No custom services configured.</p>
<p>Custom controls may be added by editing:</p>
<pre>/etc/urfd-dashboard/service-controls.conf</pre>
<?php else: ?>
<table>
<tr><th>Service</th><th>Unit</th><th>Status</th><th>Action</th></tr>
<?php foreach ($customServiceControls as $svc): ?>
<?php $customState = service_state($svc['unit']); ?>
<tr>
<td><?= htmlspecialchars($svc['name']) ?></td>
<td><?= htmlspecialchars($svc['unit']) ?></td>
<td class="<?= state_class($customState) ?>"><?= htmlspecialchars($customState) ?></td>
<td>
<div style="display:flex;gap:0.5rem;flex-wrap:wrap;">
<?php foreach (['start' => 'Start', 'stop' => 'Stop', 'restart' => 'Restart'] as $actionValue => $actionLabel): ?>
<form method="post" action="service-control.php" style="margin:0;">
<input type="hidden" name="service" value="<?= htmlspecialchars($svc['unit']) ?>">
<input type="hidden" name="action" value="<?= htmlspecialchars($actionValue) ?>">
<input type="hidden" name="csrf" value="<?= htmlspecialchars($_SESSION['service_control_csrf']) ?>">
<button type="submit"><?= htmlspecialchars($actionLabel) ?></button>
</form>
<?php endforeach; ?>
</div>
</td>
</tr>
<?php endforeach; ?>
</table>
<?php endif; ?>

<p>
<a href="service-discovery.php"
   target="serviceDiscovery"
   onclick="window.open(this.href,'serviceDiscovery','width=900,height=700,scrollbars=yes'); return false;"
   style="color:#66ccff;font-weight:bold;">
Find Ham Radio Services
</a>
</p>

</div>

<div class="card">
<h2>Server Status</h2>
<table>
<tr><td>Host</td><td><?= htmlspecialchars($hostname) ?></td></tr>
<tr><td>Server Time</td><td><?= htmlspecialchars($time) ?></td></tr>
<tr><td>Server Uptime</td><td><?= htmlspecialchars($serverUptime) ?></td></tr>
<tr><td>Load Average</td><td><?= htmlspecialchars(number_format($load[0],2)." / ".number_format($load[1],2)." / ".number_format($load[2],2)) ?></td></tr>
<tr><td>CPU Temperature</td><td><?= htmlspecialchars($cpuTemp) ?></td></tr>
<tr><td>Memory Usage</td><td><?= htmlspecialchars($mem) ?></td></tr>
<tr><td>Disk Usage</td><td><?= htmlspecialchars($disk) ?></td></tr>
</table>
</div>

</main>

</body>
</html>
