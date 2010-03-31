/* ###################   APOGEE COMPILED   ################## */
/*

 Do Partedge specific validation and send wrt message
 EMSedge.EMvalidate.

HISTORY
	SM	03-Feb-89	Creation.
	SM	26-May-89	Partedge must own ONLY one edge. Else
				report error.
	SM	21-Jun-89	If partedge owns more than 1 edge, delete
				those edges which are exclusively owned
				by the partedge, as corrective action.
*/

class implementation EMSpartedge;

#include <stdio.h>
#include <ctype.h>
#include "emsdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define	EdBuff	10

extern OMuword OPP_EMSnatedge_class_id;

method EMvalidate(IGRlong *EMmsg; struct GRmd_env *mod_info;
		  IGRchar *surf_geom;
		  GRobjid *cancer; IGRushort *option;
		  IGRchar *objinfo, *ioptr)
{
  OMuint                count;
  IGRint		sts;
  IGRchar		obj_info[256];
  struct		GRid my_GRid;
  IGRboolean		continu = TRUE, correct;
  OMuword		bot_classid;
  GRobjid		bottom_edge = NULL_OBJID;
  OM_S_CHANSELECT       to_owners, to_edge;
  OM_S_OBJECT_LINKAGE	*ed = NULL, edbuff[EdBuff];
  GRobjid		*deled = NULL, *disconned = NULL, 
			deledbuff[EdBuff], disconnedbuff[EdBuff];
  OMuint                numown = 0;
  IGRint		i, numdeled = 0, numdisconned = 0;
  extern IGRint  	EMcount_loops();
  GRobjid		srfid = NULL_OBJID;
  IGRboolean		defective = FALSE, deletable = FALSE;
  extern IGRboolean	IGEstop();

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
 if(!(continu = !(IGEstop()))) goto wrapup;

  sts = om$send(msg = message EMSedge.EMgetsurface_info(EMmsg, &srfid, 
						NULL),
			targetid = my_id);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_LoopError,wrapup);

