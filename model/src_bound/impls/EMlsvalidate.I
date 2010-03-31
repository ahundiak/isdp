/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include <stdio.h>
#include <ctype.h>
#include "emsdef.h"
#include "OMmacros.h"
#include "EMSlmdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSloop import EMget_props, EMset_props;

method EMvalidate(IGRlong *EMmsg; struct GRmd_env *mod_info;
		  IGRchar *surf_geom;
		  GRobjid *cancer; IGRushort *option;
		  IGRchar *objinfo, *ioptr)
{
  IGRint sts;
  IGRint   ix;
  OMuint count;
  OM_S_CHANSELECT chan_to_loops, chan_to_surface, chan_to_loopset;
  OM_S_OBJECT_LINKAGE	oblist;
  IGRchar obj_info[256];
  IGRushort lp_props;
  struct GRid my_GRid;
  IGRboolean continu = TRUE, correct, defective = FALSE;
  GRobjid		srfid = NULL_OBJID;
  IGRshort edDispOpt = EMS_WHL_EDGE;
  extern IGRboolean	IGEstop();

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  if(!(continu = !(IGEstop()))) goto wrapup;

/*******************  
  sprintf(obj_info, "Loopset (id=%d) (props=0x%x)",my_id,
				ME.EMSloopset->ls_props);
*******************/
				
  sts = om$send(msg = message EMSloopset.EMgetsurface_info(EMmsg, &srfid, 
						NULL),
			targetid = my_id);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_LoopsetError,wrapup);

  if(!objinfo)
   {
    /* Keep the following sprintf statements as they are.
    */
    if(IF_NULL_OBJID(srfid))
     sprintf(obj_info, "Loopset (id=%d) (props=0x%x)\n             No path to surface", my_id, ME.EMSloopset->ls_props);
    else
     sprintf(obj_info, "Loopset (id=%d) (props=0x%x)\n             On surface = %d osnum %d", my_id, ME.EMSloopset->ls_props, srfid, my_GRid.osnum);
   }
  else
   strcpy(obj_info, objinfo);

  chan_to_loops.type = OM_e_addr;
  chan_to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

  chan_to_surface.type = OM_e_addr;
  chan_to_surface.u_sel.addr = &ME.EMSloopset->to_surface;

  /* Message is sent instead of channel count to get a count ignoring all
     the feature loops.
     -- 9/10/92-- Since feature loops are no longer under the loopset,
     it is ok to make a channel count. This will also prevent false alarms
     if the only loops under the loopset are point loops. Point loops can
     get generated during booleans/make face/imp bdry etc.
  */
/****************************
  sts = om$send(msg = message EMSloopset.EMget_loops(EMmsg, EMS_OPT_ALL, 
				&depth, NULL, NULL, &junk, &count), 
				targetid = my_id);
  EMomerr_exit (sts, wrapup);
****************************/

  sts = om$get_channel_count(object = me, p_chanselect = &chan_to_loops, 
                               count = &count);
    
  EMomerr_exit (sts, wrapup);

  if (!count)
  {
    sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info,
		"Empty","Delete", &continu, &correct, 
		 NULL, option, ioptr, &edDispOpt);
    EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);    
    if (correct)
    {
	sts = om$get_channel_objects(object = me,
				p_chanselect = &chan_to_surface,
				list = &oblist,
				size = 1,
				count = &count);
	EMomerr_exit (sts, wrapup);

        sts = EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
	EMomerr_exit (sts, wrapup);

	sts = om$send(msg = message Root.disconnect(chan_to_surface,
			oblist.S_objid, OM_Gw_current_OS, chan_to_loopset),
			targetid = my_id);
	EMomerr_exit (sts, wrapup);

	sts = om$send(msg = message Root.delete(0),
			targetid = my_id);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
    }
    else defective = TRUE;
    goto wrapup; 

  }  /* if count == 0 */

  else if (count > 1 && (ME.EMSloopset->ls_props & EMLS_NATURAL))
  {
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info,
		 "Incorrect natural bit",
		  "Turn the bit off", &continu, &correct, NULL, 
		   option, ioptr, &edDispOpt);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);    
      if (correct)
      {
        sts = om$send(msg = message EMSloopset.EMset_props(EMmsg, 
					EMLS_NATURAL, EMS_O_OFF),
			targetid = my_id);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopsetError,wrapup);
      }
     else defective = TRUE;
      if (!continu) goto wrapup;
  }

  /* Get channel count so that feature loops are included in further
     validation processing.
  */
  sts = om$get_channel_count (objid = my_id, p_chanselect =
             &chan_to_loops, count = &count);
  EMomerr_exit (sts, wrapup);

  for (ix=0; ix<count; ix++)
  {
    sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &lp_props),
			p_chanselect = &chan_to_loops,
			to = ix);
    EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);

    if( (!(lp_props & EMLP_PLOOP)) && (!(lp_props & EMLP_NOAREA_NOHOLE)))
    {
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info,
			 "External C loop", NULL, &continu, &correct, 
			  NULL, option, ioptr, &edDispOpt);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      defective = TRUE;
      if (!continu) goto wrapup;
    }

    if (! (lp_props & EMLP_EXTERNAL))
    {
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"External loop not flagged",
		  "Flag it", &continu, &correct, NULL, 
		  option, ioptr, &edDispOpt);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);    
      if (correct)
      {
        sts = om$send(msg = message EMSloop.EMset_props(EMmsg, 
					EMLP_EXTERNAL, EMS_O_ON),
			p_chanselect = &chan_to_loops,
			to = ix);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);
      }
      else defective = TRUE;
      if (!continu) goto wrapup;
    }
  }
  if (ME.EMSloopset->ls_props & EMLS_SPLIT)
  {
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Flagged as split",
		  "Turn the bit off", &continu, &correct, NULL, 
		  option, ioptr, &edDispOpt);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);    
      if (correct)
      {
        sts = om$send(msg = message EMSloopset.EMset_props(EMmsg, 
					EMLS_SPLIT, EMS_O_OFF),
			targetid = my_id);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopsetError,wrapup);
      }
      else defective = TRUE;
      if (!continu) goto wrapup;
  }
  if (ME.EMSloopset->ls_props & EMLS_XYZ)
  {
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Incorrect xyz-bit",
		  "Turn the bit off", &continu, &correct, NULL, option, 
		 ioptr, &edDispOpt);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);    
      if (correct)
      {
        sts = om$send(msg = message EMSloopset.EMset_props(EMmsg, 
					EMLS_XYZ, EMS_O_OFF),
			targetid = my_id);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopsetError,wrapup);
      }
      else defective = TRUE;
      if (!continu) goto wrapup;
  }
  sts = om$send(msg = message GRgraphics.EMvalidate(EMmsg, mod_info,
					surf_geom, cancer, option, objinfo, 
					ioptr), 
			p_chanselect = &chan_to_loops);
  EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);
  if(sts == OM_I_STOP_SENDING) continu = FALSE; 
	
wrapup :
 if(defective)
  {
   *cancer = my_id;
   *EMmsg = EMS_I_LoopsetError;
  }
  EMWRAPUP(*EMmsg, sts, "In EMSloopset.EMvalidate")
  if(!continu || (*EMmsg == EMS_I_Interrupt))
   {*EMmsg = EMS_I_Interrupt; return (OM_I_STOP_SENDING);}
  else return (sts);
}

end implementation EMSloopset;
