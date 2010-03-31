/*
NAME:
   EMoffset

ABSTRACT:

    This method constructs the offset composite surface of this object
    given the distance to offset and a Boolean flag indicating inward or
    outward offset. The following options are supported:
    EMS_opt_offsetS_extend_start
    EMS_opt_offsetS_shorten_start
    EMS_opt_offsetS_by_delta_at_start
    EMS_opt_offsetS_extend_stop
    EMS_opt_offsetS_shorten_stop
    EMS_opt_offsetS_by_delta_at_stop

    These options indicate whether to extend the offset's sweep in the sweep
    direction either forward or backward by a small delta (10 times chttol)
    or by the offset distance specified.

ARGUMENTS:

RETURN VALUES:

ALGORITHM:

NOTES:

    Check for memory allocation/deallocation.

KEYWORDS:

HISTORY:
 Jagan   : 05/22/95   :  The variables stopoff and startoff are initialized to
                         zero and that fixes the TR#119524936. 
 Sanjay  : 03/30/95   :  Some times the method EMcvoffset returns a self-inter-
                         secting curve. Even though the root cause is BSmath,
                         a check has been included here to check for the same 
                         and if it is so, error out.
 Sudhakar: 01/28/94   :  Modified to not invoke the general algorithm if the
                         "EMS_opt_offsetS_special_algo_only" option is set.
 Sudhakar:  11/04/93  :  Fixed problem with multiple distance offset of
                         'symmetric' surface of projection.
 Sudhakar:  09/08/93  :  Modified to invoke the 'general offset algorithm'
                         if and only :
                          i) this special algorithm fails and
                         ii) this 'EMoffset' has not been called from
                             the 'EMoffset' at the 'EMSsfsolid' level.
                         Got rid of the USE_SMART_OFFSET ifdef.
 Sudha      06/21/93     Modified to handle BSprototype ansification
 Sudhakar:  22Mar'93  :  Modified to handle multiple offset distances.
                         Introduced the call to the function 
                         'EFget_offsetdistance_for_surface' to determine 
                         the offset distance for each surface.
 Sudhakar:  01/29/93  :  Forced to do composite offset unless USE_SMART_OFFSET
                         is set.
 sampath :  01/19/93  :  Added addtional argumants to EMoffset .
 Tapadia :  09/23/92  :  Support for Symmetric distance of solid of projection
			 (fix for TR 11925981)
    SS   :  03/09/92  :  Creation
*/

class implementation EMSprjcompsf;

%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include "REgensolid.h"
#include "ma.h"
#include "matypemx.h"
#include "matrlmx.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscrossp.h"

#define FIRST  0
#define SECOND 1

#define PROJ_CRV   0
#define PROJ_DIST  1
#define PROJ_VEC   2

#define OFFCENTRE_PARAM 0.475

#define STOP_INDEX  1
#define START_INDEX 2

from expression import NDgive_value;
from EMSparamgm import EMgetgeom;
from GRcurve import EMcvtanorm, EMcvoffset, EMcrvslfint;
from EMSsubbs import EMsftanorm, EMgetbsdef;

