# Do not alter this SPC information: $Revision: 1.1.56.1 $
# written by Adell 'O.P.P" Warren
#
#  Please adust the directory names for the following
#  setup32\csource  setup32\deliv  and location for scratch file scratch.lyt
#
 
sub dodir
{
    local($dir,$nlink) = @_;
    local($dev,$ino,$mode,$subcount);

    ($dev,$ino,$mode,$nlink) = stat('.') unless $nlink;

    opendir(DIR,'.') || die "Cant open $dir";

    local(@filenames) = readdir(DIR);
    
    closedir(DIR);

     if ($nlink == 2)                         # No subdirectories left
        {
          for (@filenames)
            {
                next if $_ eq '.';
                next if $_ eq '..';
                print "$dir/$_";
            }
        }
      else
        {
                $subcount = $nlink - 2;
                for (@filenames)
                  {
                      next if $_ eq '.';
                      next if $_ eq '..';
                      $name  = "$dir\\$_";
# DEBUG LINE          print $name,"\n";
                      push(@fiddle,$name);
                    
                      next if $subcount == 0;           # got all of the subdirs ????

                      ($dev,$ino,$mode,$nlink) = lstat($_);
                      next unless -d _;

                      chdir $_ || "Can't cd to $name";
                      &dodir($name,$nlink);
                      chdir '..';
                      --$subcount;
                    }
          }
}

    open (INFILE,"$ENV{'RIS_PROD_SHARE_DIR'}\\rispack.lyt") || die "Open $ENV{'RIS_PROD_SHARE_DIR'}\\rispack.lyt failed";
    open (OUTPUT,"> $ENV{'RIS_SETUP_DIR'}\\scratch.lyt");

    $pwd = `cd`;
    chdir ("$ENV{'LOCAL_DIR'}");
    &dodir('.');
    chdir ("$pwd");


    while (<INFILE>)
      {
         if (/!disk_id!\\(\w+).(\w+),(.*)/)
             {             
               $file = "$1" . "." . "$2"; 
              
                foreach $data (grep(/$file/,@fiddle))
                    {($junk,$device,$junk1) = split(/\\/,$data,3); }
               
               s/!disk_id!/$device/g ;

               print OUTPUT "$_";
             }
          else
             {
               print OUTPUT "$_";
             }
       }

     close(INFILE);
     close(OUTPUT);

     `cd $pwd`;

     `copy $ENV{'RIS_SETUP_DIR'}\\scratch.lyt  $ENV{'RIS_PROD_SHARE_DIR'}\\rispack.lyt `;

     `del $ENV{'RIS_SETUP_DIR'}\\scratch.lyt`;
