/* $Id: vdxppl.m,v 1.2 2001/05/04 20:41:32 anand Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdextr/ppl/exrppl.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdxppl.m,v $
 *	Revision 1.2  2001/05/04 20:41:32  anand
 *	TR 5143
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:48  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1999/04/19  14:02:26  pinnacle
# for dynapipe
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

CCIOPT	-Xnoptrchk -Xnoargchk -m -q

#if ISDP_MAKE_SP

VDXcre_dgn.u

#else

VDX4rvw.u
VDXcre_dgn.u

#endif
