# This is the script run to restore the nfs mounts and links for NFM 
#
# Read the nfmnfstabs file to find out the required mounts

nfmnfstabs=/usr/ip32/nfm/config/nfs/nfmnfstabs
nfmnfslinks=/usr/ip32/nfm/config/nfs/nfmnfslinks
nfmerrfile=/usr/tmp/ERRNFMFILE
ERRFLAG=0

echo "" > $nfmerrfile

if test  -r $nfmnfstabs
then
cat ${nfmnfstabs} |
	while read resource mountpoint nodename options
	do
		case ${resource} in
		 '#'*|''|'-')	# Ignore comments, empty lines, no action lines
			continue
		esac

# Check if the mountpoint exists
	if test -d "$mountpoint" > /dev/console 2>&1
	then
		echo "<$mountpoint>" already exists > /dev/console 2>&1
		echo "<$nodename:$resource>" not mounted on "<$mountpoint>" > /dev/console 2>&1
		ERRFLAG=1
		echo NFS:Mount:Mountpoint "<$mountpoint>" already exists >> $nfmerrfile
		echo "<$nodename:$resource>" not mounted on "<$mountpoint>" >> $nfmerrfile
		continue
	fi

# Create the mountpoint with mode 0777 
	if ! mkdir -m 0777 -p ${mountpoint} > /dev/console 2>&1
	then	
		echo Cannot create mountpoint "<$mountpoint>"  > /dev/console 2>&1
		echo "<$nodename:$resource>" not mounted on "<$mountpoint>" > /dev/console 2>&1
		ERRFLAG=1
		echo NFS:Mount:Cannot create Mountpoint "<$mountpoint>" >> $nfmerrfile
		echo "<$nodename:$resource>" not mounted on "<$mountpoint>" >> $nfmerrfile
		continue
	fi
	if ! /etc/mount -r -f NFS,$options $nodename:$resource $mountpoint > /dev/console 2>&1
	then
		echo NFS:mount failed for Resource "<$nodename:$resource>" at Mountpoint "<$mountpoint>" > /dev/console 2>&1
		echo "<$nodename:$resource>" not mounted on "<$mountpoint>" > /dev/console 2>&1
		ERRFLAG=1
		echo NFS:Mount:Mount Failed for "<$nodename:$resource>" at Mountpoint "<$mountpoint>" >> $nfmerrfile
		echo "<$nodename:$resource>" not mounted on "<$mountpoint>" >> $nfmerrfile
		continue
	fi
	done

# Do the links


if test -r $nfmnfslinks
then
cat ${nfmnfslinks} |
	while read source destination
	do
		case ${source} in
		 '#'*|''|'-')	# Ignore comments, empty lines, no action lines
			continue
		esac

# Check if the source exists
	if test ! -f "${source}" > /dev/console 2>&1
	then
		echo Link:Source file "<$source>" doesnot exists > /dev/console 2>&1
		echo Link:Source file "<$source>" not linked to "<$destination>" > /dev/console 2>&1
		ERRFLAG=1
		echo Link:Source file "<$source>" doesnot exists >> $nfmerrfile
		echo Link:Source file "<$source>" not linked to "<$destination>" >> $nfmerrfile
		continue
	fi
# Check if destination exists
	if test  -f ">${destination}" > /dev/console 2>&1
	then
		echo Link:Destination file "<$destination>"  exists > /dev/console 2>&1
		echo Link:Source file "<$source>" not linked to "<$destination>" > /dev/console 2>&1
		ERRFLAG=1
		echo Link:Destination file "<$destination>"  exists >> $nfmerrfile
		echo Link:Source file "<$source>" not linked to "<$destination>" >> $nfmerrfile
		continue
	fi
	if ! ln -s "${source}" "${destination}" > /dev/console 2>&1
	then
		echo Link:ln -s "<$source>" "<$destination>"  failed > /dev/console 2>&1
		echo Link:Source file "<$source>" not linked to "<$destination>" > /dev/console 2>&1
		ERRFLAG=1
		echo Link:ln -s "<$source>" "<$destination>"  failed >> $nfmerrfile
		echo Link:Source file "<$source>" not linked to "<$destination>" >> $nfmerrfile
		continue
	fi
	done
else
	echo NFM:NFS:LINK:"<WARNING>" No links to establish >/dev/console 2>&1
	echo NFM:NFS:LINK:"<WARNING>" No links to establish > $nfmerrfile
        ERRFLAG=1
fi

# Check to see if error occured If so Inform user on the console

if (( $ERRFLAG >= 1 ))
then
	echo Some Failures in restoring mounts occured > /dev/console 2>&1
	echo Errors saved in file "<$nfmerrfile>" > /dev/console 2>&1
	exit 1
else
	echo NFM:NFS: Restore mounts and links SUCCESSFUL >/dev/console 2>&1
	exit 0
fi
fi
