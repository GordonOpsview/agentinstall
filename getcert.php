<?php

// Collect request parameters
$fqdn = $_GET['fqdn'];
$outputFile = "/opt/opsview/etc/ssl/$fqdn.pem";

// Execute the bash script with parameters
exec("/opt/opsview/pki/bin/pki client-cert $fqdn || exit \$?", $output, $returnVar);

// Check if the script executed successfully
if ($returnVar != 0) {
    header('HTTP/1.1 500 Internal Server Error');
    echo "An error occurred while generating the certificate.";
    exit;
}

// Serve the certificate as a download
if (file_exists($outputFile)) {
    header('Content-Type: text/plain');
    header('Content-Disposition: attachment; filename="' . basename($outputFile) . '"');
    header('Content-Length: ' . filesize($outputFile));
    readfile($outputFile);

} else {
    header('HTTP/1.1 500 Internal Server Error');
    echo "Failed to generate the certificate.";
}
?>
