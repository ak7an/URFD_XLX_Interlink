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

$time = date('Y-m-d H:i:s T');
$dashboardLogo = dashboard_logo();
$xmlFile = '/var/log/xlxd.xml';
$xmlFreshSeconds = 90;
$xmlExists = is_readable($xmlFile);
$xmlAge = $xmlExists ? (time() - filemtime($xmlFile)) : null;
$reflectorOnline = $xmlExists && $xmlAge <= $xmlFreshSeconds;
$reflectorStatusText = $reflectorOnline ? 'ONLINE' : ($xmlExists ? 'STALE / OFFLINE' : 'OFFLINE');
$reflectorStatusClass = $reflectorOnline ? 'good' : 'bad';

$stations = [];
$peers = [];
$nodes = [];
$activeWindowSeconds = 120;

if (is_readable($xmlFile)) {
    $raw = file_get_contents($xmlFile);

    preg_match_all('/<STATION>(.*?)<\/STATION>/s', $raw, $stationBlocks);
    foreach ($stationBlocks[1] as $block) {
        preg_match('/<Callsign>(.*?)<\/Callsign>/s', $block, $cs);
        preg_match('/<Via node>(.*?)<\/Via node>/s', $block, $via);
        preg_match('/<On module>(.*?)<\/On module>/s', $block, $module);
        preg_match('/<Via peer>(.*?)<\/Via peer>/s', $block, $peer);
        preg_match('/<LastHeardTime>(.*?)<\/LastHeardTime>/s', $block, $lh);

        $stations[] = [
            'callsign' => trim($cs[1] ?? ''),
            'via' => trim($via[1] ?? ''),
            'module' => trim($module[1] ?? ''),
            'peer' => trim($peer[1] ?? ''),
            'lastheard' => trim($lh[1] ?? '')
        ];
    }

    // Display Last Heard as one row per operator callsign.
    // If the same callsign appears through a different node or peer,
    // keep only the newest heard entry and show that latest route.
    $uniqueStations = [];

    foreach ($stations as $st) {
        $key = strtoupper(trim($st['callsign'] ?? ''));

        // Normalize common D-Star / hotspot suffix forms.
        $key = preg_split('/\s+\/\s+|\s+/', $key)[0] ?? $key;

        if ($key === '') {
            continue;
        }

        $newTs = strtotime($st['lastheard'] ?? '') ?: 0;
        $oldTs = isset($uniqueStations[$key])
            ? (strtotime($uniqueStations[$key]['lastheard'] ?? '') ?: 0)
            : 0;

        if (!isset($uniqueStations[$key]) || $newTs >= $oldTs) {
            $uniqueStations[$key] = $st;
        }
    }

    $stations = array_values($uniqueStations);

    usort($stations, function ($a, $b) {
        return strtotime($b['lastheard']) <=> strtotime($a['lastheard']);
    });

    preg_match_all('/<NODE>(.*?)<\/NODE>/s', $raw, $nodeBlocks);
    foreach ($nodeBlocks[1] as $block) {
        preg_match('/<Callsign>(.*?)<\/Callsign>/s', $block, $cs);
        preg_match('/<LinkedModule>(.*?)<\/LinkedModule>/s', $block, $module);
        preg_match('/<Protocol>(.*?)<\/Protocol>/s', $block, $proto);
        preg_match('/<IP>(.*?)<\/IP>/s', $block, $ip);
        preg_match('/<LastHeardTime>(.*?)<\/LastHeardTime>/s', $block, $lh);

        $lastheard = trim($lh[1] ?? '');
        $lastTs = $lastheard !== '' ? strtotime($lastheard) : 0;

        $nodes[] = [
            'callsign' => trim($cs[1] ?? ''),
            'module' => trim($module[1] ?? ''),
            'protocol' => trim($proto[1] ?? ''),
            'ip' => trim($ip[1] ?? ''),
            'lastheard' => $lastheard,
            'active' => ($lastTs > 0 && (time() - $lastTs) <= $activeWindowSeconds)
        ];
    }

    usort($nodes, function ($a, $b) {
        return strtotime($b['lastheard']) <=> strtotime($a['lastheard']);
    });

    preg_match_all('/<PEER>(.*?)<\/PEER>/s', $raw, $peerBlocks);
    foreach ($peerBlocks[1] as $block) {
        preg_match('/<Callsign>(.*?)<\/Callsign>/s', $block, $cs);
        preg_match('/<LinkedModule>(.*?)<\/LinkedModule>/s', $block, $module);
        preg_match('/<Protocol>(.*?)<\/Protocol>/s', $block, $proto);

        $peers[] = [
            'callsign' => trim($cs[1] ?? ''),
            'module' => trim($module[1] ?? ''),
            'protocol' => trim($proto[1] ?? '')
        ];
    }
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

function xlx_reflector_dashboard_links()
{
    static $links = null;

    if ($links !== null) {
        return $links;
    }

    $links = [];
    $cacheFile = '/var/lib/urfd-dashboard/xlx-reflector-list.xml';
    $cacheMaxAge = 86400;
    $apiUrl = 'http://xlxapi.rlx.lu/api.php?do=GetReflectorList';

    if (
        (!is_readable($cacheFile)) ||
        ((time() - filemtime($cacheFile)) > $cacheMaxAge)
    ) {
        $xml = @file_get_contents($apiUrl);
        if ($xml !== false && strpos($xml, '<reflector>') !== false) {
            @file_put_contents($cacheFile, $xml);
        }
    }

    if (!is_readable($cacheFile)) {
        return $links;
    }

    $raw = file_get_contents($cacheFile);
    if ($raw === false) {
        return $links;
    }

    preg_match_all('/<reflector>(.*?)<\/reflector>/s', $raw, $blocks);

    foreach ($blocks[1] as $block) {
        preg_match('/<name>(.*?)<\/name>/s', $block, $name);
        preg_match('/<dashboardurl>(.*?)<\/dashboardurl>/s', $block, $url);

        $peer = strtoupper(trim($name[1] ?? ''));
        $dash = trim($url[1] ?? '');

        if ($peer !== '' && filter_var($dash, FILTER_VALIDATE_URL)) {
            $links[$peer] = $dash;
        }
    }

    return $links;
}

function peer_dashboard_link($callsign)
{
    $callsign = trim($callsign);
    $key = strtoupper($callsign);
    $links = xlx_reflector_dashboard_links();

    if (isset($links[$key])) {
        return '<a href="' .
               htmlspecialchars($links[$key]) .
               '" target="_blank" rel="noopener noreferrer">' .
               htmlspecialchars($callsign) .
               '</a>';
    }

    return htmlspecialchars($callsign);
}

function nice_time($zulu)
{
    if ($zulu == '') return '';
    $ts = strtotime($zulu);
    if (!$ts) return $zulu;
    return date('Y-m-d H:i', $ts);
}



function qrz_callsign($callsign)
{
    $raw = strtoupper(trim($callsign));
    if ($raw === '') return '';

    // D-Star node callsigns may look like "AK7AN   B" or "AK7AN / ID31".
    $base = preg_split('/[\s\/]+/', $raw)[0] ?? '';
    $base = preg_replace('/[^A-Z0-9]/', '', $base);

    if ($base === '') {
        return htmlspecialchars($callsign);
    }

    $url = 'https://www.qrz.com/db/' . rawurlencode($base);
    return '<a href="' . htmlspecialchars($url) . '" target="_blank" rel="noopener noreferrer">' .
           htmlspecialchars($callsign) .
           '</a>';
}

function masked_ip_tail($ip)
{
    $ip = trim($ip);
    if ($ip === '') return '';

    if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)) {
        $parts = explode('.', $ip);
        return '*.*.' . $parts[2] . '.' . $parts[3];
    }

    return 'hidden';
}

