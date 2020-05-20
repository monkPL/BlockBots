<?php

$db = new SQLite3("secure.db");

// delete rows older than 30 days
$m30d = date("Y-m-d",strtotime("-30 day"));
$sql="DELETE FROM `blocked` WHERE `dt` <= '{$m30d}'";
$db->query($sql);

$sql="SELECT `ip`,`dt` FROM `blocked`";
$res=$db->query($sql);
$blocked = array();
while($row = $res->fetchArray(SQLITE3_ASSOC))
{
    $blocked[] = $row['ip'];
}

$files  = array(
'ftp_warn.csv',
'ssh_warn.csv',
);



foreach($files as $file)
{
    $type = str_replace('.csv','',$file);
    $lines = file($file);
    $block = array();
    foreach($lines as $line)
    {
	$ip = null;
	if (preg_match('/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/', $line, $ip_match)) {
	    $ip = $ip_match[0];
	}
	$tab = explode(';',$line);
	$date = date("Y-m-d",strtotime($tab[0]));
	if(count($tab)>2)
	    $info = $tab[1]." ".$tab[2];
	else
	    $info = $tab[1];

	if($ip && stripos($type,'warn')!==false)
	{
	    $block[$ip][] = $date;
	}
    }
    
    if($block)
    {
	foreach($block as $ip=>$datas)
	{
	    if(count($datas) > 2 && !in_array($ip,$blocked))
	    {
		$sql = "INSERT INTO `blocked` VALUES('{$datas[0]}','{$ip}')";
		$db->query($sql);
		
	    }
	}
    }

}

#block ip
if($blocked)
{
    $savetofile='';
    foreach($blocked as $ip){
	$savetofile.=$ip."\n";
    }

    file_put_contents('blockedip.db',$savetofile);
}

foreach($files as $file){
    file_put_contents($file,'');
}


?>
