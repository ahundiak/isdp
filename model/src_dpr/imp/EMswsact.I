/* ###################   APOGEE COMPILED   ################## */
/*
History
	SM	17-Jan-89	Creation.
*/
class implementation EMSsfspltwsf;

#include "EMS.h"
#include "EMSprop.h"
#include "EMSopt.h"

method EMactivate (
    IGRlong *EMmsg;
    IGRshort *option;
    struct GRmd_env *env;
    GRobjid **display_ids; 
    IGRint *display_count)
{
 IGRlong		sts;
 union EMSssi_table     *ssi = NULL;
 struct EMSboolssi_table   *my_info = NULL;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 /* Activate myself.
 */
 sts = om$send(mode = OM_e_wrt_message, 
	       msg = message EMSsfboolean.EMactivate
	(EMmsg, option, env, display_ids, display_count), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
     
 /* The activation just done has erased the affected surfaces and they will
    be redrawn later. But this has also erased parts of the complimentary
    piece (if it existed). So we need to redisplay the affected surfaces
    on the complementary piece.
 */
 if(*option & EMS_DO_DISPLAY)
  {
   OM_S_CHANSELECT	to_mirror_image;
   OMuint		i, connected = 0;
   OM_S_OBJECT_LINKAGE	image;

   sts = om$make_chanselect(channame = "EMSsfspltwsf.to_mirror_image", 
				p_chanselect = &to_mirror_image);
   sts = om$get_channel_objects(object = me, p_chanselect = &to_mirror_image, 
			    list = &image, size = 1, count = &connected);
   if(connected)   
    {
     /* Send a message to the complimentary piece to get the save state info 
        table.
     */
     sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                targetid = image.S_objid);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);

     my_info = (struct EMSboolssi_table *) &ssi->bool_info;
     for(i=0; i<my_info->num_surfaces; i++)
      {
       enum GRdpmode display_mode = GRbd;   
 
       sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                              &env->md_env.matrix_type, 
                              env->md_env.matrix, &display_mode,
                              &env->md_id),
                        targetid = my_info->surface_ids[i]);
       EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, *EMmsg, wrapup);
      }

    } /* if(connected) */

  } /* if(*option & EMS_DO_DISPLAY) */

wrapup:
if(ssi) om$dealloc(ptr = ssi);
EMWRAPUP(*EMmsg, sts, "In EMSsfspltwsf.EMactivate");
return(sts);

}

end implementation EMSsfspltwsf;
