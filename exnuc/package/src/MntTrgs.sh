#
# This script will mount all targets for packaging.
#
# Combined mntSUN220.sh & mntSGI220.sh
# 10-Jun-93 @12:00 JWW Initial version of MntTrgs.sh
# 15-Jul-93 @13:00 JWW Fixed for 2.4.0
# 10-Aug-93 @10:00 JWW Changed sgi to sgi5
# 01-Oct-96 @15:26 SCW Changed machine nodes and mount paths for v3.3.0
# 06-Jun-97 @11:26 SCW Changed machine nodes and mount paths for v3.4.0
# 15-Jul-97 @16:54 SCW Modified to use set uid bit
#

#set -x

case $# in
 0) echo "No options given: Usage: $0 [mount/dismount]"
    exit 2 ;;

 1) if [ $1 = "mount" ]
    then
      # Mount the Target disks from the 3rd party box for packaging

      # integsgi MIPS_IRIX 5.3
      rootsetuid /etc/mount -r -f NFS integsgi:/usr2/exnuc34/sgi5 \
      /usr2/exnuc34/sgi5

      # noid10 SPARC_SOLARIS 2.5.1 (Native X)
      rootsetuid /etc/mount -r -f NFS noid10:/usr2/exnuc34/sun5 \
      /usr2/exnuc34/sun5

      # integ4u SPARC_SOLARIS 2.5 (XGL)
      rootsetuid /etc/mount -r -f NFS integ4u:/usr2/exnuc34/sun6 \
      /usr2/exnuc34/sun6

      # integp5 INTEL_SOLARIS 2.5.1
      rootsetuid /etc/mount -r -f NFS integp5:/usr2/exnuc34/intel5 \
      /usr2/exnuc34/intel5

    else

      # dismount all of the targets.

      rootsetuid /etc/umount /usr2/exnuc34/sgi5
      rootsetuid /etc/umount /usr2/exnuc34/sun5
      rootsetuid /etc/umount /usr2/exnuc34/sun6
      rootsetuid /etc/umount /usr2/exnuc34/intel5
    fi ;;

 *) echo "Too many options given: Usage: $0 [mount/dismount]"
    exit 2 ;;
esac

echo ""
df
