/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsolid;

# include "EMS.h"
# include "EMSprop.h"
# include "EMSerrordef.h"
# include "emsmacros.h"
# include "bserr.h"
# include "emsgetgeom.h"  
# include "msdef.h"
# include "maerr.h"
# include "EMSconstruct.h" /* for REVERSED AND NOT_REVERSED */
# include "emsedgedef.h" /* for edge type definitions */
# include "OMmacros.h"

#include "bststcvdegn.h"
#include "bsprj_cv_pl.h"
#include "bsnorvec.h"
#include "bsfreecv.h"
#include "bsconstprcv.h"
#include "bsalloccv.h"

extern OMuword OPP_EMSgenbs_class_id;

from EMSsubbs import EMruled_surface;
from EMSgenbs import EMbs4cvs;
from EMSsubbs import EMmk_nat_bdry;
from EMSgencompsf import EMmake_comp;

# define NO_OF_FACES 6
# define NO_OF_CONTROL_POINTS 0

# define CONSTANTU 1
# define CONSTANTV 2
# define GENERATING_SURF 0
# define SIDE_SURF1 1
# define SIDE_SURF2 2
# define SIDE_SURF3 3
# define SIDE_SURF4 4
# define PROJECTED_SURF 5

method EMproj_4_bnd_on_plane (IGRlong *msg;
                              struct IGRbsp_surface *surf;
                              struct GRlc_info *located_surf;
                              IGRpoint point_on_plane;
                              IGRvector plane_normal;
                              IGRvector projection_vector;
                              struct GRvg_construct *construct_list)

                   
/* ********************************************************************

Description

            This method constructs a solid of projection when specified a 
            surface with four natural non-degenerate boundaries and an
            unbounded plane on which the projection is to be done.  This
            method accepts both the surface structure or located_surf as
            input.  If the surface structure is inputted located_surf 
            argument is set to NULL and viceversa.

            Input Arguments

            surf   -    buffer containing the surface that is to be
                        projected onto the plane. 
            located_surf - the locate info of the surface which is to
                        be projected
            point_on_plane - a point lying on the plane on which the
                        projection is to be done
            plane_normal - normal vector of the plane
            projection_vector - direction alongwhich the projection is
                        to be done.
            construct_list - construction information

            Output Arguments
 
            msg - completion code

Notes
            Upon exit the completion code will be one of the following:

            EMS_S_Success -  if successful
            EMS_E_NoStackMemory - if insufficient memory
            EMS_E_Fail - severe failure
            EMS_E_InvalidArg - if invalid arguments

            This routine requires the surface to be made up of four
            natural, non-degenerate boundaries.

            Below the topology of the solid is described:

             generating_surf : surface 1
             Side_surf1 : surface 2
             side_surf2 : surface 3
             side_surf3 : surface 4
             side_surf4 : surface 5
             projected_surf : surface 6

Assumptions
            The plane does not intersect the projecting surface.


History
	   Sudha      :     07/01/93    Modified for BSprototype ansification
           Jack       :    12-Feb-93    Changed om$send EMSgenbs.EMruled_surface
                                        to EMSsubbs.EMruled_surface since message
                                        def. was moved.
           pp         :     03/16/90    Made modifications to take
                                        care of the case where the corners
                                        of the projecting surface were
                                        intersecting the plane on which
                                        they were projected.
          
           PP         :     10/10/87    Modified the method to enable
                                        setting of the edge types as free
                                        form curves. 
           PP         :     08/21/87    Changed the arguments to the 
                                        EMruled surface method
           PP         :     02/04/87    Genesis


***************************************************************** */

