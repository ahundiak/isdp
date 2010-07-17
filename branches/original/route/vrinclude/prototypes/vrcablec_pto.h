/* $Id: vrcablec_pto.h,v 1.1.1.1 2001/01/04 21:12:56 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrcablec_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrcablec_pto.h,v $
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
 * Revision 1.3  1996/01/19  08:28:28  pinnacle
 * Replaced: vrinclude/prototypes/vrcablec_pto.h for:  by ashankar for route240
 *
 * Revision 1.2  1996/01/17  00:34:14  pinnacle
 * Replaced: vrinclude/prototypes/vrcablec_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:49:16  pinnacle
 * Created: vrinclude/prototypes/vrcablec_pto.h by tlbriggs for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/11/96   tlb		created
 *	01/12/96   tlb		Add include files, externs
 *
 *************************************************************************/
#include <standards.h>
#include <stdio.h>
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"		/* struct IGRdisplay */
#include "gr.h"
#include "ex.h"
#include "dpstruct.h"		/* struct DPele_header */
#include "parametric.h"
#include "growner.h"
#include "VRcabledef.h"		/* struct VRcable_data */


/* VRcable_dsp.I */

/* VRcable_dyn.I */
extern IGRint VRCbDynamics	__((	struct VRcable_data	*CabData,
					IGRdouble		*Pnts,
					IGRint			Num_Pnts,
					struct	IGRdisplay	*display,
					IGRdouble		*Z_Window,
					GRobjid			Obj_Id,
					IGRboolean		Dynamic_Type,
					IGRdouble		*St_Pnt,
					IGRdouble		*St_Vec,
					IGRdouble		*End_Pnt ));
extern IGRboolean VRVerifyBendRad __((	IGRlong *msg ,
					 IGRint NbAdjPts ,
					 IGRdouble dAdjPts [],
					 IGRdouble dModPt [],
					 IGRdouble dBendRadius ));

/* VRcable_fnc.I */
extern int VRCb_Equip_Active 	__((	IGRchar *Obj_Name ,
					 struct GRid *Obj_Id ));
extern int VRCb_Object_Active 	__((	IGRchar *Obj_Name ,
					 struct GRid *Obj_Id ));
extern IGRint VRCbGetProjectPnt __((	IGRdouble *Pnt ,
					 IGRdouble *Pnt_Vec ,
					 IGRdouble *Next_Pnt ,
					 IGRdouble *Win_Dir ,
					 IGRdouble *Proj_Pnt ));
extern IGRint VRCbGetSeqList 	__((	IGRint *NumListId ,
					 struct GRobj_env *ListId ,
					 struct GRobj_env *SeqList ));
extern int VRCb_Pr_Defined 	__((	FILE *file_Ptr ,
					 IGRchar *Obj_Name ,
					 IGRdouble length ));

/* VRcable_msg.I */

/* VRcableconi.I */

/* VRcableradi.I */

/* VRcablerepi.I */

/* VRcableseti.I */
