/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRlocate_processing

Description
   This method performs the locate processing for an owner.

   *msg                 IGRlong           completion code
   *cvl                 struct GRlc_cvl   Module and action handler info
   *path                struct GRlc_path  The locate path of objects
   *path_position       IGRint            Position of calling object in
                                          the path structure.
   *owner_eligible      IGRint            If 1 owner is eligible
                                          If 0 owner is not eligible
   *component_eligible  IGRint            If 0 no components are eligible
                                          If 1 all components are eligible
                                          If 2 all but immediate component
                                          are eligible

Return Values
   MSSUCC   -  if successful completion 
   MSFAIL   -  if error occurred

History
   scw   07/23/93   ansi conversion
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "grownerdef.h"
#include "gocmacros.h"

extern IGRint  GRcheckcrit();
extern IGRint  GRlbgeomchk();
extern IGRint  GRacthand();

method GRlocate_processing (IGRlong *msg; struct GRlc_cvl *cvl;
                            struct GRlc_path *path; IGRint *path_position;
                            IGRint *owner_eligible; 
                            IGRint *component_eligible)
{
IGRlong           om_msg;
IGRint            check_geom;
IGRint            eligible_flag;
IGRboolean        world;
IGRshort          dimension = 4;
IGRpoint          origin;
IGRmatrix         window_matrix;
IGRmatrix         inv_window_matrix;
GRrange           range;
OM_S_CHANSELECT   chansel;
struct IGRlbsys   *lb;
struct IGRlbsys   tlb;

   om_msg = OM_S_SUCCESS;
   cvl->msg = MSSUCC;
   *msg = MSSUCC;
   world = FALSE;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  If this is a component up locate then act like an owner.
    *  If this is a owner down locate then act like local bounded system.
    */

   if (*path_position)
   {
      om_msg = om$send (mode = OM_e_wrt_message,
               msg = message GRowner.GRlocate_processing (msg, cvl, path, 
               path_position, owner_eligible, component_eligible),
               targetid = my_id);
   }else
   {
      om_msg = GRcheckcrit (msg, &my_id, cvl->classes, path, 
               path_position, component_eligible, &eligible_flag,
               &check_geom);

      if ((om_msg & 1) && (eligible_flag || *owner_eligible))
      {
         /* 
          *  If the object or its owner is eligible, process the 
          *  geometry, if it has not alread been processed.
          */

         if (check_geom)
         {
            GRgetabsg(msg, &cvl->module.md_env.matrix_type,
               cvl->module.md_env.matrix, (IGRchar **)&lb, i);

            if (me->properties & GRIS_VIEW_INDEP)
            {
               origin[0] = lb->matrix[3];
               origin[1] = lb->matrix[7];
               origin[2] = lb->matrix[11];
               GRget_window_matrix(msg, cvl->button.osnum, 
                  cvl->button.objid, window_matrix, NULL);

               MAtrnmx(msg, &dimension, window_matrix, inv_window_matrix);

               inv_window_matrix[3] = origin[0] - 
                                      (inv_window_matrix[0] * origin[0]
                                      + inv_window_matrix[1] * origin[1] 
                                      + inv_window_matrix[2] * origin[2]);

               inv_window_matrix[7] = origin[1] - 
                                      (inv_window_matrix[4] * origin[0] 
                                      + inv_window_matrix[5] * origin[1] 
                                      + inv_window_matrix[6] * origin[2]);

               inv_window_matrix[11] = origin[2] - 
                                      (inv_window_matrix[8] * origin[0] 
                                      + inv_window_matrix[9] * origin[1] 
                                      + inv_window_matrix[10] * origin[2]);

               MAlbxform (msg, lb, inv_window_matrix, &tlb);

               om$send(msg = message GRgraphics.GRgetrang (msg, NULL, NULL,
                  &world, range),
                  p_chanselect = &chansel, from = NULL, to = NULL);

               tlb.diag_pt1[0] = range[0];
               tlb.diag_pt1[1] = range[1];
               tlb.diag_pt1[2] = range[2];
               tlb.diag_pt2[0] = range[3];
               tlb.diag_pt2[1] = range[4];
               tlb.diag_pt2[2] = range[5];
            }else
            {
               tlb = *lb;
            }

            if (om_msg & *msg & 1)
            {
               om_msg = GRlbgeomchk(msg, cvl, &tlb, &eligible_flag, path,
                        path_position);
            }
         }

         if (om_msg & 1)
         {
            om_msg = GRacthand(msg, cvl, path, path_position, 
                     &eligible_flag);
         }
      }
   }
   return (om_msg);
}
end implementation GRsmhdr;
