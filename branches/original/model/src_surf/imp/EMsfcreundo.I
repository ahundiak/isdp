/* ###################   APOGEE COMPILED   ################## */
/*
Description


Return Values
    EMS_S_Success       - all is well.
    EMS_E_Fail          - if a failure occurred.
    EMS_E_OMerror

Notes

History
    06-JUN-91  SCW  Genesis
    08-AUG-92  NP   Modified for ANSI compliance. "struct OM_S_CHANSELECT" (and
                    not a pointer to it) was being passed in "p_chanselect" for
                    "EMcreator_is_undoing" and "EMcreator_undoing" messages.

*/

class implementation EMSsurface;

#include "emsdef.h"

extern OMuword OPP_EMScompsurf_class_id;

from EMShelper import EMcreator_undoing;

method EMcreator_is_undoing( IGRlong *EMmsg; 
                             GRobjid *creator_id )
{
  IGRlong      status;
  OMuword      my_classid;

  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;


  status = om$get_classid( objid     =  my_id,
                           osnum     =  OM_Gw_current_OS,
                           p_classid = &my_classid );
  if( !( 1 & status ))
  {
    *EMmsg = EMS_E_OMerror;
    goto wrapup;
  }

  status = om$is_ancestry_valid( subclassid   = my_classid,
                                 superclassid = OPP_EMScompsurf_class_id );

  if( status & 1 )
  {
     OM_S_CHANSELECT   to_comps;

     status = EMmake_chanselect( GRcmpowner_to_components, &to_comps );

     status = om$send( msg = message EMSsurface.EMcreator_is_undoing( 
                                                            EMmsg,
                                                            creator_id ),
                       p_chanselect = &to_comps );
  } 
  else    /* must be a EMSsubbs class */
  {
     OM_S_CHANSELECT   to_gralp;

     status = EMmake_chanselect( EMSrequester_to_helpers, &to_gralp );

     status = om$send( msg = message EMShelper.EMcreator_undoing( 
                                                            EMmsg,
                                                            creator_id ),
                       p_chanselect = &to_gralp );

     
  }


wrapup:
  EMWRAPUP(*EMmsg, status, "In EMSsurface.EMcreator_is_undoing" );
  return( status );
}

end implementation EMSsurface;
