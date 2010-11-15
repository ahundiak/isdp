/* $Id: vsupretend.m,v 1.1.1.1 2001/01/04 21:11:01 cvs Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:        $STRUCT/vsupretend/vsupretend.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsupretend.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:11:01  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1995/10/27  15:34:20  pinnacle
# Replaced: vsupretend/*.m for:  by tdumbach for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR  DESCRIPTION
 *      27-Oct-95       TRD     Added $VDS/include files to include list.
 *
 *************************************************************************/

SOURCE
VSdescrfoot.C
VSmkupretend.C

VSupretend.S
VSprgiveoutp.I

VSupretendRF.S
VSpfgiveoutp.I

LIB
$(STRUCT)/lib/vsupretend.o

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec
$(STRUCT)/spec

INCLUDE
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(VDS)/include
$(VDS)/include/prototypes
$(VDS)/vdinclude
$(STRUCT)/include
$(STRUCT)/include/prototypes

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp

/*
 * "CLIX" : -D switch for BS
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN

CC
acc -ansi -O3