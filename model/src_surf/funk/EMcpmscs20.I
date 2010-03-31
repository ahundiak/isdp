/* ###################   APOGEE COMPILED   ################## */
/*
Notes

	This function was written to replace the old version of EMcopy_mscs
	found in EMmksfcvs.I.  The algorithm used is as follows:
	    1. Get the edge id
	    2. Get the msc id
	    3. Make a copy of the msc
	    4. Copy the SOs to the new msc

History
	20-Nov-91	JSD	Creation of EMcpmscs20().
        10-Feb-92       mrm     handle absence of so table in curve os
        27-Aug-92       NP      Modified for ANSI compliance.
*/

class implementation EMSsubbs;

#include "EMS.h"
#ifndef emssfcvs_include
#include "emssfcvs.h"
#endif
#include "OMmacros.h"
#include "emseligible.h"
#include "bsparameters.h"
#include "bserr.h"
#include "EMSobjmgrdef.h"
#include "grownmacros.h"                /* For gr$add_to_active_owner */
#include "EMSlcdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "DEsomacros.h"
#include "EMSwrmacros.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/printerr.h"

#define NULL_INDEX -1

#define DEBUG	0

#if DEBUG
#define CURVE_BUF_INC 1
#else
#define CURVE_BUF_INC 20
#endif

from EMSboundary import EMgetxyzobj;
from DEso        import DEget;
from DEso        import DEadd;

IGRint EMcpmscs20(curve, local_info, invoker_info)
struct IGRbsp_curve         *curve;
struct EMSwireframe_mscinfo *local_info;
struct EMSinvoker_info      *invoker_info;
{
 IGRlong		sts, EMmsg, loc_sts, loc_EMmsg;
 struct EMScurveinfo	*curve_info;
 struct GRmd_env	*srf_env, *new_env;
 GRobjid		mscobj, edgeid;
 struct GRid		curveid, window_id;
 /*extern IGRint          EMmake_surface_curves();*/
 extern void            EMSsubbs_get_locate_window();
 IGRuchar	*curve_type;
 struct GRvg_construct	*const_list;
 IGRint                 *types, count, i;
 IGRdouble              *boundary_parms;
 struct GRid             soo;
 struct IGRdisplay      *display_attributes;
 struct IGRdisplay       orig_ele_attr;

 EMmsg = EMS_S_Success;

 curve_type = invoker_info->cvtype;
 edgeid = invoker_info->obj.objid;
 curve_info = local_info->curve_info;
 srf_env = local_info->old_env;
 const_list = curve_info->construct_list;
 new_env = const_list->env_info;
 curveid.osnum = new_env->md_id.osnum;

 /* Get the MSC of the edge
 */
 sts = om$send(msg = message EMSboundary.EMgetxyzobj(&EMmsg,
                                                     EMSlcopt_existingmsc,
                                                     NULL, NULL, NULL,
                                                     NULL, NULL,
                                                     OM_Gw_current_OS, &mscobj),
               senderid = edgeid,
               targetid = edgeid);
 if(!(1 & sts & EMmsg)) goto wrapup;

 /* Copy the msc 
  */
 sts = om$send(msg = message GRgraphics.GRcopy(&EMmsg, srf_env, new_env, 
		&curveid.objid), targetid = mscobj, senderid = NULL_OBJID, 
		targetos = srf_env->md_id.osnum);
 if(!(1&EMmsg&sts)) goto wrapup;

 /* Load new symbology
 */
 if(const_list->display)
  {
   struct GRsymbology symb;
   
   symb.level = const_list->level;
   symb.display_attr = *(const_list->display);
   loc_sts = om$send(msg = message GRvg.GRputsymb(&loc_EMmsg, &symb), 
	 senderid = NULL_OBJID, targetid = curveid.objid, 
	 targetos = curveid.osnum);
  }


 EMSsubbs_get_locate_window(&window_id.objid, &window_id.osnum);

 /* get the so table that has the info about the original object */
 DEget_soo ( &soo.objid,
             &soo.osnum,
              srf_env->md_id.osnum);

