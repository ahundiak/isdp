/* $Id: vscoord.m,v 1.3 2001/07/09 21:10:30 jayadev Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:        vscoord/vscoord.m
 *
 * Description:	
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vscoord.m,v $
 *      Revision 1.3  2001/07/09 21:10:30  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/04/02 22:26:02  ramarao
 *      Fixed TR# 4999
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:31  cvs
 *      Initial import to CVS
 *
# Revision 1.3  2000/02/23  22:22:04  pinnacle
# tr179901005
#
# Revision 1.2  2000/02/17  16:45:38  pinnacle
# (No comment)
#
 *
 * History:
 * MM/DD/YY AUTHOR DESCRIPTION
 * 06/16/97 ah     Added Header, Deleted class files
 * 06/16/97 ah     TR179701071 Checkin
 * 10/30/97 ah	   Added grnuc/src/assoc/include_priv
 * 02/23/00 ah     Restored it to prePaul condition
 *************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VSint.I
VScsby2elF.I
#else
VScsby2elF.I
VSint.I
VSget3dbeam.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXS)/lib/vscoord.o
#else
$(STRUCT)/lib/vscoord.o
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec
$(STRUCT)/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/vdinclude
$(SPXV)/include/prototypes
$(SPXS)/include
$(SPXS)/include/prototypes
#endif
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/proto_priv
$(GRNUC)/src/assoc/include_priv
$(MODEL)/include
$(FORMS)/include
$(VDS)/include
$(VDS)/vdinclude
$(STRUCT)/include
$(STRUCT)/include/prototypes

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp

/*
 * "CLIX" : -D switch for operating system
 * "ENV5" : -D switch for windowing system
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN

CC
acc -ansi -O3
