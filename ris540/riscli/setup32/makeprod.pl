require "ctime.pl";

{
$shortVersion = join ('.', $ENV{'RIS_MAJ'},$ENV{'RIS_MIN'}) ;
$date = &ctime(time);
($day,$month,$num,$time,$zone,$year) = split(' ',$date);

# Kludge to get over the problem with ctime returning different strings
# on different PC's. The string has the zone (e.g CST) on some machines
# and does not have it on other machines.
if ( length($year) eq 0)
	{ $year = $zone; }

if ($#ARGV >= 0) {
    
    if ($ARGV[0] eq "RISAPP") {
        $productName = "risdp" ;
        $productTitle = "RIS Development Platform Setup" ;        
        $productID = "SN0N387AA-0504A";
        $productLongName = "RIS DEVELOPMENT";
        $productType ="Nucleus:Development Tools" ;
        $productIndex="3168" ;
        $minSize="3000 KB";
        $maxSize="12500 KB";
    } elsif ($ARGV[0] eq "RISSRV") {
        $productName = $ENV{'DS_PRODUCT'} ;
        SWITCH: {
            if ($productName eq "rissybds") {
                $productTitle = "RIS SYBASE Data Server Setup (RISSYBDS)" ;
                $productID = "SN0N410AA-0504A";
                $productLongName = "RIS SYBASE Data Server";
                $productIndex="3172" ;
                $minSize="4500 KB";
                $maxSize="4500 KB";
            }
            if ($productName eq "rismsfds") {
                $productTitle = "RIS MSSQL Data Server Setup (RISMSFDS)" ;
                $productID = "SN0N482AA-0504A";
                $productLongName = "RIS MSSQL Data Server";
                $productIndex="3171" ;
                $minSize="3500 KB";
                $maxSize="3500 KB";
            }
            if ($productName eq "risingds") {
                $productTitle = "RIS INGRES Data Server Setup (RISINGDS)" ;
                $productID = "SN0L078AA-0504A";
                $productLongName = "RIS INGRES Data Server";
                $productIndex="0647" ;
                $minSize="11000 KB";
                $maxSize="11000 KB";
            }
            if ($productName eq "risorads") {
                $productTitle = "RIS Oracle Data Server Setup (RISORADS)" ;
                $productID = "SN0N074AA-0504A";
                $productLongName = "RIS ORACLE Data Server";
                $productIndex="3161" ;
                $minSize="5000 KB";
                $maxSize="5000 KB";
            }
            if ($productName eq "risorans") {
                $productTitle = "RIS Oracle Net Server Setup (RISORANS)" ;
                $productID = "SN0N222AA-0504A";
                $productLongName = "RIS ORACLE Net Data Server";
                $productIndex="3165" ;
                $minSize="5000 KB";
                $maxSize="5000 KB";
            }
            if ($productName eq "risinfds") {
                $productTitle = "RIS Informix Data Server Setup (RISINFDS)" ;
                $productID = "SN0N071AA-0504A";
                $productLongName = "RIS INFORMIX Data Server";
                $productIndex="3159" ;
                $minSize="3500 KB";
                $maxSize="3500 KB";
            }
            if ($productName eq "risinfns") {
                $productTitle = "RIS Informix Net Server Setup (RISINFNS)" ;
                $productID = "SN0N227AA-0504A";
                $productLongName = "RIS INFORMIX Net Data Server";
                $productIndex="3167" ;
                $minSize="3500 KB";
                $maxSize="3500 KB";
            }
            if ($productName eq "risdb2ds") {
                $productTitle = "RIS DB2 Data Server Setup (RISDB2DS)" ;
                $productID = "SN0N211AAI0504A";
                $productLongName = "RIS DB2 Data Server";
                $productIndex="3163" ;
                $minSize="3500 KB";
                $maxSize="3500 KB";
            }      
        } 
    } elsif ($ARGV[0] eq "RISCLI") {            
    } else {
        &ErrorHandler() ;
    }
} else
{
    &ErrorHandler() ;
}
$productShortName = $productName ;


if ($ARGV[0] ne "RISCLI") {            
    &create_prod_ini() ;
    &create_settings_ini();
    &create_product_pdf() ;
    &patch_fixes() ;
}
&patch_readme() ;
exit (0) ;
}
############################################################################
#
# Subroutine to create settings.ini
#
############################################################################
sub create_settings_ini {

  print "Creating $productName.ini\n" ;
  # open the source file or die
  open ( SOURCE, ">settings.ini" ) || die "Can't open settings.ini: $!\n";

  ##########################################################################
  # modify the template file to produce the source file
  ##########################################################################

    # standard section
    print SOURCE "[Standard]\n";

    # redefine DestPath
    print SOURCE "DestPath=c:\\Program Files\\".$productName."\\\n";
    print SOURCE "InstallType=\"typical\"\n";

    print SOURCE "\n";

  # registration
    print SOURCE "[Registration]\n";
    print SOURCE "name=\"Licensed to Intergraph Corporation\"\n";
    print SOURCE "organization=\"\"\n";
    print SOURCE "serial=\"\"\n";
    print SOURCE "\n";

  # Options
    if ($ARGV[0] eq "RISAPP") {
        print SOURCE "[Options]\n";
        printf SOURCE "OptFiles1=no\n";
        printf SOURCE "OptFiles2=no\n";
        printf SOURCE "OptFiles3=no\n";
        printf SOURCE "RISPack\n\n";
    }

  # SMS_Options
    print SOURCE "[SMS_Options]\n";
    print SOURCE "Producer=Intergraph Corporation\n";
    print SOURCE "ProductName=$productName\n";
    print SOURCE "Version=$shortVersion\n";
    print SOURCE "PName=$productShortName\n";
    print SOURCE "OurCaption=$productTitle\n";
    print SOURCE "SetupModule=.\\setup.exe\n";
    print SOURCE "MIF=\\$productShortName.mif\n";
    print SOURCE "\n";

  close ( SOURCE );

} # sub create_settings_ini

