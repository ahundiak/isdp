/*
  DESCRIPTION

    This method returns the appropriate offset object. Currently it only
    handles solids which are the result of capping a surface of projection,
    surface of revolution:

    Surface of projection solid:
      It assumes that the characteristic object/composite is on the zeroth
      index of the "to_comps" channel. Also, that the capping plane at the
      "start" is on the index=2 and the "stop" is on index=1. Sometimes
      one or both the capping planes may be removed from the channel during
      say a Boolean op. In this case the solid's projection vector is
      obtained and using dot-products the remaining capping planes are
      determined to be the start or the stop ones. If the capping planes are
      in the list of surfaces to be not-offset, then the appropriate action
      is taken while specifying the offset.
    Surface of revolution solid:
      There are two kinds of such solids. One with closed profiles whose
      start and sweep angle can be other than 0 and 360. The other with
      open profiles where the start and sweep are 0 and 360, regardless.
      Currently, only the latter is fully supported. In this latter case,
      there are at most two caps, one at the begginning of the curve and
      and the other at the end. These two caps are at index=1 or at
      index=2, respectively. If any of the ends is on the axis no corresponding
      caps are produced. So if the channel count = 2, the there is a problem
      trying to determine which end corresponds. This problem is solved
      by taking an end-point of the curve and determining if it lies on
      the plane. If the capping planes are in the list of surfaces to be
      not-offset, then the appropriate action is taken while specifying the
      offset.
    Drafted surface solid:
      Structure similar to that of 'Surface of projection solid' above.

  HISTORY:

    SS   :  ??/??/92  :  Creation
   ashok :  09/21/92  :  Added code to support solid of revolution created
		         by sweeping closed profile by less than 360 degrees.
   S'kar :  12/01/93  :  Added code to support drafted solid created by
                         drafting a closed profile.
 sampath : 01/12/93   :  added code to handle other type of solids ( solids 
			 other than projected solids , 
			 solids of revolution and drafted solids . )
 sampath : 01/18/93   :  Modified 'EMoffset' arguments for Phoenix
			 'offset surface'.
   S'kar : 01/20/93   :  Forced to do composite surface offset.
   S'kar : 03/29/93   :  Added a new option to indicate that the surface to be
                         offset belongs to an 'sfsolid'.
  Sudha  : 07/01/93   :  Modified for BSprototypes ansification
 Sudhakar: 09/02/93   :  Modified "OPP_EMScompsurf_class_id" to
                         "OPP_EMSsurface_class_id" to handle 'EMSsfsolid's
                         constructed from simple surfaces.
 Sudhakar: 09/08/93   :  Modified code to call the 'general' algorithm 
                         if either the special algo's fail
                            or  no special algo exists for the class of object.
 Sudhakar: 01/28/94   :  Modified to not invoke the general algorithm if the
                         "EMS_opt_offsetS_special_algo_only" option is set. 
*/

class implementation EMSsfsolid;

#include "bserr.h"
#include "bsparameters.h"
#include "gr.h"
#include "emssfint.h"
#include "bsdotp.h"
#include "bsdistptpl.h"

#define X 0
#define Y 0
#define Z 0

#define START  0
#define STOP   1

#define FIRST  0
#define SECOND 1

#define PROJ_CRV   0
#define PROJ_DIST  1
#define PROJ_VEC   2

#define REV_CRV	   0
#define REV_BASE   1
#define REV_DIR    2
#define REV_START  3
#define REV_SWEEP  4

#define UNKNOWN_SOLID -1
#define PROJECT_SOLID  0
#define REVOLVE_SOLID  1
#define DRAFTED_SOLID  2
#define COMP_SURF      3

extern GRclassid OPP_EMSproject_class_id, OPP_EMSprjcompsf_class_id;
extern GRclassid OPP_EMSrevol_class_id, OPP_EMSrevcompsf_class_id;
extern GRclassid OPP_EMAproject_class_id, OPP_EMArevol_class_id;
extern GRclassid OPP_EMSplane_class_id;
extern GRclassid OPP_EMSgencompsf_class_id;
extern GRclassid OPP_EMSgenbs_class_id, OPP_EMAgenbs_class_id;
extern GRclassid OPP_EMSsfsolid_class_id;
extern GRclassid OPP_EMSsurface_class_id;

