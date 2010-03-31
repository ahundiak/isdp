/* ###################   APOGEE COMPILED   ################## */
/*
History
	SM	Many moons ago		Creation.
        Sudha   07/09/93                Modified for BSprototypes anisfication

*/

class implementation Root;

#include "EMS.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"                   /* OM_BLOCK_MOVE */
#include "bserr.h"
#include "bsrev_cv.h"

%safe
static IGRint		EMget_curveclassid();
%endsafe

#if DEBUG
#include <stdio.h>
#endif

extern OMuword OPP_GRbcsubbc_class_id, OPP_GRlinear_class_id, 
	       OPP_GRcompcurve_class_id;
	
from EMSedge import EMget_props_type;
from GRvg import GRpostabsg;
from GRgraphics import GRconstruct;
from GRconnector import GRrigidconn;
  
IGRlong EMsfintout(num_grps, num_subgrps_grp, num_elems_subgrp, elems, 
		   subgrp_rev, elem_rev, grp_closed, subgrp_closed, 
		   construct_list, number_of_intersections,
		   intersections, msg)
		
IGRint                num_grps, *num_subgrps_grp, **num_elems_subgrp;
struct EMSintobj      ***elems;
IGRboolean            **subgrp_rev, ***elem_rev, *grp_closed, **subgrp_closed;
struct		      GRvg_construct *construct_list;
IGRlong		      *number_of_intersections;
struct GRid	      **intersections;
IGRlong		      *msg;
{
  IGRlong		sts, rc;
  struct GRid		this_grid, junk_grid;
  struct EMSintobj      *this_elem;
  IGRlong		num_inters;
  OMuword		crv_classid;
  IGRint		curve_count = 0;
  struct		GRpost_info post_info;

  /*******************************
  OM_S_CHANSELECT       to_comps, to_cpx;
  *******************************/

  struct EMSdataselect	*data;
  void			EMrevpyline();
  IGRboolean		is_composite, reverse = FALSE;
  IGRint		i, j, m;
  IGRchar		*save_geom;
  struct IGRpolyline	*poly;

  sts = OM_S_SUCCESS;
  *msg = EMS_S_Success;
  *number_of_intersections = 0;
  *intersections = NULL;
  num_inters = 0;

  /*******************************
  sts = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, wrapup);
  sts = EMmake_chanselect (GRconnector_to_owners, &to_cpx);
  EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, wrapup);
  *********************************/

  *intersections = (struct GRid *)
                   om$malloc(size = num_grps * sizeof(struct GRid));
  EMerr_hndlr(!(*intersections), *msg, EMS_E_NoDynamicMemory, wrapup);
  *number_of_intersections = 0;
  this_grid.osnum = junk_grid.osnum = construct_list->env_info->md_id.osnum;
	
  for(i=0; i<num_grps; i++)
   {
    curve_count = 0;
    num_inters = 0;

    for(j=0; j<num_subgrps_grp[i]; j++)
      num_inters += num_elems_subgrp[i][j];

    if(num_inters > 1) is_composite = TRUE;
    else is_composite = FALSE;
    if(is_composite)
     {
      sts = om$construct(classid = OPP_GRcompcurve_class_id,
                     osnum = this_grid.osnum, 
                     p_objid = &this_grid.objid, 
                     msg = message GRgraphics.GRconstruct(construct_list));
      if(!(1&sts)) goto wrapup;
     }
    for(j=0; j<num_subgrps_grp[i]; j++)
     {
      this_elem = (struct EMSintobj *) elems[i][j];
      for(m=0; m<num_elems_subgrp[i][j]; m++)
       {
	data = &this_elem->this_xyzintobj;
	reverse = subgrp_rev[i][j];
	if(elem_rev[i][j][m]) reverse = !reverse;
	if(this_elem->reversed) reverse = !reverse;
	
	if(data->datatype == EMSdata_curve3d)
	 {
	  if(reverse)
	   {
	    BSrev_cv(&rc, data->data.curve);
	    if(rc != BSSUCC) {*msg = EMS_E_Fail; goto wrapup;}
	   }
	  sts = EMget_curveclassid(msg, this_elem, &crv_classid);
	  if(!(1&sts)) goto wrapup;
 	  save_geom = construct_list->geometry;
	  construct_list->geometry = (IGRchar *) 
				   data->data.curve;
	  sts = om$construct(classid = crv_classid, 
			osnum = this_grid.osnum, 
		p_objid = is_composite ? &junk_grid.objid : &this_grid.objid, 
		msg = message GRgraphics.GRconstruct(construct_list));
	  construct_list->geometry = (IGRchar *) save_geom;
	  if(!(1&sts)) goto wrapup;
	 }
        else if(data->datatype == EMSdata_poly3d)
        {
         poly = this_elem->this_xyzintobj.data.poly;
         if(reverse)
	  {
           EMrevpyline(msg, poly, 3, NULL);
           EMerr_hndlr(!(1&*msg),*msg,EMS_E_Fail,wrapup);
          }
	 sts = EFplace_line_string(NULL_OBJID, construct_list, 
					poly->num_points, poly->points, 
			is_composite ? &junk_grid.objid : &this_grid.objid, 
			msg);
	 if(!sts) goto wrapup;
	}
       else
	{
	 *msg = EMS_E_InvalidArg;
	 goto wrapup;
	}
       if(is_composite)	
        {
         sts = om$send(msg = message GRconnector.GRrigidconn
                         (msg, &this_grid, (IGRlong *)&curve_count), 
                        targetid = junk_grid.objid, 
			targetos = junk_grid.osnum, 
			senderid = junk_grid.objid);
	 if(!(1&sts)) goto wrapup;
	 curve_count++;
	/*****************************************
         sts = om$send(msg = message Root.connect
                         (to_comps, NULL, junk_grid.objid, junk_grid.osnum, 
                                to_cpx, curve_count++), 
                        targetid = this_grid.objid, 
			targetos = this_grid.osnum, 
			senderid = junk_grid.objid);
	 if(!(1&sts)) goto wrapup;
	*****************************************/
	
	}
       else
         (*intersections)[ (*number_of_intersections)++] = this_grid;

       this_elem = this_elem->next;

      } /* for(m=0; m<num_elems_subgrp[i][j]; m++) */

     } /* for(j=0; j<num_subgrps_grp[i]; j++) */

    if(is_composite)
     {
      (*intersections)[ (*number_of_intersections)++] = this_grid;

      post_info.construct_flag = TRUE;
      sts = om$send (msg = message GRvg.GRpostabsg (msg, 
             construct_list->env_info, &post_info, NULL, &this_grid.objid),
             targetid = this_grid.objid, targetos = this_grid.osnum,
             senderid = NULL_OBJID); 
     }

    } /* for(i=0; i<num_grps; i++) */

wrapup:
EMWRAPUP(*msg, sts, "In EMsfintout");
return(sts);
}