############################################################################
#
# Subroutine to create PROD.ini
#
############################################################################
sub create_prod_ini {
# prod.ini
   print "Creating prod.ini\n" ;
  # open the source file or die
  open (SOURCE,"> $ENV{'LAYOUT_DIR'}\\prod.ini") || die "Can't open prod.ini: $!\n";
#MANDATORY FIELDS
  print SOURCE "[Product Data]\n";
  print SOURCE "IDnumber=$productID\n" ;
  print SOURCE "Name=$productLongName\n";
  print SOURCE "ShortName=$productName\n";
  print SOURCE "Version=$ENV{'RIS_MAJ'}.$ENV{'RIS_MIN'}.$ENV{'RIS_REL'}.$ENV{'RIS_SEQ'}\n";
  print SOURCE "RelDate=$num-$month-$year\n";
  print SOURCE "Language=US/English\n" ;
  print SOURCE "Description=$productTitle\n" ;
  print SOURCE "DefaultPath=\\program files\\$productName\n" ;
  print SOURCE "MinimumSize=$minSize\n" ;
  print SOURCE "MaximumSize=$maxSize\n" ;
  print SOURCE "PreInstallFile=settings.ini\n" ;
  print SOURCE "InstallProcedure=setup.exe\n" ;
  print SOURCE "LoadOrder=9999\n" ;
  print SOURCE "Remove Script=SystemDirectory\\rm$productIndex.exe\n" ;
#OPTIONAL FIELDS
  if ($ARGV[0] eq "RISAPP") {
    print SOURCE "Category=$productType\n" ;
    print SOURCE "[Documentation]\n" ;
    print SOURCE "DocDir=\\program files\\$productName\\config\\english\\help\n" ;
    print SOURCE "DocFile1=risdp.hlp\n" ;
  }

  close ( SOURCE );

} # sub create_prod_ini