from EMSparamgm import EMgetgeom;
from GRcurve import GRendpts;
from expression import NDgive_value;

method EMoffset (IGRlong *msg; IGRushort options;
                 IGRshort *mattyp; IGRmatrix mat;
                 struct GRvg_construct *const_args;
                 IGRboolean offset_inward;
                 IGRdouble thickness;
		 IGRint num_spec_thick;
		 IGRdouble *val_spec_thick;
		 struct GRobjid_set *spec_thick_sf_sets;
                 IGRint num_nooffsetsfs; GRobjid *nooffsetsfs;
                 IGRchar status_str[];
                 GRobjid *offsetobj;
		 struct EMSerror_help *errkeylist)
{
  IGRboolean found, negative_solid;
  IGRint i, j, solid_type;
  OMuint count;
  IGRlong msg_loc, stat_OM;
  IGRdouble *param_vec, chttol, dist, rev_sweep;
  IGRpoint plane_pt, endpts[2];
  IGRvector solid_side_vec;
  GRclassid objclass;
  GRclassid solid_class;

  GRobjid offset_comp, charact_obj, caps[2];
  GRspacenum dumos;
  struct GRid compid;
  struct EMSgeomdata geomdata;
  OM_S_CHANSELECT chan_to_comps, chan_to_parents;
  OM_S_OBJECT_LINKAGE complist[3];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *offsetobj = NULL_OBJID;

  negative_solid = options & EMS_opt_offsetS_negative ? TRUE : FALSE;

  /*
   * Obtain the specific type of surface-solid this is
   */

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  charact_obj = NULL_OBJID;
  om$get_objid_at_index (object = me, p_chanselect = &chan_to_comps,
   index = FIRST, objidaddr = &charact_obj, osnumaddr = &dumos);

  om$get_classid (objid = charact_obj, p_classid = &objclass);

  om$get_classid (objid = my_id, p_classid = &solid_class);

  if (objclass == OPP_EMSproject_class_id || 
      objclass == OPP_EMAproject_class_id ||
       objclass == OPP_EMSprjcompsf_class_id)
    solid_type = PROJECT_SOLID;
  else if (objclass == OPP_EMSrevol_class_id ||
           objclass == OPP_EMArevol_class_id ||
            objclass == OPP_EMSrevcompsf_class_id)
/*
            objclass == OPP_EMStorus_class_id ||
            objclass == OPP_EMAtorus_class_id)
*/

    solid_type = REVOLVE_SOLID;

  else if ((objclass == OPP_EMSgencompsf_class_id ||
              objclass == OPP_EMAgenbs_class_id ||
              objclass == OPP_EMSgenbs_class_id)  && 
             solid_class == OPP_EMSsfsolid_class_id)
    solid_type = DRAFTED_SOLID;

  else if (om$is_ancestry_valid (subclassid = objclass,
	      superclassid = OPP_EMSsurface_class_id) == OM_S_SUCCESS)
    solid_type = COMP_SURF;
  else
    solid_type = UNKNOWN_SOLID;

  /*
   * Depending on the type of the solid, special action is taken.
   */

