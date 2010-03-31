/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfspltwsf;

#include "EMS.h"
#include "EMSopt.h"

/*
History
    Sunit   Sometime in the 80's    Creation.
    DLB     03/13/91                Handle EMreex param change.
    DLB     04/30/91                Add more EMreex params.
*/

method EMreexecute(IGRlong *EMmsg; IGRushort *option;
                   struct GRmd_env *env; IGRint parent_count;
                   struct GRid *parent_list;
                   IGRuint type;
                   IGRchar *recomp_info;
                   struct GRvg_construct *construct_list)
{
 IGRlong                 sts;
 union EMSssi_table      *ssi = NULL;
 struct EMSboolssi_table *my_info = NULL;


 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 sts = om$send(mode = OM_e_wrt_message, 
               msg = message EMSsfboolean.EMreexecute(EMmsg, option, env, 
                     parent_count, parent_list,
                     type, recomp_info,
                     construct_list),
               targetid = my_id);

 /*
  If connected, re-display affected surfaces from the complimentary piece.
 */
 if(*option & EMS_DO_DISPLAY)
  {
   OM_S_CHANSELECT        to_mirror_image;
   OMuint                 i, connected = 0;
   OM_S_OBJECT_LINKAGE    image;

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
if(1&*EMmsg&sts) *EMmsg = EMS_I_ChangeClass;
if(ssi) om$dealloc(ptr = ssi);
EMWRAPUP(*EMmsg, sts, "EMSsfspltwsf.EMreexecute");
return(sts);

}

end implementation EMSsfspltwsf;