############################################################################
#
# Subroutine to create the PRODUCT.PDF file.
#
############################################################################
sub create_product_pdf {

  print "Creating $productName.pdf\n" ;
  # open the source file or die
    open ( SOURCE, ">$productName.pdf" ) || die "Can't open $productName.pdf: $!\n";

  ##########################################################################
  # modify the template file to produce the source file
  ##########################################################################

  # determine pdf file section for use later
    print SOURCE "[PDF]\n";
    print SOURCE "Version=1.000\n\n";

    print SOURCE "[Package Definition]\n";
    print SOURCE "Product=$productName\n";
    print SOURCE "Version=$shortVersion\n";
    print SOURCE "Comment=$productTitle\n";
    print SOURCE "SetupVariations=Automatic, Manual\n";
    print SOURCE "ErrorCodes=Yes\n";
    print SOURCE "Company=Intergraph\n";
    print SOURCE "ImportDirectory=\n";
    print SOURCE "SetupDirectory=\n";
    if ($ARGV[0] eq "RISSRV") {
    print SOURCE "Environments=Windows NT 3.1 (x86), Windows NT 3.51, Windows NT 4.0\n";
    	}
    else {
    print SOURCE "Environments=Windows NT 3.1 (x86), Windows NT 3.51, Windows NT 4.0, Windows 95\n";
    	}
    print SOURCE "Capabilities=Local Setup\n";
    print SOURCE "TelephoneSupportNumber=\n" ;
    print SOURCE "RebootAfterInstall=No\n";
    print SOURCE "RebootAfterDeInstall=No\n\n";

    print SOURCE "[Hermes Import Commands]\n";
    print SOURCE "cmd 1 =\n\n";

    print SOURCE "[Automatic Setup]\n";
    print SOURCE "CommandLine=wbrun20.exe $productName.pcd /c settings.ini\n";
    print SOURCE "CommandName=Automatic Setup\n";
    print SOURCE "UserInputRequired=FALSE\n";
    if ($ARGV[0] eq "RISSRV") {
    print SOURCE "SupportedPlatforms=Windows NT 3.1 (x86), Windows NT 3.51, Windows NT 4.0\n\n";
    	}
    else {
    print SOURCE "SupportedPlatforms=Windows NT 3.1 (x86), Windows NT 3.51, Windows NT 4.0, Windows95\n\n";
    	}

    print SOURCE "[Manual Setup]\n";
    print SOURCE "CommandLine=setup.exe\n";
    print SOURCE "CommandName=Manual Setup\n";
    print SOURCE "UserInputRequired=TRUE\n";
    if ($ARGV[0] eq "RISSRV") {
    print SOURCE "SupportedPlatforms=Windows NT 3.1 (x86), Windows NT 3.51, Windows NT 4.0\n\n";
    	}
    else {
    print SOURCE "SupportedPlatforms=Windows NT 3.1 (x86), Windows NT 3.51, Windows NT 4.0, Windows95\n\n";
    	}

    print SOURCE "[Setup Package for Inventory]\n";
    print SOURCE "InventoryThisPackage=TRUE\n";
    print SOURCE "Detection Rule Part 1=file 1\n";
    print SOURCE "Detection Rule Part 2= AND\n";
    print SOURCE "Detection Rule Part 3=file 2\n\n";

    print SOURCE "[file 1]\n";
    print SOURCE "File=$productName.exe\n";
    print SOURCE "Collect=FALSE\n\n";

    print SOURCE "[file 2]\n";
    print SOURCE "File=readme.txt\n";
    print SOURCE "Collect=FALSE\n";

    close ( SOURCE );
} # sub create_product_pdf


sub patch_readme {
#readme.txt
open (INPUT,"< readme.txt") || die "Could not open readme.txt";
printf ("Creating readme.txt\n") ;
if ($ARGV[0] eq "RISCLI") {
    open (OUTPUT,"> $ENV{'RIS_PROD_SHARE_DIR'}\\readme1.txt");
} elsif ($ARGV[0] eq "RISAPP") {
    open (OUTPUT,"> $ENV{'LAYOUT_DIR'}\\readme.dp");
} elsif ($ARGV[0] eq "RISSRV") {
    open (OUTPUT,"> $ENV{'LAYOUT_DIR'}\\readme.txt");
}


while (<INPUT>)               # string targ will be true for 2 different lines
  {
      if (/!version!/ || /!date!/)
       {
             s/!version!/$ENV{'RIS_MAJ'}.$ENV{'RIS_MIN'}.$ENV{'RIS_REL'}.$ENV{'RIS_SEQ'}/;
             s/!date!/$num-$month-$year/;
       }
            print OUTPUT "$_";     
   }

close (INPUT);
close (OUTPUT);
}

sub patch_fixes {
#fixes.txt
open (INPUT,"< fixes.txt") || die "Could not open fixes.txt";
printf ("Creating fixes.txt\n") ;
if ($ARGV[0] eq "RISAPP") {
    open (OUTPUT,"> $ENV{'LAYOUT_DIR'}\\fixes.txt");
} elsif ($ARGV[0] eq "RISSRV") {
    open (OUTPUT,"> $ENV{'LAYOUT_DIR'}\\fixes.txt");
}
while (<INPUT>)               # string targ will be true for 2 different lines
  {
      if (/!version!/)
       {
             s/!version!/$ENV{'RIS_MAJ'}.$ENV{'RIS_MIN'}.$ENV{'RIS_REL'}.$ENV{'RIS_SEQ'}/;
       }
      print OUTPUT "$_";     
   }

close (INPUT);
close (OUTPUT);
}

sub ErrorHandler {
    print ("Usage: perl makesms.pl <ProductType> where ProductType is one of:\n\tRISCLI\n\tRISAPP\n\tRISSRV\n") ;
    exit(-1) ;
}

