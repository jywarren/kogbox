<?php 

$user_id = $_REQUEST['u'];
$method_name = $_REQUEST['m'];
$version = $_REQUEST['v'];

ini_set("allow_url_fopen",0);
ini_set("allow_url_include",0);
ini_set("file_uploads",0);
ini_set("nsapi.read_timeout",20);
//ini_set("display_errors",0);
//safe_mode_allowed_env_vars
//safe_mode_protected_env_vars
//open_basedir
//disable_functions
//disable_classes

// function exception_handler($exception) {
//   echo "Uncaught exception: " , $exception->getMessage(), "\n";
// }
// 
// set_exception_handler('exception_handler');

// we will do our own error handling
//error_reporting(0);

// user defined error handling function
// function userErrorHandler($errno, $errmsg, $filename, $linenum, $vars) 
// {
//    // timestamp for the error entry
//    $dt = date("Y-m-d H:i:s (T)");
// 
//    // define an assoc array of error string
//    // in reality the only entries we should
//    // consider are E_WARNING, E_NOTICE, E_USER_ERROR,
//    // E_USER_WARNING and E_USER_NOTICE
//    $errortype = array (
//                E_ERROR          => "Error",
//                E_WARNING        => "Warning",
//                E_PARSE          => "Parsing Error",
//                E_NOTICE          => "Notice",
//                E_CORE_ERROR      => "Core Error",
//                E_CORE_WARNING    => "Core Warning",
//                E_COMPILE_ERROR  => "Compile Error",
//                E_COMPILE_WARNING => "Compile Warning",
//                E_USER_ERROR      => "User Error",
//                E_USER_WARNING    => "User Warning",
//                E_USER_NOTICE    => "User Notice",
//                E_STRICT          => "Runtime Notice"
//                );
//    // set of errors for which a var trace will be saved
//    $user_errors = array(E_USER_ERROR, E_USER_WARNING, E_USER_NOTICE);
//    
//    $err = "<errorentry>\n";
//    $err .= "\t<datetime>" . $dt . "</datetime>\n";
//    $err .= "\t<errornum>" . $errno . "</errornum>\n";
//    $err .= "\t<errortype>" . $errortype[$errno] . "</errortype>\n";
//    $err .= "\t<errormsg>" . $errmsg . "</errormsg>\n";
//    $err .= "\t<scriptname>" . $filename . "</scriptname>\n";
//    $err .= "\t<scriptlinenum>" . $linenum . "</scriptlinenum>\n";
// 
//    if (in_array($errno, $user_errors)) {
//        $err .= "\t<vartrace>" . wddx_serialize_value($vars, "Variables") . "</vartrace>\n";
//    }
//    $err .= "</errorentry>\n\n";
//    
//    // for testing
//    // echo $err;
// 
//    // save to the error log, and e-mail me if there is a critical user error
//    //error_log($err, 3, "/usr/local/php4/error.log");
//    if ($errno == E_USER_ERROR) {
//        mail("jeff@kogbox.com", "Critical User Error", $err);
//    }
// }
// set_error_handler("userErrorHandler");

function get_snippet_code($accesscode,$my_user_id,$my_method_name,$version = false) {
	if ($accesscode == "4kgo23k4ngs9a0sdfg82n4l4ksjzxc8b976z9h2kn1nt") :
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
		if (!$result) echo "<b>ERROR:</b> Unable to read from database: ".mysql_error();//."<br />"."<i>".$mysql_query."</i><br />";

		while ($row = mysql_fetch_assoc($result)) {
				$count = $row['count'];
				$last_marker = $row['last_marker'];
				$total_use = $row['total_use'];
				$code = $row['code'];
				$published = $row['published'];
		}

		//LOG USAGE:
		$interval = date('Y-m-d H:i:s', strtotime('1 minute ago'));
		//echo $my_method_name;
		//echo $interval."<br />";
		//echo $last_marker."<br />";
		$limit = 100;

		if ($last_marker==NULL) {
			//Give it an initial datestamp
			$reset_marker = ", last_marker = '".date ("Y-m-d H:i:s")."' ";
			$count = 0;
		} elseif (($last_marker > $interval) && ($count < $limit)) {
			//Still okay
			$reset_marker = "";
			$count += 1;
			$exceeded = false;
		} elseif (($last_marker > $interval) && ($count >= $limit)) {
			//OVERUSE!
			$count += 1;
			$reset_marker = "";
			$exceeded = true;
		} elseif ($last_marker <= $interval) {
			//Reset the marker
			$reset_marker = ", last_marker = '".date ("Y-m-d H:i:s")."' ";
			$count = 0;
			$exceeded = false;
		} else {
			$reset_marker = "";
			$count += 1;
			$exceeded = false;
		}

		$mysql_query = "UPDATE snippets
						SET total_use = ".($total_use+1).",
							count = ".$count.$reset_marker."
		 				WHERE user_id=".$my_user_id." AND method_name='".$my_method_name."'";

		$result = mysql_query($mysql_query,$link);
		if (!$result) echo "<b>ERROR:</b> Unable to read from database: ".mysql_error();//."<br />"."<i>".$mysql_query."</i><br />";

		if ($published == "public") :
			if (!$exceeded) :
				return $code;
			else :
				return "<body style='padding:0;margin:0;'><div style='width:100%;padding:12px;border-bottom:2px solid #FF9000;background:#FFEB9A;color:#A1361D;font-family:lucida grande, helvetica, arial, sans-serif;font-size:.7em;'>Usage exceeded for snippet ".$my_method_name." by user #".$my_user_id."<br />Please purchase a paid account for unlimited use: <a href='http://www.kogbox.com'>Kogbox.com</a></div>";
			endif;
		else :
			if ((@$_COOKIE['kogbox'] == @$_GET['key'])&&($published == "private")&& $_GET['key']) :
				## This is not real security, it's dummy security. With this you can generate a cookie and matching key value by yourself... 
				return $code;
			else :
				return "<body style='padding:0;margin:0;'><div style='width:100%;padding:12px;border-bottom:2px solid #FF9000;background:#FFEB9A;color:#A1361D;font-family:lucida grande, helvetica, arial, sans-serif;font-size:.7em;'>Code for snippet <b>'".$my_method_name."'</b> by user #".$my_user_id." not available. It may have been renamed, may be private, or may not exist.</div>";
			endif;
		endif;
	endif;
	}

	function include_snippet($user_id,$method_name,$version = false) {
		eval(' ?>'.get_snippet_code("4kgo23k4ngs9a0sdfg82n4l4ksjzxc8b976z9h2kn1nt",$user_id,$method_name,$version).' <?php ');
	}

	eval(' ?>'.get_snippet_code("4kgo23k4ngs9a0sdfg82n4l4ksjzxc8b976z9h2kn1nt",$user_id,$method_name,$version).' <?php ');

	?>