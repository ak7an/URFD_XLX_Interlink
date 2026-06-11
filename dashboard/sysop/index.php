<?php

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

$combinedSvc = 'urfd-tcd.service';

$hostname = gethostname();
$time = date('Y-m-d H:i:s T');

$combinedState = service_state($combinedSvc);
$urfdState = process_state('/home/ed/urfd/reflector/urfd');
$tcdState = process_state('/usr/local/bin/tcd');

$reflectorSince = service_running_since($combinedSvc);
$reflectorUptime = service_uptime($combinedSvc);

$dvsiCount = dvsi_dongle_count();
$dvsiStatus = $dvsiCount > 0 ? "ready" : "not found";
$transcoderStatus = ($combinedState === "active" && $dvsiCount > 0) ? "ready" : "not ready";

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
header{background:#162231;padding:20px;}
main{padding:20px;}
.card{background:#162231;border:1px solid #2d425c;border-radius:10px;padding:20px;margin-bottom:20px;max-width:900px;}
.good{color:#66ff66;font-weight:bold;}
.bad{color:#ff6666;font-weight:bold;}
table{border-collapse:collapse;}
td,th{padding:8px 15px;text-align:left;}
th{border-bottom:1px solid #2d425c;}
</style>
</head>
<body>

<header>
<h1>URF277 Sysop Dashboard</h1>
</header>

<main>

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
<h2>Maintenance Tools</h2>
<table>
<tr>
<td>Monit Dashboard</td>
<td><a href="/monit/" style="color:#66ccff;font-weight:bold;">Open Monit Service Manager</a></td>
</tr>
</table>
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
