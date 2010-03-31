/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "emsmacros.h"

#define StaticBuf 10

extern OMuword OPP_EMSloop_class_id, OPP_EMSpartedge_class_id, 
	       OPP_EMSdumedge_class_id;

method delete(int defer_flag)
/*
Description
     This method attempt to delete the the edge object.

Return values
    
History
   RC         ????      Creation
   DLB        4/9/87    Mod for assoc check.
   RC         11/04/87  Modified for version 1.1.0
   SM	      20-Jan-89	     Set the EMED_REVERSE_CONNECT and EMED_SUBORDINATE
			     properties off on the common edge since it is
			     not known whether the common edge is going
			     to live or die.
   SS         04/07/89  Before deleting myself, send the EMpostdelete
                        message to myself (if this has not been
                        inhibited by some higher level procedure).
   SM	      30-Jan-92 Instead of direct channel count for num owners, 
		        check the owner to have EMSloop in its ancestry
			or be of class EMSpartedge/EMSdumedge. Any other
			owners are transparent.
   WBC        01/04/94  Making sure EMrestore_postproc gets called if
                        necessary, even when EMSboundary.EMpostdelete
                        fails (TR#119313321).
*/
{
  IGRboolean		notify = FALSE;
  IGRlong               OM_stat;
  IGRint                num_owners = 0, i;
  OMuint                count = 0;
  IGRboolean            deletable = FALSE;
  OM_S_CHANSELECT       to_owners;
  OM_S_OBJECT_LINKAGE	*owners = NULL, ownersbuf[StaticBuf];
  OMuword		clsid;
  IGRlong	        EMmsg;


  OM_stat = OM_S_SUCCESS;

  to_owners.type = OM_e_addr;
  to_owners.u_sel.addr = &ME.EMSedge->to_owner;

  OM_stat = om$get_channel_count(object = me, 
                                 p_chanselect = &to_owners,
                                 count = &count);
  EMomerr_hndlr(OM_stat, wrapup, "EMSpartedge.delete -- count owners")

  if(count > StaticBuf)
   {
    owners = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count *
	    sizeof(OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!owners, OM_stat, OM_E_ABORT, wrapup);    
   }
  else owners = ownersbuf;

  OM_stat = om$get_channel_objects(object = me, p_chanselect = &to_owners, 
	    list = owners, size = count, count = &count);
  EMomerr_hndlr(OM_stat, wrapup, "EMSedge.delete -- get owners")

  num_owners = 0;
  for(i=0; i<count; i++)
   {
    if(EFisAncestryValid(&EMmsg, owners[i].S_objid, OM_Gw_current_OS, 
			 OPP_EMSloop_class_id, TRUE))
     num_owners++;
    else
     {
      OM_stat = om$get_classid(objid = owners[i].S_objid, p_classid = &clsid);
      EMomerr_hndlr(OM_stat, wrapup, "EMSedge.delete -- get owner classid")
      if( (clsid == OPP_EMSpartedge_class_id) ||
	  (clsid == OPP_EMSdumedge_class_id))
       num_owners++;
     }
   }


  /*
   * Determine if I am deletable.
   */

  if(num_owners == 0) deletable = TRUE;
  else if(num_owners == 1)
  {
    deletable = TRUE;
    OM_stat = om$is_objid_on_channel(object_c = me, 
                 p_chanselect = &to_owners, objid = sender_id);

    if(OM_stat == OM_W_NOTONCHAN)
    {
      OM_stat = OM_S_SUCCESS;
      deletable = FALSE;
    }
    EMomerr_hndlr(OM_stat, wrapup, "EMSpartedge.delete -- check owner")

  }
  else deletable = FALSE;

  if(deletable)
  {
    OM_S_CHANSELECT      to_edge;
    IGRushort props;
    OM_S_CHANSELECT   to_common_edge;

    /*
     * Delete my edge.
     */

    to_edge.type = OM_e_addr;
    to_edge.u_sel.addr = &ME.EMSbd_owner->to_comps;

    OM_stat = om$send(msg=message Root.delete(defer_flag),
                  p_chanselect=&to_edge);
    EMomerr_hndlr(OM_stat, wrapup, "EMSpartedge.delete -- edge")

    props = EMED_REVERSE_CONNECT | EMED_SUBORDINATE;
    OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
				
    OM_stat = om$send(msg = message EMSedge.EMset_props
			(&EMmsg, props, EMS_O_OFF), 
			p_chanselect = &to_common_edge);
			
    /*
     * Delete myself.
     */

    if (notify = EMcheck_inhibit_postproc())
      {
      OM_stat = om$send (msg = message EMSboundary.EMpostdelete (&EMmsg,
                 NULL, NULL), targetid = my_id);
      EMerr_hndlr (EMSerror (OM_stat & EMmsg), OM_stat, OM_E_ABORT, wrapup);
      }

    OM_stat = om$send(mode = OM_e_wrt_message, 
                  msg=message Root.delete(defer_flag),
                  targetid = my_id);

    if (notify)
    {
      EMrestore_postproc();
      notify = FALSE;
    }

    EMomerr_hndlr(OM_stat, wrapup, "EMSpartedge.delete -- self")

  } /* if(deletable) */

 wrapup:

 if (notify)
   EMrestore_postproc();

 if(owners && (owners != ownersbuf)) om$dealloc(ptr = owners);
  return(OM_stat);
}

end implementation EMSpartedge;