method EMoffset (IGRlong *msg; IGRushort options;
                 IGRshort *mattyp; IGRmatrix mat;
                 struct GRvg_construct *construct_list;
                 IGRboolean is_natural_normal;
                 IGRdouble distance;
                 IGRint num_spec_thick;
                 IGRdouble *val_spec_thick;
                 struct GRobjid_set *spec_thick_sf_sets;
                 IGRint num_nooffsetsfs; GRobjid *nooffsetsfs;
                 IGRchar status_str[];
                 GRobjid *constructed_object;
                 struct EMSerror_help *errkey_list)
{
  IGRboolean volume_on_cvside;
  IGRchar *save_ptr;
  IGRshort tmattyp;
  OMuint count;
  IGRint i, j, sign = 1, *off_code;
  IGRlong stat_OM, msg_loc;
  IGRdouble *pt, proj_dist, upar, vpar, chgdist;
  IGRdouble deltatol, chttol;
  IGRvector vec, proj_vec, crv_side_vec, solid_side_vec;
  IGRpoint proj_vec_pt1, proj_vec_pt2, tanpts[2], nrmpts[2];
  IGRmatrix tmat;
  GRobjid dumobj;
  GRclassid objclass;
  struct IGRbsp_surface srfdef;
  struct GRmd_env md_env;
  struct GRparms uparm;
  struct GRid *paramids, proj_crv, off_proj_crv;
  struct GRlc_info cvinfo, ori_cur_info;
  struct EMSsweep sweep_info;
  struct EMSgeomdata vecgeom;
  OM_S_CHANSELECT chan_to_comps, chan_to_owners;
  IGRint proj_type;
  struct EMSassoc_params param_info;
  IGRboolean sym_dist_flag = FALSE, both_sym_flag = FALSE;
  IGRpoint axis[2];
  IGRvector move_nor, tmp_nor;
  IGRdouble move_dist, sym_proj_dist = 0.0;
  struct GRid new_id, tmp_id;
  extern IGRlong EFget_axis_from_curve_one_pl(); 
  IGRmatrix matrix;
  IGRdouble   *offdists = NULL, startoff = 0.0, stopoff = 0.0;
  GRobjid     tmpobj;
  GRspacenum dumos;
  struct GRid  solid_GRid;

  IGRlong     pnt_slots=0, grand_num_pnt=0, crv_slots=0, grand_num_crv=0;

  extern void EFget_offsetdistance_for_surface();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;


#ifdef DEBUG
printf("Entered EMcspjoffset\n");
#endif

  paramids = NULL;
  off_proj_crv.objid = NULL_OBJID;
  EMgetmdenv (&md_env, mattyp, mat, OM_Gw_current_OS);

  /*
   * Obtain the parents information - curve, projection distance and/or
   * projection vector.
   */

  param_info.obj_info =NULL;
  param_info.asparents = NULL;
  param_info.parents = NULL;
  param_info.md_envs =NULL;
  if(offdists)  om$dealloc(ptr = offdists);
  if (off_proj_crv.objid != NULL_OBJID)
    om$send (msg = message GRgraphics.GRdelete (&msg_loc, &md_env),
     targetid = off_proj_crv.objid);
  stat_OM = om$send (msg = message EMSassoc.EMpack_paraminfo (&msg_loc,
             NULL, &param_info, &proj_type, NULL, NULL, (IGRint *)&count, 
	     &paramids, NULL, NULL, NULL, OM_e_wrt_object), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if(proj_type == EMS_ASsolid_proj_by_sym_dist) {
	sym_dist_flag = TRUE;
  	if (options & EMS_opt_offsetS_by_delta_at_start &&
      		options & EMS_opt_offsetS_by_delta_at_stop) 
		both_sym_flag = TRUE;
  }
  else if(proj_type == EMS_ASsolid_proj_by_trim_st_end_plane ||
	proj_type == EMS_ASsolid_proj_by_trim_end_plane ) {
	*msg = EMS_E_InvalidCase;
	goto ret_end;
  }
  else 
  	EMerr_hndlr (count != 3, *msg, EMS_E_InvalidCase, ret_end);

  proj_crv = paramids[PROJ_CRV];
  
  stat_OM = om$send (msg = message expression.NDgive_value (&proj_dist),
             targetid = paramids[PROJ_DIST].objid);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_InvalidCase, ret_end);

