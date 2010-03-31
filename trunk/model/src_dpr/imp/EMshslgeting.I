class implementation EMSshslbool;

/*

??/??/??: creation.
06/01/93: sampath : Added code to return 'geom_ids'  based on the 
                    offset direction.
09/29/93: Sudhakar: Modified to handle 'Pre- EMS 2.4' models.
*/

#include "REshsolid.h"

#define FIRST  0
#define SECOND 1

method EMgetInGeomIds (IGRlong *msg; GRobjid nodes_side_id; 
                       IGRboolean is_kd_on; 
                       IGRint *num_in_geom_ids; GRobjid **in_geom_ids; 
                       IGRushort options)
{
  OMuint count;
  IGRlong stat_OM;
  OM_S_OBJECT_LINKAGE objlist[2];
  OM_S_CHANSELECT chan_to_comps;
  IGRlong msg_loc;
  IGRint size;
  struct EMSshell_solid *ashell;
  IGRboolean is_symmetric, inward;

  *msg = EMS_S_Success;  
  stat_OM = OM_S_SUCCESS;

  ashell = NULL;
  stat_OM = om$send (msg = message EMSassoc.EMget_info (&msg_loc, NULL,
                NULL, (IGRuint *) &size,(IGRchar **) &ashell),
                targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if(size)
  {
    is_symmetric = ashell->is_symmetric;
    inward = ashell->inward;
  }
  else
  {
    /* Pre-EMS 2.4 Models */
    is_symmetric = FALSE;
    inward = TRUE;
  }
    

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  count = 0;
  om$get_channel_objects (object = me, p_chanselect = &chan_to_comps,
   count = &count, size = 2, list = objlist); 

  if (count == 2)
    {
    if(is_symmetric)
    {
	*in_geom_ids = (GRobjid *) om$malloc (size = 2*sizeof (GRobjid));
	EMerr_hndlr (!*in_geom_ids, *msg, EMS_E_NoDynamicMemory, ret_end);
 
	*(*in_geom_ids) = objlist[FIRST].S_objid;
	*(*in_geom_ids + 1) = objlist[SECOND].S_objid;
	*num_in_geom_ids = 2;
    }
    else
    {
	*in_geom_ids = (GRobjid *) om$malloc (size = sizeof (GRobjid));
	EMerr_hndlr (!*in_geom_ids, *msg, EMS_E_NoDynamicMemory, ret_end);
	*num_in_geom_ids = 1;

	if(inward)
	    *(*in_geom_ids) = objlist[SECOND].S_objid;
	else
	    *(*in_geom_ids) = objlist[FIRST].S_objid;

    }
  }
  else
    *num_in_geom_ids = 0;

ret_end:
  if(ashell) 
	free(ashell);
  EMWRAPUP (*msg, stat_OM, "EMSshslbool.getInGmIds");
  return (stat_OM);
}

end implementation EMSshslbool;
