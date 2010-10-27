/* $Id: repsrf.m1,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $ */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdloft/cmd/repsrf.m
 *
 * Description:    makemake file for files in vds/vdloft/cmd.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: repsrf.m1,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/01/30  13:58:48  pinnacle
# ah
#
# Revision 1.1  1998/01/29  20:13:00  pinnacle
# TR_179702387: converted file from Loft to VDS
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  01/23/98  ejm     TR:179702387, converted file from Loft to VDS
 ***************************************************************************/

SOURCE
VDRepSrfCmd.S
VDRepSrfCmdi.I
VDReprSrfi.I
VDrmover.I

INCLUDE
$BS/include
$BS/include/prototypes
$FORMS/include
$UMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$MODEL/include
$VDS/include
$VDS/vdinclude
$VDS/include/prototypes
$STRUCT/include

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec

LIB
$VDS/lib/vdcrepsrf.o

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc

COPT
$COMPOPT
