<?php
# add a new episode
# (c)Radif Sharafullin
$fileName = htmlspecialchars($_POST["file"]);
$title= htmlspecialchars($_POST["title"]);
$desc = htmlspecialchars($_POST["desc"]);
$date = htmlspecialchars($_POST["date"]);

if(!$fileName || !$title || !$desc || !$date ){	
	die('no data provided!');	
}

$link = mysql_connect('localhost', 'summerst_podcast', '8kqpd1C');
if (!$link) {
    die('Could not connect!!!: ' . mysql_error());
}
mysql_select_db("summerst_caststats");
#echo 'Connected successfully';

$query = "INSERT INTO `episodes` VALUES ('','$fileName', '$title', '$desc', '$date')";
if(mysql_query($query)) echo "OK";;
mysql_close($link);
?>