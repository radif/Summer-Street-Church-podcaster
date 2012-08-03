<?php
# feed generator
# (c)Radif Sharafullin
$files = array();
$directory="/home/summerst/public_html/podcasting/episodes/";
	
   $handler = opendir($directory);
   // keep going until all files in directory have been read
   while ($file = readdir($handler)) {
   	if(substr($file, 0, 1) != '.' && is_file($directory . '/' . $file) && substr($file, 0, 5) != 'backup' && substr($file, 0, 5) != 'Backup' && (substr($file, -4) == '.mp3' || substr($file, -4) == '.MP3')){
       array_push($files, "file!='".$file."'");
       }    
   }
   closedir($handler);

$queryReadyFiles = implode(" AND ", $files);


$link = mysql_connect('localhost', 'summerst_podcast', '8kqpd1C');
if (!$link) {
    die('Could not connect!!!: ' . mysql_error());
}
mysql_select_db("summerst_caststats");



#delete from table
if($queryReadyFiles){	
	$query = "DELETE FROM episodes WHERE $queryReadyFiles";
	mysql_query($query);
}else{
	$query = "DELETE FROM episodes WHERE id>=0";
	mysql_query($query);
}
$query = "SELECT file, title, description, podcastdate  FROM episodes ORDER BY id DESC";
$result=mysql_query($query);
if (!$result) {
    $message  = 'Invalid query: ' . mysql_error() . "\n";
    $message .= 'Whole query: ' . $query;
	mysql_close($link);
    die($message);
}



$posts= array();

while ($row = mysql_fetch_assoc($result)) {
  $file= $row['file'];
   $title= $row['title'];
   $desc= $row['description'];
 $date= $row['podcastdate'];

$post=<<<EOD
<item>

	<title>$title</title>

	<itunes:author>Summer Street Church, Nantucket, MA</itunes:author>

	<itunes:subtitle>Summer Street Church Podcasting</itunes:subtitle>

	<itunes:summary>$desc</itunes:summary>

	<enclosure url="http://summerstreetchurch.org/podcasting/episodes/$file" length="0" type="audio/mpeg" />
	<pubDate>$date</pubDate>
	<itunes:keywords>Summer,Street,Church,Nantucket,Evangelical,Christians,baptist,baptism,brant,point,Rich,Leland,Richard,Leland,4,Trotters,ln,summer,st,traders,ln,protestant,religion,christianity,preaching,preach,Jesus,Christ,Bible,Gospel,Service,Christian,music,New,Testam</itunes:keywords>

</item>
EOD;
 array_push($posts, $post);

}



#stats
mysql_select_db("summerst_caststats");
#echo 'Connected successfully';
date_default_timezone_set('EDT');
$mysqldate = date( 'Y-m-d H:i:s' );
$ip = getenv("REMOTE_ADDR"); 
$query = "INSERT INTO downloading_stats  VALUES ('','$mysqldate','$ip')";
mysql_query($query);

mysql_close($link);
mysql_free_result($result);

$postsString=implode(" ", $posts);

$feed = <<<EOD
<?xml version="1.0" encoding="UTF-8"?>

	<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
	<channel>
		<generator>Radif Sharafullin's custom software'</generator>
		<title>Summer Street Church Podcasting</title>
		<link>http://summerstreetchurch.org/</link>
		<language>en-us</language>
		<copyright>&#x2117; &amp; &#xA9; Summer Street Church</copyright>
		<itunes:explicit>no</itunes:explicit>
		<itunes:subtitle>Sunday Services</itunes:subtitle>
		<itunes:author>Pastor Richard Leland</itunes:author>
		<itunes:summary>Weekly Podcasting of Sunday Services From Summer Street Church, Nantucket, MA</itunes:summary>
		<description>Weekly Podcasting of Sunday Services From Summer Street Church, Nantucket, MA</description>
		<itunes:owner>
		<itunes:name>Summer Street Church, Nantucket, MA</itunes:name>
		<itunes:email>carolyn@summerstreetchurch.org</itunes:email>
		</itunes:owner>
		<itunes:image href="http://summerstreetchurch.org/podcasting/cover.jpg" />

		<itunes:category text="Religion &amp; Spirituality">
			<itunes:category text="Christianity" />
		</itunes:category>

	$postsString

	</channel>

	</rss>
EOD;







echo $feed;
?>