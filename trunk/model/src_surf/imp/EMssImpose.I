/* ###################   APOGEE COMPILED   ################## */
/*
 History    
    SM    Many Moons Ago       Design and Creation.

    SM	  06-Dec-88 Modified to allow imposition of trimmed boundaries
		    if the surface has one P loop. The validation
		    criterion for trimmed boundaries is -
		    1) Only one area (no disjoint areas)
		    2) Boundary closed wrt itself
		    if boundary is open it should have valid split points
		    on existing loopset (non dangling).
		    If a loop from existing loopset is split, it should have
		    even number of split points.
    SM	29-Feb-89   Added and supported the options EMImpBnd_NoStateTree
		    (include/emsimpdef.h). This option may be used by
		    applications wanting to impose boundaries without saving
		    history. Otherwise a compress tree was forced after the
		    operation was done.
		    Also added the argument curve_buffs. The input can now
		    be curve_buffs ^ object_information.
    SM	07-Mar-89   In case of error, clean up loops created here. Also fixed
		    a bug in outputting bad points for single area case due
		    to which endpoints of closed bdrys were being returned
		    as bad points.
    SM	28-Mar-89   Argument change in EMget_loops_for_imposition. Renamed
		    function as EMget_mapped_data().
    SM  13-Sep-89   Send EMSlinedge.EMsetIsoType message to all linear
		    edges after loops are constructed. This is to set
		    intelligent curve types for iso edges.
    SS  12-Oct-89   Added the notification stuff.
    mrm 06/11/91    Added active_state_arg to allow a state object to be
                    passed in.
    SM  11-Mar-92   Support option 'EMImpBnd_NoPrintError'
    NP  25-Aug-92   Modified for ANSI compliance. Added typecasts and changed 
                    "count" and "temp_cnt" to "IGRuint" from "IGRint".
    NP  13-Dec-93   Since we dont support the option 'EMImpBnd_NoPrintError' any
                    more, removed reference to it. The same functionality as 
                    'EMImpBnd_NoPrintError' can be achieved by setting the 
                    global variable "OM_Gf_verbose_warning" to FALSE
Note
	If the loopset has only one P loop it is eligible for imposition
of trimmed boundaries. In such a case validation is not performed in
EMget_loop_for_imposition but is posponed untill a later method
where more information is available and validation is cheaper. In any case, 
for invalid boundaries the output from this method remains the same.

*/

class implementation EMSsubbs;

#include "EMS.h"

#ifndef DEBUG
# define DEBUG 0
#endif
# if DEBUG
# include <stdio.h>
# endif

# include "bserr.h"
# include "EMSbnddef.h"
# include "emsimpdef.h"
# include "emsmapdef.h"
# include "EMSopt.h"
# include "EMSbnd.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "EMSprop.h"
# include "emssfint.h"
# include "msdef.h"
# include "msmacros.h"
# include "ECmsg.h"
# include "EMSssprops.h"
# include "EMStpmacros.h"
# include "EMSutlmacros.h"

from EMSloopset import EMimpose_boundaries, EMmake_natural_loopset, 
		       EMget_loops, EMget_props;
from EMSsfimpbnd import EMsfimpbnd_init;
from EMSdpr import EMputSSI;
from EMSsfregmod import EMprepare_ssi;
from EMSloop import EMget_props;
from EMSlinedge import EMsetIsoType;
from EMSgraloop import EMglpinit, EMupdate_feature;

extern void UI_status();
/*extern IGRint EMget_mapped_data();*/
extern void EMownercomp_free();
extern void BSsfeval();

extern OMuword OPP_EMSsfimpbnd_class_id, OPP_EMSsfdpr_class_id, 
	       OPP_EMSplane_class_id, OPP_EMSsfasplit_class_id, 
	       OPP_EMSsffea_class_id, OPP_EMSgraloop_class_id,
               OPP_EMSptgralp_class_id, OPP_EMSptedge_class_id;

