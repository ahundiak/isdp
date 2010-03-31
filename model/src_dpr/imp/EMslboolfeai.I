/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslboolfea;

/*

This file contained three methods: EMpunch_hole, EMpunch_counterpart and
EMmake_part is using by the boolean features.

*/

#if DEBUG
#include <stdio.h>
#endif

#ifndef OMerrordef_include
#include "OMerrordef.h"
#endif

#ifndef OMmacros_include
#include "OMmacros.h"
#endif

#ifndef igrtypedef_include
#include "igrtypedef.h"
#endif

#ifndef igetypedef_include
#include "igetypedef.h"
#endif

#ifndef gr_include
#include "gr.h"
#endif

#ifndef igr_include
#include "igr.h"
#endif

#ifndef EMSmsgdef_include
#include "EMSmsgdef.h"	/* for EMS_I_NoIntersection */
#endif

#ifndef EMSfeadef_include
#include "EMSfeadef.h"	/* for feature's struct */
#endif

#ifndef EMSopt_include
#include "EMSopt.h"
#endif

#ifndef EMSstruct_include
#include "EMSstruct.h"
#endif

#ifndef emssfintdef_include
#include "emssfintdef.h"  /* for EMSsfbool_opt_xxxx */
#endif

#ifndef emserr_include
#include "emserr.h"
#endif

#ifndef emsdef_include
#include "emsdef.h"	/* for MAXINT, DPR_DISPLAY_BUFF_INCR */
#endif

#ifndef EC_I_include
#include "EC_I.h"  /* for EMS_I_Processing */
#endif

#ifndef bserr_include
#include "bserr.h"
#endif

#ifndef bsparameters_include
#include "bsparameters.h"	/* for BSEXTRACTPAR() */
#endif

#ifndef msmacros_include
#include "msdef.h"
#include "msmacros.h"	/* for ex$message() */
#endif

#ifndef exmacros_include
#include "exmacros.h" 
#endif

#ifndef lcmacros_include
#include "lcmacros.h"
#endif

#include "EMSasfeatdef.h"
#include "emssfint.h"
#include "maidmx.h"
#include "maacos.h"
#include "gocmacros.h"
#include "bstrans1.h"
#include "bsinvtmat.h"
#include "bsbasisvect.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#define REGULAR	0	/* for the regular circular hole */
#define VBOTTOM	1	/* for the blind hole with v_bottom */
#define PROFILE	2	/* for the profile hole */
#define BLIND	3	/* for checking a blind hole */

#define COUNTERSINK  0	/* for countersink hole */

#define CREAT	0
#define CONST	1
#define DELET	2

#define HALF_RADIAN	0.0087266462599716483
#define MAXNUM	10

#define IS_IDENTICAL(a, b, tol)	(( (a-b) < 0 ? (b-a) : (a-b) ) <= tol)


from EMScylindr import  EMcylinder_by_axis_n_radius;
from EMScone	import  EMcone;
from EMSsubbs	import	EMget_unit_norm;
from EMSgencompsf import  EMmake_comp;
from EMSproject import  EMplace_surface_of_projection;
from EMSrevol  	import  EMrevolve_curve;
from EMSsfsolid import  EMcap_thyself;

extern OMuword  OPP_EMScone_class_id, OPP_EMScylindr_class_id;
extern OMuword  OPP_EMSproject_class_id, OPP_EMSrevol_class_id;
extern OMuword  OPP_EMSslboolean_class_id, OPP_EMSsfsolid_class_id;
extern OMuword  OPP_EMSdatpln_class_id;


method EMpunch_hole(IGRlong *EMmsg; 
		IGRushort hole_type, *depth_type; 
		struct GRlc_info  *surf_info;
		IGRdouble *v_angle;
		struct GRvg_construct *construct_list;
		IGRint num_holes;
		struct EMShole *holes;
		struct GRid *active_GRid)
