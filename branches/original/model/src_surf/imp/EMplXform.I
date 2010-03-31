/* ###################   APOGEE COMPILED   ################## */
/*
Description

 This method ensures that edges type and cross hatching remain
 valid during non-uniform scaling operations.

History

 10/14/88 : rlw : Creation date
 10/20/88 : RC  : Added code to update cross_hatch spacing if
                  one exists.
 01/18/89 : RC  : Converted the common code between EMSplane.EMintcopy
                  and EMSplane.GRxform into a function.
 08/19/92 : NP  : Modified for ANSI compliance. Typecast mismatch.
*/

class implementation EMSplane;

#include "EMS.h"
#include "emssfdef.h"		/* matrix classification codes */
#include "emsedgedef.h"		/* Edge types */
#include "igrtypedef.h"		/* for gocmacros.h  */
#include "godef.h"		/* for gocmacros.h  */
#include "gocmacros.h"		/* GRgetabsg macro  */
#include "emsdef.h"		/* MAXINT */
#include "bserr.h"
#include "bsparameters.h"
#include "EMSfrtdef.h"
#include "EMSopt.h"
#include "bsparameters.h"

from EMSboundary import EMtree_traverse;

method GRxform(
 IGRlong	*EMmsg; 
 struct		GRmd_env *obj_dsenv; 
 IGRshort	*mx_type; 
 IGRmatrix	mx; 
 GRobjid	*newobjid)
{
 IGRlong            sts, modification_type, rc;
 extern IGRlong     EFmatrixClassification();
 IGRboolean	        already_transformed;

/*
 * Initialize
 */

 *EMmsg = EMS_S_Success;
 already_transformed = FALSE;

/*
 * Determine the type of matrix involved
 */

 modification_type = EFmatrixClassification(mx);

/*
 * Uniform and Nonuniform scaling requires some extra work
 */

 if (modification_type == EMSnonuniformTransformation ||
     modification_type == EMSuniformTransformation )
 {
   struct GRlc_info      lc_info;
   struct IGRbsp_surface *old_surface, *new_surface;
   extern void           EFplane_xform_support();

   old_surface = new_surface = NULL;
   already_transformed = TRUE;
   lc_info.located_obj.objid = my_id;
   lc_info.located_obj.osnum = OM_Gw_current_OS;
   lc_info.module_info = *obj_dsenv; 

   sts = EMget_the_geometry(
     &lc_info,
     FALSE,		/* Not a curve */
     FALSE,		/* Not directed */
     FALSE,		/* One large malloc is OK */
     my_id,
     &old_surface,
     EMmsg);
   if (! (1 & sts)) goto wrapup;

   sts = om$send(
       mode = OM_e_wrt_parent,
       msg = message EMSplane.GRxform(
        EMmsg,
        obj_dsenv,
        mx_type,
        mx,
        newobjid),
       targetid = my_id);
   if (! (1 & sts)) goto wrapup;
 
   sts = om$send(			/* Don't use the macro */
       msg = message GRvg.GRgenabsg(
        EMmsg,
        &obj_dsenv->md_env.matrix_type, 
        obj_dsenv->md_env.matrix, 
        (IGRchar **) &new_surface),
       targetid = my_id);
   if (! (1 & sts)) goto wrapup;

   /*
    *  o For non_uniform scaling Reset the edge types to freeform.  
    *    Actually we should compute the actual types, but this 
    *    requires an undo amount of effort.
    * 
    *  o In case I have a cross hatch graphics data object,
    *    uniform/non_uniform transformation should result in:
    *      o Cross_hatch angle should remain unchanged.
    *      o Spacing should be scaled appropriately.
    */

   EFplane_xform_support (&rc, modification_type, my_id, 
                          OM_Gw_current_OS, old_surface, new_surface);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   if (old_surface) free(old_surface);

 } /* if (modification_type == EMSnonuniformTransformation ||
          modification_type == EMSuniformTransformation ) */

/*
 * Let my parent take care of the rest
 */
 if (! already_transformed)
  {
   sts = om$send(
     mode = OM_e_wrt_parent,
     msg = message EMSplane.GRxform(
      EMmsg,
      obj_dsenv,
      mx_type,
      mx,
      newobjid),
     targetid = my_id);
    if (! (1 & sts)) goto wrapup;
  } /* if (! already_transformed) */

/*
 * Eof
 */
wrapup:
 if (! (1 & *EMmsg))
  return(OM_E_ABORT);
 else
  return(OM_S_SUCCESS);
}

end implementation EMSplane;
