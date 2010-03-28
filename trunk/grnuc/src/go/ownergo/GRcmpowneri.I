class implementation GRcmpowner;

#include "grimport.h"
#include "igrtypedef.h"
#include "OMerrordef.h"
#include "msdef.h"

extern int   GRget_to_comp_chansel ();

from GRmodule     import GRmdaddwrng, GRmdremove;
from GRconnector  import GRdisconn;

/*
Name
    unknown

Description
    This method will send the unknown message to the graphics object.

Return Values
    The OM return code will be set in the graphics object.
                                 chanselect to improve performance
*/

method unknown ( OM_p_MESSAGE msg )
{
  long            om_msg = OM_W_UNKNOWN_MSG;
  OM_S_CHANSELECT chansel;

  /*
   *  If the unknown message was from the graphics object then
   *  ignore the message.
   */
  if (om_msg = GRget_to_comp_chansel ( &chansel ))
  {
    if(!memcmp ( (char *)&(chansel.u_sel.number), (char *)&in_channel,
        sizeof ( OM_S_CHANNUM ) ))
      om_msg = OM_W_UNKNOWN_MSG;
    else 
    {

      /*
       *  Send the unknown message to the graphics object (s).
       */
      if (me->to_components)
      {
        om_msg = om$send ( msg = msg, senderid = my_id,  p_chanselect = &chansel );
      }
    }
  }

  return om_msg;
}

/*
Name
   GRlocate_owner

Description
   This method performs the locate operation for owners.  This method
   is responsible for locating the owner and the component that sent 
   this message.

   *msg           long              completion code
   *cvl           struct GRlc_cvl      Module and action handler info
   *path          struct GRlc_path     The locate path of objects
   *path_position  int              Position of calling object in
                                       the path structure.

Notes
   The msg should be initialized to GR_I_NO_RESPONSE.  Only
   legitimate owners can change the message setting.

Return Values
   MSSUCC            -  if successful completion 
   MSFAIL            -  if error occurred
   GR_I_NO_RESPONSE  -  If no legitimate owners.
*/

method GRlocate_owner ( long *msg; struct GRlc_cvl *cvl; struct GRlc_path *path; int *path_position )
{
  long om_msg;

  /*
   *  Pass on to the next object.
   */
  om_msg = GRsend_to_next_sibling ( 
      path[*path_position].lc_info.located_obj.osnum,
      path[*path_position].lc_info.located_obj.objid,
      OM_Gw_current_OS, 
      my_id, 
      message GRcmpowner.GRlocate_owner (msg, 
      cvl, 
      path, 
      path_position) );

  return om_msg;
}


/*
Name
   GRownaddwrng

Description
   This method adds a component of an owner to the rtree with respect 
   to range.

   *msg        long              completion code
   *mod_env    struct GRmd_env      environment information
   *objid      GRobjid              objid of the component
   range       GRrange              range of component object

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure
*/

method GRownaddwrng ( long *msg; struct GRmd_env *md_info; GRobjid *objid; GRrange range )
{
  long om_msg;

  /*
   *  Add the component to the R-tree
   */
  om_msg = om$send ( msg = message GRmodule.GRmdaddwrng ( msg, range, objid ),
      senderid = *objid,
      targetid = md_info->md_id.objid,
      targetos = md_info->md_id.osnum );

  if (om_msg & *msg & 1) om_msg = OM_I_STOP_SENDING;

  return om_msg;
}


/*
Name
    GRownremwrng

Description
    This method removes a component of an owner from the rtree with 
    respect to range.

    *msg        long           completion code
    *mod_env    struct GRmd_env   environment information
    *objid      GRobjid           objid of the component
    range       GRrange           range of component object

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure
*/

method GRownremwrng ( long *msg; struct GRmd_env *md_info; GRobjid *objid; GRrange range )
{
  long om_msg;

  /*  
   *  delete the object from the R-tree
   */
  om_msg = om$send ( msg = message GRmodule.GRmdremove ( msg, range, objid ),
      senderid = *objid,
      targetid = md_info->md_id.objid,
      targetos = md_info->md_id.osnum );

  if (om_msg & *msg & 1) om_msg = OM_I_STOP_SENDING;

  return om_msg;
}

/*
Name
    GRcomponent_disconnecting

Description
    This method notifies a owner that one of his components is disconnecting
    from the "GRcmpowner.to_components" channel.

    *msg        long           completion code
    *mod_env    struct GRmd_env   environment information
    *comp_id    struct GRid       Object id of the component

Notes
    The owner is responsible for disconnecting the components if the
    owner is deleting himself.  If the owner does not disconnect the
    components then an infinite loop could occur.

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure
*/
method GRcomponent_disconnecting ( long *msg; struct GRmd_env *md_info; struct GRid *comp_id )
{
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

/*
Name
    GRrigid_connecting

Description
    This method notifies an owner, which owns a component on its flexible
    channel, that another object is requesting a rigid connection to the
    same component.  A flexible owner should disconnect from the component
    when receiving this message.  However a flexible owner with override
    privileges does not have to disconnect.

    *msg           long              return code 
    *go_id         struct GRid          The graphics object id

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure
*/

method GRrigid_connecting ( long *msg; struct GRid *go_id )
{
  long        om_msg;
  struct GRid my_GRid;

  *msg = MSSUCC;
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  om_msg = om$send ( msg = message GRconnector.GRdisconn ( msg, &my_GRid ),
      targetid = go_id->objid,
      targetos = go_id->osnum );

  return om_msg;
}

/*
Name
    GRcomponent_idchanged

Description
    This method notifies a owner that one of his components id changed.

    *msg              long           completion code
    *num_comp_ids     IGRshort          number of new ids
    *comp_ids         struct GRid       new object ids

Notes
    The original component whose id changed will be deleted.

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure

History
    Gray Winn      04/19/88    Creation Date
*/
method GRcomponent_idchanged ( long *msg; short *num_comp_ids; struct GRid *comp_ids )
{
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}


end implementation GRcmpowner;
