/*
  DESCRIPTION

    This function is used to take in a general definition of a double value
    (numeric, event-structure, name, etc) and convert it into a parametric
    value object (expression). If an object is to be constructed, then
    a name can be specified. If no name is specified in this case, a 
    name is generated.

  HISTORY

    SS  :  03/10/91  :  Creation
*/

class implementation EMSparamvl;

#include <string.h>
#include "OMmacros.h"
#include "exdef.h"
#include "ex.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "actparam.h"

static IGRboolean aflag;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

IGRlong EMgetparval_object (msg, constros, objname, parval,
                            parval_obj)
IGRlong *msg;
GRspacenum constros;
IGRchar *objname;
struct EMSvalue_info *parval;
struct EMSobject_info *parval_obj;
{
  IGRboolean stat_func;
  IGRchar *nameptr, *syntaxptr, name_mem[DI_PATH_MAX], syntax_mem[DI_PATH_MAX];
  IGRshort s_msg_loc;
  IGRint i, len, subtype;
  IGRlong msg_loc, stat_DI, stat_OM;
  GRclassid exp_classid;
  struct GRid *gridptr;
  struct GRmd_env *mdenvptr;
  struct EMSvalue_info loc_parval;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Process for the object id of the value, maybe constructing
   * one. To process the event type, first transform it to one of the other
   * types and call this function recursively.
   */

  gridptr = &parval_obj->grid;

  if (parval->type == EMSdatainfo_event)
    {
    /*
     * If the parval type is an event, always convert it into a either a dumb
     * numeric value or use the object in the event structure. When using
     * the object, make sure that it is a subclass of EMSparamvl. If not:
     * check if the expression object is a super-class of EMSparamvl, if
     * so then the class can be changed to EMSparamvl and the older class's
     * functionality would still be intact. If not: create an EMSparamvl
     * object and connect this object as the child of the expression in the
     * event-structure.
     */

    gridptr = &parval->valevent->located_object[0].located_obj;
    if (!parval->valevent->num_id || IF_NULL_OBJID (gridptr->objid))
      {
      loc_parval.type = EMSdatainfo_numeric;
      loc_parval.val = parval->valevent->event.value;

      stat_OM = EMgetparval_object (msg, constros, objname, &loc_parval,
                 parval_obj);
      }
    else
      {
      subtype = parval->valevent->subtype;
      om$get_classid (objid = gridptr->objid, osnum = gridptr->osnum,
       p_classid = &exp_classid);
      if (subtype == GRst_v_SYNTAX ||
          om$is_ancestry_valid (subclassid = exp_classid,
           superclassid = OPP_EMSparamvl_class_id) != OM_S_SUCCESS)
        {
        if (subtype != GRst_v_SYNTAX &&
            om$is_ancestry_valid (subclassid = OPP_EMSparamvl_class_id,
             superclassid = exp_classid) == OM_S_SUCCESS)
          {
          stat_OM = om$change_class (osnum = gridptr->osnum,
                     objid = gridptr->objid, classname = "EMSparamvl");
          EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
          }
        else
          {
          nameptr = name_mem;
          stat_func = EMdefnewname (nameptr, constros, EMSscalar);
          EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);
 
          syntaxptr = syntax_mem;
          if (subtype == GRst_v_SYNTAX)
            {
            stat_OM = om$send (msg = message expression.give_formula
                       (syntaxptr), targetid = gridptr->objid,
                       targetos = gridptr->osnum, senderid = NULL_OBJID);
            EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail,
             ret_end);
            len = strlen (syntaxptr);
            for (i=len-1; i>=0; i--)
              if (syntaxptr[i] == '[')
                break;
            syntaxptr[i] = NULL;
            }
          else
            {
            stat_DI = di$untranslate (objname = syntaxptr,
                       objid = gridptr->objid, osnum = gridptr->osnum);
            EMerr_hndlr (stat_DI != DIR_S_SUCCESS, *msg, EMS_I_NotFound,
             ret_end);
            }

          stat_OM = om$construct (classid = OPP_EMSparamvl_class_id,
                     msg = message expression.create (nameptr, syntaxptr,
                     &s_msg_loc), osnum = gridptr->osnum,
                     p_objid = &gridptr->objid);
          msg_loc = s_msg_loc;
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
           ret_end);
          }
        }
      parval_obj->grid = *gridptr;
      parval_obj->env = parval->valevent->located_object[0].module_info;
      }
    }

  else if (parval->type == EMSdatainfo_numeric)
    {
    /*
     * Get the name, if needed, and construct the special expression
     * object that is of the class EMSparamvl.
     */

    if (!objname)
      {
      nameptr = name_mem;
      stat_func = EMdefnewname (nameptr, constros, EMSscalar);
      EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);
      }
    else
      nameptr = objname;

    aflag = pwIsActivationOn();
    if (!aflag)
    {
    stat_OM = om$construct (classid = OPP_EMSparamvl_class_id,
               msg = message EMSparamvl.EMconstruct (&msg_loc, NULL,
               parval->val, nameptr), osnum = constros,
               p_objid = &gridptr->objid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    gridptr->osnum = constros;
    }
    else
    {
        stat_OM = om$construct (classid = OPP_EMSparamvl_class_id,
                                osnum = constros,
                                p_objid = &gridptr->objid);
        EMerr_hndlr (EMSerror (stat_OM ), *msg, EMS_E_Fail, ret_end);
        gridptr->osnum = constros;
 
        om$send(msg = message EMSparamvl.EMconstruct (&msg_loc, NULL,
                                                      parval->val, nameptr),
                senderid = NULL_OBJID,
                targetid = gridptr->objid,
                targetos = gridptr->osnum);
    }

    /*
     * The module environment has no matrix for a scalar number
     */

    mdenvptr = &parval_obj->env;

    mdenvptr->md_env.matrix_type = MAIDMX;

    stat_func = ex$get_modid (mod_osnum = constros, 
                 mod_id = &mdenvptr->md_id.objid);
    EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
    mdenvptr->md_id.osnum = constros;
    }

  else if (parval->type == EMSdatainfo_name)
    {
    /*
     * If the value/expression has been passed in by name, the object is
     * deemed to already be in existence.
     */

    stat_DI = di$translate (objname = parval->valname,
               p_objid = &gridptr->objid, p_osnum = &gridptr->osnum);
    EMerr_hndlr (EMSerror (stat_DI != DIR_S_SUCCESS), *msg, EMS_E_Fail,
     ret_end);

    /*
     * Get the module environment. 
     */

    mdenvptr = &parval_obj->env;

/* Commented oy by Jagtas
    mdenvptr->md_env.matrix_type = MAIDMX;
*/

    stat_func = ex$get_modid (mod_osnum = gridptr->osnum, 
                 mod_id = &mdenvptr->md_id.objid);
    EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
    mdenvptr->md_id.osnum = gridptr->osnum;
    }

  else if (parval->type == EMSdatainfo_object)
    {
    /*
     * If the point has been passed by object, then the data
     * is already known.
     */

    parval_obj->grid = parval->valobj;

    mdenvptr = &parval_obj->env;
    mdenvptr->md_env.matrix_type = MAIDMX;

    stat_func = ex$get_modid (mod_osnum = constros, 
                 mod_id = &mdenvptr->md_id.objid);
    EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
    mdenvptr->md_id.osnum = constros;
    }

  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetparval_object");
  return (stat_OM);
}