{

 IGRint                  num_faces;
 IGRlong                i;
 IGRshort               option;
 IGRlong                status;    /* OM return status */
 
 IGRboolean             bssts;     /* Math return status */
 IGRboolean             degn;      /* test for degeneracy */
 IGRboolean             tst_plan = FALSE;  
                                   /* to test the planarity of the constant
                                      parametric curve */
 BSrc                   rc;        /* Math completion code */
 
                     
 IGRlong                cln_sts, cleanup_msg;

 IGRdouble              uv;        /* for extracting iso parametric curve */

 OMuword                generating_surf_classid;
                                   /* class id of the generating 
                                      surface */

 struct IGRbsp_curve    *generating_curve1,
                                   /* u0 curve */
                        *generating_curve2,
                                   /* u1 curve */
                        *generating_curve3,
                                   /* v0 curve */
                        *generating_curve4;
                                   /* v1 curve */

 struct IGRbsp_curve    *projected_curve1,
                                   /* projected u0 curve */
                        *projected_curve2,
                                   /* projected u1 curve */
                        *projected_curve3,
                                   /* projected v0 curve */
                        *projected_curve4;
                                   /* projected v1 curve */

 struct IGRbsp_surface  *generating_surf; 
                                   /* the surface being projected */

 OM_S_OBJID             surface_objid[NO_OF_FACES];
 struct GRid            temp_GRid, my_GRid;

/* **********************************

   Initialisation

   ********************************** */
  
 *msg = EMS_S_Success;
 status = OM_S_SUCCESS;

 generating_surf = NULL;
 generating_curve1 = NULL;   
 generating_curve2 = NULL;   
 generating_curve3 = NULL;   
 generating_curve4 = NULL;   

 projected_curve1 = NULL;
 projected_curve2 = NULL;
 projected_curve3 = NULL;
 projected_curve4 = NULL;
 num_faces = NO_OF_FACES;

 temp_GRid.objid = NULL_OBJID;

 for (i=0 ; i < NO_OF_FACES; i++)
   surface_objid[i] = NULL_OBJID;

 bssts = BSnorvec (&rc, plane_normal);
 if (!bssts)
  {
   *msg = EMS_E_InvalidArg;
   goto wrapup;
  }

 bssts = BSnorvec (&rc, projection_vector);
 if (!bssts)
  {
   *msg = EMS_E_InvalidArg;
   goto wrapup;
  }


 if (surf)
 {
   generating_surf = surf;
 }
 else if (located_surf)
 {
   EMS_GET_GEOMETRY(status, msg, located_surf, FALSE, generating_surf)
   if (! (1 & status & *msg)) goto wrapup;
 }
 else
 {
   *msg = EMS_E_InvalidArg;
   goto wrapup;
 }

/* **********************

   Allocate memory for the generating_curves and projected_curves

   ********************** */

 BSalloccv (generating_surf->v_order, generating_surf->v_num_poles,
            generating_surf->rational, NULL, &generating_curve1, &rc);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);


 BSalloccv (generating_surf->v_order, generating_surf->v_num_poles,
            generating_surf->rational, NULL, &generating_curve2, &rc);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

 BSalloccv (generating_surf->u_order, generating_surf->u_num_poles,
            generating_surf->rational, NULL, &generating_curve3, &rc);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

 BSalloccv (generating_surf->u_order, generating_surf->u_num_poles,
            generating_surf->rational, NULL, &generating_curve4, &rc);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

 BSalloccv (generating_surf->v_order, generating_surf->v_num_poles,
            generating_surf->rational, NULL, &projected_curve1, &rc);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

 BSalloccv (generating_surf->v_order, generating_surf->v_num_poles,
            generating_surf->rational, NULL, &projected_curve2, &rc);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

 BSalloccv (generating_surf->u_order, generating_surf->u_num_poles,
            generating_surf->rational, NULL, &projected_curve3, &rc);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

 BSalloccv (generating_surf->u_order, generating_surf->u_num_poles,
            generating_surf->rational, NULL, &projected_curve4, &rc);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

