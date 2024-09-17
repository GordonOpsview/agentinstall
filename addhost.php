<?php

$bashScript = 'addhost.sh';

// Collect request parameters
$hostname = $_GET['hostname'];
$hostip = $_GET['hostip'];
$daemons = $_GET['daemons'];

// Execute the bash script with parameters
exec("bash $bashScript $hostname $hostip $daemons", $output, $returnVar);
// Check if the script executed successfully
if ($returnVar != 0) {
    header('HTTP/1.1 500 Internal Server Error');
    echo "\nAn error occurred while adding the host.\n";
    exit;
} else {
    echo "\nHost $hostname added.\n";
}
?>
