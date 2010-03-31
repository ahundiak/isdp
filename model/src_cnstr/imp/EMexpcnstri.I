class implementation EMSexpcnstr;

#include <alloca.h>
#include "OMmacros.h"
#include "msdef.h"
#include "nddef.h"
#include "dimdef.h"
#include "dimmacros.h"
#include "EMSopt.h"
#include "EMSasprops.h"
#include "expression.h"

#define FIRST 0

extern GRclassid OPP_EMSparamvl_class_id, OPP_EMSangcnstr_class_id;

from DMroot 	import get_dim_type;

method GRcopy(IGRlong *msg; struct GRmd_env *obj_dsenv;
              struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
    IGRlong     om_stat;
    struct GRid new_grid;

    *msg = MSSUCC;
    om_stat = om$send(msg = message NDmacro.ACcopy_to_Groot(msg,
                                ND_TO_DEF_TEMP,
                                obj_dsenv, new_dsenv,
                                &new_grid),
                      targetid = my_id);
    *newobjid = new_grid.objid;
    return(om_stat);
}
/*

Name
  EMset_units_convert_flag

Abstract

Synopsis

Description
  This function finds all the explicit parameter values that drive a solid
  and checks if we need to set the unit conversion flag on them.  If
  the dimension units differ from the expression unit, the expression value
  and syntax is changed.
  
Return Value

Notes

Index

Keywords
  dimension,units

History
  06/10/93 : Rajiv Agrawal : created

 */

#argsused
EMset_units_convert_flag(long *msg, IGRushort opts, struct GRmd_env *md_env,
                         GRobjid solid_id)
{
  char 			syntax[EXP_MAX_LEN];
  short 		action, props;
  int			i, num_parents = 0;
  long 			stat_OM, msg_loc;
  double 		db_value;
  OM_S_CHANSELECT 	chan_to_comps;
  struct GRid		*parents;
  GRclassid 		objclass;
  GRspacenum		osnum;
    
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  osnum = md_env->md_id.osnum;
  /*
   * find the parents of the solid.
   */
  stat_OM = om$send (msg = message NDnode.NDget_objects (ND_ROOT,
                           NULL, 0, NULL, 0, MAXINT, &num_parents), 
                     targetid = solid_id, targetos = osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
  if (num_parents)
  {
    parents = (struct GRid *) alloca (num_parents*sizeof(struct GRid));
    stat_OM = om$send (msg = message NDnode.NDget_objects (ND_ROOT,
                             parents, num_parents, NULL, 0, MAXINT, &num_parents), 
                       targetid = solid_id, targetos = osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );

    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    for (i = 0; i < num_parents; i++)
    {
      /*
       * find EMSparamvl kind of parents.
       */
      om$get_classid ( osnum = parents[i].osnum, objid = parents[i].objid, 
                       p_classid = &objclass );
      
      if (om$is_ancestry_valid ( subclassid = objclass,
              superclassid = OPP_EMSparamvl_class_id) == OM_S_SUCCESS)
      {
        stat_OM = om$send  ( msg = message expression.NDgive_value (&db_value),
                             targetid = parents[i].objid, targetos = parents[i].osnum, 
                             senderid = NULL_OBJID);
        EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );

        EMcnvt_db_dim_units (&msg_loc, &parents[i], &db_value, NULL, FALSE);
        EMerr_hndlr (EMSerror (msg_loc), msg_loc, EMS_E_Fail, ret_end);
        if (msg_loc == EMS_I_Modified) 
        {
          action = EMS_O_ON;
          props = EMScnstr_convert_units;
          stat_OM = om$send (msg = message EMScnstr.EMchgprops (&msg_loc, action, props), 
                             targetid = parents[i].objid, targetos = parents[i].osnum, 
                             senderid = NULL_OBJID);
          EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
         
          /*
           * Change the instance data for the expression value and syntax also.
           */
          stat_OM = om$send (msg = message expression.put_value (db_value),
                             targetid = parents[i].objid, 
                             targetos = parents[i].osnum, 
                             senderid = NULL_OBJID);
          EMerr_hndlr (EMSerror (stat_OM), stat_OM, OM_E_ABORT, ret_end);
      
          sprintf(syntax, "\\-1 = %lf", db_value);
          stat_OM = om$send (msg = message expression.put_syntax (syntax),
                             targetid = parents[i].objid, 
                             targetos = parents[i].osnum, 
                             senderid = NULL_OBJID);
          EMerr_hndlr (EMSerror (stat_OM), stat_OM, OM_E_ABORT, ret_end);
       }
      }
    }
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMset_units_convert_flag");
  return stat_OM;   
}

/*

Name
  GRdelete

Abstract

Synopsis

Description
  If I have any children, I need to send the NDparent_deleted message to
  the children.
Return Value

Notes

Index

Keywords

History
  11/24/93 : G Mallikarjuna : created

 */

method GRdelete (IGRlong *msg; struct GRmd_env *md_env)
{
  int		  ii,num_del;
  long 		  stat_OM, msg_loc;
  OMuint	  count;
  GRobjid	  memid;
  GRspacenum	  memos;
  OM_S_CHANSELECT chan_to_children;
  struct GRid my_grid,new_obj;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  num_del = 1;
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  om$make_chanselect ( channame = "NDchildren.children",
                       p_chanselect = &chan_to_children );
  /* 
   * Make sure the children know that I'm going away
   */
  om$get_channel_count ( objid = my_id, osnum = OM_Gw_current_OS,
                         p_chanselect = &chan_to_children, count = &count );
  for (ii = 0; ii < count; ii++)
  {
    if (om$get_objid_at_index ( objid = my_id,
          p_chanselect = &chan_to_children, index = 0,
          objidaddr = &memid, osnumaddr = &memos ) & 1)
    {
      stat_OM = om$send ( msg = message NDnode.NDparent_deleted( &msg_loc, num_del,
                                &my_grid, &new_obj, md_env ), 
                          targetid = memid, 
                          targetos = memos );
    }
  }

  /*
   * Invoke the default message to do the rest of the work
   */
  stat_OM = om$send (mode = OM_e_wrt_parent,
                     msg = message EMSexpcnstr.GRdelete (&msg_loc, md_env),
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSexpcnstr.GRdelete");
  return (stat_OM);
}

end implementation EMSexpcnstr;

