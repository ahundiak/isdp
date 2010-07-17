
/* $Id: VCcreate.h,v 1.2 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCcreate.h
 *
 * Description:
 *
 *      Function prototypes and definitions for cabling create
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCcreate.h,v $
 *      Revision 1.2  2002/05/08 15:48:24  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1998/03/12  10:19:46  pinnacle
 * Replaced: vcinclude/VCcreate.h for: TR179800045 by aharihar for route
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.2  1997/07/14  21:18:08  pinnacle
 * Replaced: vcinclude/*.h for:  by hverstee for cabling
 *
 * Revision 1.1  1997/04/28  21:41:06  pinnacle
 * Created: vcinclude/VCcreate.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *
 *************************************************************************/

#ifndef	vc_create_include
#define vc_create_include

#ifndef _STANDARDS_H_
#       include <standards.h>
#endif

extern
IGRint      VC_CreateColl __((IGRlong        *msg,
                              IGRshort        nNum,
                       struct ACrg_coll      *Coll,
                       struct GRid           *CGRid));

extern
IGRint      VC_CreateTerm __((IGRlong        *msg,
                              IGRint          NumPar,
                       struct GRid           *Parents,
                       struct VCGenInfo      *GenIn,
                              short           Level,
                       struct IGRdisplay     *DispAtt,
                       struct GRmd_env       *md_env,
                       struct GRid           *OutId));

extern
IGRint      VC_CreateCab  __((IGRlong        *msg,
                              IGRint          NumPar,
                       struct GRid           *Parents,
                       struct VCGenInfo      *GenIn,
                              short           Level,
                       struct IGRdisplay     *DispAtt,
                       struct GRmd_env       *md_env,
                       struct GRid           *OutId,
			      IGRshort        nTermCount,
			      IGRdouble      *Offset,
			      IGRboolean      bSubCable,
			      IGRint	      NumLeads,
			      IGRchar	     (*LdNames)[VC_MAX_LEAD_ID] ));

extern
IGRint      VC_CreateGd   __((IGRlong        *msg,
                              IGRint          NumPar,
                       struct GRid           *Parents,
                       struct VCGenInfo      *GenIn,
                              short           Level,
                       struct IGRdisplay     *DispAtt,
                       struct GRmd_env       *md_env,
                       struct GRid           *OutId));

extern
IGRint      VC_CreateBksh __((IGRlong        *msg,
                              IGRint          NumPar,
                       struct GRid           *Parents,
                       struct VCGenInfo      *GenIn,
                              short           Level,
                       struct IGRdisplay     *DispAtt,
                       struct GRmd_env       *md_env,
                       struct GRid           *OutId));

#endif