method EMimpose_boundaries(
  IGRlong       	*EMmsg;
  IGRlong       	number_of_objects;
  struct IGRbsp_curve   curve_buffs[];
  struct GRlc_info 	object_information[];
  IGRdouble     	in_uv[2]; 
  IGRboolean		uv_in_area;
  struct GRmd_env 	*my_env;
  IGRlong      		*number_of_bad_points;
  IGRpoint      	**bad_points;
  IGRlong       	*number_of_bad_curves;
  IGRlong       	bad_curve_indices[];
  IGRint        	*num_sfloops;
  struct EMSownercomp   **sfloops;
  IGRint		*num_output_loops;
  GRobjid		**output_loops;
  IGRushort 	map_options, imp_options;
  OM_S_OBJID            *active_state_arg)
{
 IGRboolean		notify;
 IGRlong        	num_bytes, msg_loc, rc, sts,i;
 IGRdouble      	parametric_tolerance;
 struct         	IGRbsp_surface *surface;
 struct EMSpartolbasis 	partolbasis;
 union EMSssi_table	*ssibuff;
 IGRint			loc_num_output_loops,loc_num_sfloops, 
			num_imp_loops = 0, num_trim_info = 0;
 IGRuint		count=0;
 GRobjid		*loc_output_loops, new_state, *imp_loops = NULL;
 struct EMSownercomp	*loc_sfloops;
 OM_S_CHANSELECT     	to_loopset;
 struct GRid		active_state, my_GRid, working_ls;
 OMuword		my_classid;
 IGRushort	new_state_props;
 struct EMSsfintedpar	**trim_info;
 OM_S_OBJECT_LINKAGE	loopsetobj;
 IGRboolean		single_area = FALSE, nohist = FALSE;
 IGRboolean		areasplit = FALSE, features = FALSE;
 IGRuchar	edtype[4];
 IGRushort	edprops[4];

/*
 * Initialize
 */
 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 surface = NULL;
 if(number_of_bad_points) *number_of_bad_points = 0;
 if(bad_points) *bad_points = NULL;
 imp_loops = NULL;
 loc_output_loops = NULL;
 loc_sfloops = NULL;
 loc_num_output_loops = 0;
 loc_num_sfloops = 0;
 trim_info = NULL; 
 ssibuff = NULL;
 working_ls.objid = NULL_OBJID;
 nohist = imp_options & EMImpBnd_NoStateTree ? TRUE : FALSE;

 /* Following operations are supported -
 1) Regular boundary imposition with a point provided to indicate area/hole.
    Indicated by providing a point and neither of the options for 2 and 3.
 2) Auto nesting of closed boundaries, with the outermost boundary becoming
    the new area. No point is required.
    Indicated by the option EMImpBnd_AutoNest.
 3) Feature placement. No point is required.
    Indicated by the option EMImpBnd_PlaceFeatures.
 4) Area splitting. No point is required.
    Indicated by not providing the point and neither of the options for
    2 or 3.
 */
 features = imp_options & EMImpBnd_PlaceFeatures ? TRUE : FALSE;
 areasplit = !in_uv && !(imp_options & EMImpBnd_AutoNest) && !features ? TRUE 
								       : FALSE;
 notify = EMcheck_inhibit_postproc();

/************************************************************************** 
 EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
**************************************************************************/
 ems$make_chanselect (
          chan_label = EMSsubbs_to_loopset,
          chan_selector = &to_loopset);
 loopsetobj.S_objid = NULL_OBJID;

 sts = om$get_channel_objects(object = me, p_chanselect = &to_loopset, 
				list = &loopsetobj, size = 1, count = &count);
 EMerr_hndlr(!sts,*EMmsg,EMS_E_OMerror,wrapup);

/* If the surface has no loopset, create a natural loopset on it.
*/
 if(!count)
  {
   sts = om$send (msg = message EMSsubbs.EMmk_nat_bdry (
		EMmsg, &my_env->md_env, NULL), 
		targetid = my_id); 
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_SurfaceError,wrapup);

   sts = om$get_channel_objects(object = me, p_chanselect = &to_loopset, 
				list = &loopsetobj, size = 1, count = &count);
   EMerr_hndlr(!sts,*EMmsg,EMS_E_OMerror,wrapup);

   if(count && !(imp_options & EMImpBnd_DegenerateBdrys)) single_area = TRUE;
  }
 else if(!(imp_options & EMImpBnd_DegenerateBdrys) && !features)
  {
/**************************
   IGRint		depth = MAXINT;
   count = 0;
   sts = om$send(msg = message EMSloopset.EMget_loops(EMmsg, EMS_OPT_PLOOP, 
				&depth, NULL, NULL, NULL, (IGRint *)&count), 
			p_chanselect = &to_loopset);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_SurfaceError,wrapup);
   if(count == 1) single_area = TRUE;
***************************/
   single_area = TRUE;
  }

 if(single_area || features)
   working_ls.objid = loopsetobj.S_objid;
 else
  {
   sts = om$construct(classid = OPP_EMSloopset_class_id, 
                    p_objid =&working_ls.objid,  
                    msg = message EMSloopset.EMmake_natural_loopset
                          (EMmsg, NULL, NULL, NULL));
 
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
  }
 
 working_ls.osnum = OM_Gw_current_OS;
 
