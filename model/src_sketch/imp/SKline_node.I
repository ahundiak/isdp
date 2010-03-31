class implementation SKline;

#include <stdio.h>
#include "OMmacros.h"
#include "parametric.h"
#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSopt.h"


extern OMuword OPP_DMsrc_class_id, OPP_SKifptpt_class_id, OPP_DMsglpara_class_id;

%safe
static struct GRid ptpt_id = { 0, 0 };
static struct GRid ifptpt_id = { 0, 0 };
%endsafe

method NDnotify_disconnect ( struct GRid previous_connected )
/*
   We use this method to re-connect dimensions moved using the attach dimension
   command.
*/
{
  OMuword             classid;
  OM_S_CHANSELECT     to_owners, children, to_member_constrs, to_variables, to_manager;
  OM_S_OBJECT_LINKAGE list [10];
  OMuint              count;
  
  classid = -1;
  count = 0;

  /* see if the previous connected is a DMsrc */
  om$get_classid ( osnum = previous_connected.osnum,
     objid = previous_connected.objid,
     p_classid = &classid );

  if (classid == OPP_DMsrc_class_id)
  {
    /* see if that DMsrc is connected to a DMsglpara that has an owner */
    EMmake_chanselect ( NDchildren_children, &children );
    om$get_channel_objects ( osnum = previous_connected.osnum,
       objid = previous_connected.objid,
       size = 10,
       count = &count,
       list = list,
       p_chanselect = &children );
    om$get_classid ( osnum = list [0].osnum,
       objid = list [0].S_objid,
       p_classid = &classid );
    if (classid == OPP_DMsglpara_class_id)
    {
      /* we get the interface */
      EMmake_chanselect ( GRconnector_to_owners, &to_owners );
      om$get_channel_objects ( osnum = list [0].osnum,
         objid = list [0].S_objid,
         size = 10,
         count = &count,
         list = list,
         p_chanselect = &to_owners );
      om$get_classid ( osnum = list [0].osnum,
         objid = list [0].S_objid,
         p_classid = &classid );
      if (classid == OPP_SKifptpt_class_id)
      {
        /* we disconnect the interface from the manager */
        ifptpt_id.osnum = list [0].osnum;
        ifptpt_id.objid = list [0].S_objid;
        EMmake_chanselect ( SKconstraint_to_mgr, &to_manager );
        om$send ( msg = message Root.wild_disconnect ( to_manager ),
           targetid = list [0].S_objid,
           targetos = list [0].osnum );

        /* we get the constraint */
        EMmake_chanselect ( SKinterface_to_member_constrs, &to_member_constrs );
        om$get_channel_objects ( osnum = ifptpt_id.osnum,
           objid = ifptpt_id.objid,
           size = 10,
           count = &count,
           list = list,
           p_chanselect = &to_member_constrs );
        if (count == 1)
        {
          /* we save the constraint id and disconnect it from the variables */
          ptpt_id.osnum = list [0].osnum;
          ptpt_id.objid = list [0].S_objid;
          EMmake_chanselect ( SKconstraint_to_variables, &to_variables );
          om$send ( msg = message Root.wild_disconnect ( to_variables ),
             targetid = list [0].S_objid,
             targetos = list [0].osnum );
        }
      }
    }
  }
    
  return om$send ( msg = message NDnode.NDnotify_disconnect ( previous_connected ),
            mode = OM_e_wrt_message,
            targetid = my_id );
}


method NDnotify_connect ( struct GRid new_connected )
/*
   We use this method to re-connect dimensions moved using the attach dimension
   command.
*/
{
  OM_S_CHANSELECT     to_defpts, to_variables, to_constraints, to_manager;
  OM_S_OBJECT_LINKAGE list [10];
  OMuint              count;

  if (ptpt_id.objid != NULL_OBJID)
  {
    /* we get the variables from the new line */
    EMmake_chanselect ( SKgeometry_to_defpts, &to_defpts );
    om$get_channel_objects ( osnum = OM_Gw_current_OS,
       objid = my_id,
       size = 10,
       count = &count,
       list = list,
       p_chanselect = &to_defpts );
    if (count == 2)
    {
      /* we re-connect those to the constraint */
      EMmake_chanselect ( SKconstraint_to_variables, &to_variables );
      EMmake_chanselect ( SKvariable_to_constraints, &to_constraints );
      om$send (msg = message Root.connect ( to_variables, 0,
         list [0].S_objid, OM_Gw_current_OS, to_constraints, 0 ),
         targetid = ptpt_id.objid );
      om$send (msg = message Root.connect ( to_variables, 0,
         list [1].S_objid, OM_Gw_current_OS, to_constraints, 0 ),
         targetid = ptpt_id.objid );

      /* we get the mgr from the variables */
      EMmake_chanselect ( SKvariable_to_mgr, &to_manager );
      om$get_channel_objects ( osnum = list [0].osnum,
         objid = list [0].S_objid,
         size = 10,
         count = &count,
         list = list,
         p_chanselect = &to_manager );
      if (count == 1)
      {
        /* we re-connect the interface to the manager */
        EMmake_chanselect ( SKconstraint_to_mgr, &to_manager );
        EMmake_chanselect ( SKmgr_to_constrs, &to_constraints );
        om$send (msg = message Root.connect ( to_manager, 0,
           list [0].S_objid, list [0].osnum, to_constraints, 0 ),
           targetid = ifptpt_id.objid );
      }
    }
    ptpt_id.objid = NULL_OBJID;
    ifptpt_id.objid = NULL_OBJID;
  }
  
  return om$send ( msg = message NDnode.NDnotify_connect ( new_connected ),
                   mode = OM_e_wrt_message,
                   targetid = my_id );
}


end implementation SKline;


