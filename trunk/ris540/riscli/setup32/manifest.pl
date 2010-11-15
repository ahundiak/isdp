# Do not alter this SPC information: $Revision: 1.2.41.1 $

open(OUTFILE,">> $ENV{'RIS_PROD_SHARE_DIR'}\\manifest.ris") || die "Could not open $ENV{'RIS_PROD_SHARE_DIR'}\\manifest.ris";

open(INFILE,"< $ENV{'SHAMROCKDIR'}\\shared\\manifest.txt") || die "Could not open $ENV{'SHAMROCKDIR'}\\shared\\manifest.txt";

print OUTFILE "\n\nShamrock shared component files:\n\n"; # this string not found in Shamrock manifest.txt

$flag = 0;                # String we are looking for is in 2 different spots.
while (<INFILE>)
{
    if (/SHARED directory:/)
     {
        s/ and files necessary to/./ ;
        print OUTFILE "$_\n";
        $flag = 1;
     }
    
    if ($flag eq 1)
      {
        if (/Shamrock runtime DLL/)
          {
            print OUTFILE "$_\n";
            last;
          }
      }
}

close (INFILE);

