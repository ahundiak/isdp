/* $Id: vsapis.m,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/vsapis.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vsapis.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1997/01/30  10:26:44  pinnacle
# Replaced: vsapis/vsapis.m for:  by svkadamb for struct
#
# Revision 1.1  1996/02/20  23:45:52  pinnacle
# Created: ./vsapis/vsapis.m by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *
 ***************************************************************************/

SOURCE

VSmdplate.I
VSmdstif.I
VSmdstifaxis.I
VSmdbeam.I
VSmdjoint.I
VSplplate.I
VSplstif.I 
VSplstifaxis.I
VSplbeam.I
VSpljoint.I
VSsplit.I
VSgetplattr.I
VSgetbsattr.I
VSmodusratt.I
VSmvnmirstf.I
VScrshellexp.I
VSexpshcv.I
VSmgshexp.I
VSretngrcopy.I

LIB
$(STRUCT)/lib/vsapis.o

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
$(GRNUC)/proto_priv
$(MODEL)/include
$(VDS)/include
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