  /* Copy the profile only if it is created due to non-symmetric option */
  if(!sym_dist_flag) {
  	stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
             mattyp, mat, &vecgeom), targetid = paramids[PROJ_VEC].objid);
  	EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
  	EMerr_hndlr (vecgeom.geomtype != GEOMDATA_VECTOR, *msg, 
		EMS_E_InvalidCase, ret_end);

  	OM_BLOCK_MOVE (vecgeom.vector, proj_vec, sizeof (IGRvector));
  }
  else { /* obtain the axis information */
  	ori_cur_info.located_obj = paramids[PROJ_CRV];
  	OM_BLOCK_MOVE(&md_env, &ori_cur_info.module_info, 
		sizeof(struct GRmd_env));
	stat_OM = EFget_axis_from_curve_sym_dist(&msg_loc, &ori_cur_info, 
		proj_dist, axis);
  	EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
	sym_proj_dist = proj_dist;

	tmp_nor[0] = axis[0][0] - axis[1][0];
	tmp_nor[1] = axis[0][1] - axis[1][1];
	tmp_nor[2] = axis[0][2] - axis[1][2];
	BSnorvec(&msg_loc, tmp_nor);
	OM_BLOCK_MOVE(tmp_nor, proj_vec, sizeof(IGRvector));
  }

  /*
   * Determine if the curve flows such that the volume enclosed by this
   * surface is on the right or not, when viewed along the projection vector.
   */

  uparm.u = OFFCENTRE_PARAM;
  uparm.polygon_inx = 0;
  uparm.leaf_id.objid = NULL_OBJID;
  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  om$get_classid (objid = proj_crv.objid, osnum = proj_crv.osnum,
   p_classid = &objclass);
  if (om$is_ancestry_valid (subclassid = objclass,
       superclassid = OPP_EMScomposite_class_id) == OM_S_SUCCESS)
       stat_OM = om$send (msg = message GRcurve.EMcvtanorm (&msg_loc,
               mattyp, mat, NULL, 1, &uparm, NULL, NULL, 1.0, NULL,
               TRUE, NULL, (IGRdouble *) tanpts, NULL),
               p_chanselect = &chan_to_comps, senderid = proj_crv.objid,
               from = FIRST, to = FIRST);
  else
       stat_OM = om$send (msg = message GRcurve.EMcvtanorm (&msg_loc,
               mattyp, mat, NULL, 1, &uparm, NULL, NULL, 1.0, NULL,
               TRUE, NULL, (IGRdouble *) tanpts, NULL),
               targetid = proj_crv.objid, targetos = proj_crv.osnum);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  OM_BLOCK_MOVE (tanpts[FIRST], proj_vec_pt1, sizeof (IGRpoint));
  BSmkvec (&msg_loc, vec, proj_vec_pt1, tanpts[SECOND]);
  BScrossp (&msg_loc, vec, proj_vec, crv_side_vec);
  BSnorvec (&msg_loc, crv_side_vec);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidCase, ret_end);

  stat_OM = om$send (msg = message EMSsubbs.EMgetbsdef (&msg_loc, &srfdef),
             p_chanselect = &chan_to_comps, from = FIRST, to = FIRST);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  upar = OFFCENTRE_PARAM;
  vpar = 0.0;
  stat_OM = om$send (msg = message EMSsubbs.EMsftanorm (&msg_loc,
             mattyp, mat, NULL, 1, &upar, 1, &vpar, 1.0, NULL,
             FALSE, TRUE, (IGRdouble *) nrmpts, NULL),
             p_chanselect = &chan_to_comps, from = FIRST, to = FIRST);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  BSmkvec (&msg_loc, solid_side_vec, nrmpts[FIRST], nrmpts[SECOND]);
  if (!srfdef.pos_orient)
    for (i=X; i<=Z; i++)
      solid_side_vec[i] = -solid_side_vec[i];

  if (BSdotp (&msg_loc, crv_side_vec, solid_side_vec) > 0.0)
    volume_on_cvside = TRUE;
  else
    volume_on_cvside = FALSE;

  /*
   * Offset the projection curve with the given distances on the correct
   * side.
   */

  count = 0;
  om$get_channel_count (objid = proj_crv.objid, p_chanselect = &chan_to_comps,
   count = &count);
  if (count)
    {
    off_code = (IGRint *) alloca (count * sizeof (IGRint));
    for (i=0; i<count; i++)
      off_code[i] = BSCONSTOFF;
    }
  else
    off_code = NULL;

  if(count)
    {
     offdists = (IGRdouble *) om$malloc (size = count * sizeof(IGRdouble));
     EMerr_hndlr ((!offdists), *msg, EMS_E_DynamicMemoryAllocated, ret_end);
/*
 * Always check for return from malloc.
 * pp
 */
     for(i=0; i<count; i++)
       {
        /* Get the surface at the 'i'th index of the projected surface */

        tmpobj = NULL_OBJID;
        om$get_objid_at_index (objid = my_id,
        osnum = proj_crv.osnum, p_chanselect = &chan_to_comps, index = i,
        objidaddr = &tmpobj, osnumaddr = &dumos);

        /* Determine the corresponding offset distance */
        EFget_offsetdistance_for_surface(tmpobj, distance,
                                            num_spec_thick,
                                            val_spec_thick,
                                            spec_thick_sf_sets,
                                            num_nooffsetsfs, 
                                            nooffsetsfs,
                                            &offdists[i]);
       }
    }



  save_ptr = construct_list->class_attr;
  construct_list->class_attr = NULL;
  stat_OM = om$send (msg = message GRcurve.EMcvoffset (&msg_loc, 
             mattyp, mat, construct_list, (count ? &offdists[0] : &distance), 
               proj_vec,
             is_natural_normal ? volume_on_cvside : !volume_on_cvside,
             FALSE, off_code, FALSE, TRUE, &off_proj_crv,
             NULL, NULL, NULL), targetid = proj_crv.objid);
  construct_list->class_attr = save_ptr;
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_BSerror || msg_loc == EMS_I_InvalidArg ||
   msg_loc == EMS_I_Degenerate, *msg, EMS_I_Degenerate, ret_end);

  /*
   * check for curve self intersection
   */
  stat_OM = om$send (msg = message GRcurve.EMcrvslfint (&msg_loc, 
                           construct_list, &construct_list->env_info->md_env,
                           &pnt_slots, &grand_num_pnt, NULL, NULL, NULL, 
                           &crv_slots, &grand_num_crv, NULL, NULL),
                     senderid = off_proj_crv.objid,
                     targetid = off_proj_crv.objid,
                     targetos = off_proj_crv.osnum);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
