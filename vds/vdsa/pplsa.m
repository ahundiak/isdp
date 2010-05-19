/* $Id: pplsa.m,v 1.3 2001/11/09 15:08:39 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsa/pplsa.m
 *
 * Description: List of PPL files
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: pplsa.m,v $
 *      Revision 1.3  2001/11/09 15:08:39  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/22 15:27:06  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/07/28  14:55:02  pinnacle
# VDsaDelCache
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/04/10  21:58:30  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/30/98  ah      creation
 * 07/28/98  ah      Added VDsaDelCache
 ***************************************************************************/

CCIOPT        -Xnoargchk -m -q

#if ISDP_MAKE_SP
VDsaReview.u
#else
VDsaReview.u
VDsaAttr.u
VDsaDelCache.u
UCM_SA.u
#endif