/*

PROCEDURES:

(1) Surface construction:
    a) The circular hole type:
       1. constructs cylinder(s) and/or cone(s).
       2. stitches the surfaces to be a composite surface if any.
    b) The profile hole type:
       Constructs the surface(s) of projection.
(2) Solid construction:
    Apply EMcap_thyself to make the EMScylindr/EMSproject/EMScompsurf object(s) 
    become a EMSsfsolid object(s).

(3) Difference boolean operation (punch).

VARIABLES:

IGRlong	 *EMmsg		O	return status.
IGRshort hole_type	I	hole type indicator :
				0 : for the regular circular hole.
				1 : for the blind hole with v bottom.
				2 : for the profile hole.
IGRshort *depth_type	I	depth indicator.
struct GRlc_info *surf_info  I 	surfaces information.
IGRdouble *v_angle	I	v bottom angle, it can be NULL if it is not
				a v bottom blind hole.
struct GRvg_construct *construct_list  I  construct information of holes;
IGRint	num_holes	I   	number of holes are constructed.
struct hole_data *holes   I/O	hole parts information.
struct GRid *active_GRid   I	active state id.

HISTORY:

BL  07/28/89	Creation date.
BL  06/21/90	Moved this method from ECplhole class to EMSslboolfea class 
		and also removed the parameter construct_id and added
		parameter construct_list.
TAPADIA 12/21/90 Fix made to place multiple holes (TR 90n2785)

Sudha   06/23/93     Modified for BSprototype ansification

*/
{
  IGRboolean  sts_fun, end_ref = FALSE;
  IGRchar  status_str[54];
  IGRlong  sts, msg_loc;
  IGRint  i, point_size, total_objs, num_objs, count_surfs;
  IGRdouble  dist_tol, vec[3], tanv, d_r, cone_rads[2];
  IGRpoint  axis_line[2];
  IGRvector  vec1, vec2, vec3;
  IGRmatrix  matrix;
  OM_S_OBJID  surfs[2], surf_id;
  GRobjid  *holes_id = NULL, hole_objs[MAXNUM], *surf_ids = NULL;
  GRspacenum  *osnum;
  enum GRdpmode  DisplayMode;
  struct GRid  *surf_list = NULL;
  struct EMSradius  radius_stuff;
  IGRushort optionsEMboolean;
  extern IGRboolean EFisAncestryValid();

  /* initialize */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  osnum = &surf_info[0].located_obj.osnum;

  if(*depth_type == 1) {
  	if(EFisAncestryValid(&msg_loc, surf_info[1].located_obj.objid,
		surf_info[1].located_obj.osnum, OPP_EMSdatpln_class_id,
		FALSE)) 
	    end_ref = TRUE;
  }

  if(*depth_type == BLIND)  point_size = 3 * sizeof(IGRdouble);

  if(num_holes > MAXNUM)
  {
     holes_id = (GRobjid *) om$malloc(size = num_holes * sizeof(GRobjid));
     if(!holes_id)
     {
	*EMmsg = EMS_E_NoDynamicMemory;
	goto wrapup;
     }
  }
  else  holes_id = hole_objs;

  /* 
   * Construct the solid cylinder(s) (hole part)
   */

  if(*depth_type == BLIND && hole_type == VBOTTOM)
  {
     IGRdouble  angle;
     extern IGRdouble  tan();

     angle = *v_angle * HALF_RADIAN;
     tanv = tan(angle);
  }
  else if(hole_type == PROFILE && num_holes > 1)
  {
     /* initialize */
     for(i = 14 ; i > 0 ; --i)  matrix[i] = 0.0;

     matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;
  }

  sts = BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, dist_tol);
  dist_tol *= 100; /* Hope it is enough */

  radius_stuff.select = 0;  /* by radius value */

  if(end_ref) 
	   dist_tol= 0.0;

  for(i = 0 ; i < num_holes ; ++i)
  {
    /* Fix for TR 90n2785. Compute vec data for each hole separately */

    vec[0] = holes[i].axis_line[1][0] - holes[i].axis_line[0][0];
    vec[1] = holes[i].axis_line[1][1] - holes[i].axis_line[0][1];
    vec[2] = holes[i].axis_line[1][2] - holes[i].axis_line[0][2];

    /* 
     * Increase the top axis line of cylinder a little bit such that 
     * it won't be tangent to the solid's surface.
     */

    axis_line[0][0] = holes[i].axis_line[0][0] - dist_tol * vec[0];
    axis_line[0][1] = holes[i].axis_line[0][1] - dist_tol * vec[1];
    axis_line[0][2] = holes[i].axis_line[0][2] - dist_tol * vec[2];

    radius_stuff.input.value = holes[i].radius;

    /* If THROUGH hole */

    if(*depth_type != BLIND)
    {
      /* Do the same to the bottom axis line of cylinder */
		
      axis_line[1][0] = holes[i].axis_line[1][0] + dist_tol * vec[0];
      axis_line[1][1] = holes[i].axis_line[1][1] + dist_tol * vec[1];
      axis_line[1][2] = holes[i].axis_line[1][2] + dist_tol * vec[2];

      if(hole_type == REGULAR)
      {
	 sts = om$construct(classid = OPP_EMScylindr_class_id,
		msg = message EMScylindr.EMcylinder_by_axis_n_radius(
		construct_list, axis_line[0], axis_line[1], &radius_stuff),
		p_objid = &surf_id,
		osnum = *osnum);
     	 EMerr_hndlr(!(1 & sts & *construct_list->msg), *EMmsg, 
		EMS_E_OMerror, wrapup);

      } /* if is a CIRCULAR THROUGH hole */
      else if(hole_type == PROFILE)
      {
	 /* I only construct the first profile, the rest profiles, if any, 
	    do copy and transform */

	 if(i == 0)
	 {
	    sts = om$construct(classid = OPP_EMSproject_class_id,
		msg = message EMSproject.EMplace_surface_of_projection(
		construct_list, &surf_info[2].located_obj, 
		&surf_info[2].module_info, NULL, NULL, 
		axis_line[0], axis_line[1], TRUE, &surf_id), 
		p_objid = &surfs[0],
		osnum = *osnum);
     	    EMerr_hndlr(!(1 & sts & *construct_list->msg), *EMmsg, 
			EMS_E_OMerror, wrapup);
	 } /* if num_hole = 1 */
	 else
	 {
	    struct GRid  new_obj;
	    struct GRmd_env  new_mdenv;

	    matrix[3] = holes[i].center[0] - holes[0].center[0];
	    matrix[7] = holes[i].center[1] - holes[0].center[1];
	    matrix[11] = holes[i].center[2] - holes[0].center[2];
	    new_mdenv = surf_info[0].module_info;

	    /* construct another profile */

	    sts = om$send(msg = message GRgraphics.GRcptform(EMmsg, 
			&surf_info[0].module_info, 
			matrix, &new_mdenv, &new_obj.objid),
			targetid = surf_info[2].located_obj.objid,
			targetos = surf_info[2].located_obj.osnum);
     	    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

	    new_obj.osnum = *osnum;

	    sts = om$construct(classid = OPP_EMSproject_class_id,
		msg = message EMSproject.EMplace_surface_of_projection(
		construct_list, &new_obj, &new_mdenv, NULL, NULL, 
		axis_line[0], axis_line[1], TRUE, &surf_id), 
		p_objid = &surfs[0],
		osnum = *osnum);
     	    EMerr_hndlr(!(1 & sts & *construct_list->msg), *EMmsg, 
			EMS_E_OMerror, wrapup);

	    sts = om$send(msg = message GRgraphics.GRdelete(
			EMmsg, &new_mdenv),
			targetid = new_obj.objid,
			targetos = *osnum);
     	    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);
	 }
      } /* else if it is profile hole */

    } /* if depth_type != BLIND */
    else  
    {
      /* If BLIND hole */

      if(hole_type == REGULAR)
      {
	 sts = om$construct(classid = OPP_EMScylindr_class_id,
		msg = message EMScylindr.EMcylinder_by_axis_n_radius(
		construct_list, axis_line[0], holes[i].axis_line[1], 
		&radius_stuff),
		p_objid = &surf_id,
		osnum = *osnum);
     	 EMerr_hndlr(!(1 & sts & *construct_list->msg), *EMmsg, 
		EMS_E_OMerror, wrapup);

      } /* if is a circular hole with a flat bottom */
      else if(hole_type == VBOTTOM)
      {
	 IGRint  sts_loc;

	 sts_fun = BSbasisvect(EMmsg, vec, vec1, vec2, vec3);
	 if(!sts_fun || *EMmsg != 0)
	 {
    	    *EMmsg = EMS_E_Success;
	    goto  wrapup;
	 } /* if */

	 d_r = radius_stuff.input.value / tanv;
	 axis_line[1][0] = holes[i].axis_line[1][0] + vec1[0] * d_r;
	 axis_line[1][1] = holes[i].axis_line[1][1] + vec1[1] * d_r;
	 axis_line[1][2] = holes[i].axis_line[1][2] + vec1[2] * d_r;

	 /* construct the cylinder surface */

	 sts = om$construct(classid = OPP_EMScylindr_class_id,
		msg = message EMScylindr.EMcylinder_by_axis_n_radius(
		construct_list, axis_line[0], holes[i].axis_line[1], 
		&radius_stuff),
		p_objid = &surfs[0],
		osnum = *osnum);
         EMerr_hndlr(!(1 & sts & *construct_list->msg), *EMmsg, 
			EMS_E_OMerror, wrapup);

	 sts = om$send(msg = message EMSsubbs.EMmk_nat_bdry(
		EMmsg, &construct_list->env_info->md_env, NULL),
		targetid = surfs[0],
		targetos = *osnum);
     	 EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

	 /* construct the cone surface */

         cone_rads[0] = radius_stuff.input.value;
         cone_rads[1] = 0.0;
	 OM_BLOCK_MOVE(holes[i].axis_line[1], axis_line[0], point_size);

         sts = om$construct(classid = OPP_EMScone_class_id,
		msg = message EMScone.EMcone(&sts_loc, 
		construct_list, axis_line, cone_rads),
		p_objid = &surfs[1],
		osnum = *osnum);
         EMerr_hndlr(!(1 & sts & *construct_list->msg & sts_loc), 
			*EMmsg, EMS_E_OMerror, wrapup);

	 sts = om$send(msg = message EMSsubbs.EMmk_nat_bdry(
		EMmsg, &construct_list->env_info->md_env, NULL),
		targetid = surfs[1],
		targetos = *osnum);
     	 EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

	 /* connect the cylinder and cone to become a comp surface */

	 sts = om$construct(classid = OPP_EMSgencompsf_class_id,
		msg = message EMSgencompsf.EMmake_comp(EMmsg, 
		2, surfs, construct_list->env_info), 
		p_objid = &surf_id,
		osnum = *osnum);
     	 EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

      } /* else if is a v_bottom hole */

    } /* end of blind hole */

    sts = om$construct(classid = OPP_EMSsfsolid_class_id,
		msg = message EMSsfsolid.EMcap_thyself(
		EMmsg, construct_list, &surf_id),
		p_objid = &holes_id[i],
		osnum = *osnum);
    if(!(1 & sts & *EMmsg & *construct_list->msg))
    {
       sts = om$send(msg = message GRgraphics.GRdelete(EMmsg,
		construct_list->env_info),
		targetid = surf_id,
		targetos = *osnum);

       *EMmsg = EMS_E_Success;
       goto  wrapup;
    }

  } /* for (hole construction) */

  /*
   * Get all the surfaces of holes for redraw after boolean.
   */

  sts = om$send(msg=message GRowner.GRget_number_components(
		EMmsg, &count_surfs),
                targetid = holes_id[0],
		targetos = *osnum);
  EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

  num_objs = total_objs = num_holes * count_surfs;

  if(total_objs < DPR_DISPLAY_BUFF_INCR)  total_objs = DPR_DISPLAY_BUFF_INCR;
  else if(total_objs % DPR_DISPLAY_BUFF_INCR)
  {
     i = (IGRint) total_objs / DPR_DISPLAY_BUFF_INCR;
     total_objs = ++i * DPR_DISPLAY_BUFF_INCR;
  }
    
  surf_list = (struct GRid *) om$malloc(size = num_objs * sizeof(struct GRid));
  surf_ids = (GRobjid *) om$malloc(size = total_objs * sizeof(GRobjid));
  if(!surf_list || !surf_ids)
  {
     *EMmsg = EMS_E_NoDynamicMemory;
     goto  wrapup;
  }

  for(i = total_objs = 0 ; i < num_holes ; ++i)
  {
     sts = om$send(msg = message GRowner.GRget_components(EMmsg, 
		&surf_info[0].module_info, 
		&surf_list[total_objs], count_surfs, 
		&num_objs, 0, MAXINT),
                targetid = holes_id[i],
		targetos = *osnum);
     EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

     total_objs += count_surfs;
  } /* for */

  for(i = 0 ; i < total_objs ; ++i)  surf_ids[i] = surf_list[i].objid;

  /*
   * Do the punch hole boolean operation
   */

  ex$message(msgnumb = EMS_I_Processing, buff = status_str);

  optionsEMboolean = EMSsfbool_opt_display | EMSsfbool_opt_noredraw;

  sts = om$send(msg = message EMSsfboolean.EMboolean(EMmsg, 
	&surf_info[0].module_info.md_env.matrix_type,
        surf_info[0].module_info.md_env.matrix,
        active_GRid->objid, num_holes,
        holes_id, construct_list,
	EMSbool_difference, optionsEMboolean,
        status_str, NULL, NULL, &surf_ids, &total_objs),
	targetid = my_id);

  DisplayMode = GRbe;
  if( !(1 & sts & *EMmsg) || (*EMmsg == EMS_I_NoIntersection) )
  {
     for(i = 0 ; i < num_holes ; ++i)
     {

	sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                     	&surf_info[0].module_info.md_env.matrix_type,
                     	surf_info[0].module_info.md_env.matrix,
                     	&DisplayMode, &surf_info[0].module_info.md_id),
             	targetid = holes_id[i],
                targetos = *osnum);

	sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
			construct_list->env_info),
		targetid = holes_id[i],
		targetos = *osnum);
	if(!(1 & sts & msg_loc)) goto wrapup;
     }
  }   /* if */

  // intentional block to set immediate display of elements in ref. space
  {
  IGRboolean aflag = 0;
  struct GRmd_env display_env;

  aflag = pwIsActivationOn();
  gr$get_module_env(buffer = &display_env);    

  DisplayMode = GRbd;
  for(i = total_objs-1 ; i >= 0 ; --i)
  {

     sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                         aflag?&display_env.md_env.matrix_type:
                               &surf_info[0].module_info.md_env.matrix_type,
                         aflag?display_env.md_env.matrix:
                               surf_info[0].module_info.md_env.matrix, 
                         &DisplayMode, 
                         aflag?&display_env.md_id:
                               &surf_info[0].module_info.md_id),
                targetid = surf_ids[i],
		targetos = *osnum);
     EMerr_hndlr(!(1 & sts & msg_loc), *EMmsg, EMS_E_OMerror, wrapup);
  }
 } 
