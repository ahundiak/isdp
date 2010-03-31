/* ###################   APOGEE COMPILED   ################## */
/*
  Abstract:

    The input is an object-id of a loopset or any of it's components
    (loop, edge, etc.). This method returns the "cutting" intersection 
    or the "normal" intersection of the input object with itself (the edge) -
    the flag cut_intersect differentiates the two. The intersection(s) on 
    the input object with itself (the edge). The intersection(s) on the
    input object is returned as a linked list of structures of type
    EMintparms (other_int) and a similar linked-list is returned for the 
    intersection(s) on me (my_int). 

    If the "my_int" pointer (or the "other_int" pointer) is not NULL, the
    method assumes an existing linked list and appends it's output to the
    end of this list.


  Change History:

    SS : 03/01/87   Creation
   
    PP : 05/07/87   Modified the method so that if the other object is
                    a bs edge, its bspline geometry is called and the
                    same is trimmed with respect to myself.

    SS : 05/26/87   The other edges geometry is extracted in it's natural
                    form (using EMSedge.EMgetgeom)

    SS : 06/14/88   Support for non-cutting intersections

*/

class implementation EMSedge;

#include "EMS.h"
#include "emsinterdef.h"
#include "emssfint.h"
#include "emserr.h"
#include "msdef.h"
#include "emsdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSedge_class_id, OPP_EMSbsedge_class_id;

method EMobint (IGRlong *msg; struct EMSpartolbasis *mytol_basis;
                GRobjid other_obj; struct EMSpartolbasis *othertol_basis;
                IGRushort options;
                IGRint *num_int; struct EMSsfintedpar **my_int, **other_int)
{
  IGRint stat_OM, i, num_loc;
  IGRlong msg_loc;
  GRclassid other_classid;
  struct EMSpypoint  *polyinters;
  struct EMSproj_info projinfo;
  struct EMSaltdataselect othergeom;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  othergeom.datatype = EMSdata_null;
  othergeom.data.poly.points = NULL;
  othergeom.data.curve.poles = NULL;
  othergeom.data.curve.knots = NULL;
  othergeom.data.curve.weights = NULL;
  polyinters = NULL;

  stat_OM = om$get_classid (objid = other_obj, p_classid = &other_classid);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$is_ancestry_valid (subclassid = other_classid,
             superclassid = OPP_EMSedge_class_id);
  if (stat_OM != OM_S_SUCCESS)
    {
    stat_OM = om$send (msg = message EMSboundary.EMobint (&msg_loc, 
               othertol_basis, my_id, mytol_basis, options, 
               num_int, other_int, my_int), targetid = other_obj);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    }
  else
    {
    stat_OM = om$send (msg = message EMSedge.EMgetgeom (&msg_loc,
               0, MAXINT, FALSE, NULL, &othergeom), targetid = other_obj);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

    num_loc = 0;
    if (othergeom.datatype == EMSdata_curve3d)
      stat_OM = om$send (msg = message EMSedge.EMedbstrimint (&msg_loc,
                 &othergeom.data.curve, NULL, mytol_basis, NULL, options,
                 &num_loc, my_int, other_int ? &polyinters : NULL), 
                 targetid = my_id);
    else
      stat_OM = om$send (msg = message EMSedge.EMedpytrimint (&msg_loc, 
                 &othergeom.data.poly, NULL, mytol_basis, NULL, options,
                 &num_loc, my_int, other_int ? &polyinters : NULL),
                 targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

    if (num_loc)
      {
      if (other_int)
        {
        for (i=0; i<num_loc; i++)
          {
          stat_OM = om$send (msg = message EMSedge.EMptproject 
                     (&msg_loc, polyinters->point, 1, &projinfo, NULL,
                     othertol_basis), targetid = other_obj);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    
          EMmkeparlist (&msg_loc, other_int, projinfo.location, other_obj,
           projinfo.param.span_inx, projinfo.param.param, 
           polyinters->point, NULL, FALSE);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
           
          polyinters = polyinters->next;
          }
        }
      (*num_int) += num_loc;
      }
    }  

ret_end:
  if (othergeom.datatype == EMSdata_poly2d)
    {
    if (othergeom.data.poly.points)
      om$dealloc (ptr = othergeom.data.poly.points);
    }
  else if (othergeom.datatype == EMSdata_curve3d)
    {
    if (othergeom.data.curve.poles)
      om$dealloc (ptr = othergeom.data.curve.poles);
    if (othergeom.data.curve.knots)
      om$dealloc (ptr = othergeom.data.curve.knots);
    if (othergeom.data.curve.weights)
      om$dealloc (ptr = othergeom.data.curve.weights);
    }

  if (!EMSerror (stat_OM) && !my_int && !other_int && (*num_int))
    stat_OM = OM_I_STOP_SENDING;
  EMWRAPUP (*msg, stat_OM, "EMSedge.EMobint");
  return (stat_OM);
}

end implementation EMSedge;
