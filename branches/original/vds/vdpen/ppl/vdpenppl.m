/* $Id: vdpenppl.m,v 1.5 2001/10/10 19:24:29 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpen/ppl/vdpenppl.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdpenppl.m,v $
 *	Revision 1.5  2001/10/10 19:24:29  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.4  2001/05/16 15:53:08  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.3  2001/05/09 19:56:35  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/19 22:32:40  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1999/05/03  16:54:22  pinnacle
# initial revision
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	05/02/99	jhanson/adz	first release
 * -------------------------------------------------------------------*/

CCIOPT  -Xnoptrchk -Xnoargchk -m -q
#if ISDP_MAKE_SP
COpcg.u
COpcgMod.u
COpen.u
COpenMod.u
COz_pcgAxis.u

#else
COpcg.u
COpcgMod.u
COpen.u
COpenMod.u
COz_movePcg.u
COz_namePen.u
COz_pcgAxis.u
#endif
