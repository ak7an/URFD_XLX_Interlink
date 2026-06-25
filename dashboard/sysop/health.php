<?php

function urfd_health_engine_path()
{
    $local = dirname(__DIR__) . '/bin/urfd-health';

    if (is_executable($local)) {
        return $local;
    }

    if (is_executable('/usr/local/bin/urfd-health')) {
        return '/usr/local/bin/urfd-health';
    }

    return $local;
}

function urfd_default_health()
{
    return [
        'overall' => 'WARN',
        'counts' => ['PASS' => 0, 'WARN' => 1, 'FAIL' => 0],
        'checks' => [
            [
                'id' => 'health_engine',
                'label' => 'URFD Health Engine',
                'status' => 'WARN',
                'message' => 'Health engine is unavailable',
                'details' => [],
            ],
        ],
    ];
}

function urfd_health()
{
    $engine = urfd_health_engine_path();

    if (!is_executable($engine)) {
        $health = urfd_default_health();
        $health['checks'][0]['message'] = 'Health engine is not executable';
        $health['checks'][0]['details'] = ['path' => $engine];
        return $health;
    }

    $cmd = escapeshellarg($engine) . ' 2>/dev/null';
    $output = shell_exec($cmd);

    if ($output === null || trim($output) === '') {
        $health = urfd_default_health();
        $health['checks'][0]['message'] = 'Health engine returned no output';
        $health['checks'][0]['details'] = ['path' => $engine];
        return $health;
    }

    $decoded = json_decode($output, true);
    if (!is_array($decoded) || !isset($decoded['overall']) || !isset($decoded['checks']) || !is_array($decoded['checks'])) {
        $health = urfd_default_health();
        $health['checks'][0]['message'] = 'Health engine returned invalid JSON';
        $health['checks'][0]['details'] = ['path' => $engine];
        return $health;
    }

    if (!isset($decoded['counts']) || !is_array($decoded['counts'])) {
        $decoded['counts'] = urfd_health_counts($decoded);
    }

    return $decoded;
}

function urfd_health_counts($health)
{
    $counts = ['PASS' => 0, 'WARN' => 0, 'FAIL' => 0];

    foreach ($health['checks'] ?? [] as $item) {
        $status = $item['status'] ?? '';
        if (isset($counts[$status])) {
            $counts[$status]++;
        }
    }

    return $counts;
}

function urfd_health_problem_checks($health, $limit = 5)
{
    $items = [];

    foreach ($health['checks'] ?? [] as $item) {
        $status = $item['status'] ?? '';
        if ($status === 'FAIL' || $status === 'WARN') {
            $items[] = $item;
        }
    }

    return array_slice($items, 0, $limit);
}