/*
 * Get my abstract data
 */
 if (map_options & EMMapBnd_WantStatMsg) 
  ex$message(msgnumb = EMS_I_GettingSurfaceData)
 sts = om$send(mode = OM_e_wrt_object,
               msg = message EMSsubbs.GRgetsize(
                &msg_loc,
                &my_env->md_env.matrix_type, 
                my_env->md_env.matrix, 
                &num_bytes),
               senderid = my_id,
               targetid = my_id);
 EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_Fail,wrapup);

 surface = (struct IGRbsp_surface *) alloca(num_bytes);

 EMerr_hndlr(!surface,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);

/* Get the surface geometry.
*/
 sts = om$send(mode = OM_e_wrt_object,
               msg = message EMSsubbs.GRgetgeom(
                &msg_loc,
                &my_env->md_env.matrix_type, 
                my_env->md_env.matrix, 
                (IGRchar *) surface),
               senderid = my_id,
               targetid = my_id);
  if (!(1 & sts)) goto wrapup;

/* Get the parametric tolerance for this surface.
*/
/***********************************************************************
 sts = EFsspbtol_by_geom(EMmsg, surface, &parametric_tolerance);
***********************************************************************/
 sts = ems$sspbtol_by_geom(
                       msg = EMmsg,
                      surface = surface,
                      partolbasis = &parametric_tolerance);
 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);

/*
 * Convert the input objects to loops
 */

 {
  IGRboolean            status;

  num_imp_loops = 0;

  /* If this is a plane or its subclass, set the appropriate bit on so 
     that mapping to uv space is optimised.
  */
  sts = om$get_classid(objid=my_id,
		      p_classid=&my_classid);
  if(!(1&sts)) goto wrapup;

  if(my_classid == OPP_EMSplane_class_id) map_options |= EMMapBnd_SurfIsPlane;
  else
   {
     sts = om$is_ancestry_valid(subclassid = my_classid, 
			    superclassid = OPP_EMSplane_class_id);
			
    if(sts == OM_S_SUCCESS) map_options |= EMMapBnd_SurfIsPlane;
   }
  if(single_area) map_options |= EMMapBnd_NoValidate;

  if( features )
     working_ls.objid = NULL_OBJID;

  {
   struct EMSgetlp_output	junk;
   struct EMSgetlp_badcrvinfo	badcrv;
   struct IGRpolyline		badpts;

   badpts.points = NULL;
   badpts.num_points = 0;
   badcrv.num = 0;
   badcrv.bad_indices = bad_curve_indices;
   junk.num_objs = 0;
   junk.objs = NULL;
/****************************************************************************
   status = EMget_mapped_data( number_of_objects, curve_buffs, 
    		object_information, NULL, surface, &parametric_tolerance, 
		my_env, 
		(bad_curve_indices && number_of_bad_curves) ? &badcrv : NULL,
		(bad_points && number_of_bad_points) ? &badpts : NULL, &junk,
    		NULL, working_ls, map_options, NULL, EMmsg);
****************************************************************************/
   status = ems$get_mapped_data(
                    number_of_objects = number_of_objects,
                       input_curves = (struct IGRbsp_curve **)curve_buffs,
                       object_information = object_information,
                       surface = surface,
                      partolbasis = &parametric_tolerance,
                     surfaceenv = my_env,
     bad_curves = (bad_curve_indices && number_of_bad_curves) ? &badcrv : NULL,
     bad_points = (bad_points && number_of_bad_points) ? &badpts : NULL,
                      out_loops = &junk,
                      clip_ls = working_ls,
                        opts = map_options,
                         msg = EMmsg);

  imp_loops = junk.objs;
  num_imp_loops = junk.num_objs;
  if(number_of_bad_curves) *number_of_bad_curves = badcrv.num;
  if(number_of_bad_points) *number_of_bad_points = badpts.num_points;
  if(bad_points) *bad_points = (IGRpoint *)badpts.points;
  if(!(1&*EMmsg)) goto wrapup;
 }
  if(!num_imp_loops) 
   {
#if DEBUG
     fprintf(stderr,"No valid boundaries to impose");
#endif
     *EMmsg = EMS_I_NoMoreLoops;
     goto wrapup;
   }
}

