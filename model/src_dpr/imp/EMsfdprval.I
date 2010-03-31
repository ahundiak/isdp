/*
History
      SM    12/09/92    Creation. Check if top DPR node is active.
*/
class implementation EMSsfdpr;

#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSopt.h"

method EMvalidate(IGRlong *EMmsg; struct GRmd_env *mod_info;
		  IGRchar *geom; GRobjid *cancer; IGRushort *option;
		  IGRchar *objinfo, *ioptr)


{
 IGRlong	     OM_stat;    
 OM_S_CHANSELECT     to_owners;
 extern IGRboolean   IGEstop();
 IGRboolean	     continu = TRUE, correct = TRUE, defective = FALSE, 
                     owner_dpr = FALSE;
 IGRushort	     props = NULL;
 IGRint		     count;
 IGRchar   	     obj_info[256];
 GRobjid             sendid;
 OM_S_OBJECT_LINKAGE ownid[2];

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 if(!(continu = !(IGEstop()))) goto wrapup;
 sendid = sender_id;

 /* Execute the composite implementation first.
 */
 OM_stat = om$send(mode = OM_e_wrt_message, 
           msg = message EMScompsurf.EMvalidate(EMmsg, mod_info, geom, cancer,
                 option, objinfo, ioptr), targetid = my_id, 
           senderid = sendid);
 if(!(1&*EMmsg&OM_stat)) goto wrapup;
 if(*EMmsg == EMS_I_Interrupt) goto wrapup;

 /* DPR validations
 */
 if(!objinfo)
  sprintf(obj_info, "DPR Node (id=%d) (grprops=0x%x, dprprops=0x%x)\n", my_id, 
		ME.GRgraphics->properties, ME.EMSdpr->dpr_props);
 else
  strcpy(obj_info, objinfo);

 /* If I am the top node, I should have 'active' and 'active path'
    properties. If I am an intermediate node I should have 'active path'
    property only.
 */
 EMmake_chanselect(GRconnector_to_owners, &to_owners);
/*******
 OM_stat = om$get_channel_count(object = me, p_chanselect = &to_owners, 
           count = &count);
**************/
 OM_stat = om$get_channel_objects(object = me, p_chanselect = &to_owners, 
           list = ownid, size = 2, count = (OMuint *)&count);
 if(!(1&OM_stat)) goto wrapup;

 if(count)
  owner_dpr = EFisAncestryValid(EMmsg, ownid[0].S_objid, ownid[0].osnum, 
              OPP_EMSdpr_class_id, TRUE);

 props = ME.EMSdpr->dpr_props;
 if(!(props & EMSIS_ACTIVE_PATH))
  {
   OM_stat = EMvalidate_io(EMmsg, mod_info, NULL, obj_info,
	"Incorrect Active Path flag", "Turn the bit ON", 
	 &continu, &correct, NULL, option, ioptr, NULL);
   EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);

   if(correct) ME.EMSdpr->dpr_props |= EMSIS_ACTIVE_PATH;
   else defective = TRUE;
   if (!continu) goto wrapup;
  }

 props = ME.EMSdpr->dpr_props;
 if( (owner_dpr && count && (props & EMSIS_ACTIVE_STATE)) ||
     (owner_dpr && !count && !(props & EMSIS_ACTIVE_STATE)))
  {
   OM_stat = EMvalidate_io(EMmsg, mod_info, NULL, obj_info,
	"Incorrect Active State flag", 
	props & EMSIS_ACTIVE_STATE ? "Turn the bit OFF" : "Turn the bit ON", 
	 &continu, &correct, NULL, option, ioptr, NULL);
   EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);

   if(correct) 
    {
     if(props & EMSIS_ACTIVE_STATE)
      ME.EMSdpr->dpr_props &= (~EMSIS_ACTIVE_STATE);
     else ME.EMSdpr->dpr_props |= EMSIS_ACTIVE_STATE;
    }
   else defective = TRUE;
   if (!continu) goto wrapup;
  }

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsfdpr.EMvalidate")
  if(!continu || (*EMmsg == EMS_I_Interrupt)) 
   {*EMmsg = EMS_I_Interrupt; return (OM_I_STOP_SENDING);}
  else return (OM_stat);
}
end  implementation EMSsfdpr;

