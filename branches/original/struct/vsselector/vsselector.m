/* $Id: vsselector.m,v 1.1.1.1 2001/01/04 21:10:58 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsselector/vsselector.m 
 *
 * Description:
 *		List of source files.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vsselector.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/09/22  17:37:26  pinnacle
# Replaced: vsselector/vsselector.m for:  by s250_int for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/01/97	i-struct	creation date
 *	09/22/97	adz		Add VSslgetdump.I file for review.
 ***************************************************************************/

SOURCE
VSselector.S
VSslcnstfeet.I
VSslgetattr.I
VSslgetdump.I
VSslgetobjdf.I
VSslputattr.I
VSslsleep.I

VSslcheck.C
VSsldebug.C
VSsldistobob.I
VSslerror.C
VSslexec.C
VSslexecsend.I
VSslfcnlib.C
VSslfunction.C
VSsloprtn.C
VSsllex.C
VSslnode.C
VSslparse.C
VSsltable.C
VSsltranslex.C
VSslyacc.C

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
$(STRUCT)/include
$(STRUCT)/include/prototypes

OMCPP
$(EXNUC)/bin/omcpp

OPP
$(EXNUC)/bin/opp

LIB
$(STRUCT)/lib/vsselector.o

/*
 * "CLIX" : -D switch for BS
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN

CC
acc -ansi -O3