wrapup:
  if(surf_list)  om$dealloc(ptr = surf_list);
  if((num_holes > MAXNUM) && holes_id)  om$dealloc(ptr = holes_id);
  if(surf_ids)  om$dealloc(ptr = surf_ids);

  EMWRAPUP(*EMmsg, sts, "In EMSslboolfea.EMpunch_hole")
  return(sts);

} /* EMpunch_hole */


%safe
static void  	transpt_pltopl();
%endsafe

method EMpunch_counterpart(IGRlong *EMmsg; 
	struct GRvg_construct *construct_list;
	IGRint part_type; IGRboolean axis_normal;
	IGRboolean through_hole; IGRdouble *bottom_ang;
	struct GRlc_info *surf_info; IGRint num_parts; 
	struct part_data *parts; IGRdouble *angle_or_depth; 
	IGRdouble *drill_radius; IGRdouble *hole_radius; 
	struct GRid *solid_id)
/*

ABSTRACT:

This method first constructs the countersink/counterbore part(s) and then 
does punch the countersink(s)/counterbore(s) on the surface of the given solid.

VARIABLES:

IGRlong		*EMmsg		Output	return status.
struct GRvg_construct *construct_list  Input  construct information of 
					countersink/counterbore holes;
IGRint		part_type	Input	describe what kind of part(s) needs to
					be constructed.
IGRboolean	axis_normal	Input	indicate whether axis is normal or not.
IGRboolean	through_hole	Input	flag of hole depth.
IGRdouble	*bottom_ang	Input	the bottom angle only for blind hole.
struct GRlc_info  *surf_info	Input	the information of surface placed
					countersink(s)/counterbore(s).
IGRint		num_parts	Input   number of countersinks/counterbores 
					are constructed.
struct part_data  *parts	Input 	the counterpart(s) information.
IGRdouble 	*angle_or_depth Input	the angle of countersink or the depth
					of counterbore.
IGRdouble	*drill_radius	Input	the radius of countersink/counterbore.
IGRdouble	*hole_radius	Input	the radius of hole.
struct GRid	*solid_id	Input	the active solid id.

HISTORY:

BL  07/28/89	Creation date.
BL  09/22/89	Modified code for adding the through hole and bottom choice 
		options and also moved part of codes as the method EMmake_part.
BL  10/19/89	Added axis_normal argument to this method and modified the 
		code for dealing the axis is not normal to the surface.
BL  06/21/90	Moved this method from ECplpocket class to EMSslboolfea class 
		and also removed the parameter construct_id and added
		parameter construct_list.
TAPADIA 01/28/91 - Fix for TR 91n0254. Normal of multiple  holes/sinks
		is now w.r.t to each hole face. 
*/
{
  IGRchar  status_str[54];
  IGRboolean  v_bottom;
  IGRint  i, point_size, total_objs, num_objs, count_surfs;
  IGRlong  msg_loc, sts;
  IGRdouble  center[3], diff;
  GRobjid  *part_ids, *surf_ids, part_objs[MAXNUM], *surf_id;
  GRspacenum  *osnum;
  enum GRdpmode  DisplayMode;
  struct GRid  *surf_list, *md_id;
  struct GRmdenv_info  *md_env;
  IGRushort optionsEMboolean;

  /* initialize */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  part_ids = surf_ids = NULL;
  surf_list = NULL;
  point_size = sizeof(IGRpoint);
  surf_id = &surf_info->located_obj.objid;
  osnum = &surf_info->located_obj.osnum;
  md_id = &surf_info->module_info.md_id;
  md_env = &surf_info->module_info.md_env;

  if(num_parts > MAXNUM)
  {
     part_ids = (GRobjid *)  om$malloc(size = num_parts * sizeof(GRobjid));
     if(!part_ids)
     {
	*EMmsg = EMS_E_NoDynamicMemory;
	goto wrapup;
     }
  }
  else  part_ids = part_objs;

  if(num_parts > 0)
  {
    if(axis_normal)  OM_BLOCK_MOVE(parts[0].center, center, point_size);
    else
    {
       IGRdouble  angle, axis_dir[3];
extern IGRdouble tan() ;

       sts = om$send(msg = message EMSsubbs.EMget_unit_norm(
		&msg_loc, FALSE, NULL, md_env, 
		parts[0].center, axis_dir), 
		targetid = *surf_id,
		targetos = *osnum);
       EMerr_hndlr(!(1 & sts & msg_loc), *EMmsg, EMS_E_OMerror, wrapup);

       angle = axis_dir[0] * parts[0].axis_dir[0] + axis_dir[1] * 
		parts[0].axis_dir[1] + axis_dir[2] * parts[0].axis_dir[2];
       diff = *drill_radius * tan(MAacos(&msg_loc, &angle));

       center[0] = parts[0].center[0] - parts[0].axis_dir[0] * diff;
       center[1] = parts[0].center[1] - parts[0].axis_dir[1] * diff;
       center[2] = parts[0].center[2] - parts[0].axis_dir[2] * diff;

    } /* axis is not normal */

    if(!through_hole && *bottom_ang > 0 && *bottom_ang < 180) v_bottom = TRUE;
    else  v_bottom = FALSE;

      /*
         Making use of this field of part_data to send the surface-id of
         the surface on which the countersink is being placed - 
         TR#119301661 - 23/08/94 - Vadi.
      */

    if(part_type == COUNTERSINK)
    parts[0].objid = *surf_id;

    sts = om$send(msg=message EMSslboolfea.EMmake_part(EMmsg, &part_type,
		center, &v_bottom, bottom_ang, osnum, &parts[0], 
		construct_list, angle_or_depth, drill_radius, hole_radius),
                targetid = my_id);
    EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

    sts = om$send(msg=message GRowner.GRget_number_components(
		EMmsg, &count_surfs),
                targetid = parts[0].objid,
		targetos = *osnum);
    EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

    part_ids[0] = parts[0].objid;

    if(num_parts > 1)
    {
      IGRint  n;
      IGRdouble  dist_tol, *tag;
      IGRmatrix  matrix;

      /* initialize the transformation matrix */
      for(tag = matrix ; tag < matrix + 15 ; )  *tag++ = 0.0;
      matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;

      if(through_hole)
      {
	IGRboolean  try_hole1;

      	sts = BSEXTRACTPAR(EMmsg, BSTOLLENVEC, dist_tol);
     	EMerr_hndlr(!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);

	dist_tol *= 50;

	if(num_parts > 2)  try_hole1 = TRUE;
	else  try_hole1 = FALSE;

        for(n = 1 ; n < num_parts ; ++n)
        {
	  if(IS_IDENTICAL(parts[0].hole_depth, parts[n].hole_depth, dist_tol))
	  {
	     /* Fix for TR 91n0254 - normal is w.r.t to each hole */

	     	transpt_pltopl(EMmsg,parts[0].center,parts[0].axis_dir,
				parts[n].center,parts[n].axis_dir,matrix);

	     	if(*EMmsg != 0) {
			*EMmsg = EMS_E_OMerror;
			goto wrapup;
	     	}

	     /* construct another countersink/counterbore part(s) */

	     sts = om$send(msg = message GRgraphics.GRcptform(EMmsg, 
			&surf_info->module_info, 
			matrix, &surf_info->module_info, 
			&parts[n].objid),
			targetid = parts[0].objid,
			targetos = *osnum);
     	     EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);
	  } /* if IS_IDENTICAL */
	  else 
	  {
	     if(n != 1 && try_hole1 &&
		IS_IDENTICAL(parts[1].hole_depth,parts[n].hole_depth,dist_tol))
	     {
		transpt_pltopl(EMmsg,parts[0].center,parts[0].axis_dir,
				parts[n].center,parts[n].axis_dir,matrix);

	     	if(*EMmsg != 0) {
			*EMmsg = EMS_E_OMerror;
			goto wrapup;
	     	}

	      	/* construct another countersink/counterbore part(s) */

	      	sts = om$send(msg = message GRgraphics.GRcptform(EMmsg, 
			&surf_info->module_info, 
			matrix, &surf_info->module_info, 
			&parts[n].objid),
			targetid = parts[1].objid,
			targetos = *osnum);
     		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

	     } /* if n > 1 & try_hole1 & hole(1).depth == hole(N).depth */
	     else  /* OTHERWISE, recreate one */
	     {
    		if(axis_normal)  OM_BLOCK_MOVE(parts[n].center, center, 
			point_size);
    		else
    		{
	       	  center[0] = parts[n].center[0]-parts[n].axis_dir[0]*diff;
	      	  center[1] = parts[n].center[1]-parts[n].axis_dir[1]*diff;
	      	  center[2] = parts[n].center[2]-parts[n].axis_dir[2]*diff;
		}

            /*
              Making use of this field of part_data to send the surface-id of
              the surface on which the countersink is being placed -
              TR#119301661 - 23/08/94 - Vadi.
            */

                if(part_type == COUNTERSINK)
                parts[n].objid = *surf_id;

    	        sts = om$send(msg=message EMSslboolfea.EMmake_part(EMmsg, 
			&part_type, center, &v_bottom, bottom_ang, 
			osnum, &parts[n], construct_list, 
			angle_or_depth, drill_radius, hole_radius),
                	targetid = my_id);
    	        if( !( 1 & sts & *EMmsg))
		{
		  for(i = 0 ; i < n ; ++i)
		  {
     		    sts = om$send(msg = message GRgraphics.GRdelete(EMmsg,
			construct_list->env_info),
			targetid = parts[i].objid,
			targetos = *osnum);
     		    EMerr_hndlr(!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
		  } /* for */
		  goto wrapup;
		}
	     } /* else */
	  } /* else if not IS_IDENTICAL */

	  part_ids[n] = parts[n].objid;

        } /* for */
      } /* if it is a through hole */
      else  
      {
        for(n = 1 ; n < num_parts ; ++n)
        {
	   transpt_pltopl(EMmsg,parts[0].center,parts[0].axis_dir,
			parts[n].center,parts[n].axis_dir,matrix);

	   if(*EMmsg != 0) {
		*EMmsg = EMS_E_OMerror;
		goto wrapup;
	   }

	   /* construct another countersink/counterbore part(s) */
	   sts = om$send(msg = message GRgraphics.GRcptform(EMmsg, 
		&surf_info->module_info, 
		matrix, &surf_info->module_info, 
		&parts[n].objid),
		targetid = parts[0].objid,
		targetos = *osnum);
     	   EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

	   part_ids[n] = parts[n].objid;

        } /* for */
      } /* else if not a through hole */

    } /* if num_parts > 1 */

  } /* if num_parts > 0 */
  else
  {
     *EMmsg = EMS_E_Success;
     goto  wrapup;
  }
	
  total_objs = num_objs = num_parts * count_surfs;

  /* get all the surfaces' ids in the parts for boolean display use */

  if(total_objs < DPR_DISPLAY_BUFF_INCR)  num_objs = DPR_DISPLAY_BUFF_INCR;
  else if(total_objs % DPR_DISPLAY_BUFF_INCR)
  {
     i = (IGRint) total_objs / DPR_DISPLAY_BUFF_INCR;
     num_objs = ++i * DPR_DISPLAY_BUFF_INCR;
  }

  surf_list = (struct GRid *) om$malloc(size = total_objs * 
	sizeof(struct GRid));
  surf_ids = (GRobjid *) om$malloc(size = num_objs * sizeof(GRobjid));
  if(!surf_list || !surf_ids)
  {
     *EMmsg = EMS_E_NoDynamicMemory;
     goto wrapup;
  }

  for(i = 0, total_objs = 0 ; i < num_parts ; ++i)
  {
     sts = om$send(msg = message GRowner.GRget_components(EMmsg, 
		&surf_info->module_info, 
		&surf_list[total_objs], count_surfs, 
		&num_objs, 0, MAXINT),
                targetid = parts[i].objid,
		targetos = *osnum);
     EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

     total_objs += count_surfs;
  } /* for */

  for(i = 0 ; i < total_objs ; ++i)  surf_ids[i] = surf_list[i].objid;

  /* 
   * Construct the countersink/counterbore part(s)
   */

  optionsEMboolean = EMSsfbool_opt_display | EMSsfbool_opt_noredraw;

  ex$message(msgnumb = EMS_I_Processing, buff = status_str);

  sts = om$send(msg = message EMSsfboolean.EMboolean(EMmsg, 
	&md_env->matrix_type, md_env->matrix,
        solid_id->objid, num_parts,
        part_ids, construct_list, 
	EMSbool_difference, optionsEMboolean,
        status_str, NULL, NULL, &surf_ids, &total_objs),
	targetid = my_id);

  if( !(1 & sts & *EMmsg) || (*EMmsg == EMS_I_NoIntersection) )
  {
    DisplayMode = GRbe;
    for(i = 0 ; i < num_parts ; ++i)
    {
     	sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                &md_env->matrix_type, md_env->matrix, 
                &DisplayMode, md_id),
                targetid = part_ids[i],
		targetos = *osnum);
     	EMerr_hndlr(!(1 & sts & msg_loc), *EMmsg, EMS_E_OMerror, wrapup);

	sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
		construct_list->env_info),
		targetid = part_ids[i],
		targetos = *osnum);
     	EMerr_hndlr(!(1 & sts & msg_loc), *EMmsg, EMS_E_OMerror, wrapup);
    } /* for */

    goto wrapup;

  } /* if */

  DisplayMode = GRbd;

  for(i = total_objs-1 ; i >= 0 ; --i)
  {
    sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                &md_env->matrix_type, md_env->matrix, 
                &DisplayMode, md_id),
                targetid = surf_ids[i],
		targetos = *osnum);
    EMerr_hndlr(!(1 & sts & msg_loc), *EMmsg, EMS_E_OMerror, wrapup);
  } /* for */

