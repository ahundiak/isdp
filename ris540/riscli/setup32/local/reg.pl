# Do not alter this SPC information: $Revision: 1.1.42.1 $
#!/usr/bin/perl
#This script create setreg.bat with set commands for RIS products found in
#the registry

require "registry.pl";


@RISproducts = (
	'RIS',
	'RISDP',
	'RISORADS',
	'RISORANS',
	'RISDB2DS',
	'RISMSFDS',
	'RISINGDS',
	'RISINFDS',
	'RISINFNS',
	'RISSYBDS');


open (OUTFILE,"> setreg.bat") || die "Could not open setreg.bat";

foreach $prod (@RISproducts)
{
	$tkey = $prod . "\\$ENV{'_RISVER'}";
#	printf("key = %s\n",$tkey);
	$key = "SOFTWARE\\Intergraph\\" . $tkey;
	$loc = &FindKey($key);
#	printf("<%s> found at <%s>\n", $key,$loc) if $loc ne "missing";
	printf OUTFILE ("set _%s_DIR=%s\n",$prod,$loc) if $loc ne "missing";
}
close(OUTFILE);

#----------------------------------------------------------------------
sub FindKey
{
	local($keystring,$work);	

	$keystring = shift(@_);
	$work="N/A";

	return "missing" if &RegOpenKeyEx($HKEY_LOCAL_MACHINE,$keystring,$reserved,$KEY_READ,$hkey) == 0;
	&RegQueryValue($hkey,"PathName", $work);
#	printf("Findkey: <%s> found at <%s>\n", $keystring,$work);
	&RegCloseKey($hKey);
	return $work;
}



1;
__END__

