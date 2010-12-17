# This is the script run to unmount the nfs mounts and unlink for NFM 
#
# Read the nfmnfstabs file to find out the required mounts

nfmnfstabs=/usr/ip32/nfm/config/nfs/nfmnfstabs
nfmnfslinks=/usr/ip32/nfm/config/nfs/nfmnfslinks
nfmerrfile=/usr/tmp/ERRNFMFILE
ERRFLAG=0
NFMNFSFLAG=0

# Do the links

if test -r $nfmnfslinks
then
NFMNFSFLAG=1
cat ${nfmnfslinks} |
	while read source destination
	do
		case ${source} in
		 '#'*|''|'-')	# Ignore comments, empty lines, no action lines
			continue
		esac

# Check if destination exists and is a symbolic link
	if test !  -L "${destination}" > /dev/console 2>&1
	then
		echo Unlink:Destination file "<$destination>"  does not exists or not a symbolic link > /dev/console 2>&1
		echo Unlink:Destination file "<$destination>"  will not be removed > /dev/console 2>&1
		ERRFLAG=1
		echo Unlink:Destination file "<$destination>"  does not exist or not a symbolic link >> $nfmerrfile
		echo Unlink:Destination file "<$destination>"  will not be removed >> $nfmerrfile
		continue
	fi
	if ! \rm -f  "${destination}" > /dev/console 2>&1
	then
		echo Unlink:"\rm" -f "<$destination>"  failed > /dev/console 2>&1
		echo Unlink:Destination file "<$destination>"  not  removed > /dev/console 2>&1
		ERRFLAG=1
		echo Unlink:"\rm" -f "<$destination>"  failed >> $nfmerrfile
		echo Unlink:Destination file "<$destination>"  not  removed >> $nfmerrfile
		continue
	fi
	done
fi


echo "" > $nfmerrfile

if test  -r $nfmnfstabs
then
NFMNFSFLAG=1
cat ${nfmnfstabs} |
	while read resource mountpoint  nodename rest_of_junk
	do
		case ${resource} in
		 '#'*|''|'-')	# Ignore comments, empty lines, no action lines
			continue
		esac

# Check if the mountpoint exists
	if test ! -d "$mountpoint" > /dev/console 2>&1
	then
		echo "<$mountpoint>" does not exists > /dev/console 2>&1
		echo "<$nodename:$resource>" not unmounted from "<$mountpoint>" > /dev/console 2>&1
		ERRFLAG=1
		echo NFS:Mount:Mountpoint "<$mountpoint>" does not exists >> $nfmerrfile
		echo "<$nodename:$resource>" not unmounted from "<$mountpoint>" >> $nfmerrfile
		continue
	fi
# umount the mount
	if ! /etc/umount  $mountpoint > /dev/console 2>&1
	then
		echo NFS:umount failed for Resource "<$nodename:$resource>" at Mountpoint "<$mountpoint>" > /dev/console 2>&1
		echo "<$nodename:$resource>" not unmounted from "<$mountpoint>" > /dev/console 2>&1
		ERRFLAG=1
		echo NFS:Mount:Umount Failed for "<$nodename:$resource>" at Mountpoint "<$mountpoint>" >> $nfmerrfile
		echo "<$nodename:$resource>" not unmounted from "<$mountpoint>" >> $nfmerrfile
		continue
	fi

# Remove the mount point
	if ! rmdir  ${mountpoint} > /dev/console 2>&1
	then	
		echo Cannot remove mountpoint "<$mountpoint>"  > /dev/console 2>&1
		ERRFLAG=1
		echo NFS:Mount:Cannot remove Mountpoint "<$mountpoint>" >> $nfmerrfile
		continue
	fi
	done
fi

# Check to see if error occured If so Inform user on the console

if (( $ERRFLAG >= 1 ))
then
	echo Some Failures in umounts or remove occured > /dev/console 2>&1
	echo Errors saved in file "<$nfmerrfile>" > /dev/console 2>&1
	exit 1
elif (( $NFMNFSFLAG >= 1 ))
then
	echo NFM:NFS: Umounts and unlinks SUCCESSFUL >/dev/console 2>&1
	exit 0
fi
