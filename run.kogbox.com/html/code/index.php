<?php 

$user_id = $_REQUEST['u'];
$method_name = $_REQUEST['m'];
$version = $_REQUEST['v'];


function get_snippet_code($my_user_id,$my_method_name,$version = false) {
	$link = mysql_connect("internal-db.s29515.gridserver.com","db29515","JJlDi5Mi");
	if (!$link) {
	   die('Could not connect: ' . mysql_error());
	} else {
		//echo '<p>Connected to host '.$db_host.' as user '.$db_user.'.</p>';
		//$row = mysql_fetch_row($durch_brutto); 
	}
	if(mysql_select_db("db29515_kogbox_production",$link)) {
		//echo "Opened database ".$db_database."<br />";
	} else {
		echo "Failed to open database.";
	}

	if ($version) {
		$mysql_query = "SELECT * FROM snippets WHERE user_id=".$my_user_id." AND method_name='".$my_method_name."' AND version=".$version." ORDER BY id DESC LIMIT 1;";
	} else {
		$mysql_query = "SELECT * FROM snippets WHERE user_id=".$my_user_id." AND method_name='".$my_method_name."' ORDER BY id DESC LIMIT 1;";
		
	}

	$result = mysql_query($mysql_query,$link);
	if (!$result) echo "<b>ERROR:</b> Unable to read from database: ".mysql_error()."<br />"."<i>".$mysql_query."</i><br />";

	while ($row = mysql_fetch_assoc($result)) {
		if (($row['published'] == "public")&&($row['license_id'] != "NULL")&&($row['license_id'] != 0)) :
			#execute the code
			return $row['code'];
		endif;
	}
}

echo("<pre>".htmlentities(get_snippet_code($user_id,$method_name,$version))."</pre>");


?>