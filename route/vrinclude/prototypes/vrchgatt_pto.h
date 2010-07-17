/* $Id: vrchgatt_pto.h,v 1.1.1.1 2001/01/04 21:12:56 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrchgatt_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrchgatt_pto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:56  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.2  1996/01/17  00:34:20  pinnacle
 * Replaced: vrinclude/prototypes/vrchgatt_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:49:26  pinnacle
 * Created: vrinclude/prototypes/vrchgatt_pto.h by tlbriggs for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/11/96   tlb		created
 *	01/12/96   tlb		Add include files, externs
 *
 *************************************************************************/
#include <standards.h>
#include "igrtypedef.h"
#include "gr.h"
#include "FI.h"

/* VRchgattri.I */

/* VRchgfunk.I */
extern IGRint VRUpdALLSysForm 	__((	IGRint product ,
					 Form form_ptr ,
					 struct GRid *pId ));
extern int VRreset_gadget 	__((	IGRint product ,
					 IGRchar *form_ptr ));
extern int VRUpdate 		__((	struct GRid *ObjId ,
					 IGRint OldType ,
					 IGRint NewType ,
					 struct GRmd_env *MdEnv ));
extern IGRint VRReportLineId 	__((	struct GRid *pCmpCollId ,
					 struct GRid *pModCollId ));

/* VRform.I */
extern IGRint VRFormatSysForm 	__((	IGRint Product ,
					 Form pForm ,
					 IGRint ChgAttrFlag ,
					 IGRboolean bPidFlag ));
extern IGRint VRUpdEquiDiamFV 	__((	Form pForm ));