/* ***************************************
   Get the genenerating curve geometry
   *************************************** */

 uv = 0.0;
 option = CONSTANTU;
 bssts = BSconstprcv (&rc, generating_surf, &option, &uv, 
                      &tst_plan, generating_curve1);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

 (void) BStstcvdegn (generating_curve1, &degn, &rc);
 if ( rc != BSSUCC)
 {
  *msg = EMS_E_Fail;
  goto wrapup;
 }

 if (degn)
 {
  *msg = EMS_E_DegenerateEdge;
  goto wrapup;
 }

 uv = 1.0;
 bssts = BSconstprcv (&rc, generating_surf, &option, &uv, 
                      &tst_plan, generating_curve2);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

 (void) BStstcvdegn (generating_curve2, &degn, &rc);
 if ( rc != BSSUCC)
 {
  *msg = EMS_E_Fail;
  goto wrapup;
 }

 if (degn)
 {
  *msg = EMS_E_DegenerateEdge;
  goto wrapup;
 }
 

 uv = 0.0;
 option = CONSTANTV;
 bssts = BSconstprcv (&rc, generating_surf, &option, &uv, 
                      &tst_plan, generating_curve3);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

 (void) BStstcvdegn (generating_curve3, &degn, &rc);
 if ( rc != BSSUCC)
 {
  *msg = EMS_E_Fail;
  goto wrapup;
 }

 if (degn)
 {
  *msg = EMS_E_DegenerateEdge;
  goto wrapup;
 }
 

 uv = 1.0;
 bssts = BSconstprcv (&rc, generating_surf, &option, &uv, 
                      &tst_plan, generating_curve4);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

 (void) BStstcvdegn (generating_curve4, &degn, &rc);
 if ( rc != BSSUCC)
 {
  *msg = EMS_E_Fail;
  goto wrapup;
 }

 if (degn)
 {
  *msg = EMS_E_DegenerateEdge;
  goto wrapup;
 }
 

/* ***************************************************
   Project the four generating curves on the plane
   *************************************************** */

 bssts = BSprj_cv_pl (&rc, generating_curve1, point_on_plane, plane_normal,
                      projection_vector, projected_curve1);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

 bssts = BSprj_cv_pl (&rc, generating_curve2, point_on_plane, plane_normal,
                      projection_vector, projected_curve2);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

 bssts = BSprj_cv_pl (&rc, generating_curve3, point_on_plane, plane_normal,
                      projection_vector, projected_curve3);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

 bssts = BSprj_cv_pl (&rc, generating_curve4, point_on_plane, plane_normal,
                      projection_vector, projected_curve4);
 EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

/*
 * First construct the bottom plane
 */

 status = om$construct (classid = OPP_EMSgenbs_class_id,
                        p_objid = &surface_objid[PROJECTED_SURF],
                        msg = message EMSgenbs.EMbs4cvs ( msg, NULL,
                              projected_curve3, NULL,  projected_curve2,
                              NULL, projected_curve4 , NULL,
                              projected_curve1,  
                              NULL,
                              construct_list));
 EMerr_hndlr (!(1 & status & *msg), *msg, EMS_E_Fail,wrapup);