#ifdef DEBUG
  printf ("Number of Intersections and Overlaps for the offset Curve : %d, %d\n", grand_num_pnt, grand_num_crv);
#endif

  EMerr_hndlr (grand_num_pnt > 1 || grand_num_crv, *msg, EMS_E_Fail, ret_end);
                           
  /*
   * If the resultant offset should be stretched or shortened at either or
   * both ends, do so by adjusting the relevant parameters. A "delta"
   * stretch (or shortening) is a constant multiple of the current cht.
   */

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
  deltatol = 10 * chttol;

  /* Find the 'id' of the parent solid, if it exists, to help determine
     the appropriate end-plane id */
  if(options & EMS_opt_offsetS_extend_start ||
     options & EMS_opt_offsetS_shorten_start||
     options & EMS_opt_offsetS_extend_stop  ||
     options & EMS_opt_offsetS_shorten_stop)
    {
     stat_OM = EMmake_chanselect (GRconnector_to_owners, &chan_to_owners);
     EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);
     stat_OM = om$get_objid_at_index(objid = my_id,
                                 osnum = proj_crv.osnum,
                                 index = 0,
                                 objidaddr = &solid_GRid.objid,
                                 osnumaddr = &solid_GRid.osnum,
                                 p_chanselect = &chan_to_owners);
#ifdef DEBUG
 printf("The Solid id = %d\n", solid_GRid.objid);
