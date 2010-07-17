/* $Id: vsefp.m,v 1.2 2002/04/23 16:02:49 ahundiak Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsefp/vdiefp.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsefp.m,v $
 *      Revision 1.2  2002/04/23 16:02:49  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/08/01 20:21:14  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/22 15:40:24  ramarao
 *      Added VSefpNeatPl.I enrty.
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:36  cvs
 *      Initial import to CVS
 *
# Revision 1.4  1999/10/26  19:45:44  pinnacle
# ah
#
# Revision 1.3  1999/07/01  15:29:00  pinnacle
# Like parts
#
# Revision 1.2  1999/05/24  19:52:28  pinnacle
# ah
#
# Revision 1.1  1999/05/24  18:19:20  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/24/99  ah      creation
 * 04/23/02  ah      Most of the files are obsolete
 ***************************************************************************/
SOURCE
VSefpNeatPl.I
VSefpEdge.I

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
$(SPXS)/include
$(SPXS)/include/prototypes
#endif
$BS/include
$BS/include/prototypes
$UMS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
$STRUCT/include
$STRUCT/include/prototypes

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec

LIB
#if ISDP_MAKE_SP
$(SPXS)/lib/vsefp.o
#else
$(STRUCT)/lib/vsefp.o
#endif

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

