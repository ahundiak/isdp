/* ###################   APOGEE COMPILED   ################## */
/*
History
	SM	11-Jan-89	Creation.
*/
class implementation EMSsfspltwsf;

#include "EMS.h"
#include "EMSprop.h"
#include "EMSopt.h"

method EMdeactivate(IGRlong *EMmsg; IGRshort *option;
                    struct GRmd_env *env;
                    GRobjid **display_ids; IGRint *display_count)
{
 IGRlong		sts;
 OM_S_CHANSELECT	to_mirror_image;
 OMuint			connected = 0;
 OM_S_OBJECT_LINKAGE	image;
 IGRboolean		other_free = FALSE;


 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 if(!(*option & EMS_UNDO_SAVE))
  {
   sts = om$make_chanselect(channame = "EMSsfspltwsf.to_mirror_image", 
				p_chanselect = &to_mirror_image);
   sts = om$get_channel_objects(object = me, p_chanselect = &to_mirror_image, 
			    list = &image, size = 1, count = &connected);
  }

 if(connected && !(*option & EMS_UNDO_SAVE))
  {
   IGRshort props = NULL;
   sts = om$send(msg = message GRgraphics.GRgetprops(EMmsg, &props), 
			p_chanselect = &to_mirror_image);
   other_free = props & GR_RIGID_RELATIONSHIP ? FALSE : TRUE;
  }

 if(connected && !(*option & EMS_UNDO_SAVE))
  {
   if(other_free)
    {
     if(!(ME.EMSsfspltwsf->splt_props & EMsws_IsOriginal))
      {
       sts = om$send(msg = OPPmargs, p_chanselect = &to_mirror_image);
       goto wrapup;
      }
     else
      {
       /* Delete the copy.
       */
       sts = om$send(msg = message Root.wild_disconnect(to_mirror_image), 
				targetid = my_id);
       sts = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                    targetid = image.S_objid);
       if (!(1&sts&*EMmsg)) goto wrapup;
       sts = om$send(mode = OM_e_wrt_message, 
	       msg = message EMSsfboolean.EMdeactivate
	       (EMmsg, option, env, display_ids, display_count), 
	       targetid = my_id);
      }

     }/* if(other_free) */
    
    else
     {
      sts = om$send(mode = OM_e_wrt_message, 
	      msg = message EMSsfboolean.EMdeactivate
	      (EMmsg, option, env, display_ids, display_count), 
	      targetid = my_id);
      if (!(1&sts&*EMmsg)) goto wrapup;
      sts = om$send(msg = message Root.wild_disconnect(to_mirror_image), 
				targetid = my_id);
      sts = om$send(msg = message EMSdpr.EMchangeClass(EMmsg, NULL, NULL), 
			targetid = image.S_objid);
     }

  }/* if(connected && !(*option & EMS_UNDO_SAVE))*/

 else 
   sts = om$send(mode = OM_e_wrt_message, 
	      msg = message EMSsfboolean.EMdeactivate
	      (EMmsg, option, env, display_ids, display_count), 
	      targetid = my_id);

wrapup:
EMWRAPUP(*EMmsg, sts, "In EMSsfspltwsf.EMdeactivate");
return(sts);

}

end implementation EMSsfspltwsf;
