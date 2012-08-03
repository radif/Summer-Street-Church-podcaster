<?php
# stats
# (c)Radif Sharafullin

require_once('IpLocation/Ip.php');
require_once('IpLocation/Service/CsvWebhosting.php');
require_once('IpLocation/Service/GeoIp.php');

$timePeriod=$_GET["period"];

if(!$timePeriod){
	 die('No Input provided for Summer Street Church Podcaster (c)Radif Sharafullin');
}

$link = mysql_connect('localhost', 'summerst_podcast', '8kqpd1C');
if (!$link) {
    die('Could not connect!!!: ' . mysql_error());
}
mysql_select_db("summerst_caststats");


if($timePeriod=='all'){
	$query = "SELECT datetime, ip FROM downloading_stats ORDER BY id DESC";
		
}else{

if($timePeriod=='clear'){
	$query = "DELETE FROM downloading_stats WHERE id>=0";
	mysql_query($query);
	mysql_close($link);
    die("<h2>All Stats Cleared</h2><br><a href='http://summerstreetchurch.org/podcasting/stats.php?period=all'>Back to stats</a>");
		
}else{

	$offsetDate  = mktime(0, 0, 0, date("m")  , date("d")-$timePerod, date("Y"));
	$mysqldate = date( 'Y-m-d H:i:s',$offsetDate );
	$query = "SELECT  datetime, ip FROM downloading_stats WHERE datetime >= '$mysqldate' ORDER BY id DESC";

}
}

$result=mysql_query($query);
if (!$result) {
    $message  = 'Invalid query: ' . mysql_error() . "\n";
    $message .= 'Whole query: ' . $query;
	mysql_close($link);
    die($message);
}


$tPeriod='since last cleared';

if($timePeriod>0) $tPeriod="of $timePeriod days";



echo '<html>';
echo "<h1>Podcast requests</h1>";
echo "<h2>For the time period $tPeriod</h2>";
echo "<table border='1'>";
echo "<tr><td ><b>Index</b></td><td WIDTH=170><b>Date and Time</b></td><td WIDTH=200><b>Country</b></td><td WIDTH=200><b>IP Address</b></td></tr>";
$counter=0;
while ($row = mysql_fetch_assoc($result)) {
$counter+=1;
$dateTime=$row['datetime'];
$ipAddress=$row['ip'];

$objIpLocationObject = new IpLocation_Ip(new IpLocation_Service_GeoIp());
$countryNameResult = $objIpLocationObject->getIpLocation($ipAddress);
$countryName=$countryNameResult->__get('countryName');

echo "<tr><td>$counter</td><td>$dateTime</td><td>$countryName</td><td>$ipAddress</td></tr>";
}
echo "</table><br><a href='http://summerstreetchurch.org/podcasting/stats.php?period=all'>All</a><a> </a><a href='http://summerstreetchurch.org/podcasting/stats.php?period=1'>Last 24 hours</a><br>";
echo "<a href='http://summerstreetchurch.org/podcasting/stats.php?period=7'>Last 7 days</a><a> </a><a href='http://summerstreetchurch.org/podcasting/stats.php?period=31'>Last 31 days</a><br>";
echo "<br><a href='http://summerstreetchurch.org/podcasting/stats.php?period=clear'>Clear Stats</a>";
echo "<br><br><a href='http://summerstreetchurch.org'>Summer Street Church website</a>";
echo '</html>';

mysql_close($link);
mysql_free_result($result);

