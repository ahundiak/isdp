# Do not alter this SPC information: $Revision: 1.2.41.1 $
#!/usr/bin/perl
#This script appends to setreg.bat with set commands for current dir.

open (INFILE," wert.rlk") || die "Could not open wert.rlk";
open (OUTFILE,">> setreg.bat") || die "Could not open setreg.bat";
while (<INFILE>)
{
	chop;
	$kit_dir = $_;
	printf OUTFILE ("set _KIT=%s\n",$kit_dir);
}

close(INFILE);


$in_drive = substr($ENV{'_LOCAL_DIR'},0,2);
printf OUTFILE ("set _IN_DRIVE=%s\n",$in_drive);

$kit_drive = substr($kit_dir,0,2);
printf OUTFILE ("set _KIT_DRIVE=%s\n",$kit_drive);

close(OUTFILE);



1;
__END__

