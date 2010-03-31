/* ###################   APOGEE COMPILED   ################## */
/*
Notes
  The following function, accepts a curve geometry, constructs a curve
  object (or uses the supplied shell objid) and applies the supplied
  message if any to that curve. If a new object is constructed it returned
  via the supplied pointer.

  For the structure EMScurveinfo see the file old_include/emssfcvs.h

History
	20_jan-88	SM	Creation.
	04-Feb-88	SM	Modified so that if an order 2 curve is
				to be constructed, it will happen through
				Richard's function EFplace_linestring
				which takes into account the number of points
				and places line string/segment/point
				accordingly.
	02-Jun-88	SM	Modified to construct intelligent curves
				if the edge type is passed in.
        03-Mar-89       PP      Modified the code to the minimal possible
                                extent to correct potential zinger problems
                                while plotting curves which claim to
                                be either a linestring, point or a linesegment
                                and are of order > 2 and rational. In such
                                a case the same are constructed as bspline
                                curves.
	23-Jul-89	SM	Modified to handle also the converse of above
				i.e a curve of order 2 claiming to a a non
				linear curve. This can potentially
				happen if the edge types of linear edges
				are not consistent with their xyz
				geometry.
	22-Sep-89	SM	Modified PP's fix to use EFisEdgeTypeLinear()
				instead of explicit checks for all linear
				classes.
	14-Feb-90	SM	If a boundary causes problems, continue with
				the next, instead of aborting.
	22-Mar-90	SM	Added function EMcopy_mscs().
        27-Aug-92       NP      Modified for ANSI compliance.
        6-july-93	Sudha   Modified for BSprototypes ansification
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

#include "bsunwght_p.h"
#include "bsactivsplt.h"

extern OMuword OPP_GR3dlinestr_class_id, OPP_GRbcsubbc_class_id, 
	       OPP_GR3dlineseg_class_id, OPP_GR3dpoint_class_id;
	
#define DEBUG	0

#if DEBUG
#define STATIC_BUF_SIZE	10
#define CURVE_BUF_INC 1
#else
#define STATIC_BUF_SIZE 100
#define CURVE_BUF_INC 20
#endif

%safe
static IGRint EMmake_surface_curves_without_boundaries();
%endsafe

IGRint EMmake_surface_curves(curve, curve_info, invoker_info)
  struct IGRbsp_curve	*curve;
  struct EMScurveinfo	*curve_info;
  struct EMSinvoker_info *invoker_info;
{
   IGRlong		EMmsg;
   struct IGRbsp_curve	part_curve;
   IGRdouble		static_part_buffer[STATIC_BUF_SIZE], *part_buffer;
   IGRint		num_doubles, pole_dimension, i;
   BSrc			rc;
   IGRboolean		test_planar = TRUE;
   IGRdouble		from_par, to_par, *loc_poles, *save_poles, *save_wts;
   IGRuchar	loc_curve_type, *curve_type;

   EMmsg = EMS_S_Success;
   part_buffer = static_part_buffer;
   loc_poles = NULL;
   save_poles = NULL;
   save_wts = NULL;
   curve_type = invoker_info->cvtype;

   /* If the curve is second order rational then unweight the poles and
      treat the curve as non rational hereafter. The unweighting is done
      in a local buffer to keep the incoming curve intact. The
      unweighting is required because for order 2 curves, the IGE plot code
      assumes non-rational geometry.
   */
   if( (curve->order == 2) && curve->rational && curve->weights)
    {
	IGRint	size = curve->num_poles * 3 * sizeof(IGRdouble);
	IGRboolean loc_sts;
	
       loc_poles = (IGRdouble *) om$malloc(size = size);
       if(!loc_poles) {EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
       (void) BSunwght_p(&rc, curve->poles, curve->weights, 
				 &curve->num_poles, loc_poles);
       if(rc!= BSSUCC) {EMmsg = EMS_E_BSerror; goto wrapup;}
       save_poles = (IGRdouble *) curve->poles;
       curve->poles = (IGRdouble *) loc_poles;
       curve->rational = FALSE;
       save_wts = (IGRdouble *) curve->weights;
       curve->weights = NULL;
    }

   if(curve->num_boundaries)
    {
     /* If the curve has boundaries then extract each piece out and plot
	it seperately.
     */
     if(curve->rational) pole_dimension = 4;
     else pole_dimension = 3;
     num_doubles = curve->num_poles * pole_dimension;
     num_doubles += curve->num_knots;
     if(curve_type)
	EFget_clipped_edge_type(&EMmsg, *curve_type, &loc_curve_type);

     /* If the static buffer is not large enough then malloc memory once
	and reuse it for each part curve.
     */
     if(num_doubles > STATIC_BUF_SIZE)
      {
        part_buffer = (IGRdouble *)
          om$malloc(size = num_doubles * sizeof(IGRdouble));
        if(! part_buffer) { EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
      }

      /* Partition the part_buffer of doubles to hold poles, knots and
	 weights. The number of these is considered to be that in the full
	 curve (maximum).
      */
      part_curve.poles = part_buffer;
      part_curve.knots = part_curve.poles + (curve->num_poles * 3);
      if(curve->rational)
        part_curve.weights = part_curve.knots + curve->num_knots;
      else part_curve.weights = NULL;

      part_curve.num_boundaries = 0;
      part_curve.bdrys = NULL;

      for(i=0; i< 2*curve->num_boundaries; i++)
       {
         /* Check and extract the section begining at 0.0
         */
          if(!i)
           {
	     if(curve->bdrys[i] == 0.0) continue;   /* hole starting at 0 */
	     from_par = 0.0;
	     to_par = curve->bdrys[0];
	   }
	
	 /* Check and extract the section at the end.
	 */
	  else if( i == (2 * curve->num_boundaries - 1))
	   {
	     if(curve->bdrys[i] == 1.0) continue; /* Hole ending at 1 */
	     from_par = curve->bdrys[i];
	     to_par = 1.0;
	   }
	
	  /* extract the internal portion of the curve
	  */
	  else
	   {
	     from_par = curve->bdrys[i];
	     to_par = curve->bdrys[i+1];
	     i++;  /* Increment i to indicate middle extraction */
	   }
	
	 /* Extract the active part of the curve 
	 */
	 (void)BSactivsplt(&rc, curve, &from_par, &to_par, &part_curve, 
			   &test_planar);
	 if(rc != BSSUCC) {EMmsg = EMS_S_Success; continue;}
		
	/* Plot the extracted piece
	*/
         EMmsg = EMmake_surface_curves_without_boundaries
			(&part_curve, curve_info, curve_type ? &loc_curve_type
							     : FALSE);
	 EMmsg = EMS_S_Success;
							
        } /* for(i=0; i< 2*curve->num_boundaries; i++) */

    } /* if(curve->num_boundaries) */

   else
     EMmsg = EMmake_surface_curves_without_boundaries
					(curve, curve_info, curve_type);

wrapup:

  if(part_buffer && (part_buffer != static_part_buffer))
    om$dealloc(ptr = part_buffer);

  if(save_poles) 
   {
    curve->poles = (IGRdouble *) save_poles;
    curve->rational = TRUE;
    curve->weights = (IGRdouble *) save_wts;
    if(loc_poles) om$dealloc(ptr = loc_poles);
   }

  return(EMmsg);
}

static IGRint EMmake_surface_curves_without_boundaries(curve, curve_info, 
						       curve_type)
  struct IGRbsp_curve	*curve;
  struct EMScurveinfo	*curve_info;
  IGRuchar	*curve_type;
{

  IGRlong			sts, EMmsg, loc_sts;
  IGRlong			*counter, loc_counter = 0;
  struct GRid			curveid;
  struct GRpost_info		post_info;
  GRobjid			newobjid;
  OMuword			crv_classid;
  OM_p_MESSAGE			crv_messg;
  IGRlong			EFget_classid_for_an_edge_type();

  sts = OM_S_SUCCESS;
  EMmsg = EMS_S_Success;

  post_info.construct_flag = FALSE;

  /* Decide what kind of curve we are dealing with.
  */
  if(curve->order == 2)
   { 
     curveid = curve_info->linestr; 
     counter = &curve_info->linestr_counter;
     sts = OM_E_NOSUCHCLASS;
     if(curve_type)
       sts = EFget_classid_for_an_edge_type (&crv_classid, *curve_type);

     /* If there is an error finding the classid, or if the curve type is
	not passed in or if the curve having order 2 is claiming to a non
	linear curve, set the default curve classid as 3d linestring.
     */
     if(!(1&sts) || (curve_type ? !EFisEdgeTypeLinear(*curve_type) : NULL)) 
      {crv_classid = OPP_GR3dlinestr_class_id; sts = OM_S_SUCCESS;}
     crv_messg = (OM_p_MESSAGE) curve_info->messg_linestr;
   } 
  else
   {
     curveid = curve_info->gencrv; 
     counter = &curve_info->gencrv_counter;
     sts = OM_E_NOSUCHCLASS;   

     if(curve_type) 
      sts = EFget_classid_for_an_edge_type (&crv_classid, *curve_type);
     if(!(1&sts))
      {crv_classid = OPP_GRbcsubbc_class_id; sts = OM_S_SUCCESS;}
	
     /*
      * If the curve is claiming to be a linesegment/point/linestring and its
      * order is greater than 2 then construct the same as a bspline curve. 
      * pp (03/31/89)
      */

     if ( (curve_type ? EFisEdgeTypeLinear(*curve_type) : NULL) 
          && (curve->order > 2))
      crv_classid = OPP_GRbcsubbc_class_id;

     /* end pp */

     crv_messg = (OM_p_MESSAGE) curve_info->messg_gencrv;
   }

  /* If curve object is not supplied and it is to be constructed and
     returned, do memory allocations if necessary.
  */

  if(IF_NULL_OBJID(curveid.objid))
   {
     if( curve_info->curves && !(*(curve_info->buf_size)))
      {
	if( *(curve_info->curves))
	 *(curve_info->curves) = (struct GRid *)
			om$realloc(ptr = (IGRchar *)(*(curve_info->curves)), 
			 size = (*(curve_info->num_curves) + CURVE_BUF_INC)
			        * sizeof(struct GRid));
	else *(curve_info->curves) = (struct GRid *)
			om$malloc(size = CURVE_BUF_INC * sizeof(struct GRid));
	*(curve_info->buf_size) = CURVE_BUF_INC;
      }
	curveid.osnum = curve_info->construct_list->env_info->md_id.osnum;
	counter = &loc_counter; 

   } /* if(IF_NULL_OBJID(curveid.objid)) */

  /* counter in the arglist indicates whether the objid in question was
	already used once before or not.
  */

  if(*counter)
   {
     sts = om$send(msg = message GRvg.GRpostabsg
			(&EMmsg, curve_info->construct_list->env_info, 
			 &post_info, (IGRchar *)curve, &newobjid), 
		senderid = curveid.objid, 
		targetid = curveid.objid, 
		targetos = curveid.osnum);
     if(!(1&EMmsg&sts)) goto wrapup;
   }

  else  /* curve has to be initialized */

   {
	IGRchar		*save_geom;
	
     /* construct object only if it is a general curve. If order 2
	go through Richard's function EFplace_line_string.
     */

     if(IF_NULL_OBJID(curveid.objid))    /* No curve supplied-construct*/
      {
	 if( (crv_classid != OPP_GR3dlineseg_class_id) &&
	     (crv_classid != OPP_GR3dlinestr_class_id) &&
	     (crv_classid != OPP_GR3dpoint_class_id)
	   )
	  {
            sts = om$construct(classid = crv_classid, 
	     	      osnum = curveid.osnum, p_objid = &curveid.objid);
            if(!(1&sts)) goto wrapup;
            save_geom = (IGRchar *) curve_info->construct_list->geometry;
            curve_info->construct_list->geometry = (IGRchar *) curve;
            *(curve_info->construct_list->msg) = EMS_S_Success;

            sts = om$send(msg = message GRgraphics.GRconstruct
			(curve_info->construct_list), 
		senderid = curveid.objid, 
		targetid = curveid.objid, 
		targetos = curveid.osnum);
           if(!(1& *(curve_info->construct_list->msg) & sts))
	   { EMmsg = EMS_E_Fail; goto wrapup;}
           curve_info->construct_list->geometry = (IGRchar *) save_geom;

          } /* if(crv_classid == OPP_GRbcsubbc_class_id) */
        
         else
	  {
 	    sts = EFplace_line_string(NULL_OBJID, curve_info->construct_list, 
				     curve->num_poles, curve->poles, 
				     &curveid.objid, &EMmsg); 
	   if(!(1&EMmsg)) goto wrapup;
	  }
	
      }  /* if(IF_NULL_OBJID(curveid.objid)) */

     else  /* curve supplied - initialize it with geometry */
      {
        save_geom = (IGRchar *) curve_info->construct_list->geometry;
        curve_info->construct_list->geometry = (IGRchar *) curve;
        *(curve_info->construct_list->msg) = EMS_S_Success;

        sts = om$send(msg = message GRgraphics.GRconstruct
			(curve_info->construct_list), 
		senderid = curveid.objid, 
		targetid = curveid.objid, 
		targetos = curveid.osnum);
        if(!(1& *(curve_info->construct_list->msg) & sts))
          { EMmsg = EMS_E_Fail; goto wrapup;}
        curve_info->construct_list->geometry = (IGRchar *) save_geom;
      }

     if(curve_info->curves)
      {
       (*(curve_info->curves))[*(curve_info->num_curves)] = curveid;
       (*(curve_info->num_curves))++;
       (*(curve_info->buf_size))--;
      }

   }  /* if(*counter) */

  /* Send the message to the curve if supplied */

   if(crv_messg)
    {
      sts = om$send(msg = crv_messg,
		senderid = curveid.objid, 
		targetid = curveid.objid, 
		targetos = curveid.osnum);
      if(!(1&EMmsg&sts)) goto wrapup;
    }

   (*counter)++;

   loc_sts = GRabsg_del_by_objid(&curveid.objid, &curveid.osnum);

wrapup:
  if(!(1&sts)) EMmsg = EMS_E_Fail;
  return(EMmsg);
}

#include "EMSobjmgrdef.h"
#include "grownmacros.h"                /* For gr$add_to_active_owner */

IGRint EMcopy_mscs(curve, local_info, invoker_info)
struct IGRbsp_curve 	*curve;
struct EMSwireframe_mscinfo *local_info;
struct EMSinvoker_info *invoker_info;
{
 IGRlong		sts, EMmsg, loc_sts, loc_EMmsg;
 struct EMScurveinfo	*curve_info;
 struct GRmd_env	*srf_env, *new_env;
 GRobjid		mscobj, msc_copy, edgeid;
 extern IGRlong 	EMmanipentry();
 struct GRid		curveid;
 extern IGRint          EMmake_surface_curves();
 IGRuchar	*curve_type;
 struct GRvg_construct	*const_list;
 OM_S_CHANSELECT	to_common;
 extern IGRint		EMmake_chanselect();

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
 EMmanipentry (&EMmsg, srf_env->md_id.osnum, EMScp_sfbdry, 
	       EMScpmanip_get | EMScpmanip_keywise, 1, &edgeid, &mscobj);
 if( (EMmsg == EMS_I_NotFound) || !(1&EMmsg))
  {
   OM_S_OBJECT_LINKAGE	comm;
   IGRuint		count;

   EMmake_chanselect(EMSedge_to_common_edge, &to_common);
   sts = om$get_channel_objects(objid = edgeid, osnum = srf_env->md_id.osnum, 
	 p_chanselect = &to_common, list = &comm, size = 1, count = &count);
   if(!count) goto wrapup;
   edgeid = comm.S_objid;
   /* Get the MSC of the edge
   */
   EMmanipentry (&EMmsg, srf_env->md_id.osnum, EMScp_sfbdry, 
	       EMScpmanip_get | EMScpmanip_keywise, 1, &edgeid, &mscobj);
   if( (EMmsg == EMS_I_NotFound) || !(1&EMmsg)) goto wrapup;
  }

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

wrapup:

/* In case of any problem, invoke EMmake_surface_curves().
*/
if(!(1&EMmsg&sts))
  sts = EMmake_surface_curves(curve, curve_info, invoker_info);
return(sts);

}

end implementation EMSsubbs;
