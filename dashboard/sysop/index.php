<?php

function service_state($svc)
{
    return trim(shell_exec("systemctl is-active " . escapeshellarg($svc) . " 2>/dev/null"));
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

$svc = 'urfd-tcd.service';

$hostname = gethostname();
$time = date('Y-m-d H:i:s T');

$urfd = service_state($svc);
$reflectorSince = service_running_since($svc);
$reflectorUptime = service_uptime($svc);

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
<title>URF277 Dashboard</title>
<style>
body{background:#0b1118;color:#fff;font-family:Arial,sans-serif;margin:0;}
header{background:#162231;padding:20px;}
main{padding:20px;}
.card{background:#162231;border:1px solid #2d425c;border-radius:10px;padding:20px;margin-bottom:20px;max-width:900px;}
.good{color:#66ff66;}
.bad{color:#ff6666;}
table{border-collapse:collapse;}
td{padding:8px 15px;}
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
<tr><td>URFD/TCD Service</td><td class="<?=($urfd=='active')?'good':'bad'?>"><?= htmlspecialchars($urfd) ?></td></tr>
<tr><td>Reflector Uptime</td><td><?= htmlspecialchars($reflectorUptime) ?></td></tr>
<tr><td>Running Since</td><td><?= htmlspecialchars($reflectorSince) ?></td></tr>
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
