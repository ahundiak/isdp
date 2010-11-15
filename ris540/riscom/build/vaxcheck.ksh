# Do not alter this SPC information: $Revision: 1.1.55.1 $
if [ -z "$1" ] ; then
	machine=risvax.mcintyre.terry
else
	machine=$1
fi
fmu $machine <<!
com ty [.$RIS_VERS.build]build.log
exit
!
