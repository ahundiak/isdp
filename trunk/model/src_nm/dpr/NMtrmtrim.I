class implementation NMtrim;

#include "EMS.h"
#include <string.h>
#include "OMmacros.h"
#include "dp.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "nddef.h"

from NMinters import NMget_inters;

extern OMuword OPP_NMinters_class_id;
  
method NMtrim_element (IGRlong *EMmsg; struct GRmd_env *env;
                         IGRushort boolopt;
		       struct GRid *int_src, *trim_elem;
                         IGRchar *status_str; GRobjid **display_ids; 
			 IGRint *display_count)
{
 IGRlong		sts = OM_S_SUCCESS;
 struct GRid		src, sf, my_GRid;
 struct EMSobject_info	locop[2];
 IGRint			count = 0;
 struct EMSinters	*inters = NULL;
 struct EMSsftracedata	tracedata;
 enum EMSbooltype	emsbool_type;
 enum NMbooltype	bool_type;
 IGRdouble		cht;
 struct GRid		parents[2];
 union EMSparent_info   roots[2];
 unsigned int	root_type[2];
 extern OM_S_OBJID	current_creator;

 *EMmsg = EMS_S_Success;
 NMinit_tracedata(&tracedata);

 if(!int_src)
  {
   /* Get my source object for the intersection data
   */
   sts = om$send(msg = message NDnode.NDget_objects(ND_ROOT, parents, 2, NULL,
	 0, MAXINT, &count), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   root_type[0] = root_type[1] = EMSgrid;
   sts = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg, NULL, count, 
         (IGRchar *) parents, root_type, roots), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   src = roots[SrcIdx].grobj.grid;
   int_src = &src;
  }

 /* Get the data for trimming
 */
 sts = om$send(msg = message NMinters.NMget_inters(EMmsg, &inters, NULL, 
       trim_elem ? NULL : locop, &tracedata, &bool_type, &cht, NULL), 
       targetid = int_src->objid, targetos = int_src->osnum);
 if(!(1&*EMmsg&sts)) goto wrapup;

 sf = trim_elem ? *trim_elem : locop[NmOpIdx].grid;
 EMerr_hndlr(!inters, *EMmsg, EMS_I_NoIntersection, wrapup);

 /* Do the trimming
 */
 boolopt |= EMSsfbool_opt_SingleTopology |
            EMSsfbool_opt_OpenIntPossible | EMSsfbool_opt_IncompleteInt;
 my_GRid.osnum = OM_Gw_current_OS;
 my_GRid.objid = my_id;
 emsbool_type = bool_type == NMbool_union ? EMSbool_union : EMSbool_intersect;

 current_creator = my_id;
 sts = EMboolean_surfaces_w_intersection(EMmsg, 
       &my_GRid, 				/* boolid */
       emsbool_type, 				/* boolop */
       trim_elem? env : &locop[NmOpIdx].env,	/* mdenv */
       sf.objid,				/* sf1 */
       0, 					/* numsfs2 */
       NULL, 					/* sfs2 */
       inters, 					/* sf1_inters */
       NULL, 					/* sfs2_inters */
       &tracedata, 				/* sf1_tracedata */
       NULL, 					/* sfs2_tracedata */
       NULL, 					/* sf1_loopdata */
       NULL, 					/* sfs2_loopdata */
       boolopt, 				/* options */
       display_count, 				/* num_dispsfs */
       display_ids, 				/* dispsfids */
       status_str       
       );

wrapup:
current_creator = NULL_OBJID;
EMsfinttrace_free (EMmsg, tracedata.num_grps, tracedata.num_subgrps_grp, 
     tracedata.num_elems_subgrp, tracedata.elems, tracedata.subgrp_rev, 
     tracedata.elem_rev, tracedata.grp_closed, tracedata.subgrp_closed);
EMWRAPUP(*EMmsg, sts, "NMtrim.NMtrim_element");
return(sts);
}

end implementation NMtrim;
