class implementation SKifexplicit;

#include <alloca.h>
#include "exdef.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dimdef.h"
#include "dimplcmacros.h"
#include "expression.h"
#include "EMSopt.h"

extern GRclassid OPP_SKfixang_class_id, OPP_SKrelang_class_id;

from DMroot import inq_geom_type;

/*
  HISTORY

  01/10/94 : Rajiv Agrawal : Implemented SK_HALFVALUE handling to get the RADIAL_DIAMETER
                             and CIRCULAR_DIAMETER cases to work.
*/

method SKgetval (IGRlong *msg; IGRdouble *value)
{
  IGRlong status;
  OM_S_CHANSELECT to_mem_cnstrs;

  *msg = EMS_S_Success;
  status = OM_S_SUCCESS;

  EMmake_chanselect (SKinterface_to_member_constrs, &to_mem_cnstrs);
  status = om$send (msg = OPPmargs, p_chanselect = &to_mem_cnstrs,
                    from = 0, to = 0);

  EMWRAPUP (*msg, status, "SKifexplicit.SKgetval");
  return (status);
}

method SKstoreval (IGRlong *msg; IGRdouble value)
{
  IGRlong status;
  OM_S_CHANSELECT to_mem_cnstrs;

  *msg = EMS_S_Success;
  status = OM_S_SUCCESS;

  EMmake_chanselect (SKinterface_to_member_constrs, &to_mem_cnstrs);
  status = om$send (msg = OPPmargs, p_chanselect = &to_mem_cnstrs);

  EMWRAPUP (*msg, status, "SKifexplicit.SKstoreval");
  return (status);
}

method modify (IGRchar *name; IGRchar *rhs ; IGRshort *s_msg)
{
  IGRchar geom_type, *valtype = NULL;
  IGRushort props;
  IGRint i;
  OMuint  count;
  IGRlong stat_OM, msg_loc;
  IGRdouble use_value, db_value;
  GRobjid memobj;
  GRclassid myclass;
  struct GRid dim_grid, my_grid, mem_grid;
  struct GRmd_env md_env;
  OM_S_CHANSELECT chan_to_mem, chan_to_comps, chan_to_parents;
  OM_S_OBJECT_LINKAGE objlist, *memobjs;
  
  *s_msg = TRUE;
  msg_loc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (mode = OM_e_wrt_parent,
                     msg = message SKifexplicit.modify (name, rhs, s_msg),
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM), msg_loc, EMS_E_Fail, ret_end);
  if (*s_msg != EXP_SUCCESS)
    return OM_S_SUCCESS;

  /*
   * If this expression stores a value other than in data-base units,
   * this means that the value coming in is in units other than data-base.
   * Obtain the value in data-base units in case one needs to post this
   * into the member constraints.
   */

  db_value = ME.expression->value;
  if (ME.SKconstraint->props & SK_UNITSCONVERT)
  {
    om$get_classid (object = me, p_classid = &myclass);
    if (om$is_ancestry_valid (superclassid = OPP_SKrelang_class_id,
         subclassid = myclass) == OM_S_SUCCESS ||
        om$is_ancestry_valid (superclassid = OPP_SKfixang_class_id,
         subclassid = myclass) == OM_S_SUCCESS)
      valtype = GRIO_ANGLE;
    else
      valtype = GRIO_DISTANCE;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &db_value, valtype, TRUE);
    EMerr_hndlr (EMSerror (msg_loc), msg_loc, EMS_E_Fail, ret_end);
  }

  EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_mem);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_mem,
                        count = &count);
  if (count)
  {
    memobjs = (OM_p_OBJECT_LINKAGE) alloca (count *
               sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!memobjs, msg_loc, EMS_E_NoStackMemory, ret_end);

    om$get_channel_objects (object = me, p_chanselect = &chan_to_mem,
                            count = &count, size = count, list = memobjs);
    for (i=0; i<count; i++)
    {
      memobj = memobjs[i].S_objid;
      use_value = db_value;

      props = NULL;
      om$send (msg = message SKconstraint.SKgetprops (&msg_loc, &props),
               targetid = memobj);
      if (props & SK_UNITSCONVERT)
      {
        mem_grid.objid = memobj;
        mem_grid.osnum = OM_Gw_current_OS;
        EMcnvt_db_dim_units (&msg_loc, &mem_grid, &use_value, valtype, FALSE);
        EMerr_hndlr (EMSerror (msg_loc), msg_loc, EMS_E_Fail, ret_end);
      }

      if (ME.SKconstraint->props & SK_HALFVALUE)
        use_value *= 0.5;

      stat_OM = om$send (msg = message SKexplicit.SKputval 
                               (&msg_loc, NULL, use_value, NULL), 
                         targetid = memobj);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), msg_loc, EMS_E_Fail, ret_end);
    }
  }

  /*
   * The dimension handle owned by this object needs to have it's type set 
   * to implicit if this expression has any parents driving it.
   */

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  count = 0;
  om$get_channel_objects (object = me, p_chanselect = &chan_to_comps,
                          count = &count, size = 1, list = &objlist);
  if (count)
  {
    md_env.md_env.matrix_type = MAIDMX;
    ex$get_modid (mod_osnum = OM_Gw_current_OS,
                  mod_id = &md_env.md_id.objid);
    md_env.md_id.osnum = OM_Gw_current_OS;

    dim_grid.objid = objlist.S_objid;
    dim_grid.osnum = OM_Gw_current_OS;

    geom_type = NULL;
    om$send (msg = message DMroot.inq_geom_type (&geom_type),
             targetid = dim_grid.objid);

    EMmake_chanselect (NDfather_father, &chan_to_parents);
    count = 0; 
    om$get_channel_count (object = me, p_chanselect = &chan_to_parents,
                          count = &count);
    if (count && !(geom_type & DIM_IMPLICIT))
    {
      dm$set_type (type = DIM_IMPLICIT, update = TRUE, md_env = &md_env,
       dim_grid = &dim_grid);
    }
    else if (!count && geom_type & DIM_IMPLICIT)
    {
      dm$set_type (type = DIM_IMPLICIT, op_code = BIT_CLEAR, update = TRUE,
                   md_env = &md_env, dim_grid = &dim_grid);
    }
  }