  switch (solid_type)
    {
    case PROJECT_SOLID:

      if (num_nooffsetsfs)
        {
        caps[START] = caps[STOP] = NULL_OBJID;
        count = 0;
        om$get_channel_objects (object = me, p_chanselect = &chan_to_comps,
         count = &count, size = 3, list = complist);
        if (count == 3)
          {
          caps[START] = complist[2].S_objid;
          caps[STOP] = complist[1].S_objid;
          }
        else if (count && count < 3)
          {
          EMmake_chanselect (NDfather_father, &chan_to_parents);
          stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc,
                     NULL, mattyp, mat, &geomdata),
                     p_chanselect = &chan_to_parents,
                     from = PROJ_VEC, to = PROJ_VEC);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc) ||
           geomdata.geomtype != GEOMDATA_VECTOR, *msg, EMS_E_InvalidCase,
           ret_end);
          param_vec = geomdata.vector;

          for (i=0; i<count; i++)
            {
            compid.objid = complist[i].S_objid;
            compid.osnum = OM_Gw_current_OS;
            om$get_classid (objid = compid.objid, p_classid = &objclass);
            if (om$is_ancestry_valid (subclassid = objclass,
                 superclassid = OPP_EMSplane_class_id) == OM_S_SUCCESS)
              {
              stat_OM = EMgetorntnrm (&msg_loc, NULL, mattyp, mat, &compid,
                         0.5, 0.5, plane_pt, solid_side_vec);
              EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
               ret_end);

              if ((BSdotp (&msg_loc, param_vec, solid_side_vec) > 0.0) ^
                  negative_solid)
                caps[START] = compid.objid;
              else
                caps[STOP] = compid.objid;
              }
            }
          }
        }

      for (i=START; i<=STOP; i++)
        {
        found = FALSE;
        for (j=0; j<num_nooffsetsfs; j++)
          if (caps[i] == nooffsetsfs[j])
            {
            found = TRUE;
            break;
            }

        if (found && offset_inward ^ negative_solid)
          {
          if (i == START)
            options |= EMS_opt_offsetS_extend_start | 
                        EMS_opt_offsetS_by_delta_at_start;
          else
            options |= EMS_opt_offsetS_extend_stop | 
                        EMS_opt_offsetS_by_delta_at_stop;
          }
        else if (!found)
          {
          if (i == START)
            options |= offset_inward ^ negative_solid ?
                        EMS_opt_offsetS_shorten_start :
                        EMS_opt_offsetS_extend_start;
          else
            options |= offset_inward ^ negative_solid ?
                        EMS_opt_offsetS_shorten_stop :
                        EMS_opt_offsetS_extend_stop;
          }
        }
      /* Set the option to indicate the surface belongs to a solid */
      options |= EMS_opt_offsetS_of_sfsolid; 

      stat_OM = om$send (msg = message EMSsurface.EMoffset
                 (&msg_loc, options, mattyp, mat, const_args,
                 offset_inward, thickness, num_spec_thick,
		 val_spec_thick, spec_thick_sf_sets,
		 num_nooffsetsfs, nooffsetsfs, 
		 status_str, &offset_comp, errkeylist),
                 p_chanselect = &chan_to_comps,
                 from = FIRST, to = FIRST);
      EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
      EMerr_hndlr (msg_loc == EMS_I_Degenerate, *msg, msg_loc, ret_end);
      
      stat_OM = om$construct (classid = OPP_EMSsfsolid_class_id,
                 msg = message EMSsfsolid.EMcap_thyself (&msg_loc,
                 const_args, &offset_comp), p_objid = offsetobj);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      break;

    case REVOLVE_SOLID:

      EMmake_chanselect (NDfather_father, &chan_to_parents);
      if (num_nooffsetsfs)
        {
        caps[START] = caps[STOP] = NULL_OBJID;
        count = 0;
        om$get_channel_objects (object = me, p_chanselect = &chan_to_comps,
         count = &count, size = 3, list = complist);
        if (count == 3)
          {
          caps[START] = complist[1].S_objid;
          caps[STOP] = complist[2].S_objid;
          }
        else if (count && count < 3)
          {
          stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc,
                     mattyp, mat, endpts[START], endpts[STOP]),
                     p_chanselect = &chan_to_parents,
                     from = REV_CRV, to = REV_CRV);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidCase,
           ret_end);

          BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
          for (i=0; i<count; i++)
            {
            compid.objid = complist[i].S_objid;
            compid.osnum = OM_Gw_current_OS;
            om$get_classid (objid = compid.objid, p_classid = &objclass);
            if (om$is_ancestry_valid (subclassid = objclass,
                 superclassid = OPP_EMSplane_class_id) == OM_S_SUCCESS)
              {
              stat_OM = EMgetorntnrm (&msg_loc, NULL, mattyp, mat, &compid,
                         0.5, 0.5, plane_pt, solid_side_vec);
              EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
               ret_end);

              BSdistptpl (&msg_loc, endpts[START], plane_pt, solid_side_vec,
               &dist);
              if (dist <= chttol)
                caps[START] = compid.objid;
              else
                caps[STOP] = compid.objid;
              }
            }
          }
        }

