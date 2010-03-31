/*
 This file contains the following 3 functions:

 EFrapid_make_face()
 EFradid_lift_face()
 EFrapic_make_and_lift_face()

 This functions are documented in there respective headers
 and were written to support the command object ECfast_lift().

 Description

 This function makes one or more faces on the input surface.

 Limitations

 It is expected that the input curves are closed and planar.
 Ambiguous grouping conditions are not supported and if this
 condition arises it is considered to be an error.
 This function is very much a subset of the functionality provided
 for in the make face command.  It was intended to work for
 a very simple subset of the general problem.

 History

 07/26/88 : rlw : Creation date
 09/15/88 : rlw : Modified the logic to determine the object id of the
                  made face.  Due to large ranges of bs edges (conics)
                  sometimes make face does not return the id I want.
 11/06/89 : BL	: Added some code to get the final made_face id.
 11/15/89 : BL  : Modified the code to get the correct made_face id.
 12/11/89 : RC  : Modified the logic to get the correct made_face id. 
                  The earlier logic was failing incase the make_face 
                  profile is off the surface.
 01/30/90 : RC  : Added code to align the profile and the surface's 
                  points along the xy plane before invoking BSpt_in_cv()
                  as this function only works for curves lying on
                  xy_plane.

 06/01/92 : Vadiraj : Modified for message subsystem compliance.
 07/02/93 :  Sudha  : Modified for BSprototypes ansification
 */

class implementation EMSsubbs;

#include "EMS.h"
#include "EMSbnddef.h"		/* Required by EMSbnd.h */
#include "EMSbnd.h"		/* Required by one of the messages */
#include "EMSlm.h"		/* Has the ambiguous grouping structure */
#include "EMSlmdef.h"		/* Make face defines */
#include "EMSmsgdef.h"		/* EMS_I_NeedGrpInfo is defined here */
#include "bsparameters.h"
#include "bserr.h"
#include "emsmapdef.h"
#include "EC_P.h"
#include "EC_I.h"
#include "EC_E.h"
#include "EC_S.h"
#include "msdef.h"
#include "msmacros.h"

#include "EMSdef.h"		/* struct EMparms */
#include "EMSconstruct.h"	/* EMS_GET_POS_ORIENT */
#include "EMSopt.h"		/* EMS_DO_DISPLAY */
#include "matypemx.h"
#include "marptsxfo.h"
#include "maoptsxfo.h"
#include "maidmx.h"
#include "bstst_plan.h"
#include "bstagsort.h"
#include "bspt_in_cv.h"
#include "bsfreecv.h"
#include "bsalloccv.h"

extern OMuword OPP_EMSsubbs_class_id, OPP_GRbcsubbc_class_id;

from EMSsf_lift import EMlift_face;
from EMSsfmkface import EMmake_face_execute;
from EMSsfmkface import EMgraceful_exit;
from EMSsfdpr import EMadd;
from EMSboundary import EMget_objid;

IGRlong EFrapid_make_face(
		/* Input arguments */
 surface_lc_info,		/* Locate information for the surface */
 number_of_curves,		/* Number of faces to make */
 curves_lc_info,		/* Curves defining the faces to be made */
 construct_list,		/* Standard list used to build new sf */
 top_state_before,		/* Top node before make face */
 my_stupid_id,			/* Caller's object id */
		/* Output arguments */
 top_state_after,		/* Top node after make face */
 made_face,			/* Object id of made face surface */
 msg)				/* Errror return code */

struct		GRlc_info *surface_lc_info;
IGRlong		number_of_curves;
struct		GRlc_info curves_lc_info[];
struct		GRvg_construct *construct_list;
struct		GRid *top_state_before;
GRobjid		my_stupid_id;
struct		GRid *top_state_after;
struct		GRid *made_face;
IGRlong		*msg;

