class implementation SKifexplicit;

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
  01/10/94 : Rajiv Agrawal : Implemented SK_HALFVALUE handling to get the RADIAL_DIAMETER
                             and CIRCULAR_DIAMETER cases to work.
*/

#include "EMSopt.h"
#include "bserr.h"
#include "bsdistptpt.h"

#define FIRST  0
#define SECOND 1

extern OMuword OPP_SKptpt_class_id;

from SKvariable import SKgetvar;

method SKinit (IGRlong *EMmsg; IGRushort options;
               struct GRmd_env *md_env;
               IGRint num_pts; GRobjid *pt_ids;
               IGRushort cnstr_props;
               GRobjid *geom_handle; IGRchar *moreinfo)
{
 IGRboolean found;
 IGRushort loc_options, valid_options;
 IGRlong status, bsrc;
 IGRint i, index;
 OMuint cnstr_count, var_count;
 IGRdouble dist;
 IGRpoint ptvals[2];
 OM_S_CHANSELECT to_constraints, to_variables;
 GRobjid constrid, ptpt_constrid;
 GRclassid constrclass;
 struct GRid my_grid;
 OM_S_OBJECT_LINKAGE objlist[2];
 GRspacenum dumos;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 /*
  * Find the point-to-point constraint that should have been constructed
  * between pt2-pt1. Connect myself to this constraint.
  */

 EMmake_chanselect (SKvariable_to_constraints, &to_constraints);
 cnstr_count = 0;
 om$get_channel_count (p_chanselect = &to_constraints, objid = pt_ids[1],
  count = &cnstr_count);

 EMmake_chanselect (SKconstraint_to_variables, &to_variables);
 found = FALSE;
 for (index=0; index<cnstr_count; index++)
   {
   om$get_objid_at_index (objid = pt_ids[1], p_chanselect = &to_constraints,
    index = index, objidaddr = &constrid, osnumaddr = &dumos);

   om$get_classid (objid = constrid, p_classid = &constrclass);

   if (constrclass == OPP_SKptpt_class_id)
     {
     var_count = 0;
     om$get_channel_objects (objid = constrid, p_chanselect = &to_variables,
      size = 2, count = &var_count, list = objlist);
     EMerr_hndlr (var_count != 2, *EMmsg, EMS_E_InvalidCase, wrapup);

     if (objlist[0].S_objid == pt_ids[0] || objlist[1].S_objid == pt_ids[0])
       {
       ptpt_constrid = constrid;
       found = TRUE;
       break;
       }
     }
   }

 if (!found)
   {
   valid_options = SK_OPT_MARK_AS_USERADD | SK_OPT_MARK_AS_NEWADD;
   loc_options = options & valid_options | 
                  SK_OPT_NO_MGR_CONNECT | SK_OPT_NO_CREATE_EXPR;
   status = om$construct (classid = OPP_SKptpt_class_id,
             p_objid = &ptpt_constrid,
             msg = message SKconstraint.SKinit (EMmsg, loc_options, md_env,
             2, pt_ids, NULL, NULL, NULL));
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }

 status = om$send (msg = message SKinterface.SKconnect_to_member
           (EMmsg, NULL, ptpt_constrid, MAXINT, MAXINT),
           targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 status = om$send (msg = message SKconstraint.SKchgprops (EMmsg, EMS_O_OFF,
           SK_NOVALUE), targetid = ptpt_constrid);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 status = om$send (mode = OM_e_wrt_parent,
           msg = message SKifexplicit.SKinit (EMmsg,
           (options & ~SK_OPT_NO_MGR_CONNECT) | SK_OPT_NO_CONNECT_PTS,
           md_env, 2, pt_ids, cnstr_props, geom_handle, moreinfo),
           targetid = my_id);
 EMerr_hndlr (EMSerror (status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 /*
  * Obtain the distance that this constraint represents.
  */

 for (i=FIRST; i<=SECOND; i++)
 {
   status = om$send (msg = message SKvariable.SKgetvar (EMmsg, NULL,
              NULL, NULL, ptvals[i]), targetid = pt_ids[i]);
   EMerr_hndlr (EMSerror (status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 dist = BSdistptpt (&bsrc, ptvals[FIRST], ptvals[SECOND]);

 if (ME.SKconstraint->props & SK_HALFVALUE)
   dist *= 2.0;

 /*
  * If this expression has a dimension handle, convert the value into
  * the units of the dimension. If a conversion was necessary, then
  * record this in the props field.
  */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  EMcnvt_db_dim_units (EMmsg, &my_grid, &dist, GRIO_DISTANCE, FALSE);
  EMerr_hndlr (EMSerror (*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  if (*EMmsg == EMS_I_Modified)
    ME.SKconstraint->props |= SK_UNITSCONVERT;
  
  /*
   * Initialize myself as an expression, unless inhibited
   */

  if (! (options & SK_OPT_NO_CREATE_EXPR))
    status = om$send (msg = message SKexplicit.SKcreate_expression (EMmsg,
               NULL, dist), targetid = my_id);
  else
    status = om$send (msg = message SKexplicit.SKputval (EMmsg, 
               NULL, dist, NULL), targetid = my_id);
  EMerr_hndlr (EMSerror (status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:
 EMWRAPUP (*EMmsg, status, "SKifexplicit.SKinit");
 return (status);
}

end implementation SKifexplicit;


