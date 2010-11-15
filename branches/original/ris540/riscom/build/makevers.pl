# Do not alter this SPC information: $Revision: 1.3.4.1 $
#!/usr/bin/perl
require "ctime.pl";

# This perl script creates the the temp file for risver.h and can only be
# called from makvers.bat

$maj=$ENV{'RIS_MAJ'};
$min=$ENV{'RIS_MIN'};
$rel=$ENV{'RIS_REL'};
$seq=$ENV{'RIS_SEQ'};

$date = &ctime(time);
($day,$month,$num,$time,$zone,$year) = split(' ',$date);
# Kludge to get over the problem with ctime returning different strings
# on different PC's. The string has the zone (e.g CST) on some machines
# and does not have it on other machines.
if ( length($year) eq 0)
	{ $year = $zone; }

$q='"';#quote mark

$tmpfile = shift(@ARGV);
open (TMPFILE,">$tmpfile");
printf TMPFILE ("#define RIS_VERSION %s,%s,%s,%s\n",$maj,$min,$rel,$seq);
printf TMPFILE ("#define RIS_VERSION_STR %s%s.%s.%s.%s\\0%s\n",$q,$maj,$min,$rel,$seq,$q);
printf TMPFILE ("#define RIS_MAJ_MIN_STR %s%s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define RIS_VERSION_FIX %s,%s,%s,%s\n",$maj,$min,$rel,$seq);
printf TMPFILE ("#define RIS_VERSION_CUI %sVersion %s.%s.%s.%s%s\n",$q,$maj,$min,$rel,$seq,$q);
printf TMPFILE ("#define RIS_VERSION_MAJ %s\n",$maj);
printf TMPFILE ("#define RIS_VERSION_MIN %s\n",$min);
printf TMPFILE ("#define RIS_VERSION_REL %s\n",$rel);
printf TMPFILE ("#define RIS_VERSION_SEQ %s\n",$seq);
printf TMPFILE ("#define RIS_VERSION_MAJ_STR %s%s%s\n",$q,$maj,$q);
printf TMPFILE ("#define RIS_VERSION_MIN_STR %s%s%s\n",$q,$min,$q);
printf TMPFILE ("#define RIS_VERSION_REL_STR %s%s%s\n",$q,$rel,$q);
printf TMPFILE ("#define RIS_VERSION_SEQ_STR %s%s%s\n",$q,$seq,$q);

printf TMPFILE ("#define RIS_PROGMAN_STR %sRISDP %s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define RIS_LIST_STR %sRISDP\\\\%s.%s%s\n",$q,$maj,$min,$q);

printf TMPFILE ("#define RELDATE %s%s-%s-%s%s\n",$q,$num,$month,$year,$q);
printf TMPFILE ("#define COPYRIGHTYEAR %s%s%s\n",$q,$year,$q);
printf TMPFILE ("#define SETUP_COPYRIGHT_YEAR %sCopyright \\251 1993-%s%s\n",$q,$year,$q);
printf TMPFILE ("#define PATHNAME %s\\\\win32app\\\\ingr\\\\share\\\\ris%s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define RISCOMPONENT %sRIS%s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define RISPROGGROUP %sRIS %s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define REGISTRY %sSoftware\\\\Intergraph\\\\RIS\\\\%s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define RIS_MAJOR_MINOR %s%s.%s%s\n",$q,$maj,$min,$q);

printf TMPFILE ("#define RISCLI_LIST_STR %sRISCLI\\\\%s.%s%s\n",$q,$maj,$min,$q);

printf TMPFILE ("#define RISDP_PROGMAN_STR %sRISDP %s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define RISDP_LIST_STR %sRISDP\\\\%s.%s%s\n",$q,$maj,$min,$q);

printf TMPFILE ("#define DB2DS_PROGMAN_STR %sRISDB2DS %s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define DB2DS_LIST_STR %sRISDB2DS\\\\%s.%s%s\n",$q,$maj,$min,$q);

printf TMPFILE ("#define ORADS_PROGMAN_STR %sRISORADS %s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define ORADS_LIST_STR %sRISORADS\\\\%s.%s%s\n",$q,$maj,$min,$q);

printf TMPFILE ("#define ORANS_PROGMAN_STR %sRISORANS %s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define ORANS_LIST_STR %sRISORANS\\\\%s.%s%s\n",$q,$maj,$min,$q);

printf TMPFILE ("#define IGSDS_PROGMAN_STR %sRISIGSDS %s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define IGSDS_LIST_STR %sRISIGSDS\\\\%s.%s%s\n",$q,$maj,$min,$q);

printf TMPFILE ("#define INFDS_PROGMAN_STR %sRISINFDS %s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define INFDS_LIST_STR %sRISINFDS\\\\%s.%s%s\n",$q,$maj,$min,$q);

printf TMPFILE ("#define INFNS_PROGMAN_STR %sRISINFNS %s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define INFNS_LIST_STR %sRISINFNS\\\\%s.%s%s\n",$q,$maj,$min,$q);

printf TMPFILE ("#define MSFDS_PROGMAN_STR %sRISMSFDS %s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define MSFDS_LIST_STR %sRISMSFDS\\\\%s.%s%s\n",$q,$maj,$min,$q);

printf TMPFILE ("#define SYBDS_PROGMAN_STR %sRISSYBDS %s.%s%s\n",$q,$maj,$min,$q);
printf TMPFILE ("#define SYBDS_LIST_STR %sRISSYBDS\\\\%s.%s%s\n",$q,$maj,$min,$q);

printf TMPFILE ("#define RIS_CR %sCopyright %s, Intergraph Corporation. All Rights Reserved\\0%s\n",$q,$year,$q);
printf TMPFILE ("#define RIS_CO %sIntergraph Corporation\\0%s\n",$q,$q);
printf TMPFILE ("#define RIS_TM %sIntergraph\\256 is a registered trademark of Intergraph Corporation.\\0%s\n",$q,$q);


printf TMPFILE ("static char *RIS_version = %s%s.%s.%s.%s%s;\n",$q,$maj,$min,$rel,$seq,$q);
printf TMPFILE ("static int RIS_version_maj = %d;\n",$maj);
printf TMPFILE ("static int RIS_version_min = %d;\n",$min);
printf TMPFILE ("static int RIS_version_rel = %d;\n",$rel);
printf TMPFILE ("static int RIS_version_seq = %d;\n",$seq);
close(TMPFILE);


1;
__END__

