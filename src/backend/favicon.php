<?php
error_reporting(0);
// get url
$url = "http://localhost:80";
// load home page
$doc = new DOMDocument();
$doc->strictErrorChecking = FALSE;
$doc->loadHTML(file_get_contents($url));
$xml = simplexml_import_dom($doc);
// get favicon of homepage
$arr = $xml->xpath('//link[@rel="icon"]');
// if favicon is on homepage
if (!empty($arr[0]['href'])) {
    // get file exstension
    $ext = pathinfo($arr[0]['href'], PATHINFO_EXTENSION);
    header('Content-Type: image/'.$ext);
    // echo homepage favicon
    echo file_get_contents($url . $arr[0]['href']);
} else {
    // echo /favicon,ico as fallback
    header('Content-Type: image/ico');
    echo file_get_contents(__DIR__ . "/favicon.ico");
}
