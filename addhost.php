<?php

$bashScript = 'addhost.sh';

// Collect request parameters
$hostname = $_GET['hostname'];
$hostip = $_GET['hostip'];

// Execute the bash script with parameters
exec("/opt/opsview/pki/bin/pki client-cert $fqdn || exit \$?", $output, $returnVar);

// Check if the script executed successfully
if ($returnVar != 0) {
    header('HTTP/1.1 500 Internal Server Error');
    echo "An error occurred while adding the host.";
    exit;
}

// Serve the certificate as a download
// if (file_exists($outputFile)) {
//     header('Content-Type: text/plain');
//     header('Content-Disposition: attachment; filename="' . basename($outputFile) . '"');
//     header('Content-Length: ' . filesize($outputFile));
//     readfile($outputFile);

// } else {
//     header('HTTP/1.1 500 Internal Server Error');
//     echo "Failed to generate the certificate.";
// }
?>