/* Set intelligent curve types for any iso edges that might have been
   constructed. Ignore errors returned from non linear edges.
*/
sts = om$send(msg = message EMSsubbs.EMget_natedge_info(EMmsg, &my_env->md_env,
				edtype, edprops), targetid = my_id);
if(1&*EMmsg&sts)
 {
  OM_S_CHANSELECT	to_edges;
/**************************************************************************
  EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);
**************************************************************************/
  ems$make_chanselect(
                chan_label = EMSbd_owner_to_comps,
                chan_selector = &to_edges);  

  for(i=0; i<num_imp_loops; i++)
    sts = om$send(msg = message EMSlinedge.EMsetIsoType(EMmsg, my_id, NULL, 
				&edtype[0], &edtype[1], TRUE), 
			senderid = imp_loops[i], p_chanselect = &to_edges);
  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
 }

 partolbasis.tol = parametric_tolerance;
 partolbasis.in_world = TRUE;
 partolbasis.is_valid = TRUE;
 partolbasis.mattyp = &my_env->md_env.matrix_type;
 partolbasis.mat = my_env->md_env.matrix;

 if(features)
  {
   GRobjid			new_feature, feature, **outlps = NULL;
   IGRushort		f_props = EMLP_ACTIVE;
   OM_S_CHANSELECT		to_edges;
   IGRint			*num_outlps;
/***********************************************************************
   sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
***********************************************************************/
   sts = ems$make_chanselect (
                  chan_label = EMSbd_owner_to_comps,
                  chan_selector = &to_edges);    
   if(nohist)
    {
     outlps = output_loops;
     num_outlps = num_output_loops;
    }
   else
    {
     outlps = &loc_output_loops;
     num_outlps = &loc_num_output_loops;
    }

   if(outlps)
    {
     *outlps = (GRobjid *) om$malloc(size = num_imp_loops * sizeof(GRobjid));
     EMerr_hndlr(!*outlps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     *num_outlps = 0;
    }

   {
     IGRuint              temp_cnt;
     OMuword              feature_class_id;
     OM_S_CHANSELECT      to_feature;
     OM_S_OBJECT_LINKAGE  feature_obj[1];

     for(i=0; i<num_imp_loops; i++)
     {
/*************************************************************************
       EMmake_chanselect( EMSbd_owner_to_comps, &to_feature );
*************************************************************************/
       ems$make_chanselect( 
                chan_label = EMSbd_owner_to_comps,
                chan_selector = &to_feature );
       feature_obj[0].S_objid = NULL_OBJID;

       sts = om$get_channel_objects( objid        =  imp_loops[i],
                                     p_chanselect = &to_feature,
                                     list         =  feature_obj,
                                     size         =  1,
                                     count        = &temp_cnt );

       sts = om$get_classid( osnum     =  feature_obj[0].osnum,
                             objid     =  feature_obj[0].S_objid,
                             p_classid = &feature_class_id );
  
       sts = om$is_ancestry_valid( subclassid = feature_class_id,
                                   superclassid = OPP_EMSptedge_class_id );

       if( sts == OM_I_INVANCESTRY )
       {
          sts = om$construct( classid = OPP_EMSgraloop_class_id, 
                              p_objid = &feature );
       }
       else
       {
          sts = om$construct( classid = OPP_EMSptgralp_class_id, 
                              p_objid = &feature );
       }
			
       sts = om$send(msg = message Root.move_chan(to_edges, imp_loops[i],
                             OM_Gw_current_OS, to_edges),
                       targetid = feature, senderid = imp_loops[i]);
       EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

       sts = om$send(msg = message EMSgraloop.EMglpinit( EMmsg, 
                                                         f_props, 
                                                        &partolbasis, 
                                                         my_id ), 
                       targetid = feature);
       EMerr_hndlr (!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
       new_feature = NULL_OBJID;
       sts = om$send(msg = message EMSgraloop.EMupdate_feature
  			                     (EMmsg, 
                                             &my_env->md_env.matrix_type,
                                              my_env->md_env.matrix), 
                     targetid = feature);
       EMerr_hndlr (!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

       if(*EMmsg == EMS_I_InAreaTrim) new_feature = feature;

       sts = om$send(msg = message Root.delete(TRUE), 
  			 targetid = imp_loops[i]);
    
       if(!IF_NULL_OBJID(new_feature) && outlps) 
        (*outlps)[(*num_outlps)++] = new_feature;

     }
  }
  } /* if(features) */
 else
  {
   /* Impose the loops on the surface
   */
   sts = om$send(msg=message EMSloopset.EMimpose_boundaries(EMmsg,
          imp_loops, num_imp_loops, in_uv, uv_in_area, 
	  nohist ? output_loops : &loc_output_loops,
	  nohist ? num_output_loops : &loc_num_output_loops, 
	  &trim_info, &num_trim_info, 
	  nohist ? num_sfloops : &loc_num_sfloops, 
	  nohist ? sfloops : &loc_sfloops, 
	  &partolbasis, my_env, &working_ls.objid, imp_options),
          p_chanselect=&to_loopset);
   if(single_area && (*EMmsg == EMS_E_IntersectTrim) && num_trim_info &&
      bad_points && number_of_bad_points && (num_trim_info == num_imp_loops))
    {
     IGRint	i, j;
      
     /* Maximum number of bad points = 2 * num_trim_info */
     if (*bad_points)
      *bad_points = (IGRpoint *) om$realloc(ptr = (IGRchar *)*bad_points, 
			size = sizeof(IGRpoint) * 
			(*number_of_bad_points + 2 * num_trim_info));
     else
      *bad_points = (IGRpoint *) om$malloc(size = sizeof(IGRpoint) *
					2 * num_trim_info);
     EMerr_hndlr(!*bad_points, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     for(i=0; i<num_trim_info; i++)
      {
       struct EMSsfintedpar *this_trim;
       IGRushort	props = NULL;

       sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &props), 
			targetid = imp_loops[i]);
       if((1&*EMmsg&sts) && !(props & EMLP_OPEN)) continue;

       this_trim = (struct EMSsfintedpar *) trim_info[i];
       for(j=0; j<2; j++)
        {
         if(this_trim && IF_NULL_OBJID(this_trim->edgeid))
          {
	   BSsfeval(surface, this_trim->point[0], this_trim->point[1], 0, 
		   (*bad_points)[*number_of_bad_points], &rc);
	   if(rc == BSSUCC) (*number_of_bad_points)++;
	  }
         if(this_trim) this_trim = this_trim->next;
        }
      }
     *EMmsg = EMS_I_NoMoreLoops;
     sts = OM_S_SUCCESS;
     goto wrapup;

    }/* if(single_area && (*EMmsg == EMS_E_IntersectTrim)) */

   else if( (*EMmsg == EMS_E_IntersectTrim) || (*EMmsg == EMS_E_InvalidArg))
	{sts = OM_S_SUCCESS; *EMmsg = EMS_I_NoMoreLoops; goto wrapup;}
   else if(!(1&*EMmsg&sts)) goto wrapup;

  } /* else for if(features) */

 if(!nohist)
  {
   /* Get the currently active state. If no state then I am the active
      state.
   */

   sts = om$send(msg = message EMSsurface.EMgetactiveid(
				EMmsg, &active_state, NULL), 
				targetid = my_id);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

   /*
    * Initialize the region modification table for the new state.
    */
   new_state_props = ME.GRgraphics->properties & (~GR_RIGID_RELATIONSHIP);

   if (active_state_arg && (*active_state_arg != NULL_OBJID))
   {
       new_state = *active_state_arg;
   }
   else
   {
       OMuword classid;

       if (areasplit)
           classid = OPP_EMSsfasplit_class_id;
       else if (features)
           classid = OPP_EMSsffea_class_id;
       else
           classid = OPP_EMSsfimpbnd_class_id;

       sts = om$construct(classid = classid, p_objid = &new_state);
       EMerr_hndlr(!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);
   }

   sts = om$send(msg = message EMSsfimpbnd.EMsfimpbnd_init
                      (EMmsg, active_state.objid, new_state_props),
                 targetid = new_state);

   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_OMerror, wrapup);

   /* Prepare the save state buffer.
   */

   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;

   sts = om$send(msg = message EMSsfregmod.EMprepare_ssi
			(EMmsg, trim_info, num_trim_info, 
			 loc_num_output_loops, loc_output_loops, 
			 loc_sfloops, 1, &my_GRid, &ssibuff), 
		targetid = new_state);
   EMerr_hndlr (!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

   sts = om$send (msg = message EMSdpr.EMputSSI (EMmsg, ssibuff), 
                      targetid = new_state);
   EMerr_hndlr (!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

   if ((active_state_arg) && (*active_state_arg == NULL_OBJID))
   {
       *active_state_arg = new_state;
   }

   if (notify)
     om$send (msg = message EMSsurface.EMpostgeomod (&msg_loc,
      EMS_POST_SAVEDSTATE, my_env, OPPmargs, NULL),
      targetid = active_state.objid);
  }
 else
  {
   if (notify)
     om$send (msg = message EMSsurface.EMpostgeomod (&msg_loc,
      NULL, my_env, OPPmargs, NULL), targetid = my_id);
  } 

 /* Update Rtree range.
 */
 if(my_env && (!IF_NULL_OBJID(my_env->md_id.objid)))
  {
   IGRuchar sfchange = GEOMETRICAL;
   IGRlong rc;
/*
 *
 *     The property EMSIS_RTREE_RANGE_GOOD should be used internally
 *     and should not be touched --- vidya 10/6/93
   om$send(msg = message EMSsubbs.EMset_props(&rc, EMSIS_RTREE_RANGE_GOOD, 
        EMS_O_OFF), targetid = my_id);
 */
   om$send(msg = message EMSsubbs.EMput_range_in_rtree(&rc, NULL, NULL, 
        NULL, sfchange, &my_env->md_id), targetid = my_id);
  }

wrapup:
 if (notify)
   EMrestore_postproc();
 if(!(1&*EMmsg&sts) || (*EMmsg == EMS_I_NoMoreLoops))
  {
   IGRint	dumsts, i;

   for(i=0; i<num_imp_loops; i++)
    dumsts = om$send(msg = message Root.delete(TRUE), targetid = imp_loops[i]);
  }

 if(imp_loops) om$dealloc(ptr=imp_loops);

 if(output_loops && loc_output_loops) 
	*output_loops = (GRobjid *) loc_output_loops;
 else if(loc_output_loops) om$dealloc(ptr = loc_output_loops);

 if(sfloops && loc_sfloops) *sfloops = (struct EMSownercomp *) loc_sfloops;
 else if(loc_sfloops) EMownercomp_free(loc_sfloops, NULL);

 if(num_sfloops && loc_num_sfloops) *num_sfloops = loc_num_sfloops;

 if(num_output_loops && loc_num_output_loops) 
  *num_output_loops = loc_num_output_loops;

 if (trim_info)
  {
   for (i = 0; i < num_trim_info; i++)
     EMsfintedpar_free(trim_info[i],2);
   om$dealloc(ptr = trim_info);
  }
 if(ssibuff) om$dealloc(ptr = ssibuff);
 if(!IF_NULL_OBJID(working_ls.objid) && !IF_EQ_OBJID(working_ls.objid, 
		loopsetobj.S_objid))
  sts = om$send(msg = message Root.delete(TRUE), targetid = working_ls.objid);

 EMWRAPUP(*EMmsg,sts,"In EMSsubbs.EMimpose_boundaries");
 return(sts);
}



end implementation EMSsubbs;
