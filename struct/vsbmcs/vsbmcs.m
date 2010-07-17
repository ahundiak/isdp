/* $Id: vsbmcs.m,v 1.1.1.1 2001/01/04 21:10:21 cvs Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:        $STRUCT/vsbmcs/vsbmcs.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsbmcs.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:21  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1995/10/27  15:32:52  pinnacle
# Replaced: vsbmcs/*.m for:  by tdumbach for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR  DESCRIPTION
 *      27-Oct-95       TRD     Added $VDS/include files to include list.
 *
 *************************************************************************/

SOURCE
/*
	Beam co-ordinate system.
*/
VSbeamCS.S
VScnstCS.I
VSbccnstfeet.I
VSbcevalCS.I
VSbcgetattr.I
VSbcgetobjdf.I
VSbcputattr.I

LIB
$(STRUCT)/lib/vsbmcs.o

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec
$(STRUCT)/spec

INCLUDE
$(EXNUC)/include
$(BS)/include
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
