<?php

session_start();

if (empty($_SESSION['service_control_csrf'])) {
    $_SESSION['service_control_csrf'] = bin2hex(random_bytes(32));
}

function service_state($svc)
{
    $state = trim(shell_exec("systemctl is-active " . escapeshellarg($svc) . " 2>/dev/null"));
    return $state !== "" ? $state : "unavailable";
}

function state_class($state)
{
    return ($state === "active" || $state === "ready" || $state === "online") ? "good" : "bad";
}

function configured_custom_services()
{
    $conf = '/etc/urfd-dashboard/service-controls.conf';
    $configured = [];

    if (!is_readable($conf)) {
        return $configured;
    }

    foreach (file($conf, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') {
            continue;
        }
        if (strpos($line, 'service=') === 0) {
            $unit = trim(substr($line, 8));
            $configured[$unit] = true;
        }
    }

    return $configured;
}

function discover_ham_radio_services()
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
        'DStarGateway'   => 'dstargateway.service',
        'DStarRepeater'  => 'dstarrepeater.service',
        'MMDVMHost'      => 'mmdvmhost.service',
        'Dire Wolf'      => 'direwolf.service',
        'SvxLink'        => 'svxlink.service',
        'AllStarLink'    => 'allstarlink.service',
        'AllStar Asterisk' => 'asterisk.service',
        'APRX'           => 'aprx.service',
        'AX25'           => 'ax25.service',
        'PAT Winlink'    => 'pat.service',
        'BPQ Node'       => 'bpq32.service',
        'LinBPQ Node'    => 'linbpq.service',
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

$configured = configured_custom_services();
$services = discover_ham_radio_services();

?>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Find Ham Radio Services</title>
<style>
body{background:#0b1118;color:#fff;font-family:Arial,sans-serif;margin:0;padding:25px;}
.card{background:#162231;border:1px solid #2d425c;border-radius:10px;padding:20px 30px;margin-bottom:20px;}
.good{color:#66ff66;font-weight:bold;}
.bad{color:#ff6666;font-weight:bold;}
table{border-collapse:collapse;width:100%;}
td,th{padding:8px 15px;text-align:left;border-bottom:1px solid #2d425c;}
button{font-size:16px;padding:6px 12px;}
</style>
</head>
<body>

<div class="card">
<h1>Find Ham Radio Services</h1>
<p>Select the services that should appear on the Sysop Dashboard custom controls.</p>

<?php if (empty($services)): ?>
<p>No known ham radio services detected.</p>
<?php else: ?>
<form method="post" action="service-config.php">
<input type="hidden" name="action" value="save">
<input type="hidden" name="csrf" value="<?= htmlspecialchars($_SESSION['service_control_csrf']) ?>">

<table>
<tr><th>Show</th><th>Service</th><th>Unit</th><th>Status</th><th>Dashboard</th></tr>
<?php foreach ($services as $svc): ?>
<?php $already = isset($configured[$svc['unit']]); ?>
<tr>
<td>
<input type="checkbox" name="services[]" value="<?= htmlspecialchars($svc['unit']) ?>" <?= $already ? 'checked' : '' ?>>
</td>
<td><?= htmlspecialchars($svc['name']) ?></td>
<td><?= htmlspecialchars($svc['unit']) ?></td>
<td class="<?= state_class($svc['state']) ?>"><?= htmlspecialchars($svc['state']) ?></td>
<td><?= $already ? 'Currently Shown' : 'Not Shown' ?></td>
</tr>
<?php endforeach; ?>
</table>

<p>
<button type="submit">Save Changes</button>
<button type="button" onclick="window.close();">Cancel</button>
</p>
</form>
<?php endif; ?>
</div>

</body>
</html>