 if (soo.objid == NULL_OBJID)
 {
  count = 0;
 }
 else
 {
  sts = gr$get_active_display( buffer = &orig_ele_attr );

  sts = om$send ( msg = message DEso.DEget (
                             &loc_EMmsg,
                             &types,
                             &boundary_parms,
                             &count,
                             &display_attributes,
                             &orig_ele_attr,
                              mscobj,
                              window_id.objid,
                             &srf_env->md_env.matrix_type,
                              srf_env->md_env.matrix,
                              0,
                              1 ),
                  senderid = soo.objid,
                  targetid = soo.objid,
                  targetos = soo.osnum );
  if(!(1 & sts)) 
  {
    pwDebugLine (PW_K_DebugWarning, "EMcpmscs20: Bad SOO table\n");
    goto wrapup;
  }

  /* Now get the so table for the msc's object space (it could be different if
     copying from a reference file to the master file, for instance).  This
     macro will create a soo in the new space if one doesn't already exist. */

  de$create_soo(msg = &loc_EMmsg,
                p_objid = &soo.objid,
                osnum = (soo.osnum = new_env->md_id.osnum));
  if(!(1 & loc_EMmsg)) 
  {
    pwDebugLine (PW_K_DebugWarning, "EMcpmscs20: Create SOO failure\n");
    goto wrapup;
  }

  for ( i=0; i<count; i++ )
  {
    sts = om$send ( msg = message DEso.DEadd (
                             &loc_EMmsg,
                              types [i],
                              curveid.objid,
                              boundary_parms [i*2],
                              boundary_parms [i*2+1],
                             &display_attributes [i],
                             &window_id,
                              NULL_INDEX,
                              new_env,
                              NULL_INDEX ),
                    senderid = soo.objid,
                    targetid = soo.objid,
                    targetos = soo.osnum );
    if(!(1 & sts & loc_EMmsg)) 
    {
      pwDebugLine (PW_K_DebugWarning, "EMcpmscs20: Add SOO failure\n");
      continue;
    }
  }
 }

 if(const_list->class_attr)
  {
   struct IGResbc *element_specific;
   
   element_specific = (struct IGResbc *) const_list->class_attr;
   loc_sts = om$send(msg = message GRvg.GRputattr
	 (&loc_EMmsg, (IGRchar *)element_specific), 
	 senderid = NULL_OBJID, targetid = curveid.objid, 
	 targetos = curveid.osnum);
  }

 /* Add the new object to active owner
 */
 loc_sts = gr$add_to_active_owner(msg = &loc_EMmsg, mod_env = new_env, 
		objid = curveid.objid, osnum = curveid.osnum);

 if( curve_info->curves && !(*(curve_info->buf_size)))
  {
   if( *(curve_info->curves))
    *(curve_info->curves) = (struct GRid *)
			    om$realloc(ptr = (IGRchar *)(*(curve_info->curves)), 
			    size = (*(curve_info->num_curves) + CURVE_BUF_INC)
			        * sizeof(struct GRid));
   else *(curve_info->curves) = (struct GRid *)
				om$malloc(size = CURVE_BUF_INC * 
				sizeof(struct GRid));
   *(curve_info->buf_size) = CURVE_BUF_INC;
   if(!(*(curve_info->curves))) {EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

  }

 if(curve_info->curves)
  {
   (*(curve_info->curves))[*(curve_info->num_curves)] = curveid;
   (*(curve_info->num_curves))++;
   (*(curve_info->buf_size))--;
  }

/*
 if(! count)
  {
    short action = 0, property = DEHAS_OVERRIDE;
    
       clear the DEHAS_OVERRIDE bit for this msc copy 
    sts = om$send ( msg = message GRgraphics.GRchgprops ( &loc_EMmsg,
                                                          &action,
                                                          &property ),
                    senderid = curveid.objid,
                    targetid = curveid.objid,
                    targetos = curveid.osnum );
 }
 */

wrapup:

/* In case of any problem, invoke EMmake_surface_curves().
*/
if(!(1&EMmsg&sts))
/***********************************************************************
  sts = EMmake_surface_curves(curve, curve_info, invoker_info);
***********************************************************************/
  sts = ems$make_surface_curves(curve = curve,
                                curve_info = curve_info,
                                invoker_info = invoker_info); 
return(sts);

}

end implementation EMSsubbs;
