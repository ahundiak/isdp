/* ###################   APOGEE COMPILED   ################## */
/*
 This function is intended to restore the topology to its original state
 if failure ocuurs during spliting of edges or during closing of some new
 loops.
 This function will do the following -
 1) Unsplit all the edges and restore them to their original state. During
    this processing the partedges created as a result of the splits will
    be deleted along with the split objects if any.
 2) Delete all the new loops created.
 3) Turn the EMLP_SPLIT bit off in all the loops to which the edges that
    were split belonged.

History
	SM	13-July-88	Creation.
	SM	21-Nov-88	For edges that were not split in the middle, 
				the split objects were left hanging
				around. Fixed this by explicitly deleting
				the split objects.
*/

class implementation EMSedge;

#include "EMS.h"

#include "emsdef.h"
#include "OMmacros.h"

#if DEBUG
#include <stdio.h>
#endif

from EMSloop import EMset_props, EMtreemod;

extern OMuword OPP_EMSedge_class_id;

IGRint EMsplit_graceful_exit(EMmsg, num_edsplit, edsplit, num_newloops, 
			     new_loops)
 IGRlong		*EMmsg;
 IGRint			num_edsplit;
 GRobjid		*edsplit;
 IGRint			num_newloops;
 GRobjid		*new_loops;
{
 IGRlong		sts, rc;
 IGRint			i;
 OM_S_CHANSELECT	to_edges;
 GRobjid		splitobj[2];
 IGRushort 	split = NULL;
 

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 rc = EMS_S_Success;

 sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
				
#if DEBUG
 fprintf(stderr, "Peacefuly, Gracefuly, Cheerfuly exiting\n");
#endif

/* Unsplit all the split edges */

 for(i=0; i<num_edsplit; i++)
  {
   if(IF_NULL_OBJID(edsplit[i])) 
    continue;

   if(!EFisAncestryValid(EMmsg, edsplit[i], OM_Gw_current_OS, 
       OPP_EMSedge_class_id, TRUE))
    {
     edsplit[i] = NULL_OBJID;
     continue;
    }
   sts = om$send(msg = message EMSedge.EMunsplityourself(EMmsg, NULL), 
			targetid = edsplit[i], senderid = edsplit[i]);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
  }

/* Turn the EMLP_SPLIT bit off.
*/
 for(i=0; i<num_edsplit; i++) 
  {
   if(IF_NULL_OBJID(edsplit[i])) 
    continue;

   sts = EMsend_loops(&rc, 
		message EMSloop.EMset_props(EMmsg, EMLP_SPLIT, EMS_O_OFF), 
		edsplit[i], 0, MAXINT, EMLP_SPLIT, NULL, NULL);
   EMerr_hndlr(!(1&*EMmsg&sts&rc), *EMmsg, EMS_E_Fail, wrapup);
  } 

/* Delete all the new loops
*/
 for(i=0; i<num_newloops; i++)
  {
   struct EMSnest_info	junk;
   OMuint num_edges;
   IGRint j;

   if((sts = om$is_objid_valid(objid = new_loops[i])) != OM_S_SUCCESS)
     {sts = OM_S_SUCCESS; continue;}
	
   sts = om$get_channel_count(objid = new_loops[i], p_chanselect = &to_edges, 
				count = &num_edges);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

   for(j=0; j<num_edges; j++)
    {
     split = NULL;
     
     sts = om$send(msg = message EMSedge.EMissplit(EMmsg, &split, splitobj), 
		senderid = new_loops[i], p_chanselect = &to_edges, 
		from = j, to = j);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

     if(split & EMSedge_BeginSplit)
      {
       sts = om$send(msg = message Root.delete(TRUE), targetid = splitobj[0], 
			senderid = splitobj[0]);
       EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);
      }

     if(split & EMSedge_EndSplit)
      {
       sts = om$send(msg = message Root.delete(TRUE), targetid = splitobj[1], 
			senderid = splitobj[1]);
       EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);
      }
    } /* for(j=0; j<num_edges; j++) */

   sts = om$send(msg = message EMSloop.EMtreemod(EMmsg, &junk, DELETE, NULL),
			targetid = new_loops[i], senderid = new_loops[i]);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
  }


wrapup:
 EMWRAPUP(*EMmsg, sts, "In EMsplit_graceful_exit");
 return(sts);
}

end implementation EMSedge;