/* fix for umr */
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  if(!objinfo)
   {
    /* Keep the following sprintf statements as they are.
    */
    if(IF_NULL_OBJID(srfid))
     sprintf(obj_info, "Part Edge (id=%d) (props=0x%x)\n             No path to surface", my_id, ME.EMSedge->ed_props);
    else
     sprintf(obj_info, "Part Edge (id=%d) (props=0x%x)\n             On surface = %d osnum %d", my_id, ME.EMSedge->ed_props, srfid, my_GRid.osnum);
   }
  else
   strcpy(obj_info, objinfo);

  EMmake_chanselect(EMSbd_owner_to_comps, &to_edge);
  EMmake_chanselect(EMSedge_to_owner, &to_owners);


  sts = om$send (msg = message EMSedge.EMget_bottom_edge (EMmsg,
                          &bottom_edge), targetid = my_id);
  if (!(1&sts)) goto wrapup;

  /* Partedge must have a path to the full edge to be able to lead a 
     fruitful and enjoyable life. If not and caller willing, try mercy
     killing. */

  if(IF_NULL_OBJID(bottom_edge))
   {
    sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		   "Part edge has no path to full edge",
	    "Delete the partedge", &continu, &correct, NULL, option, ioptr, 
	    NULL);
    EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
    if (correct) 
     {
      sts = om$send(msg = message Root.wild_disconnect(to_owners), 
				targetid = my_id);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      sts = om$send(msg = message Root.delete(TRUE), targetid = my_id);
      goto wrapup;
     }
    else defective = TRUE;
    if (!continu) goto wrapup;

   } /* if(IF_NULL_OBJID(bottom_edge)) */

  if(!IF_NULL_OBJID(bottom_edge))
   {
     /* Having two full edges is too much of an achievement for the partedge
        to handle.
     */
     sts = om$get_channel_count(object = me, p_chanselect = &to_edge, 
				count = &count);
     EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
     if(count > 1)
      {
       if(count > EdBuff)
         ed = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count * 
	      sizeof(OM_S_OBJECT_LINKAGE));
       else ed = edbuff;

       EMerr_hndlr (!ed, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

       if(count > EdBuff)
        {
         deled = (GRobjid *) om$malloc(size = count * sizeof(GRobjid));
         disconned = (GRobjid *) om$malloc(size = count * sizeof(GRobjid));
	}
       else
        {
	 deled = deledbuff;
	 disconned = disconnedbuff;
        }

       EMerr_hndlr (!deled || !disconned, *EMmsg, EMS_E_NoDynamicMemory, 
		    wrapup);

       sts = om$get_channel_objects(object = me, p_chanselect = &to_edge, 
				list = ed, size = count, count = &count);
       EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);

       /* any edge exclusively owned by this edge is deletable. If all are 
	  deletable keep atleast one.
       */     
       for(i=0; i<count; i++)
        {
	 numown = 0;
	 deletable = FALSE;
         sts = om$get_channel_count(objid = ed[i].S_objid, 
		p_chanselect = &to_owners, count = &numown);
         EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
         if(! (1&*EMmsg&sts))goto wrapup;
	 if(!numown) deletable = TRUE;
	 else if(numown ==1)
	  {
	   OM_S_OBJECT_LINKAGE	junk;
	   OMuint		junkjunk = 0;
	
           sts = om$get_channel_objects(objid = ed[i].S_objid, 
 		 p_chanselect = &to_owners, list = &junk, size = 1, 
		 count = &junkjunk);
           EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
	   if(IF_EQ_OBJID(junk.S_objid, my_id)) deletable = TRUE;
	  }
	
	 if(deletable) deled[numdeled++] = ed[i].S_objid;
	 else disconned[numdisconned++] = ed[i].S_objid;
	
        } /* for(i=0; i<count; i++) */

       if( (numdeled+numdisconned) >= count)
        {
	 if(numdisconned) numdisconned--;
         else if(numdeled) numdeled--; /* keep atleast 1 */
        }

       sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		   "Part edge owns more than one full edge", 
		   numdeled ? "Delete exclusively owned edges"
		   : (numdisconned ? "Disconnect edges, keeping one connection"
				   : NULL), 
		   &continu, &correct, NULL, option, ioptr, NULL);
       EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
       if(correct)
        {
         for(i=0; i<numdeled; i++)
	  sts = om$send(msg = message Root.delete(TRUE), senderid = my_id, 
				targetid = deled[i]);

	 for(i=0; i<numdisconned; i++)
	  sts = om$send(msg = message Root.disconnect
		 (to_owners, my_id, OM_Gw_current_OS, to_edge), 
				targetid = disconned[i]);
				
	 /* Get the bootom edge again for further use since we could have
	    deleted the one obtained before.
	 */
	 if(numdeled)
	  {
  	   sts = om$send (msg = message EMSedge.EMget_bottom_edge (EMmsg,
                          &bottom_edge), targetid = my_id);
  	   if (!(1&sts)) goto wrapup;
	  }
        }

       else defective = TRUE;
       if (!continu) goto wrapup;

      } /* if(count > 1) */

   }/* if(!IF_NULL_OBJID(bottom_edge)) */

  /* Check the natural property of the partedge.
  */
  if(!IF_NULL_OBJID(bottom_edge))
   {
    sts = om$get_classid(objid = bottom_edge, 
                               p_classid = &bot_classid);
    if( !(1&sts)) goto wrapup;

    if ( (sts = om$is_ancestry_valid
		(superclassid = OPP_EMSnatedge_class_id, 
		 subclassid = bot_classid)) == OM_S_SUCCESS)
     {
      if (!(me->ed_props & EMED_NATURAL))
       {
        sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		   "Part of natural edge is not flagged as natural",
		    "Turn the natural-bit on", &continu, &correct, NULL, 
		    option, ioptr, NULL);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
        if (correct) ME.EMSedge->ed_props |= EMED_NATURAL;
        else defective = TRUE;
        if (!continu) goto wrapup;
       }
     }
    else
     {
      if (me->ed_props & EMED_NATURAL)
       {
        sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		   "Part edge is incorrectly flagged natural",
		    "Turn the natural-bit off", &continu, &correct, NULL, 
		   option, ioptr, NULL);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
        if (correct) ME.EMSedge->ed_props &= ~EMED_NATURAL;
        else defective = TRUE;
        if (!continu) goto wrapup;
       }
     }

   } /* if(!IF_NULL_OBJID(bottom_edge)) */

  sts = om$send(mode = OM_e_wrt_message, msg = message EMSedge.EMvalidate
			(EMmsg, mod_info, surf_geom, cancer, option, obj_info, 
			 ioptr), 
			targetid = my_id) ;
			
wrapup :
  if(ed && (ed != edbuff)) om$dealloc(ptr = ed);
  if(deled && (deled != deledbuff)) om$dealloc(ptr = deled);
  if(disconned && (disconned != disconnedbuff)) om$dealloc(ptr = disconned);

  if(defective)
   {
    *cancer = my_id;
    *EMmsg = EMS_I_EdgeError;
   }
  EMWRAPUP(*EMmsg, sts, "In EMSpartedge.EMvalidate")
  if(!continu || (*EMmsg == EMS_I_Interrupt))  
   {*EMmsg = EMS_I_Interrupt; return (OM_I_STOP_SENDING);}
  else return (sts);
}

end implementation EMSpartedge;