#endif
     EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);
    }

  if (options & EMS_opt_offsetS_extend_start ||
      options & EMS_opt_offsetS_shorten_start)
    {
    if (options & EMS_opt_offsetS_by_delta_at_start)
      chgdist = deltatol;
    else
     {
      stat_OM = om$get_objid_at_index(objid = solid_GRid.objid,
                                 osnum = solid_GRid.osnum,
                                 index = START_INDEX,
                                 objidaddr = &tmpobj,
                                 osnumaddr = &dumos,
                                 p_chanselect = &chan_to_comps);
      EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);

      /* Determine the corresponding offset distance */
      EFget_offsetdistance_for_surface(tmpobj, distance,
                                            num_spec_thick,
                                            val_spec_thick,
                                            spec_thick_sf_sets,
                                            num_nooffsetsfs,
                                            nooffsetsfs,
                                            &startoff);
      chgdist = startoff;
     }


    if (options & EMS_opt_offsetS_extend_start)
      sign = -1;
    else
      sign = 1;

    for (i=X; i<=Z; i++)
      vec[i] = sign * chgdist * proj_vec[i];
    MAtrlmx (&msg_loc, vec, tmat);
    MAtypemx (&msg_loc, tmat, &tmattyp);

    if(!sym_dist_flag) {
    	stat_OM = om$send (msg = message GRgraphics.GRxform (&msg_loc, &md_env,
               &tmattyp, tmat, &dumobj), targetid = off_proj_crv.objid);
    	EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
    }

    proj_dist += (sign == -1 ? 1 : -1) * chgdist;
    for (i=X; i<=Z; i++)
      proj_vec_pt1[i] += (chgdist + deltatol) * proj_vec[i];
    }

  if (options & EMS_opt_offsetS_extend_stop ||
      options & EMS_opt_offsetS_shorten_stop)
    {
    if (options & EMS_opt_offsetS_by_delta_at_stop)
      chgdist = deltatol;
    else
     {
      stat_OM = om$get_objid_at_index(objid = solid_GRid.objid,
                                 osnum = solid_GRid.osnum,
                                 index = STOP_INDEX,
                                 objidaddr = &tmpobj,
                                 osnumaddr = &dumos,
                                 p_chanselect = &chan_to_comps);
      EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);

      /* Determine the corresponding offset distance */
      EFget_offsetdistance_for_surface(tmpobj, distance,
                                            num_spec_thick,
                                            val_spec_thick,
                                            spec_thick_sf_sets,
                                            num_nooffsetsfs,
                                            nooffsetsfs,
                                            &stopoff);
      chgdist = stopoff;
     }

    if (options & EMS_opt_offsetS_extend_stop)
      sign = 1;
    else
      sign = -1;

    proj_dist += sign * chgdist;
    }

  /*
   * Construct and initialize the offset surface of projection.
   */

  dumobj = NULL_OBJID;
  cvinfo.located_obj = off_proj_crv;
  OM_BLOCK_MOVE (&md_env, &cvinfo.module_info, sizeof (struct GRmd_env));

  /* If solid of projection created is due to symmetric distance then calculate
  the axis points depending on if one/both or none of the surfaces are open */
  if(sym_dist_flag) {
	IGRdouble tmp_dist;
	
    	for(i = 14; i > 0; i--) matrix[i] = 0.0;
    	matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;

  	pt = (IGRdouble *) proj_vec_pt2;
  	OM_BLOCK_MOVE (proj_vec_pt1, pt, sizeof (IGRpoint));

  	for (i=X; i<=Z; i++)
    	    pt[i] += proj_dist * proj_vec[i];
	OM_BLOCK_MOVE(tmp_nor, move_nor, sizeof(IGRvector));

  	if(options & EMS_opt_offsetS_by_delta_at_start ||
      		options & EMS_opt_offsetS_by_delta_at_stop) 
	    tmp_dist = proj_dist;
        else 
	    tmp_dist = BSdistptpt(&msg_loc, proj_vec_pt1, proj_vec_pt2);

	/* Get the new axis points to be used by solid of projection */
	stat_OM = EFget_axis_from_curve_sym_dist(&msg_loc, &ori_cur_info, 
			tmp_dist, axis);
  	EMerr_hndlr(EMSerror(msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

	for(i = 0; i < 3; i++) 
		move_nor[i] *= sign;

        if(options & EMS_opt_offsetS_of_sfsolid)
        {
	     move_dist = sym_proj_dist/2.0 + 
                    (is_natural_normal ? (sign * stopoff) : (sign * startoff));
                    /*Because, 
                       For inward offset:  (is_natural_normal = TRUE)
                        sign = -1; profile is moved towards the stop-cap-plane
                       For outward offset: (is_natural_normal = FALSE)
                        sign = 1 ; profile is moved towards the start-cap-plane 
                     */
        }
        else
	     move_dist = tmp_dist/2.0;


	matrix[3] = move_dist * move_nor[0];
	matrix[7] = move_dist * move_nor[1];
	matrix[11] = move_dist * move_nor[2];

	new_id.objid = NULL_OBJID;
	stat_OM = om$send(msg = message GRgraphics.GRcptform(&msg_loc,
			&cvinfo.module_info, matrix,
			&cvinfo.module_info, 
			&new_id.objid),
		senderid = NULL_OBJID,
		targetid = cvinfo.located_obj.objid,
		targetos = cvinfo.located_obj.osnum);

        EMerr_hndlr(EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

	tmp_id.objid = cvinfo.located_obj.objid;
	cvinfo.located_obj.objid = new_id.objid;

	for(i = 0; i < 2; i++) {
	    for(j = 0; j < 3; j++) 
		axis[i][j] *= sign;
	}

        sweep_info.type = EMProject;
        sweep_info.data.prj_data.point1 = (IGRpoint *)axis[0];
        sweep_info.data.prj_data.point2 = (IGRpoint *)axis[1];
  }
  else {
  	sweep_info.type = EMProject;
  	sweep_info.data.prj_data.point1 = (IGRpoint *) proj_vec_pt1;
  	sweep_info.data.prj_data.point2 = (IGRpoint *) proj_vec_pt2;
  	pt = (IGRdouble *) proj_vec_pt2;
  	OM_BLOCK_MOVE (proj_vec_pt1, pt, sizeof (IGRpoint));
  	for (i=X; i<=Z; i++)
    	 	pt[i] += proj_dist * proj_vec[i];
  }

  save_ptr = construct_list->class_attr;
  construct_list->class_attr = NULL;
  stat_OM = om$construct (classid = OPP_EMSprjcompsf_class_id,
             msg = message EMSswcompsf.EMsweep_composite_curve
             (construct_list, &cvinfo, &sweep_info, &dumobj),
             p_objid = constructed_object);
  construct_list->class_attr = save_ptr;
  EMerr_hndlr (EMSerror (1 & stat_OM), *msg, EMS_E_Fail, ret_end);

  /* delete the profile created */
  if(sym_dist_flag) {
	cvinfo.located_obj.objid = tmp_id.objid;
  	if(new_id.objid != NULL_OBJID) {
    	om$send (msg = message GRgraphics.GRdelete (&msg_loc, &md_env),
     		targetid = new_id.objid);
	}
  }

ret_end:
 /* fix for mlk */
  if(param_info.obj_info)
    om$dealloc (ptr = param_info.obj_info);
  if(param_info.asparents)
    om$dealloc (ptr = param_info.asparents);
  if(param_info.md_envs)
    om$dealloc (ptr = param_info.md_envs);
  if(paramids)
    om$dealloc(ptr = paramids);
  if(offdists)  om$dealloc(ptr = offdists);
  if (off_proj_crv.objid != NULL_OBJID)
    om$send (msg = message GRgraphics.GRdelete (&msg_loc, &md_env),
     targetid = off_proj_crv.objid);

  EMWRAPUP (*msg, stat_OM, "EMSprjcompsf.EMoffset");
  if((1 & stat_OM) || (options & EMS_opt_offsetS_of_sfsolid) ||
                      (options & EMS_opt_offsetS_special_algo_only))
       return (stat_OM);
  else
     /* Invoke the 'general offset' algorithm. */
       return (om$send (msg = message EMScompsurf.EMoffset (msg, options,
           mattyp, mat, construct_list, is_natural_normal, distance,
           num_spec_thick, val_spec_thick, spec_thick_sf_sets,
           num_nooffsetsfs, nooffsetsfs, status_str, constructed_object,
           errkey_list),
           mode = OM_e_wrt_message, targetid = my_id));
}

end implementation EMSprjcompsf;
