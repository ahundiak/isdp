# $Id: vcapi.sh,v 1.1 2001/01/26 17:51:54 anand Exp $
#!/bin/ksh
# -------------------------------------------------------------------
# I/CABLE
#
# File: api/vcapi.sh
#
# Description:
#	Shellscript to compile and install the cabling API
#
# Dependencies:
#
# Revision History:
#       $Log: vcapi.sh,v $
#       Revision 1.1  2001/01/26 17:51:54  anand
#       *** empty log message ***
#
#       Revision 1.1.1.1  2001/01/04 21:12:00  cvs
#       Initial import to CVS
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/04  04:59:10  pinnacle
# Replaced: api/* for: Merging CABLE with ROUTE by aharihar for route
#
# Revision 1.1  1997/10/31  08:18:28  pinnacle
# Created by aharihar for route (from cabling)
#
# Revision 1.3  1997/07/15  19:13:16  pinnacle
# Replaced: api/vcapi.sh for:  by hverstee for cabling
#
# Revision 1.2  1997/07/14  21:32:42  pinnacle
# Replaced: api/vcapi.sh for:  by hverstee for cabling
#
#
# History:
#       MM/DD/YY        AUTHOR          DESCRIPTION
#       12/03/95        tlb             created
# -------------------------------------------------------------------

#-------------------------------------------------------------------------------
function Tput {
        /usr/bin/tput $1
} # Tput
#-------------------------------------------------------------------------------
function Info {
        echo "$*"
        return 0
} # Info
#-------------------------------------------------------------------------------
function Header {
        Tput smul ; Info "$*" ; Tput rmul ;
} # Header
#-------------------------------------------------------------------------------

integer rc

#
#	Init globals.
#
OMCPP=""		# Omcpp executable
OPL=""			# Opl executable
OPLCLEAN=""		# Oplclean executable
CABLEname=""		# Name of I/CABLE in "product_data"
CABLEvers=""		# Version of I/CABLE in product.def
TMPprodInit=""		# .C generated by "opl -d"
VCprodInit=""		# OMprodinit.C with VC symbols only
VCprodDir=""		# Directory where OMprodinit.C and version file are kept
VCrelDir=""		# Release directory where product.def is kept
VCdloadProd=""		# Dload directory in release version
VCdloadCmds=""		# Dload (commands) directory in release version
VCversFile=""		# Version file
VCdloadObj=""		# DLOADable object file
VCdloadObj1=""		# DLOADable object file
OMprodInit="OMprodinit.C"
VCaccOpt="${COMPOPT}"

Header "\n\t\tCreation of loadable I/CABLE API functions \n"

SUN=`uname -s`

                                if [ $SUN = "SunOS" ] ;
                                then
                                        VCdloadObj="${VCdloadCmds}/CABLE.so"
#                                       VCdloadObj1="${VCdloadCmds}/CABLE1.so"
                                        LD="/usr/ccs/bin/ld"
                                        LDOPT=" -z text -G "
                                        CC="/opt/SUNWspro/bin/cc"
                                        MCS="/usr/ccs/bin/mcs"
                                else
                                        VCdloadObj="${VCdloadCmds}/CABLE.o"
#                                       VCdloadObj1="${VCdloadCmds}/CABLE1.o"
                                        LD="/bin/ld"
                                        LDOPT=" -r -M "
                                        CC="/bin/acc"
                                        MCS="/usr/bin/mcs"
                                fi

make dyn

make ppl

#      make a .so on a solaris machine    

if [ $SUN = "SunOS" ] ; then
        dot=`ls -1 $ROUTE/config/dload/corrections/*.o`
        for i in $dot
        do
                name=${i%.*}
                ${LD} -z text -G -o ${name}.so ${name}.o
                rm ${name}.o
        done
fi


exit ${rc}
