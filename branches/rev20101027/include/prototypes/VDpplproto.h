/* $Id: VDpplproto.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:	include/prototypes/ VDpplproto.h
 *
 * Description:
 *	protypes for ppl functions
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDpplproto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1995/08/30  19:58:38  pinnacle
 * Created: include/prototypes/VDpplproto.h by tlbriggs for vds.240
 *
 *
 * History:
 *   	08/29/95   tlb		created
 *
 *************************************************************************/

#ifndef vdpplproto_include
#	define vdpplproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

/* VDppl.I */
extern int VD_pplLoad(char *ppl_name, char *entry, struct GRid *ppl_id);
extern int VD_pplRun(char *ppl_name, char *entry, struct GRid ppl_id, int *val);
extern int VD_pplPushArgs(int num, void **list, int *size);
extern int VD_pplDelete(struct GRid ppl_id);

#endif