function lookup_operator($callsign)
{
    $callsign = strtoupper(trim($callsign));

    // Normalize D-Star style callsigns like "AK7AN / ID31" before RadioID lookup.
    if (strpos($callsign, '/') !== false) {
        $callsign = trim(explode('/', $callsign, 2)[0]);
    }
    if ($callsign === '') return '';

    $dbFile = '/var/lib/urfd-dashboard/radioid.sqlite';
    if (!is_readable($dbFile)) return '';

    try {
        $db = new SQLite3($dbFile, SQLITE3_OPEN_READONLY);
        $stmt = $db->prepare(
            "SELECT first_name, last_name
             FROM radioid
             WHERE UPPER(callsign) = :callsign
             LIMIT 1"
        );
        $stmt->bindValue(':callsign', $callsign, SQLITE3_TEXT);
        $row = $stmt->execute()->fetchArray(SQLITE3_ASSOC);
        $db->close();

        if (!$row) return '';

        return trim(($row['first_name'] ?? '') . ' ' . ($row['last_name'] ?? ''));
    } catch (Exception $e) {
        return '';
    }
}

?>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>URF277 Public Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="refresh" content="30">

<style>
body{background:#0b1118;color:#ffffff;font-family:Arial,sans-serif;margin:0;}
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
.card{background:#162231;border:1px solid #2d425c;border-radius:10px;padding:20px 30px 40px 30px;margin-bottom:20px;max-width:1100px;}
.good{color:#66ff66;font-weight:bold;}
.idle{color:#a0a0a0;}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:12px;}
.badge{background:#0f1a25;border:1px solid #2d425c;border-radius:8px;padding:15px;text-align:center;}
table{width:100%;border-collapse:collapse;}
th,td{padding:10px;border-bottom:1px solid #2d425c;text-align:left;}
.small{color:#a0a0a0;font-size:0.9em;}

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

a {
color:#FFD700;
font-weight:bold;
}

a:hover {
color:#FFE866;
}

</style>
</head>

<body>

<header>
<h1>URF277 Reflector Dashboard</h1>
<div class="small">
Hosted by Bit By Bit Hams<br>
<a href="https://www.bitbybithams.com" target="_blank">www.bitbybithams.com</a>
</div>

<?php if ($dashboardLogo !== ''): ?>
<div class="logo">
<img src="<?= htmlspecialchars($dashboardLogo) ?>" alt="Dashboard Logo">
</div>
<?php endif; ?>

</header>

<main>

<div class="card">
<h2>Reflector Status</h2>
<p><span class="<?= $reflectorStatusClass ?>"><?= htmlspecialchars($reflectorStatusText) ?></span></p>
<p class="small">Last dashboard update: <?= htmlspecialchars($time) ?></p>
</div>

<div class="card">
<h2>Protocols</h2>
<div class="grid">
<?php
$protocolStatusText = $reflectorOnline ? 'ONLINE' : 'OFFLINE';
$protocolStatusClass = $reflectorOnline ? 'good' : 'bad';
?>
<div class="badge">D-Star<br><span class="<?= $protocolStatusClass ?>"><?= $protocolStatusText ?></span></div>
<div class="badge">DMR<br><span class="<?= $protocolStatusClass ?>"><?= $protocolStatusText ?></span></div>
<div class="badge">YSF<br><span class="<?= $protocolStatusClass ?>"><?= $protocolStatusText ?></span></div>
<div class="badge">NXDN<br><span class="<?= $protocolStatusClass ?>"><?= $protocolStatusText ?></span></div>
<div class="badge">P25<br><span class="<?= $protocolStatusClass ?>"><?= $protocolStatusText ?></span></div>
<div class="badge">M17<br><span class="<?= $protocolStatusClass ?>"><?= $protocolStatusText ?></span></div>
</div>
</div>

<div class="card">
<h2>Linked Systems</h2>
<table>
<tr><th>System</th><th>Protocol</th><th>Module</th><th>Status</th></tr>

<?php if (count($peers) > 0): ?>
<?php foreach ($peers as $peer): ?>
<tr>
<td><?= peer_dashboard_link($peer['callsign']) ?></td>
<td><?= htmlspecialchars($peer['protocol']) ?></td>
<td><?= htmlspecialchars($peer['module']) ?></td>
<?php if ($reflectorOnline): ?>
<td class="good">LINKED</td>
<?php else: ?>
<td class="bad">STALE</td>
<?php endif; ?>
</tr>
<?php endforeach; ?>
<?php else: ?>
<tr><td colspan="4" class="idle">No linked peers found.</td></tr>
<?php endif; ?>

</table>
</div>

<div class="card">
<h2>Last Heard</h2>
<table>
<tr>
<th>Time</th>
<th>Callsign</th>
<th>Operator</th>
<th>Via Node</th>
<th>Module</th>
<th>Via Peer</th>
</tr>

<?php if (count($stations) > 0): ?>
<?php foreach ($stations as $st): ?>
<tr>
<td><?= htmlspecialchars(nice_time($st['lastheard'])) ?></td>
<td><?= qrz_callsign($st['callsign']) ?></td>
<td><?= htmlspecialchars(lookup_operator($st['callsign'])) ?></td>
<td><?= htmlspecialchars($st['via']) ?></td>
<td><?= htmlspecialchars($st['module']) ?></td>
<td><?= htmlspecialchars($st['peer']) ?></td>
</tr>
<?php endforeach; ?>
<?php else: ?>
<tr><td colspan="6" class="idle">No last-heard stations found.</td></tr>
<?php endif; ?>

</table>
</div>


<div class="card">
<h2>Linked Repeaters / Nodes</h2>
<table>
<tr>
<th>Callsign</th>
<th>Protocol</th>
<th>Module</th>
<th>IP</th>
<th>Last Heard</th>
<th>Status</th>
</tr>

<?php if (count($nodes) > 0): ?>
<?php foreach ($nodes as $node): ?>
<tr>
<td><?= qrz_callsign($node['callsign']) ?></td>
<td><?= htmlspecialchars($node['protocol']) ?></td>
<td><?= htmlspecialchars($node['module']) ?></td>
<td><?= htmlspecialchars(masked_ip_tail($node['ip'])) ?></td>
<td><?= htmlspecialchars(nice_time($node['lastheard'])) ?></td>
<td>
<?php if ($reflectorOnline): ?>
<span class="good">LINKED</span>
<?php else: ?>
<span class="bad">STALE</span>
<?php endif; ?>
</td>
</tr>
<?php endforeach; ?>
<?php else: ?>
<tr><td colspan="5" class="idle">No linked repeaters or nodes found.</td></tr>
<?php endif; ?>

</table>
</div>

<div class="card">
<h2>Active Streams</h2>
<table>
<tr>
<th>Callsign</th>
<th>Protocol</th>
<th>Module</th>
<th>Last Heard</th>
<th>Status</th>
</tr>

<?php
$activeFound = false;
foreach ($nodes as $node):
    if (!$node['active']) continue;
    $activeFound = true;
?>
<tr>
<td><?= qrz_callsign($node['callsign']) ?></td>
<td><?= htmlspecialchars($node['protocol']) ?></td>
<td><?= htmlspecialchars($node['module']) ?></td>
<td><?= htmlspecialchars(nice_time($node['lastheard'])) ?></td>
<td class="good">ACTIVE</td>
</tr>
<?php endforeach; ?>

<?php if (!$activeFound): ?>
<tr><td colspan="5" class="idle">No active streams detected.</td></tr>
<?php endif; ?>

</table>
<p class="small">Active means node activity heard within the last <?= intval($activeWindowSeconds) ?> seconds.</p>
</div>

</main>

</body>
</html>
