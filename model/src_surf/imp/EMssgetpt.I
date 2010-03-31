/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "msdef.h"
#include "EMSdef.h" /* For struct EMparms */
#include "EMSprop.h" /* For loop properties */
#include "bsparameters.h" /* for BSTOLLENVEC .. */
#include "bserr.h" /* For math errors */
#include "gocmacros.h"                  /* Has GRgetabsg macro */

#define MAX_ATTEMPTS 3
#define MAX_NO_POINTS 10

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSboundary import EMtree_traverse;
from EMSloop import EMptinside;

method EMget_point_on_surface (IGRlong *EMmsg;
                                struct GRmd_env *md_env;
                                IGRuint attempt_no;
                                IGRint number_of_points;
                                IGRdouble *points;
                                struct EMparms *params)

/* *************************************************************************
 
Description

    This message gets points lying on the area region of the surface, when
    supplied with the module environment of the surface.

    Input
     md_env - module environment of the surface
     attempt_no - Number of attempts the caller  has tried before.  This is 
           a mechanism by which the caller can ensure that he does
           not get the same points by calling the method again. If the caller
           is calling this method for the first time, the attempt_no
           should be set to 0. If he is interested in random points, he
           may set the attempt_no to be a random number ranging from 0
           to MAXINT.
     number_of_points - The number of points the caller is interested in

     Output
      EMmsg - Completion message
      points - The points that are returned. Memory should be preallocated.
               Maybe set to NULL, if the caller is not interested.
      params - Information about the u, and v parameter corresponding to
               the point, the normal vector  and the surface id on 
               which the point exists etc.
               It may be set to NULL, if the caller is not interested in 
               this field. The memory should be preallocated if the caller is
               interested in this field.

Notes
     Upon exit the completion code will be one of the following:
       EMS_S_Success - if successful
       EMS_E_DynamicMemoryAllocated - if unsucessful in allocating memory
       EMS_E_LoopsetError - If the determination of an internal point on
                            the loopset was not possible within the maximum
                            number of tries allowed. This could have been 
                            due to the loops under the loopset being
                            degenerate. 
       EMS_E_SurfaceError - if the method could not get the abstract
                            geometry.
       EMS_E_Fail - if the send to the topology methods was not successful
       EMS_E_BSerror - if there is a math error

History
     PP : 12/07/87  Creation
     NP : 08/26/92  Modified for ANSI compliance. Added typecasts etc.

************************************************************************ */
{
 IGRlong status,msg_loc, msg_loc1;
 IGRint i;
 IGRuint count;
 GRclassid eligible_classids;
 BSrc  rc;
 IGRushort all_mask = 0;
 IGRboolean in_world = TRUE;      
 OM_S_CHANSELECT to_loopset;
 IGRdouble *uvpts,atleast_dist,disttol;
 IGRdouble uvbuffer [MAX_NO_POINTS][2];
 IGRint max_no_tries;
 IGRpoint base;
 IGRboolean found_point = FALSE;
 struct EMSpartolbasis partolbasis;
 struct IGRbsp_surface *surf;
  extern  void BSsfeval ();

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 msg_loc = EMS_S_Success;
 msg_loc1 = EMS_S_Success;
 surf = NULL;
 uvpts = NULL;

 GRgetabsg (&msg_loc, &md_env->md_env.matrix_type, md_env->md_env.matrix,
            (IGRchar **)&surf,i);
 EMerr_hndlr (EMis_error (msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);

 status = om$send (msg = message EMSsubbs.EMpartolbasis(EMmsg, 
                         &md_env->md_env.matrix_type,
                         md_env->md_env.matrix, &in_world, TRUE,
                         &partolbasis.tol),
                   targetid = my_id); 
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);

 status = EFextract_par (BSTOLLENVEC,partolbasis.tol, &disttol, &rc);

 partolbasis.is_valid = TRUE;
 partolbasis.in_world = TRUE;

 all_mask |= EMLP_EXTERNAL | EMLP_PLOOP;

 to_loopset.type = OM_e_addr;
 to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;
 
 if (number_of_points > MAX_NO_POINTS)
 {
  uvpts = (IGRdouble *)om$malloc (size = sizeof (IGRdouble) * 2 * number_of_points);
  EMerr_hndlr (!uvpts, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 else
  uvpts = &uvbuffer[0][0];

 status = om$get_channel_count (p_chanselect = &to_loopset,
            object = me, count = &count);
 EMomerr_exit (status, wrapup);

 if (!count)
 {
  status = om$send (msg = message EMSsubbs.EMmk_nat_bdry (EMmsg, 
                          &md_env->md_env, NULL),
                    targetid = my_id);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 eligible_classids = OPP_EMSloop_class_id;

max_no_tries = 0;
found_point = FALSE;

while (!found_point && max_no_tries < MAX_ATTEMPTS)
{
 status = om$send (msg = message EMSboundary.EMtree_traverse ( &msg_loc,
                         message EMSloop.EMptinside (&msg_loc1, &attempt_no, 
                         &partolbasis,  number_of_points, uvpts, &atleast_dist),
                         2, 1, &eligible_classids, TRUE, all_mask, NULL,
                         NULL),
                   p_chanselect = &to_loopset);
 EMerr_hndlr (!(1&msg_loc1), *EMmsg, EMS_E_LoopsetError, wrapup);
 EMerr_hndlr (!(1&msg_loc), *EMmsg, EMS_E_LoopsetError, wrapup);
 EMerr_hndlr (!(1&status), *EMmsg, EMS_E_LoopsetError, wrapup);
 if (atleast_dist > disttol)
  found_point = TRUE;
 ++attempt_no;
 ++max_no_tries;
}

if (!found_point)
{
 *EMmsg = EMS_E_LoopsetError;
 goto wrapup;
}

 for (i=0; i < number_of_points; i++)
 {
  if (points)
  {
    BSsfeval (surf, uvpts[2*i], uvpts[2*i + 1], 0, &points[3*i], &rc);
    EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
  }

  if (params)
  {
   params[i].u = uvpts[2*i];
   params[i].v = uvpts[2*i + 1];
   params[i].leaf_id.osnum = OM_Gw_current_OS;
   params[i].leaf_id.objid = my_id;
   BSsfarrevn (&rc, surf, 1, &uvpts[2*i], 1, &uvpts[2*i + 1], base,
               params[i].normal);
   EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

  }
 }

wrapup: 
 EMWRAPUP (*EMmsg, status, "In EMSsubbs:EMget_point_on_surface error");
 if (uvpts != (IGRdouble *)uvbuffer)
   om$dealloc (ptr = (IGRchar *) uvpts);

 return (status);
}

end implementation EMSsubbs;
