/*
  DESCRIPTION

    This function is used to take in a general definition of a point
    (numeric, event-structure, name, etc) and convert it into a parametric
    point object which can enter paramteric/variational relationships.

  HISTORY

    SS  :  03/10/91  :  Creation
*/

class implementation EMSparampt;

#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "dimdef.h"
#include "dim.h"
#include "dimsrc.h"
#include "dimplan.h"
#include "diminfo.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSas.h"

#include "actparam.h"

extern OMuword OPP_GR3dpoint_class_id, OPP_EMSasptcnstr_class_id;

from GRlinear import GRgetpolyline;
from EMScnstr import EMinit;


static IGRboolean aflag;



IGRlong EMgetparpt_object (msg, mattyp, mat, constros, parpt, parpt_obj)
IGRlong *msg;
IGRshort mattyp;
IGRmatrix mat;
GRspacenum constros;
struct EMSpoint_info *parpt;
struct EMSobject_info *parpt_obj;
{
  IGRboolean stat_func;
  IGRint subtype;
  IGRlong msg_loc, stat_OM;
  GRobjid cnstr_objid;
  struct GRid *gridptr;
  struct GRmd_env *mdenvptr, md_env;
  struct EMSpoint_info loc_parpt;
  struct EMSgeomdata ptgeom;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Process for the object id of the point, maybe constructing
   * one. To process the event type, first transform it to one of the other
   * types. The type is restored upon exit.
   */

  gridptr = &parpt_obj->grid;

  if (parpt->type == EMSdatainfo_event)
    {
    /*
     * If the parpt type is an event, convert it into a dumb numeric point
     * type and call this function recursively. If the sub-type is not one of
     * the ones being specially handled nothing more needs to be done. On
     * finding an event with a recognizable sub-type, the knowledge is captured
     * by constructing an appropriate constraint for the parametric point
     * object.
     */

    loc_parpt.type = EMSdatainfo_numeric;
    OM_BLOCK_MOVE (&parpt->ptevent->event.button.x, loc_parpt.pt,
     sizeof (IGRpoint));

    stat_OM = EMgetparpt_object (&msg_loc, mattyp, mat, constros, &loc_parpt,
               parpt_obj);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    subtype = parpt->ptevent->subtype;
    if (EMptsubtype_supported (parpt->ptevent))
      {
      if ((md_env.md_env.matrix_type = mattyp) != MAIDMX)
        OM_BLOCK_MOVE (mat, md_env.md_env.matrix, sizeof (IGRmatrix));
      stat_func = ex$get_modid (mod_osnum = constros, 
                   mod_id = &md_env.md_id.objid);
      EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
      md_env.md_id.osnum = constros;

      EMasptcnstr (&msg_loc, NULL, &md_env, parpt->ptevent, 1, gridptr,
       &cnstr_objid);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }

  else if (parpt->type == EMSdatainfo_numeric)
    {
    /*
     * If the point is passed in as numeric, construct an EMSparampt object
     * which can enter variational relationships. 
     */

    ptgeom.geomtype = GEOMDATA_POINT;
    OM_BLOCK_MOVE (parpt->pt, ptgeom.point, sizeof (IGRpoint));

   aflag = pwIsActivationOn();
   if (aflag)
   {
    stat_OM = om$construct (classid = OPP_EMSparampt_class_id,
               osnum = constros,
               p_objid = &gridptr->objid);
    gridptr->osnum = constros;
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

    stat_OM = om$send(msg = message EMSparamgm.EMconstruct (&msg_loc, NULL, 
                                                    &mattyp, mat, &ptgeom), 
                      senderid = NULL_OBJID,
                      targetid = gridptr->objid,
                      targetos = gridptr->osnum);

   }
   else
   {
    stat_OM = om$construct (classid = OPP_EMSparampt_class_id,
               msg = message EMSparamgm.EMconstruct (&msg_loc, NULL, 
               &mattyp, mat, &ptgeom), osnum = constros,
               p_objid = &gridptr->objid);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
    gridptr->osnum = constros;
   }

    /*
     * Get the module environment
     */

    mdenvptr = &parpt_obj->env;
    if ((mdenvptr->md_env.matrix_type = mattyp) != MAIDMX)
      OM_BLOCK_MOVE (mat, mdenvptr->md_env.matrix, sizeof (IGRmatrix));

    stat_func = ex$get_modid (mod_osnum = constros, 
                 mod_id = &mdenvptr->md_id.objid);
    EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
    mdenvptr->md_id.osnum = constros;
    }

  else if (parpt->type == EMSdatainfo_object)
    {
    /*
     * If the point is passed in as an object, then use this object
     * to output. The midule environment is embedded inside the object_info.
     */

    *parpt_obj = parpt->ptobj;
    }

  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}


ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetpptobj");
  return (stat_OM);
}


IGRlong EMgetparpt_numeric (msg, parpt, parpt_numeric)
IGRlong *msg;
struct EMSpoint_info *parpt;
IGRpoint parpt_numeric;
{
  IGRint action;
  IGRlong msg_loc, stat_OM;
  GRclassid objclass;
  struct GRid *gridptr;
  struct GRmd_env *mdenvptr;
  struct IGRpolyline py;
  struct EMSgeomdata ptgeom;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (parpt->type == EMSdatainfo_event)
    {
    /*
     * If the parpt type is an event, obtain the numeric information
     * from the "button" field.
     */

    OM_BLOCK_MOVE (&parpt->ptevent->event.button.x, parpt_numeric,
     sizeof (IGRpoint));
    }

  else if (parpt->type == EMSdatainfo_numeric)
    {
    /*
     * If the point is passed in as numeric move the data to output
     */

    OM_BLOCK_MOVE (parpt->pt, parpt_numeric, sizeof (IGRpoint));
    }

  else if (parpt->type == EMSdatainfo_object)
    {
    /*
     * If the point is passed in as an object, obtain the point thusly.
     */

    gridptr = &parpt->ptobj.grid;
    mdenvptr = &parpt->ptobj.env;

    om$get_classid (objid = gridptr->objid, p_classid = &objclass);
    if (om$is_ancestry_valid (subclassid = objclass,
        superclassid = OPP_GR3dpoint_class_id) == OM_S_SUCCESS)
      {
      action = 1;
      py.num_points = 1;
      py.points = parpt_numeric;
      stat_OM = om$send (msg = message GRlinear.GRgetpolyline (&msg_loc,
                 &mdenvptr->md_env.matrix_type, mdenvptr->md_env.matrix,
                 &action, &py), targetid = gridptr->objid,
                 targetos = gridptr->osnum, senderid = NULL_OBJID);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
      }
    else if (om$is_ancestry_valid (subclassid = objclass,
             superclassid = OPP_EMSparamgm_class_id) == OM_S_SUCCESS)
      {
      stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
                 &mdenvptr->md_env.matrix_type, mdenvptr->md_env.matrix,
                 &ptgeom), targetid = gridptr->objid,
                 targetos = gridptr->osnum, senderid = NULL_OBJID);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
      EMerr_hndlr (ptgeom.geomtype != GEOMDATA_POINT, *msg, EMS_E_InvalidArg,
       ret_end);

      OM_BLOCK_MOVE (ptgeom.point, parpt_numeric, sizeof (IGRpoint));
      }
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
    }

  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}


ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetparpt_numeric");
  return (stat_OM);
}


end implementation EMSparampt;
