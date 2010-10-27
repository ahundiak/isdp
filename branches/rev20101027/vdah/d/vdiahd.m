/* $Id: vdiahd.m,v 1.1 2001/02/01 21:23:50 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/vdiahd.m
 *
 * Description: Dummy routines for service pack
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiahd.m,v $
 *      Revision 1.1  2001/02/01 21:23:50  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/05/00  ah      creation
 ***************************************************************************/

SOURCE
VDobj2.c

LIB
vdiahd.o

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
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
