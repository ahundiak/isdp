/* $Id: vsbmaxis.m,v 1.4 2001/11/16 14:24:34 ahundiak Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:	$STRUCT/vsbmaxis/vsbmaxis.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsbmaxis.m,v $
 *      Revision 1.4  2001/11/16 14:24:34  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/11/04 17:47:21  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/04/27 13:25:14  ramarao
 *      Fixed TR# 5117.
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:13  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/03/22  14:41:02  pinnacle
# ah
#
# Revision 1.2  1998/03/22  14:01:28  pinnacle
# CR179800676
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1995/10/27  15:25:38  pinnacle
# Replaced: vsbmaxis/*.m for:  by tdumbach for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/27/95  TRD     Added $VDS/include files to include list.
 * 03/22/98  ah      CR179800676 Modify Stiffener Axis
 *    ""             CR179800677 Set axis orientation
 *
 *************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VSbacnstfeet.I
VSbaMod.I
VSbacnsttype.I
#else
VSbeamAxis.S
VSbacnstaxin.I
VSbacnstaxpj.I
VSbacnstfeet.I
VSbacnsttype.I
VSbattentrie.I
VSbaextflag.I
VSbafdcvinsf.I
VSbagenpersf.I
VSbagetobjdf.I
VSbagetside.I
VSbaplatside.I
VSbaputattr.I
VSbaxdirCS.I
VSbaMod.I
VSbaMod2.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXS)/lib/vsbmaxis.o
#else
$(STRUCT)/lib/vsbmaxis.o
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
$(SPXV)/include/prototypes
$(SPXV)/vdinclude
$(SPXS)/include
$(SPXS)/include/prototypes
#endif
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/src/assoc/include_priv
$(MODEL)/include
$(FORMS)/include
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