/* Get the 'sweep angle'. If sweep angle is less than 360 that means the
   solid was created necessarily using a closed profile - Ashok Sep/21/92
*/
      stat_OM = om$send (msg = message expression.NDgive_value (&rev_sweep),
                         p_chanselect = &chan_to_parents,
                         from = REV_SWEEP, to = REV_SWEEP);
      EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_InvalidCase,
                   ret_end);

      for (i=START; i<=STOP; i++)
        {
        found = FALSE;
        for (j=0; j<num_nooffsetsfs; j++)
          if (caps[i] == nooffsetsfs[j])
            {
            found = TRUE;
            break;
            }

/*      The case where sweep_angle is less than 360 needs to be handled
	specially
	- Ashok Sep/21/92.
*/
	if(rev_sweep < 360.0)
  	  {
          if (found && offset_inward ^ negative_solid)
            {
/* 	DO NOTHING
        'delta' option by default to avoid coincident-plane
        processing at the open caps
            if (i == STOP)
              options |= EMS_opt_offsetS_by_delta_at_start;
            else
              options |= EMS_opt_offsetS_by_delta_at_stop;
*/
            }
          else if (!found)
            {
            if (i == STOP)
              options |= EMS_opt_offsetS_extend_start | 
                         EMS_opt_offsetS_shorten_start;

/* In future need to handle the case of negative solid properly by defining
   some new options (sweep and reverse-sweep) ??
              options |= offset_inward ^ negative_solid ?
                          EMS_opt_offsetS_sweep_start :
                          EMS_opt_offsetS_rev_sweep_start;
*/
            else
              options |= EMS_opt_offsetS_extend_stop | 
                         EMS_opt_offsetS_shorten_stop;
/* In future need to handle the case of negative solid properly ?
              options |= offset_inward ^ negative_solid ?
                          EMS_opt_offsetS_sweep_stop :
                          EMS_opt_offsetS_rev_sweep_stop;
*/
            }
	  }
/*      If sweep angle is 360 AND there is an end-cap that should'nt be offset,
	means the revolved profile is an open curve. In this case the
	corresponding end-point of the profile will need to be extended or
	shortened. Set the appropriate options.
	- Ashok Sep/21/92.
*/
	else           /* rev_sweep = 360 */
          if (found)   /* the revolved curve has to be an open curve */
            {
            if (i == START)
              options |= (EMS_opt_offsetS_extend_start | 
                         EMS_opt_offsetS_shorten_start);
            else
              options |= (EMS_opt_offsetS_extend_stop | 
                         EMS_opt_offsetS_shorten_stop);
            }

        } /* for(i=START; i<STOP; i++) */

      /* Set the option to indicate the surface belongs to a solid */
      options |= EMS_opt_offsetS_of_sfsolid; 

      stat_OM = om$send (msg = message EMSsurface.EMoffset
                 (&msg_loc, options, mattyp, mat, const_args,
                 offset_inward, thickness, num_spec_thick,
		 val_spec_thick, spec_thick_sf_sets,
		 num_nooffsetsfs, nooffsetsfs, 
		 status_str, &offset_comp, errkeylist),
                 p_chanselect = &chan_to_comps,
                 from = FIRST, to = FIRST);
      EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
      EMerr_hndlr (msg_loc == EMS_I_Degenerate, *msg, msg_loc, ret_end);

      stat_OM = om$construct (classid = OPP_EMSsfsolid_class_id,
                 msg = message EMSsfsolid.EMcap_thyself (&msg_loc,
                 const_args, &offset_comp), p_objid = offsetobj);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      break;

    case DRAFTED_SOLID:   
    case COMP_SURF :
      stat_OM = OM_E_ABORT;
      break;

    default:
      stat_OM = OM_E_ABORT;
      *msg = EMS_E_NotSupported;
    }

ret_end:

    EMWRAPUP (*msg, stat_OM, "EMSsfsolid.EMoffset"); 
    if(EMSokay(stat_OM) || (options & EMS_opt_offsetS_special_algo_only))
       return (stat_OM);
    else
      /* Invoke the General Algorithm for Offsetting  */
       return (om$send (msg = message EMScompsurf.EMoffset (msg, options,
           mattyp, mat, const_args, offset_inward, thickness,
           num_spec_thick, val_spec_thick, spec_thick_sf_sets,
           num_nooffsetsfs, nooffsetsfs, status_str, offsetobj,
           errkeylist),
           mode = OM_e_wrt_message, targetid = my_id));
}

end implementation EMSsfsolid;