ret_end:
  EMWRAPUP (msg_loc, stat_OM, "SKifexplicit.modify");
  if (EMSerror (stat_OM & msg_loc))
    *s_msg = FALSE;
  return (stat_OM);
}

method SKputval (IGRlong *msg; IGRushort opts;
                 IGRdouble value; IGRchar *rhs)
{
  IGRchar *valtype = NULL;
  IGRushort props;
  IGRint i;
  OMuint count;
  IGRlong stat_OM, msg_loc;
  IGRdouble use_value, db_value;
  GRobjid memobj;
  GRclassid myclass;
  struct GRid my_grid, mem_grid;
  OM_S_CHANSELECT chan_to_mem;
  OM_S_OBJECT_LINKAGE *memobjs;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (mode = OM_e_wrt_parent,
                     msg = message SKifexplicit.SKputval 
                           (&msg_loc, opts, value, rhs), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * If this expression stores a value other than in data-base units,
   * this means that the value coming in is in units other than data-base.
   * Obtain the value in data-base units in case one needs to post this
   * into the member constraints.
   */

  db_value = value;
  if (ME.SKconstraint->props & SK_UNITSCONVERT)
  {
    om$get_classid (object = me, p_classid = &myclass);
    if (om$is_ancestry_valid (superclassid = OPP_SKrelang_class_id,
         subclassid = myclass) == OM_S_SUCCESS ||
        om$is_ancestry_valid (superclassid = OPP_SKfixang_class_id,
         subclassid = myclass) == OM_S_SUCCESS)
      valtype = GRIO_ANGLE;
    else
      valtype = GRIO_DISTANCE;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &db_value, valtype, TRUE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_mem);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_mem,
                        count = &count);
  if (count)
  {
    memobjs = (OM_p_OBJECT_LINKAGE) alloca (count *
               sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!memobjs, *msg, EMS_E_NoStackMemory, ret_end);

    om$get_channel_objects (object = me, p_chanselect = &chan_to_mem,
                            count = &count, size = count, list = memobjs);
    for (i=0; i<count; i++)
    {
      memobj = memobjs[i].S_objid;
      use_value = db_value;

      props = NULL;
      om$send (msg = message SKconstraint.SKgetprops (&msg_loc, &props),
               targetid = memobj);
      if (props & SK_UNITSCONVERT)
      {
        mem_grid.objid = memobj;
        mem_grid.osnum = OM_Gw_current_OS;
        EMcnvt_db_dim_units (&msg_loc, &mem_grid, &use_value, valtype, FALSE);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
        
      if (ME.SKconstraint->props & SK_HALFVALUE)
        use_value *= 0.5;

      stat_OM = om$send (msg = message SKexplicit.SKputval (&msg_loc, 
                 opts & ~SK_OPT_SAVE_OLD_VALUE, use_value, NULL),
                 targetid = memobj);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKifexplicit.SKputval");
  return (stat_OM);
}

end implementation SKifexplicit;

