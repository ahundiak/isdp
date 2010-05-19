/* $Id: vditemppl.m,v 1.5 2001/05/29 13:42:40 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdroot/vdrootppl.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vditemppl.m,v $
 *      Revision 1.5  2001/05/29 13:42:40  jdsauby
 *      Added mat_id_key for stage object.  CR 5222.
 *
 *      Revision 1.4  2001/05/07 13:45:16  jdsauby
 *      Needed to uppercase duct_matl for RWAY objects due to AVD change in database tables.(VDit_route.u)  - jds
 *
 *      Revision 1.3  2001/04/16 20:02:07  ylong
 *      TR5063
 *
 *      Revision 1.2  2001/03/22 21:12:43  jdsauby
 *      Added VDit_rem PPL for removal of itemdb cache.
 *
 *      Revision 1.1  2001/01/10 18:04:42  art
 *      sp merge
 *
# Revision 1.1  2000/12/06  19:08:56  pinnacle
# Created: vds/vditem/ppl/vditemppl.m by jdsauby for Service Pack
#
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/09/00  js      Created
 *
 ***************************************************************************/

CCIOPT        -Xnoargchk -m -q
#if ISDP_MAKE_SP
VDit_attrs.u
VDit_route.u
VDit_vds.u
#else

VDit_attrs.u
VDit_struct.u
VDit_route.u
VDit_vds.u
VDit_rem.u
#endif
