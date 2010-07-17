/* $Id: vrsketch_pto.h,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrsketch_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrsketch_pto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:57  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.3  1998/03/20  21:24:52  pinnacle
 * Replaced: vrinclude/prototypes/vrsketch_pto.h for:  by lawaddel for route
 *
 * Revision 1.2  1998/03/06  20:04:32  pinnacle
 * Replaced: vrinclude/prototypes/vrsketch_pto.h for:  by lawaddel for route
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.2  1996/01/17  00:37:38  pinnacle
 * Replaced: vrinclude/prototypes/vrsketch_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:52:04  pinnacle
 * Created: vrinclude/prototypes/vrsketch_pto.h by tlbriggs for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/11/96   tlb		created
 *	01/12/96   tlb		Add include files,
					 externs
 *      03/06/98   law          TR179600988 prevent sketch form wrong end of
 *                              nozzle. 
 *************************************************************************/
#include <standards.h>
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "ex.h"
#include "dpstruct.h"
#include "parametric.h"
#include "ACrg_collect.h"


/* VRhcdynamic.I */
extern IGRlong VRhvlinear 	__((	IGRint action ,
					 IGRdouble *prev_pt ,
					 IGRdouble *first_pt ,
					 IGRdouble *Z_Window ,
					 IGRint NbOfImpDirection ,
					 IGRdouble *imp_direct ,
					 IGRdouble *matrix ,
					 IGRboolean twist_orient ,
					 IGRboolean orthogonal_sketch ,
					 struct IGRdisplay *display ,
					 IGRdouble angle ,
					 IGRboolean angle_flag ,
					 IGRboolean is_connect,
					 IGRint CompType,
					 IGRdouble *cmpmatrix));

/* VRloadattri.I */

/* VRplcmpbycod.I */

/* VRppdynamic.I */
extern IGRlong VRrblinear 	__((	IGRint action ,
					 IGRdouble *prev_pt ,
					 IGRdouble *first_pt ,
					 IGRdouble *Z_Window ,
					 IGRint NbOfImpDirection ,
					 IGRdouble *imp_direct ,
					 IGRboolean orthogonal_sketch ,
					 struct IGRdisplay *display ,
					 IGRdouble angle ,
					 IGRboolean angle_flag ,
					 IGRboolean is_connect ,
					 IGRint CompType,
					 IGRdouble *cmpmatrix));

/* VRskconnect.I */

/* VRskcrseg.I */

/* VRskcstpt.I */
extern IGRlong VRis_an_extend 	__((	IGRlong *extend ,
					 IGRdouble *prev_pt ,
					 IGRdouble *first_pt ,
					 IGRdouble *next_pt ));

/* VRsketchact.I */

/* VRsketchi.I */

/* VRskmerge.I */
extern int VRskChgSupport 	__((	IGRlong *msg ,
					 struct GRid *CmpId ,
					 IGRdouble *Orient ,
					 IGRshort *Index ,
					 struct GRid *PrevSeg ,
					 struct GRid *NewSeg ,
					 struct GRmd_env *md_env ));

