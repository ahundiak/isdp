# Do not alter this SPC information: $Revision: 1.4.17.1 $
open (INFILE,"< $ENV{'RIS_PROD_SHARE_DIR'}\\rispack.lyt") || die "Could not open $ENV{'RIS_PROD_SHARE_DIR'}\\rispack.lyt";
open (OUTFILE,"> rispack.scr") || die "Could not open rispack.scr";

while (<INFILE>)
   {
       if (/I9SHAMR1.DLL/)
          {
             s/I9SHAMR1.DLL/shared\\I9SHAMR1.DLL/g;
             s/SECTION=Shamshr2/SECTION=RISPack/;
           }
       if (/I9SHAMR2.DLL/)
          {
             s/I9SHAMR2.DLL/shared\\I9SHAMR2.DLL/g;
             s/SECTION=Shamshr2/SECTION=RISPack/;
           }
        print OUTFILE "$_";
    }

close(INFILE);
close(OUTFILE);

`copy rispack.scr $ENV{'RIS_PROD_SHARE_DIR'}\\rispack.lyt`;
`del rispack.scr`;


open (INFILE,"< $ENV{'RIS_PROD_SHARE_DIR'}\\rissetup.lyt") || die "Could not open $ENV{'RIS_PROD_SHARE_DIR'}\\rissetup.lyt";
open (OUTFILE,"> rissetup.scr") || die "Could not open rissetup.scr";

while (<INFILE>)
    {
          if (/I9SHAMR1.DLL/)
            {
                s/I9SHAMR1.DLL/shared\\I9SHAMR1.DLL/;
            }
          if (/I9SHAMR2.DLL/)
            {
                s/I9SHAMR2.DLL/shared\\I9SHAMR2.DLL/;
            }

           print OUTFILE "$_";
    }

close (INFILE);
close (OUTFILE);

`copy rissetup.scr $ENV{'RIS_PROD_SHARE_DIR'}\\rissetup.lyt`;
`del rissetup.scr`;

open (INFILE,"< $ENV{'RIS_PROD_SHARE_DIR'}\\riswrk.lyt") || die "Could not open $ENV{'RIS_PROD_SHARE_DIR'}\\riswrk.lyt";
open (OUTFILE,"> riswrk.scr") || die "Could not open riswrk.scr";

while (<INFILE>)
    {
          if (/I9SHAMR1.DLL/)
            {
                s/I9SHAMR1.DLL/shared\\I9SHAMR1.DLL/;
            }
          if (/I9SHAMR2.DLL/)
            {
                s/I9SHAMR2.DLL/shared\\I9SHAMR2.DLL/;
            }

           print OUTFILE "$_";
    }

close (INFILE);
close (OUTFILE);

`copy riswrk.scr $ENV{'RIS_PROD_SHARE_DIR'}\\riswrk.lyt`;
`del riswrk.scr`;