static IGRint	EMget_curveclassid(msg, this_elem, crv_classid)
IGRlong			*msg;
struct EMSintobj	*this_elem;
OMuword			*crv_classid;
{
 IGRlong		sts;
 IGRlong		EFget_classid_for_an_edge_type();
 IGRuchar       edge_type;

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;

 if(this_elem->this_xyzintobj.datatype == EMSdata_curve3d)
  {
   if(this_elem->this_uvintobj.datatype != EMSdata_object)
    *crv_classid = OPP_GRbcsubbc_class_id;
   else
    {
     sts = om$send(msg = message EMSedge.EMget_props_type
				(msg, NULL, &edge_type),
		  senderid = this_elem->this_uvintobj.data.object->objid, 
		  targetid = this_elem->this_uvintobj.data.object->objid, 
		  targetos = this_elem->this_uvintobj.data.object->osnum);
     if(!(1&sts&*msg)) goto wrapup;
     sts = EFget_classid_for_an_edge_type(crv_classid, edge_type);
     if(!(1&sts)) goto wrapup;
    }

   /* If for some reason, the geometry is not suitable, construct
      a general b spline. -
	    if order != 2 and edge type linear
            or if order = 2 but edge type non linear.
   */
		
   sts = om$is_ancestry_valid(subclassid = *crv_classid, 
					 superclassid = OPP_GRlinear_class_id);
   if( (sts == OM_S_SUCCESS) && 
       (this_elem->this_xyzintobj.data.curve->order != 2))
    *crv_classid = OPP_GRbcsubbc_class_id;
   else if( (sts != OM_S_SUCCESS) && 
	    (this_elem->this_xyzintobj.data.curve->order == 2))
    *crv_classid = OPP_GRbcsubbc_class_id;
  }

wrapup:
if(!(1&sts&*msg)) *crv_classid = OPP_GRbcsubbc_class_id;
*msg = EMS_S_Success;
return(OM_S_SUCCESS);
}

end implementation Root;