{
 extern		void UI_status(), UI_error();
 OMuword	space_number;
 IGRlong	sts;
 GRobjid	original_ls_id;
 struct		GRmd_env *md_env;
 struct		GRid *surface_id;
 struct IGRbsp_curve  *boundary;
 struct IGRbsp_surface *sf_geom = NULL;

/*
 * Initialize
 */
 *msg = EMS_S_Success;
 md_env = &surface_lc_info->module_info;
 surface_id = &surface_lc_info->located_obj;
 space_number = surface_id->osnum;
 boundary = NULL;

/*
 * Get the objid of the loopset on the surface that the
 * face is to be made on.
 */
 original_ls_id = NULL_OBJID;
 sts = om$send(
   msg = message EMSsubbs.EMpassloop(
    msg,
    message EMSboundary.EMget_objid(
     msg,
     &original_ls_id)),
    senderid = my_stupid_id,
    targetid = surface_id->objid,
    targetos = space_number);
  if (! (1 & sts)) goto wrapup;
/*
 * Make the face
 */
 {
  IGRlong	number_of_points, number_of_bad_curves;
  IGRlong	process_phase;
  IGRpoint	*points;
  struct	EMSmkf_grouping_info grp_info;

  points = NULL;
  number_of_points = 0;
  number_of_bad_curves = 0;
  process_phase = EMS_PROCESS_PHASE1;
  sts = om$send(
    msg = message EMSsurface.EMmake_face(
     msg,
     message EMSsfmkface.EMmake_face_execute(
      msg,
      *surface_id,
      md_env,
      number_of_curves,
      curves_lc_info,
      construct_list,
      &number_of_points,
      &points,
      TRUE,				/* want_bad_curves */
      &number_of_bad_curves,
      NULL,				/* bad curve indices */
      TRUE,				/* want_status_messages */
      process_phase,
      (IGRchar *) &grp_info,
      EMS_DO_DISPLAY, NULL, NULL, NULL),
     top_state_after),
    senderid = my_stupid_id,
    targetid = top_state_before->objid,
    targetos = space_number);
/*
 * Process the error, if any
 */
  if (! (1 & sts & *msg))
   {
    switch (*msg)
     {
      case EMS_E_NoValidBnd:
       ex$message(msgnumb=EMS_F_0003);
       break;
      case EMS_E_NoTrimBnd:
       ex$message(msgnumb=EMS_E_NoValidTrmBound);
       break;
      case  EMS_E_MkfCollapse:
       ex$message(msgnumb=EMS_E_MkfaceCollError);
       break;
      case EMS_E_MkfGrouping:
       ex$message(msgnumb=EMS_E_MkfaceGrpnError);
       break;
      case EMS_I_NeedGrpInfo:
       {
        IGRboolean	world_flag;
        IGRlong		loc_msg;
        struct		GRmdenv_info *mdenv_info;
        struct		EMSpartolbasis partolbasis;

        ex$message(msgnumb=EMS_I_AmbGrpnNotSupp);
        mdenv_info = &md_env->md_env;
        world_flag = TRUE;
        partolbasis.in_world = world_flag;
        partolbasis.is_valid = TRUE;
        partolbasis.mattyp = &mdenv_info->matrix_type;
        partolbasis.mat = mdenv_info->matrix;
        sts = om$send(
          msg = message EMSsubbs.EMpartolbasis(
           &loc_msg,
           &mdenv_info->matrix_type,
           mdenv_info->matrix,
           &world_flag,
           FALSE,
           &partolbasis.tol),
          senderid = my_stupid_id,
          targetid = surface_id->objid,
          targetos = space_number);
        if (1 & sts)
         {
          sts = om$send(
            msg = message EMSsfmkface.EMgraceful_exit(
             &loc_msg,
             &partolbasis,
             md_env,
             grp_info.loops_trim_info,
             grp_info.num_trim_info,
             NULL,
             NULL,
             grp_info.gr1_ls_id,
             grp_info.gr2_ls_id,
             *surface_id,
             grp_info.sf_org_ls,
             grp_info.sf_org_lps,
             grp_info.num_sf_org_lps,
             NULL_OBJID, EMS_DO_DISPLAY),
            senderid = my_stupid_id,
            targetid = top_state_after->objid,
            targetos = space_number);
         } /* if (1 & sts) */
        if (! (1 & sts)) 
         *msg = EMS_E_MkfGrExit;
        else
         *msg = EMS_E_NoValidBnd;
       }
       break;
      default:
       if (1 & *msg)		/* If the send itself failed */
        *msg = EMS_E_Fail;
       break;
     } /* switch (*msg) */
    if (*msg == EMS_E_MkfGrExit)
     ex$message(msgnumb=EMS_S_ModCouNotBeRec)  
    else
     ex$message(msgnumb=EMS_S_ModelIsRec);
   } /* if (! (1 & sts & *msg)) */
/*
 * Free memory for bad data
 */
  if (number_of_points &&
      points) free(points);
/*
 * Process errors.
 */
  if (! (1 & *msg)) goto wrapup;
 }
/*
 * Add the make face to the tree
 */
 {
  IGRushort	add_option;

  add_option = 0;
  sts = om$send(
    msg = message EMSsfdpr.EMadd(
     msg,
     top_state_before,		/* Active state */
     NULL,			/* Saved state */
     md_env,
     &add_option),
    senderid = my_stupid_id,
    targetid = top_state_after->objid,
    targetos = space_number);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * The only thing left to do is to find out the object id
 * of the made face.  We do this by asking the the top
 * local mod state for a list of surface id's excluding
 * the surface on which we made the face.  It should only
 * return 1 id and that id should be the made face.
 */
 {
  extern		void EFgetobjids();
  OMuword		eligible_classes;
  OM_S_CHANSELECT	channel_selector;
  IGRlong		number_of_ids;
  struct		GRid *return_GRids;

  sts = EMmake_chanselect (GRcmpowner_to_components, &channel_selector);
   if (! (1 & sts))
    {
     *msg = EMS_E_Fail;
     goto wrapup;
    }
  number_of_ids = 0;
  return_GRids = NULL;
  eligible_classes = OPP_EMSsubbs_class_id;
  EFgetobjids(
    msg,				/* Error return code */
    top_state_after,			/* State being questioned */
    &channel_selector,			/* Channel to search */
    &return_GRids,			/* What was found */
    &number_of_ids,			/* How many were found? */
    eligible_classes,			/* Only EMSsubbs is eligible */
    surface_id,				/* Don't return the original surface */
    1);					/* Only 1 thing rejected */
   if (! (1 & *msg)) goto wrapup;
/*
 * Usually the id returned will be the one of the made face.
 * If the original surface had no topology then it will definitely
 * be the made face.  If the original surface had topology and
 * the area of the made face (based on edge ranges) is greater than
 * the area of the original surface then Chopra will do the opposite
 * of what I want.  In this case we need to determine on which of the
 * two surfaces the original loopset lies as this is the surface
 * which we don't want.
 */

/* 
 11/06/89 : BL : I added the following code to make sure the final 
                 made_face is really inside the closed-planar boundaries.
 12/11/89 : RC : Modified the logic to result in correct face even if
                 the input boundary is off the surface.
*/
  if(number_of_ids == 1)
  { 
    IGRboolean   found, pos_orient, status;
    OMuword    input_cv_class = OPP_GRbcsubbc_class_id, pj_cv_class;
    IGRshort   modmat_type, xmat_type;
    IGRint     i, j, in_boundary;
    IGRlong    buf_size, msg_loc, max_buf_size, sf_size, num_pts;
    IGRmatrix  module_mat, xmat;
    IGRdouble   sf_points[9], point_on_plane[3];
    IGRvector   normal_vector;
    struct IGRplane plane;
    struct IGRbsp_curve *pj_cv;
    extern IGRlong EFproject_curve_onto_plane();
    extern void EMtoplnxform();

    for(max_buf_size = 0, i = 0 ; i < number_of_curves ; ++i)
    {
      sts = om$send(msg = message GRvg.GRgetsize(msg, 
		&curves_lc_info[i].module_info.md_env.matrix_type, 
		curves_lc_info[i].module_info.md_env.matrix, &buf_size),
		senderid = my_stupid_id,
		targetid = curves_lc_info[i].located_obj.objid,
		targetos = curves_lc_info[i].located_obj.osnum);
      if(! (1 & sts & *msg)) goto wrapup;

      max_buf_size = buf_size > max_buf_size ? buf_size : max_buf_size;

    } /* for */

    boundary = (struct IGRbsp_curve *) om$malloc(size = max_buf_size);
    if(!boundary) goto wrapup;

    sts = om$send(msg = message EMSsubbs.EMget_point_on_surface(msg,
   	               &surface_lc_info->module_info, 0, 3, sf_points, NULL),
                  senderid = my_stupid_id,
                  targetid = return_GRids->objid,
                  targetos = return_GRids->osnum);
    if(! (1 & sts & *msg)) goto wrapup;

    sts = om$send (msg = message GRvg.GRgetsize (msg, 
                    &md_env->md_env.matrix_type, 
                    md_env->md_env.matrix, &sf_size),
                  senderid = my_stupid_id,
                  targetid = return_GRids->objid,
                  targetos = return_GRids->osnum);
    if(! (1 & sts & *msg)) goto wrapup;

    sf_geom = (struct IGRbsp_surface *) om$malloc (size = sf_size);
    if(!sf_geom) goto wrapup;

    sts = om$send(msg = message GRvg.GRgetgeom(msg,
                   &md_env->md_env.matrix_type, md_env->md_env.matrix, 
                   (IGRchar *) sf_geom),
                  senderid = my_stupid_id,
                  targetid = return_GRids->objid,
                  targetos = return_GRids->osnum);
    if(! (1 & sts & *msg)) goto wrapup;
        
    BStst_plan (sf_geom->u_num_poles * sf_geom->v_num_poles,
                sf_geom->poles, sf_geom->weights, &sf_geom->planar,
                normal_vector, &msg_loc);
    if (msg_loc != 0) goto wrapup;

    input_cv_class = OPP_GRbcsubbc_class_id;

    for (i = 0; i < 3; i++)
    {
     point_on_plane[i] = sf_geom->poles[i];
     if (sf_geom->rational)
      point_on_plane[i] /= sf_geom->weights[0]; 
    }

    plane.point = point_on_plane;
    plane.normal = normal_vector;

    /*
     * Since, BSpt_in_cv() routine only handles xy_plane curves,
     * We need to transform the projected curve and the surface's
     * points to the xy_plane before invoking this function.
     */

    status = MAidmx (msg, module_mat);
    modmat_type = MAIDMX;

    EMtoplnxform (msg, plane.point, plane.normal, &modmat_type, 
                  module_mat, &xmat_type, xmat, NULL, NULL, NULL);
    if (!(1 & *msg)) goto wrapup;
 
    status = MAtypemx (msg, xmat, &xmat_type);
    if (!(1 & *msg)) goto wrapup;

    num_pts = 3;
    status = MAoptsxform (msg, &num_pts, &xmat_type, xmat, sf_points,
                          sf_points);
    if (!status || !(1 & *msg)) goto wrapup;

    for(i = 0 , found = FALSE; !found && i < number_of_curves ; ++i)
    {
     sts = om$send(msg = message GRvg.GRgetgeom(msg,
                    &curves_lc_info[i].module_info.md_env.matrix_type, 
                    curves_lc_info[i].module_info.md_env.matrix, 
                    (IGRchar *) boundary),
                   senderid = my_stupid_id,
                   targetid = curves_lc_info[i].located_obj.objid,
                   targetos = curves_lc_info[i].located_obj.osnum);
     if(! (1 & sts & *msg)) goto wrapup;
                   
     BSalloccv (boundary->order, boundary->num_poles, boundary->rational,
                0, &pj_cv, &msg_loc);
     if (msg_loc != 0) goto wrapup;

     sts = EFproject_curve_onto_plane (NULL, boundary, input_cv_class,
            &plane, normal_vector, NULL_OBJID, pj_cv, &pj_cv_class, msg);
     if (!(1&sts&*msg)) goto wrapup;

     status = MArptsxform (msg, &pj_cv->num_poles, &pj_cv->rational,
              pj_cv->rational ? pj_cv->weights : NULL, xmat, pj_cv->poles,
              pj_cv->poles);
     if (!status || !(1 & *msg)) goto wrapup;

     for (j = 0; !found && j < 3; j++)
     {
      BSpt_in_cv(pj_cv, &sf_points[3*j], FALSE, &pos_orient, 
                 &in_boundary, &msg_loc);
      if(msg_loc != 0) goto wrapup;

      if(in_boundary == 1)  found = TRUE;  /* inside the boundary */

     } /* for (j = 0; !found && j < 3; j++) */

     status = BSfreecv (&msg_loc, pj_cv);

    } /* for(i = 0 , found = FALSE; !found && i < number_of_curves ; */

    if(found)  *made_face = *return_GRids;
    else  *made_face = *surface_id;

/*
    if(original_ls_id != NULL_OBJID)
    {
      GRobjid  final_ls_id;

      sts = om$send(
        msg = message EMSsubbs.EMpassloop(
         msg,
         message EMSboundary.EMget_objid(
          msg,
          &final_ls_id)),
         senderid = my_stupid_id,
         targetid = surface_id->objid,
         targetos = space_number);
       if (! (1 & sts)) goto wrapup;
      if (original_ls_id != final_ls_id)
       *made_face = *surface_id;
     }  if (original_ls_id != NULL_OBJID) 
*/
  }
  else
   *msg = EMS_E_Fail;
  if (number_of_ids &&
      return_GRids) free(return_GRids);
 }
/*
 * eof
 */
wrapup:
 if(boundary)  free(boundary);
 if (sf_geom) om$dealloc (ptr = sf_geom);

 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}

/*
 Description

 This function lifts one or more faces on the input surface.
 The vector, along which the surface is lifted, is determined
 by the normal vector of the surface.  As such, this function
 will only do something meaningful for planar surfaces.

 If the sign of the lift distance is positive then material is
 added.  If the sign of the lift distance is negative then
 material is removed.

 Thoughts

 It would be rather easy to add support for lifting a face through the
 part if the lift methods supported such functionality.

 History

 07/26/88 : rlw : Creation date

 */



IGRlong EFrapid_lift_face(
		/* Input arguments */
 number_of_surfaces,		/* Number of surfaces to be lifted */
 surfaces_to_be_lifted,		/* The surfaces to be lifted */
 lift_distances,		/* Distances to be lifted */
 construct_list,		/* Standard list used to build new sf's */
 top_state_before,		/* Top node before lifts */
 my_stupid_id,			/* Caller's object id */
		/* Output arguments */
 top_state_after,		/* Top node after lifts */
 msg)				/* Errror return code */

IGRlong		number_of_surfaces;
struct		GRlc_info surfaces_to_be_lifted[];
IGRdouble	lift_distances[];
struct		GRvg_construct *construct_list;
struct		GRid *top_state_before;
GRobjid		my_stupid_id;
struct		GRid *top_state_after;
IGRlong		*msg;

{
 IGRlong	sts, i;
/*
 * Initialize
 */
 *msg = EMS_S_Success;
 *top_state_after = *top_state_before;
/*
 * Loop around each of the input surfaces 
 */
{
 IGRushort	options;
 IGRboolean	pos_orient;
 IGRdouble	lift_distance;
 IGRpoint	point, to_point;
 struct	GRmd_env *md_env;
 struct	GRid *id, new_state;
 struct	EMparms parms;

 for (i = 0; i < number_of_surfaces; i++)
 {
   md_env = &surfaces_to_be_lifted[i].module_info;
   id = &surfaces_to_be_lifted[i].located_obj;
   lift_distance = lift_distances[i];
/*
 * First compute a point on the surface and the natural
 * normal at that point.
 */
   sts = om$send(
     msg = message EMSsurface.EMget_point_on_surface(
      msg,
      md_env,
      0,			/* Attempt number */
      1,			/* Only want 1 point */
      point,
      &parms),
     senderid = my_stupid_id,
     targetid = id->objid,
     targetos = id->osnum);
    if (! (1 & sts)) goto wrapup;
/*
 * Find out if the surface has positive orientation
 */
   options = EMS_GET_POS_ORIENT;
   sts = om$send(
     msg = message EMSsurface.EMalgnnrml(
      msg,
      options,
      &pos_orient,
      NULL,			/* I need no orientation point */
      NULL),			/* Module enviroment is not necessary */
     senderid = my_stupid_id,
     targetid = id->objid,
     targetos = id->osnum);
    if (! (1 & sts)) goto wrapup;
/*
 * Build a "to" point that can be used by
 * the lift method.  I have thought of entering a
 * zero lift distance to signify a through hole, but
 * Chopra does not have the code to support this
 * option yet.  If we were making a through hole
 * then we would want to have a vector which points
 * inside the solid.
 */
   if (pos_orient)		/* Want a vector which points outside */
    {
     parms.normal[0] *= -1.0;
     parms.normal[1] *= -1.0;
     parms.normal[2] *= -1.0;
    }
   to_point[0] = point[0] + lift_distance * parms.normal[0];
   to_point[1] = point[1] + lift_distance * parms.normal[1];
   to_point[2] = point[2] + lift_distance * parms.normal[2];
/*
 * We have all the information necessary to do
 * the lift so let's get to it.
 */
   options = EMS_LC_AUTO_COINCIDENCE;
   sts = om$send(
     msg = message EMSsurface.EM_lift(
      msg,
      message EMSsf_lift.EMlift_face(
       msg,			/* Error return code */
       md_env,			/* Module enviroment */
       construct_list,		/* Construct list for side surfaces */
       point,			/* From point */
       to_point,		/* To point */
       *id,			/* Surface to be lifted */
       options,			/* Lift constraint option */
       NULL,			/* No constraint information */
       EMS_DO_DISPLAY, NULL, NULL),		
      &new_state),		/* New state that is created */
     senderid = my_stupid_id,
     targetid = top_state_after->objid,
     targetos = id->osnum);
    if (! (1 & sts)) goto wrapup;
/*
 * Add the lift face to the tree
 */
   options = 0;
   sts = om$send(
     msg = message EMSsfdpr.EMadd(
      msg,
      top_state_after,		/* Active state */
      NULL,			/* Saved state */
      md_env,
      &options),
     senderid = my_stupid_id,
     targetid = new_state.objid,
     targetos = id->osnum);
    if (! (1 & sts)) goto wrapup;
   *top_state_after = new_state;
  } /* for (i = 0; i < number_of_surfaces; i++) */
 }
/*
 * eof
 */
wrapup:
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}

/*
 Description

 Given a surface and a set of curves with distances this routine
 will use the set of curves to make faces on the surface and then
 lift the faces by the specified distances.  Curves with the same
 lift distance will be placed on the same face.

 The vector, along which the surface is lifted, is determined
 by the normal vector of the surface.  As such, this function
 will only do something meaningful for planar surfaces.

 If the sign of the lift distance is positive then material is
 added.  If the sign of the lift distance is negative then
 material is removed.

 It is expected that the input curves are closed and planar.
 Ambiguous grouping conditions are not supported and if this
 condition arises it is considered to be an error.
 This function is very much a subset of the functionality provided
 for in the make face command.  It was intended to work for
 a very simple subset of the general problem.

 Thoughts

 It would be rather easy to add support for lifting a face through the
 part if the lift methods supported such functionality.

 History

 07/26/88 : rlw : Creation date

 */

struct	rlw_temp_sort
 {
  IGRlong	number_of_curves;
  struct	GRlc_info *curves;
  IGRdouble	distance;
 };

IGRlong EFrapid_make_and_lift_face(
		/* Input arguments */
 md_env,			/* Module enviroment of the datum surface */
 datum_surface,			/* Surface on which makes are to take place */
 number_of_curves,		/* Number of curves to impose as boundaries */
 curves,			/* The curves which are used to make faces */
 lift_distances,		/* The distances the faces are to be lifted */
 construct_list,		/* Standard list used to build new sf's */
 top_state_before,		/* Top node in the state tree before */
 display_env,			/* Enviroment in which displays take place */
 my_stupid_id,			/* Caller's object id */
		/* Output arguments */
 top_state_after,		/* Top node after makes and lifts */
 last_lift,			/* The id of the last lifted surface */
 msg)				/* Errror return code */

struct		GRmd_env *md_env;
struct		GRid *datum_surface;
IGRlong		number_of_curves;
struct		GRlc_info curves[];
IGRdouble	lift_distances[];
struct		GRvg_construct *construct_list;
struct		GRid *top_state_before;
struct		GRmd_env *display_env;
GRobjid		my_stupid_id;
struct		GRid *top_state_after;
struct		GRid *last_lift;
IGRlong		*msg;

{
 IGRlong	sts, *indices, number_of_groups, last_face_index;
 struct		rlw_temp_sort *sorted;
 struct		GRlc_info *new_curves;
/*
 * Initialize
 */
 *msg = EMS_S_Success;
 indices = NULL;
 sorted = NULL;
 new_curves = NULL;
/*
 * Build up a data structure which will tell us which
 * curves should be placed on the same face.  This is
 * done by sorting the distances and then grouping
 * curves with the same distance together.
 */
 {
  IGRboolean	status;
  IGRlong	loc_msg, i, search_index, index, add_group;
  IGRdouble	distance, previous_distance;

  indices = (IGRlong *) malloc(number_of_curves * sizeof(IGRlong));
   if (! indices)
    {
     *msg = EMS_E_NoDynamicMemory;
     goto wrapup;
    }
  status = BStagsort(
    &loc_msg,
    (IGRint *)&number_of_curves,
    lift_distances,
    (IGRint *)indices);
   if (! status)
    {
     *msg = EMS_E_BSerror;
     goto wrapup;
    }
  new_curves = (struct GRlc_info *) malloc(number_of_curves *
    sizeof(struct GRlc_info));
   if (! new_curves)
    {
     *msg = EMS_E_NoDynamicMemory;
     goto wrapup;
    }
  sorted = (struct rlw_temp_sort *) malloc(number_of_curves *
    sizeof(struct rlw_temp_sort));
   if (! sorted)
    {
     *msg = EMS_E_NoDynamicMemory;
     goto wrapup;
    }
  number_of_groups = 0;
  search_index = number_of_curves - 1; /* Find out where the last curve went */
  for (i = 0; i < number_of_curves; i++)
   {
    index = indices[i];
    new_curves[i] = curves[index];
    distance = lift_distances[index];
    if (i &&
        (distance == previous_distance))
     {
      add_group = number_of_groups - 1;
      sorted[add_group].number_of_curves++;
     }
    else
     {
      add_group = number_of_groups;
      sorted[number_of_groups].number_of_curves = 1;
      sorted[number_of_groups].curves = &new_curves[i];
      sorted[number_of_groups].distance = distance;
      previous_distance = distance;
      number_of_groups++;
     }
    if (index == search_index) last_face_index = add_group;
   } /* for (i = 0; i < number_of_curves; i++) */
 }
/*
 * For each group of curves make the required face
 * and then lift it.
 */
 {
  IGRlong	i;
  IGRlong	EFrapid_make_face();	/* Not extern cause it's in the file */
  IGRlong	EFrapid_lift_face();	/* Not extern cause it's in the file */
  struct	GRlc_info surface_for_make_face;
  struct	GRlc_info surface_for_lift_face;
  struct	GRid before, made_face;

  surface_for_make_face.module_info = *md_env;
  surface_for_make_face.located_obj = *datum_surface;
  surface_for_lift_face.module_info = *md_env;
  before = *top_state_before;
  for (i = 0;
       (i < number_of_groups) && (1 & *msg);
       i++)
   {
    sts = EFrapid_make_face(
      &surface_for_make_face,
      sorted[i].number_of_curves,
      sorted[i].curves,
      construct_list,
      &before,
      my_stupid_id,
      top_state_after,
      &made_face,
      msg);
    if (1 & *msg)
     {
      if (i == last_face_index) *last_lift = made_face;
      before = *top_state_after;
      surface_for_lift_face.located_obj = made_face;
      sts = EFrapid_lift_face(
        1,			/* Only 1 surface to be lifted */
        &surface_for_lift_face,
        &sorted[i].distance,
        construct_list,
        &before,
        my_stupid_id,
        top_state_after,
        msg);
      before = *top_state_after;
     }
   } /* for (i = 0; i < number_of_groups; i++) */
 }
/*
 * If one of the make or lifts failed then
 * attempt to recover the model to it's state prior
 * to entering this routine.
 */
 if (! (1 & *msg))
  {
   IGRushort	deactivate_option;
   IGRint	display_count, invoke_count;
   IGRlong	loc_msg;
   GRobjid	*display_ids;

   deactivate_option = EMS_UNDO_DELETE | 
                       EMS_DO_DISPLAY;
   display_count = 0;
   display_ids = NULL;
   invoke_count = 0;
   sts = om$send(
     msg = message EMSsurface.EMmake_active_state(
      &loc_msg,
      &deactivate_option,
      md_env,
      NULL,		/* Active ids after undo */
      NULL,		/* Number of active ids - better be 1 */
      NULL,		/* Space manager for memory on active ids */
      &display_ids,	/* Used for internal management */
      &display_count,	/* Used for internal management */
      &invoke_count),	/* Used for internal management */
     senderid = my_stupid_id,
     targetid = top_state_before->objid,
     targetos = top_state_before->osnum);
    if (! (1 & sts)) goto wrapup;
   *top_state_after = *top_state_before;
  } /* if (! (1 & *msg)) */
/*
 * eof
 */
wrapup:
 if (indices) free(indices);
 if (sorted) free(sorted);
 if (new_curves) free(new_curves);
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}

end implementation EMSsubbs; 
