/* ###################   APOGEE COMPILED   ################## */
/*
History
	SM	14-Jan-89	Creation.
*/
class implementation EMSsfspltwsf;

#include "EMS.h"
#include "EMSprop.h"
#include "EMSopt.h"

method EMundo(IGRlong           *EMmsg;
              IGRushort *option;
              struct GRmd_env   *my_env;
              struct GRid       **active_state; 
              IGRint            *num, 
                                *buff_size;
              GRobjid           **display_ids;
              IGRint            *display_count,
                                *involk_count)
{
 IGRlong		sts;
 OM_S_CHANSELECT	to_mirror_image;
 OMuint			connected = 0;
 IGRboolean		other_free = FALSE;
 
 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 if( (ME.EMSsfspltwsf->splt_props & EMsws_IsOriginal) ||
     (*option & EMS_UNDO_SAVE))
  {
   sts = om$send(mode = OM_e_wrt_message, msg = message EMSdpr.EMundo
				(EMmsg, option, my_env, active_state, num, 
				 buff_size, display_ids, display_count, 
				 involk_count), targetid = my_id);
   goto wrapup;
  }

 /* Will come here only if copy and undo delete */

   sts = EMmake_chanselect (EMSsfspltwsf_to_mirror_image, &to_mirror_image);

   sts = om$get_channel_count(object = me, p_chanselect = &to_mirror_image, 
			      count = &connected);
   if(!(1&sts)) goto wrapup;
   if(connected)
    {
     IGRshort props = NULL;
   
     sts = om$send(msg = message GRgraphics.GRgetprops(EMmsg, &props), 
			p_chanselect = &to_mirror_image);
     other_free = props & GR_RIGID_RELATIONSHIP ? FALSE : TRUE;
    }

   if(other_free)
     sts = om$send(msg = OPPmargs, p_chanselect = &to_mirror_image);
   else sts = om$send(mode = OM_e_wrt_message, msg = message EMSdpr.EMundo
				(EMmsg, option, my_env, active_state, num, 
				 buff_size, display_ids, display_count, 
				 involk_count), targetid = my_id);
				
wrapup:
EMWRAPUP(*EMmsg, sts, "In EMSsfspltwsf.EMundo");
return(sts);

}

end implementation EMSsfspltwsf;
