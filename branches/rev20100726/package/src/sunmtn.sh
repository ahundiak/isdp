# This script will mount all targets for packaging.
# Combined mntSUN220.sh & mntSGI220.sh
# 10-Jun-93 @12:00 JWW Initial version of MntTrgs.sh
# 15-Jul-93 @13:00 JWW Fixed for 2.4.0
# 10-Aug-93 @10:00 JWW Changed sgi to sgi5
#set -x
case $# in
 0) echo "No options given: Usage: $0 [mount/dismount]"
	exit 2
	;;
 1) # Check user id for Super-User.
	Test_id=$(id | cut -c5)
	if [ "$Test_id" -ne 0 ]
	then
		echo ""
		echo "      Must be Super-User to run $0"
		echo ""
		exit 1
	fi
	if [ $1 = "mount" ]
	then

		# mount the /usr1 disk from the sundog machine for packaging.
/etc/mount -r -f NFS sundog:/usr1/exnuc/v3.1.0 /usr1/exnuc/v3.1.0

	else
		# dismount all of the targets.
		/etc/umount /usr1/exnuc/v3.1.0
	fi
	;;
 *) echo "Too many options given: Usage: $0 [mount/dismount]"
	exit 2
	;;
esac
echo ""
df
