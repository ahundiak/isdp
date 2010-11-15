# Do not alter this SPC information: $Revision: 1.1.42.1 $
#!/usr/bin/perl
#This script creates sub directories and their dependent ones


# check index of last arg (should be at least 1 args)
if (@ARGV != 1)
{
    print ("No directory specified on command line\n");
    exit (1);
}
$dirname = shift(ARGV);
@names = split(/\\/,$dirname);
$numdirs = @names;
$cnt= 0;

for ($cnt = 0; $cnt < $numdirs; $cnt++)
{
	if ($cnt ==0)
	{
		$subdir = $names[$cnt] .'\\' . $names[$cnt + 1];
		$cnt+=2;
#printf ("Making %s\n",$subdir);
		mkdir($subdir,0777) if (-z $subdir == 0);
	}
	$subdir = $subdir . "\\" . $names[$cnt];
#printf ("Making %s\n",$subdir);
	mkdir($subdir,0777) if (-z $subdir == 0);
}


1;
__END__

