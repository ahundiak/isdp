/* $Id: penmacros.m,v 1.2 2001/05/12 22:09:33 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpen/macros/penmacros.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: penmacros.m,v $
 *	Revision 1.2  2001/05/12 22:09:33  ylong
 *	CR5209, TR5109
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1999/05/03  16:56:10  pinnacle
# initial revision
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

CCIOPT	-Xnoptrchk -Xnoargchk -m -q
#if ISDP_MAKE_SP
pcgMacro.u
penMacro.u
#else
COVDSpen.u
penMacro.u
pcgMacro.u
#endif
