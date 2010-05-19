/* $Id: ppldim.m,v 1.2 2001/10/17 20:40:11 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdppl / vdppl.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ppldim.m,v $
 *	Revision 1.2  2001/10/17 20:40:11  hans
 *	Modifications for CR# MP5368
 *	
 *	Revision 1.1  2001/01/19 23:19:30  jayadev
 *	*** empty log message ***
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *	05/05/00	Alwin	Created for SPX.
 *				Added the ppl of grnuc/src/dim/cisrc directory
 *	10/16/2001	HF	Modifications for CR# MP5368
 * -------------------------------------------------------------------*/

CCIOPT   -Xnoptrchk -Xnoargchk -m -q
#if ISDP_MAKE_SP
dim_forms.u
toggle_term.u
#else
dim_forms.u
toggle_term.u
#endif
