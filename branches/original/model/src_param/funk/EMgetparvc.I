/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This function is used to take in a general definition of a vector
    (numeric, event-structure, etc) and convert it into a parametric
    vector object which can enter parametric/variational relationships.

  HISTORY

    SS  :  03/10/91  :  Creation
*/

class implementation EMSparamvc;

#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"

#include "actparam.h"

static IGRboolean aflag;


IGRlong EMgetparvec_object (msg, mattyp, mat, constros, parvec, parvec_obj)
IGRlong *msg;
IGRshort mattyp;
IGRmatrix mat;
GRspacenum constros;
struct EMSvector_info *parvec;
struct EMSobject_info *parvec_obj;
{
  IGRboolean stat_func;
  IGRlong msg_loc, stat_OM;
  struct GRid *gridptr;
  struct GRmd_env *mdenvptr;
  struct EMSvector_info loc_parvec;
  struct EMSgeomdata vecdata;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Process for the object id of the vector, maybe constructing
   * one. To process the event type, first transform it to one of the other
   * types. The type is restored upon exit.
   */

  gridptr = &parvec_obj->grid;

  if (parvec->type == EMSdatainfo_event)
    {
    /*
     * If the parvec type is an event, for now always convert it into a
     * dumb numeric vector type and call this function recursively. The real
     * thing that should happen here, is that if a sub-type other than a
     * regular vector is found in the event, this knowledge must be captured by
     * constructing an appropriately constrained vector object. The field
     * x, y, and z are construed as delta's until newer fileds in the
     * union - event, are introduced.
     */

    loc_parvec.type = EMSdatainfo_numeric;
    OM_BLOCK_MOVE (&parvec->vecevent->event.button.x, loc_parvec.vec,
     sizeof (IGRvector));

    stat_OM = EMgetparvec_object (msg, mattyp, mat, constros, &loc_parvec,
               parvec_obj);
    }

  else if (parvec->type == EMSdatainfo_numeric)
    {
    /*
     * If the point is passed in as numeric, construct an EMSparamvec object
     * which can enter variational relationships. 
     */

    vecdata.geomtype = GEOMDATA_VECTOR;
    OM_BLOCK_MOVE (parvec->vec, vecdata.vector, sizeof (IGRvector));

    aflag = pwIsActivationOn();
    if (!aflag)
    {
    stat_OM = om$construct (classid = OPP_EMSparamvc_class_id,
               msg = message EMSparamgm.EMconstruct (&msg_loc, NULL, 
               &mattyp, mat, &vecdata), osnum = constros,
               p_objid = &gridptr->objid);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
    gridptr->osnum = constros;
    }
    else
    {
    stat_OM = om$construct (classid = OPP_EMSparamvc_class_id,
                            p_objid = &gridptr->objid, 
                            osnum = constros);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
    gridptr->osnum = constros;

    stat_OM = om$send(msg = message EMSparamgm.EMconstruct (&msg_loc, NULL, 
                                                   &mattyp, mat, &vecdata),
                      senderid = NULL_OBJID,
                      targetid = gridptr->objid,
                      targetos = gridptr->osnum);
    }

    /*
     * Get the module environment
     */

    mdenvptr = &parvec_obj->env;
    if ((mdenvptr->md_env.matrix_type = mattyp) != MAIDMX)
      OM_BLOCK_MOVE (mat, mdenvptr->md_env.matrix, sizeof (IGRmatrix));

    stat_func = ex$get_modid (mod_osnum = constros, 
                 mod_id = &mdenvptr->md_id.objid);
    EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
    mdenvptr->md_id.osnum = constros;
    }

  else if (parvec->type == EMSdatainfo_object)
    {
    /*
     * If the point is passed in as an object, then use this object
     * to output. The module environment is embedded inside the object_info.
     */

    *parvec_obj = parvec->vecobj;
    }

  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}


ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetpvcobj");
  return (stat_OM);
}


IGRlong EMgetparvec_numeric (msg, parvec, parvec_numeric)
IGRlong *msg;
struct EMSvector_info *parvec;
IGRvector parvec_numeric;
{
  IGRlong msg_loc, stat_OM;
  struct GRid *gridptr;
  struct GRmd_env *mdenvptr;
  struct EMSvector_info loc_parvec;
  struct EMSgeomdata vecgeom;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (parvec->type == EMSdatainfo_event)
    {
    /*
     * If the parvec type is an event, obtain the numeric information
     * from the "button" field. A new field needs to be eventually defined
     * inside the union - event field.
     */

    OM_BLOCK_MOVE (&parvec->vecevent->event.button.x, parvec_numeric,
     sizeof (IGRvector));
    }

  else if (parvec->type == EMSdatainfo_numeric)
    {
    /*
     * If the vector is passed in as numeric move the data to output
     */

    OM_BLOCK_MOVE (parvec->vec, parvec_numeric, sizeof (IGRvector));
    }

  else if (parvec->type == EMSdatainfo_object)
    {
    /*
     * If the vector is passed in as an object it must be of the class
     * EMSparamvc. There is no graphic object of this type.
     */

    gridptr = &parvec->vecobj.grid;
    mdenvptr = &parvec->vecobj.env;

    vecgeom.geomtype = GEOMDATA_NULL;
    stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
               &mdenvptr->md_env.matrix_type, mdenvptr->md_env.matrix,
               &vecgeom), targetid = gridptr->objid,
               targetos = gridptr->osnum, senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
    EMerr_hndlr (vecgeom.geomtype != GEOMDATA_VECTOR, *msg, EMS_E_InvalidArg,
     ret_end);

    OM_BLOCK_MOVE (vecgeom.vector, parvec_numeric, sizeof (IGRvector));
    }
  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetparvec_numeric");
  return (stat_OM);
}

end implementation EMSparamvc;
