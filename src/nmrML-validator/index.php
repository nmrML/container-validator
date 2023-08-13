<HTML>
	<HEAD>
		<TITLE>OpenMS nmrML validator</TITLE>
	</HEAD>
	<BODY>
<?     
        // enable for debugging
//        error_reporting(E_ALL);
//        ini_set("display_errors", 1);

	$output = array();
	$upload_ok = false; 
	$nmrml_file = '';
	if ($_FILES["file"]["error"] > 0)
  {
    $output[] = "<HR><B>Upload:</b> Could not upload the file. Return Code: ".$_FILES["file"]["error"]."<BR>";
	}
  else
	{
		if (isset($_FILES["file"]["name"]))
		{
			if (file_exists("files/".$_FILES["file"]["name"]))
			{
				if(move_uploaded_file($_FILES["file"]["tmp_name"], "./files/".$_FILES["file"]["name"].'_'.time()))
				{
					$nmrml_file = $_FILES["file"]["name"].'_'.time();
					// echo $_FILES["file"]["name"] . " already exists. Instead stored in: files/".$nmrml_file;
					$output[] = "<HR><B>Upload:</b> Successfully uploaded the file ".$_FILES["file"]["name"].".<BR>";
					$upload_ok = true;
				}
				else
				{
					$output[] = "<HR><B>Upload:</b> Could not upload the file. Unknown error. <BR>";
				}
			}
			else
			{
				if(move_uploaded_file($_FILES["file"]["tmp_name"], "./files/".$_FILES["file"]["name"]))
				{
//					echo "Stored in: " . "files/" . $_FILES["file"]["name"];
					$nmrml_file = trim($_FILES["file"]["name"]);
					$output[] = "<HR><B>Upload:</b> Successfully uploaded the file ".$_FILES["file"]["name"].".<BR>";
					$upload_ok = true;
				}
				else
				{
					$output[] = "<HR><B>Upload:</b> Could not upload the file. Unknown error. <BR>";
				}
			}

                        // delete files older than 7 days from upload directory
                        $files=array();
                        $index=array();
                        $timespan = strtotime('7 days ago');
	                if ($handle = opendir('files')) {
	                  clearstatcache();
                          while (false !== ($file = readdir($handle))) {
	                    if ($file != "." && $file != "..") {
	                      $files[] = $file;
	                      $index[] = filemtime( 'files/'.$file );
	                    }
	                  }
	                  closedir($handle);
	                }
	                asort($index);
	                foreach($index as $i => $t) {
	                  if($t < $timespan) {
                             @unlink('files/'.$files[$i]);
	                  }
	                }	
		}
	}
?>
		<TABLE width=100% border=0>
			<TR>
				<TD>
					<H3>Select an nmrML file to validate:</H3>
					<FORM method="post" action="index.php" enctype="multipart/form-data">
						<INPUT type="file" name="file">
						<BR>
						<INPUT type="submit" value="validate">
					</FORM>
					
					<UL>
						<!--<LI> <font color="red">We are having technical problems. Please come back later!</font>-->
						<LI> This service is based on the TOPP tool <A href="http://ftp.mi.fu-berlin.de/OpenMS/release-documentation/html/TOPP_FileInfo.html">FileInfo</A>.
						<LI> It works with <A href="http://nmrml.org/schema/">nmrML</a> using the current development versions (<A href="https://github.com/nmrML/nmrML/blob/master/xml-schemata/XMLSchema.xsd">schema</A>, <A href="https://github.com/nmrML/nmrML/blob/master/ontologies/nmr-mapping.xml">mapping</A>, <A href="https://github.com/nmrML/nmrML/blob/master/ontologies/nmrCV.owl">CV</A>).
						<LI> An HTML representation of the official MSI mapping file and the CV can be found <A href="http://htmlpreview.github.com/?https://github.com/nmrML/nmrML/blob/master/docs/mapping_and_cv.html">here</A>. It was created using the UTILS tool <A href="http://ftp.mi.fu-berlin.de/OpenMS/release-documentation/html/UTILS_CVInspector.html">CVInspector</A>.
					</UL>
				</TD>
				<TD align=right valign=top>
					<A href="http://www.nmrml.org" target="blank_"><IMG src="header-mark.jpg" border=0></A>
					<A href="http://www.OpenMS.de" target="blank_"><IMG src="OpenMS.png" border=0></A>
				</TD>
			</TR>
		</TABLE>
<?
	//write output of upload
	foreach ($output as $o)
	{
		print $o;
	}
	//validate
	if ($upload_ok)
	{

		print "<HR><B>Validation:</b> FileInfo -v -in ".$_FILES["file"]["name"].".<BR>";
		print "<PRE>";
//		echo "Executing " . './FileInfo.sh "./files/'.$nmrml_file.'" 2>&1', $out ;
		
		exec('./FileInfo.sh "./files/'.$nmrml_file.'" 2>&1', $out);
		foreach ($out as $line)
		{
			print strtr($line."\n", array("./files/"=>""));
		}	
		print "</PRE>";
	}
?>
	</BODY>
</HTML>