IGRlong EMgetparval_numeric (msg, parval, parval_numeric)
IGRlong *msg;
struct EMSvalue_info *parval;
IGRdouble *parval_numeric;
{
  IGRlong stat_OM, stat_DI;
  struct GRid *gridptr;
  struct EMSvalue_info loc_parval;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (parval->type == EMSdatainfo_event)
    {
    /*
     * If the parval type is an event, obtain the numeric information
     * from the value field.
     */

    *parval_numeric = parval->valevent->event.value;
    }

  else if (parval->type == EMSdatainfo_numeric)
    {
    /*
     * If the value is passed in as numeric assign the data to output
     */

    *parval_numeric = parval->val;
    }

  else if (parval->type == EMSdatainfo_name)
    {
    /*
     * If the value (expression) has been passed in by name, the object is
     * deemed to already be in existence.
     */
  
    gridptr = &loc_parval.valobj;
    stat_DI = di$translate (objname = parval->valname,
               p_objid = &gridptr->objid, p_osnum = &gridptr->osnum);
    EMerr_hndlr (EMSerror (stat_DI != DIR_S_SUCCESS), *msg, EMS_E_Fail,
     ret_end);

    stat_OM = EMgetparval_numeric (msg, &loc_parval, parval_numeric);
    }

  else if (parval->type == EMSdatainfo_object)
    {
    /*
     * If the value is passed in as an object, obtain the value thusly.
     */

    gridptr = &parval->valobj;
    stat_OM = om$send (msg = message expression.NDgive_value (parval_numeric),
               targetid = gridptr->objid, targetos = gridptr->osnum,
               senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    }

  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}


ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetparval_numeric");
  return (stat_OM);
}

end implementation EMSparamvl;