wrapup:
  if(surf_list)  om$dealloc(ptr = surf_list);
  if(num_parts > MAXNUM && part_ids)  om$dealloc(ptr = part_ids);
  if(surf_ids)  om$dealloc(ptr = surf_ids);
  EMWRAPUP(*EMmsg, sts, "In EMSslboolfea.EMpunch_counterpart")
  return(sts);

} /* EMpunch_counterpart */


method  EMmake_part(IGRlong *EMmsg; 
		IGRint *part_type; IGRdouble *center; 
		IGRboolean *v_bottom; IGRdouble *bottom_ang;
		GRspacenum *osnum; 
		struct part_data *part; 
		struct GRvg_construct *construct_list;
		IGRdouble *angle_or_depth, *drill_radius, *hole_radius)
/*

PROCEDURES:

(1) calculates the points of the countersink/counterbore axis.

(2) gets the dimension of cone & cylinder parts and their axis points.

(3) constructs surfaces of each part.

(4) stitches those surfaces to be a composite surface.

(5) uses capping the composite surface with planes to generate a solid.

VARIABLES:

IGRlong		*EMmsg		Output	return status.
IGRint		*part_type	Input	describe what kind of part(s) needs to
					be constructed.
IGRdouble	*center		Input	the center point of part.
IGRboolean	*v_bottom	Input	flag of v_bottom.
IGRdouble	*bottom_ang	Input	the bottom angle only for blind hole.
GRspacenum  	*osnum		Input	surface number of object.
struct part_data  *part		I/O 	the counterpart information.
IGRdouble 	*angle_or_depth Input	the angle of countersink or the depth
					of counterbore.
IGRdouble	*drill_radius	Input	the radius of countersink/counterbore.
IGRdouble	*hole_radius	Input	the radius of hole.

HISTORY:

BL  09/22/89	Creation date.
BL  06/21/90	Converted this method from ECplpocket to EMSslboolfea class.
SM  01/26/93    Convert planar revolutions into planes.
*/
{
  IGRboolean  stat_fun, planarity = FALSE;
  IGRint  sts_loc, point_size, num_surfs;
  IGRlong  sts, msg_loc;
  IGRdouble  dist_tol, tanv, cone_rads[2], len;
  IGRpoint  axis[2], pt, pts[2];
  OM_S_OBJID  surfs[4], surf_id;
  struct GRmdenv_info  *md_env;
  struct EMSradius  radius_stuff;
  extern IGRdouble  tan();
  extern IGRlong EMgetvggeom();

  point_size = sizeof(IGRpoint);
  radius_stuff.select = 0; /* input by radius value */
  md_env = &construct_list->env_info->md_env;

  sts = BSEXTRACTPAR(EMmsg, BSTOLLENVEC, dist_tol);
  EMerr_hndlr(!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);

  dist_tol *= 100;

  /*
    Check for the planarity of the surface being countersinked -
    TR#119301661 - 23/08/94 - Vadi.
  */

  if(*part_type == COUNTERSINK)
  {
  struct GRid surf_grid; 
  struct IGRbsp_surface *base_surf = NULL;

  surf_grid.objid = part->objid;
  surf_grid.osnum = *osnum;  

  EMgetvggeom (&msg_loc, &md_env->matrix_type,
               md_env->matrix, &surf_grid,
               &base_surf, NULL);
  EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  planarity = base_surf->planar;

  if(base_surf) om$dealloc(ptr = base_surf);
  }

  if(!planarity) {
  axis[0][0] = center[0] - part->axis_dir[0] * dist_tol;
  axis[0][1] = center[1] - part->axis_dir[1] * dist_tol;
  axis[0][2] = center[2] - part->axis_dir[2] * dist_tol;
  }
  else /* If the surface being countersinked is planar
          don't do any 'rise up' of the template solid
          - TR#119301661 - 23/08/94 - Vadi.
       */
  {
  axis[0][0] = center[0];
  axis[0][1] = center[1];
  axis[0][2] = center[2];
  }

  OM_BLOCK_MOVE(part->depth_pt, axis[1], point_size);

  if(*part_type == COUNTERSINK)
  {
     /* (1) constructs the cone surface */

     tanv = tan(*angle_or_depth * HALF_RADIAN);

  /* 
     If the surface being countersinked is planar
     don't do any 'rise up' of the template solid
     - TR#119301661 - 23/08/94 - Vadi.
  */

     if(!planarity)
     cone_rads[0] = *drill_radius + dist_tol * tanv;
     else
     cone_rads[0] = *drill_radius;

     cone_rads[1] = *hole_radius;

     /* the actual cone length */

     len = (*drill_radius - *hole_radius) / tanv;

     /* calculates another axis point of the cone/cylinder */

     pt[0] = center[0] + part->axis_dir[0] * len; 
     pt[1] = center[1] + part->axis_dir[1] * len;
     pt[2] = center[2] + part->axis_dir[2] * len;
     OM_BLOCK_MOVE(axis[0], pts[0], point_size);
     OM_BLOCK_MOVE(pt, pts[1], point_size);

     sts = om$construct(classid = OPP_EMScone_class_id,
		msg = message EMScone.EMcone(&sts_loc, 
		construct_list, pts, cone_rads),
		p_objid = &surfs[0],
		osnum = *osnum);
     EMerr_hndlr(!(1 & sts & sts_loc & *construct_list->msg), 
			*EMmsg, EMS_E_OMerror, wrapup);

     sts = om$send(msg = message EMSsubbs.EMmk_nat_bdry(
		EMmsg, md_env, NULL),
		targetid = surfs[0],
		targetos = *osnum);
     EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

     /* (2) constructs the cylinder surface */

     radius_stuff.input.value = *hole_radius;

     sts = om$construct(classid = OPP_EMScylindr_class_id,
		msg = message EMScylindr.EMcylinder_by_axis_n_radius(
		construct_list, pt, axis[1], &radius_stuff),
		p_objid = &surfs[1],
		osnum = *osnum);
     EMerr_hndlr(!(1 & sts & *construct_list->msg), 
			*EMmsg, EMS_E_OMerror, wrapup);

     sts = om$send(msg = message EMSsubbs.EMmk_nat_bdry(
		EMmsg, md_env, NULL),
		targetid = surfs[1],
		targetos = *osnum);
     EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

     /* check if bottom is flat only for a blind hole */

     if(*v_bottom)
     {
	/* (3) constructs another cone surface (v_bottom) */

        cone_rads[0] = *hole_radius;
        cone_rads[1] = 0.0;
        OM_BLOCK_MOVE(axis[1], pts[0], point_size);
        len = *hole_radius / tan(*bottom_ang * HALF_RADIAN);
        pts[1][0] = axis[1][0] + part->axis_dir[0] * len;
        pts[1][1] = axis[1][1] + part->axis_dir[1] * len;
        pts[1][2] = axis[1][2] + part->axis_dir[2] * len;

        sts = om$construct(classid = OPP_EMScone_class_id,
		msg = message EMScone.EMcone(&sts_loc, 
		construct_list, pts, cone_rads),
		p_objid = &surfs[2],
		osnum = *osnum);
        EMerr_hndlr(!(1 & sts & sts_loc & *construct_list->msg), 
			*EMmsg, EMS_E_OMerror, wrapup);

        sts = om$send(msg = message EMSsubbs.EMmk_nat_bdry(
		EMmsg, md_env, NULL),
		targetid = surfs[2],
		targetos = *osnum);
	EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

	num_surfs = 3;

     } /* if it is a v_bottom blind hole */
     else  num_surfs = 2;

     /* connects above surfaces to be a composite surface */

     sts = om$construct(classid = OPP_EMSgencompsf_class_id,
		msg = message EMSgencompsf.EMmake_comp(EMmsg, 
		num_surfs, surfs, construct_list->env_info), 
		p_objid = &surf_id,
		osnum = *osnum);
     EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

  } /* if COUNTERSINK */
  else
  {
     IGRdouble  knots[4], poles[6];
     IGRvector  vec, vec1, vec2, vec3;
     struct IGRbsp_curve  curve;


     vec[0] = axis[1][0] - axis[0][0];
     vec[1] = axis[1][1] - axis[0][1];
     vec[2] = axis[1][2] - axis[0][2];

     /* 
      * vec1, vec2 and vec3 are the unit vectors of coordinate system; 
      * vec1's direction is the same as the countersink axis
      */

     stat_fun = BSbasisvect(&msg_loc, vec, vec1, vec2, vec3);
     if(!stat_fun || msg_loc != 0)
     {
	*EMmsg = EMS_E_OMerror;
	goto  wrapup;
     } /* if */

     /* get another axis point of the cylinders */

     pt[0] = part->center[0] + *angle_or_depth * part->axis_dir[0];
     pt[1] = part->center[1] + *angle_or_depth * part->axis_dir[1];
     pt[2] = part->center[2] + *angle_or_depth * part->axis_dir[2];

     /* (1) constructs the upper cylinder surface */

     radius_stuff.input.value = *drill_radius;

     sts = om$construct(classid = OPP_EMScylindr_class_id,
		msg = message EMScylindr.EMcylinder_by_axis_n_radius(
		construct_list, axis[0], pt, &radius_stuff),
		p_objid = &surfs[0],
		osnum = *osnum);
     EMerr_hndlr(!(1 & sts & *construct_list->msg), *EMmsg, 
		EMS_E_OMerror, wrapup);

     sts = om$send(msg = message EMSsubbs.EMmk_nat_bdry(
		EMmsg, md_env, NULL),
		targetid = surfs[0],
		targetos = *osnum);
     EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

     /* (2) construct the surface connected between above two surfaces */

     /* initialize */
     curve.weights = curve.bdrys = NULL;
     curve.poles = poles;
     curve.knots = knots;

     curve.order = 2;
     curve.num_poles = 2;
     curve.num_knots = 4;
     curve.knots[0] = curve.knots[1] = 0.0;
     curve.knots[2] = curve.knots[3] = 1.0;
     curve.periodic = curve.rational = curve.phy_closed = FALSE;
     curve.non_uniform = curve.planar = TRUE;
     curve.num_boundaries = 0;

     curve.poles[0] =  pt[0] + *hole_radius * vec2[0];
     curve.poles[1] =  pt[1] + *hole_radius * vec2[1];
     curve.poles[2] =  pt[2] + *hole_radius * vec2[2];
     curve.poles[3] =  pt[0] + *drill_radius * vec2[0];
     curve.poles[4] =  pt[1] + *drill_radius * vec2[1];
     curve.poles[5] =  pt[2] + *drill_radius * vec2[2];

     sts = om$construct(classid = OPP_EMSrevol_class_id,
		msg = message EMSrevol.EMrevolve_curve(construct_list,
		NULL, &curve, axis, 0.0, 360.0,
		1, TRUE, &surfs[1], &sts_loc),
		p_objid = &surf_id,
		osnum = *osnum);
     EMerr_hndlr(!(1 & sts & sts_loc & *construct_list->msg), *EMmsg, 
		EMS_E_OMerror, wrapup);

     sts = EMconvert_into_plane(EMmsg, NULL, NULL, NULL, NULL, NULL, 
           NULL, NULL, construct_list->env_info, surf_id, *osnum);
     EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

     sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(EMmsg, md_env, 
           NULL, NULL, NULL, NULL), targetid = surfs[1],
	   targetos = *osnum);
     EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

     /* (3) construct another cylinder surface */

     radius_stuff.input.value = *hole_radius;

     sts = om$construct(classid = OPP_EMScylindr_class_id,
		msg = message EMScylindr.EMcylinder_by_axis_n_radius(
		construct_list, pt, axis[1], &radius_stuff),
		p_objid = &surfs[2],
		osnum = *osnum);
     EMerr_hndlr(!(1 & sts & *construct_list->msg), *EMmsg, 
		EMS_E_OMerror, wrapup);

     sts = om$send(msg = message EMSsubbs.EMmk_nat_bdry(
		EMmsg, md_env, NULL),
		targetid = surfs[2],
		targetos = *osnum);
     EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

     /* check if bottom is flat only for a blind hole */

     if(*v_bottom)
     {
        /* (4) constructs the cone surface */

        cone_rads[0] = *hole_radius;
        cone_rads[1] = 0.0;
        OM_BLOCK_MOVE(axis[1], pts[0], point_size);
        len = *hole_radius / tan(*bottom_ang * HALF_RADIAN);
        pts[1][0] = axis[1][0] + part->axis_dir[0] * len;
        pts[1][1] = axis[1][1] + part->axis_dir[1] * len;
        pts[1][2] = axis[1][2] + part->axis_dir[2] * len;

        sts = om$construct(classid = OPP_EMScone_class_id,
		msg = message EMScone.EMcone(&sts_loc, 
		construct_list, pts, cone_rads),
		p_objid = &surfs[3],
		osnum = *osnum);
     	EMerr_hndlr(!(1 & sts & sts_loc & *construct_list->msg), *EMmsg, 
		EMS_E_OMerror, wrapup);

        sts = om$send(msg = message EMSsubbs.EMmk_nat_bdry(
		EMmsg, md_env, NULL),
		targetid = surfs[3],
		targetos = *osnum);
     	EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

	num_surfs = 4;

     } /* if it is a v_bottom blind hole */
     else  num_surfs = 3;

     /* (5) connect above surfaces (1, 2, 3, or 4) to be a comp surface */

     sts = om$construct(classid = OPP_EMSgencompsf_class_id,
		msg = message EMSgencompsf.EMmake_comp(EMmsg, 
		num_surfs, surfs, construct_list->env_info), 
		p_objid = &surf_id,
		osnum = *osnum);
     EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

  } /* else if COUNTERBORE */

  /* 
   * Construct the solid countersink/counterbore part
   */

  sts = om$construct(classid = OPP_EMSsfsolid_class_id,
	msg = message EMSsfsolid.EMcap_thyself(EMmsg, 
	construct_list, &surf_id),
	p_objid = &part->objid,
	osnum = *osnum);
  if(! (1 & sts & *EMmsg & *construct_list->msg))	 
  {
     sts = om$send(msg = message GRgraphics.GRdelete(EMmsg,
		construct_list->env_info),
		targetid = surf_id,
		targetos = *osnum);
     EMerr_hndlr(!(1 & sts & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSslboolfea.EMmake_part")
  return(sts);

} /* EMmake_part */


/* 	TAPADIA - 28th Jan 91 - Creation date 
	This function is used to transform points from one coordinate system 
	to another. Written to Fix TR 91n0254.
*/

static  void  transpt_pltopl(EMmsg,pt1,pt1_nor,pt2,pt2_nor,matrix)

IGRlong   *EMmsg;	  /*  O return status  */	
IGRdouble pt1[3];	  /*  I	point on first plane */
IGRdouble pt1_nor[3];	  /*  I	normal vec of first plane [IGRvector] */	
IGRdouble pt2[3];	  /*  I	point on second plane  */
IGRdouble pt2_nor[3];	  /*  I	normal vector of second plane [IGRvector]  */
IGRmatrix matrix;	  /*  O	transformed 4x4 matrix  */
{
	IGRboolean		stat_fun;
	IGRmatrix		inv_mat;
	IGRdouble 		tran_vec[3],tra_mat[3][3],sca_val;	  

  	*EMmsg = EMS_S_Success;
	MAidmx(EMmsg,matrix);

	stat_fun = BStrans1(EMmsg,pt1,pt1_nor,pt2,pt2_nor,tran_vec,
		tra_mat,&sca_val);
        if(!stat_fun || *EMmsg != 0) {
		*EMmsg = EMS_E_BSerror;
		goto  wrapup;
     	} 

	BSinvtmat(0,tran_vec,(IGRdouble *)&tra_mat[0][0],&sca_val,matrix,inv_mat,EMmsg);
	if(*EMmsg !=0) {
		*EMmsg = EMS_E_BSerror;
		goto wrapup;
	}
wrapup:
	return;
}

#define FIRST 0
method EMoffset (IGRlong *msg; IGRushort options;
                 IGRshort *mattyp; IGRmatrix mat;
                 struct GRvg_construct *const_args;
                 IGRboolean offset_inward;
                 IGRdouble thickness;
                 IGRint num_spec_thick;
                 IGRdouble *val_spec_thick;
                 struct GRobjid_set *spec_thick_sf_set;
                 IGRint num_nooffsetsfs; GRobjid *nooffsetsfs;
                 IGRchar status_str[];
                 GRobjid *offsetobj;
                 struct EMSerror_help *errkey_list)
{

#ifdef USE_SMART_OFFSET
  /*
   * Obtain the offset objects of the first operand only and return that.
  */
   
  OM_S_CHANSELECT chan_to_comps;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  return (om$send (msg = message EMSsurface.EMoffset (msg, options,
           mattyp, mat, const_args, offset_inward, thickness,
           num_spec_thick, val_spec_thick, spec_thick_sf_set,
           num_nooffsetsfs, nooffsetsfs, status_str, offsetobj,
           errkey_list),
           p_chanselect = &chan_to_comps, from = FIRST, to = FIRST));

#endif

  return (om$send (msg = message EMScompsurf.EMoffset (msg, options,
           mattyp, mat, const_args, offset_inward, thickness,
           num_spec_thick, val_spec_thick, spec_thick_sf_set,
           num_nooffsetsfs, nooffsetsfs, status_str, offsetobj,
           errkey_list),
           mode = OM_e_wrt_message, targetid = my_id));

}

end implementation EMSslboolfea;