/* Construct the top surface object */

 status = om$get_classid (osnum = located_surf->located_obj.osnum,
                          objid = located_surf->located_obj.objid,
                          p_classid = &generating_surf_classid);
 if (! (1 & status )) goto wrapup;


 construct_list->geometry = (IGRchar *) generating_surf;
 construct_list->class_attr = NULL;

 status = om$construct (classid = generating_surf_classid,
                        p_objid = &surface_objid[GENERATING_SURF],
                        msg = message GRgraphics.GRconstruct(construct_list));
 EMerr_hndlr (!(1&status&(*construct_list->msg)),*msg,EMS_E_InvalidArg,wrapup);


 status = om$construct (classid = OPP_EMSgenbs_class_id,
                        p_objid = &surface_objid[SIDE_SURF1],
                        msg = message EMSsubbs.EMruled_surface (
                              generating_curve3, NULL, projected_curve3,
                              NULL, NO_OF_CONTROL_POINTS, NULL, NULL, NULL,
                              FALSE,
                              NULL, NULL, FALSE, FALSE,
                              construct_list,
                              msg));
 EMerr_hndlr (!(1 & status & *msg), *msg, EMS_E_InvalidArg,wrapup);

 status = om$construct (classid = OPP_EMSgenbs_class_id,
                        p_objid = &surface_objid[SIDE_SURF2],
                        msg = message EMSsubbs.EMruled_surface (
                              generating_curve2, NULL, projected_curve2,
                              NULL, NO_OF_CONTROL_POINTS, NULL, NULL, NULL,
                              FALSE,
                              NULL, NULL, FALSE, FALSE,
                              construct_list,
                              msg));
 EMerr_hndlr (!(1 & status & *msg), *msg, EMS_E_InvalidArg,wrapup);

 status = om$construct (classid = OPP_EMSgenbs_class_id,
                        p_objid = &surface_objid[SIDE_SURF3],
                        msg = message EMSsubbs.EMruled_surface (
                              generating_curve4, NULL, projected_curve4,
                              NULL, NO_OF_CONTROL_POINTS, NULL, NULL, NULL,
                              FALSE,
                              NULL, NULL, FALSE, FALSE,
                              construct_list,
                              msg));
 EMerr_hndlr (!(1 & status & *msg), *msg, EMS_E_InvalidArg,wrapup);

 status = om$construct (classid = OPP_EMSgenbs_class_id,
                        p_objid = &surface_objid[SIDE_SURF4],
                        msg = message EMSsubbs.EMruled_surface (
                              generating_curve1, NULL, projected_curve1,
                              NULL, NO_OF_CONTROL_POINTS, NULL, NULL, NULL,
                              FALSE,
                              NULL, NULL, FALSE, FALSE,
                              construct_list,
                              msg));
 EMerr_hndlr (!(1 & status & *msg), *msg, EMS_E_InvalidArg,wrapup);

 for (i=0;i<num_faces;i++)
 {
  status = om$send (msg = message EMSsubbs.EMmk_nat_bdry(msg,
                          &construct_list->env_info->md_env,
                          NULL),
                    targetid = surface_objid[i]);
  EMerr_hndlr (!(1 & status & *msg), *msg, EMS_E_Fail,wrapup);
 }

 construct_list->geometry = NULL;

 status = om$construct(classid = OPP_EMSgencompsf_class_id,
                       p_objid = &temp_GRid.objid,
                       msg = message GRgraphics.GRconstruct(construct_list));
 EMerr_hndlr (!(1 & status & *msg), *msg, EMS_E_OMerror,wrapup);

 status = om$send(msg = message EMSgencompsf.EMmake_comp(msg, 
                          num_faces, surface_objid,
                          construct_list->env_info),
                    targetid = temp_GRid.objid);
 EMerr_hndlr (!(1 & status & *msg), *msg, EMS_E_Fail,wrapup);

 temp_GRid.osnum = OM_Gw_current_OS;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 for (i = 0; i < num_faces; i++)
 {
   status = om$send (msg = message GRconnector.GRdisconn (msg,
                           &temp_GRid),
                     targetid = surface_objid[i]);
   EMerr_hndlr (!(1 & status & *msg), *msg, EMS_E_Fail,wrapup);

   status = om$send (msg = message GRconnector.GRrigidconn (msg,
                           &my_GRid, &i),
                     targetid = surface_objid[i]);
   EMerr_hndlr (!(1 & status & *msg), *msg, EMS_E_Fail,wrapup);
 }

 status = om$send (msg = message EMSsolid.EMorient_yourself(msg,
                         NULL,construct_list->env_info),
                   targetid = my_id);
 EMerr_hndlr (!(1 & status & *msg), *msg, *msg,wrapup);



wrapup:

 if (generating_curve1) BSfreecv (&rc, generating_curve1);
 if (generating_curve2) BSfreecv (&rc, generating_curve2);
 if (generating_curve3) BSfreecv (&rc, generating_curve3);
 if (generating_curve4) BSfreecv (&rc, generating_curve4);

 if (projected_curve1) BSfreecv (&rc, projected_curve1);
 if (projected_curve2) BSfreecv (&rc, projected_curve2);
 if (projected_curve3) BSfreecv (&rc, projected_curve3);
 if (projected_curve4) BSfreecv (&rc, projected_curve4);

 if (!surf && generating_surf) om$dealloc (ptr = (IGRchar *) generating_surf);
 
 if ( ! (1 & status & *msg))
 {
  for (i=0 ; i < NO_OF_FACES; i++)
  {
    cln_sts = om$send (msg = message GRgraphics.GRdelete (&cleanup_msg,
                             construct_list->env_info),
                       targetid = surface_objid[i]);
  }

    cln_sts = om$send (msg = message GRgraphics.GRdelete (&cleanup_msg,
                             construct_list->env_info),
                       targetid = my_id);

  }

 if (temp_GRid.objid != NULL_OBJID)
 {
  cln_sts = om$send (msg = message Root.delete(1),
            targetid = temp_GRid.objid);
 }
                        
 EMWRAPUP (*msg, status, "In EMSsolid: EMproj_4_bnd_on_plane error");
 return (status);

}

end implementation EMSsolid;

