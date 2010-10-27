/* $Id: vdirisc.m,v 1.3 2002/05/09 17:45:23 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdris/c/vdirisc.m
 *
 * Description: Ris Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdirisc.m,v $
 *      Revision 1.3  2002/05/09 17:45:23  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/02/17 14:18:26  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/01 21:58:19  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/01/01  ah      Creation
 ***************************************************************************/

SOURCE
VDrisUtil.c
VDrisTable.c
VDrisBlob.c
VDrisCache.c

VDnfmEnv.c
VDnfmCrypt.c
VDnfmLogin.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdirisc.o
#else
$VDS/lib/vdirisc.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
$LOCAL/include
$LOCAL/include/glib-1.2
$$BS/include
$BS/include/prototypes
$RIS/risdp/include
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

