class implementation CODelSecSol;

/**************************************************************************

 This implementation deals with the peculiar case of deletion of the  gen.
 solid created during section view construction.
 CR Section View Enhancements.

 HISTORY

 09/09/96 Creation  Sp.Balamurugan

**************************************************************************/

#include <stdio.h>
#include "FI.h"
#include <stdlib.h>
#include <string.h>
#include <alloca.h>
#include "OMindex.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrdef.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "exmacros.h"
#include "madef.h"
#include "msdef.h"
#include "griomacros.h"
#include "grerr.h"
#include "OMmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "nddef.h"
#include "msmacros.h"
#include "ECcmd.h"
#include "grmsg.h"
#include "ECmsg.h"
#include "emserr.h"
#include "csmacros.h"
#include "EMSasectvw.h"
#include "dpezmac.h"

from EMSassoc import EMget_info,EMput_info;
from GRgraphics import  GRdelete, GRlocate, GRdisplay;
from NDnode     import NDdisconnect;

extern OMuword OPP_EMSgensolid_class_id; 
extern OMuword OPP_EMSasectvw_class_id;

method init(int type; char *str_ptr)
{
    IGRint status;
    status =
    om$send(msg = message super_cmd.init(type, str_ptr),
            mode = OM_e_wrt_message,
            targetid = my_id);
    return(OM_S_SUCCESS);
}

method wakeup(int pos)
{
    IGRint status;
    ex$message(msgnumb = EM_M_DelSecSol);
    status = om$send( msg = message super_cmd.wakeup(pos),
                      mode = OM_e_wrt_message,
                     targetid = my_id);
    return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
   IGRlong msg;
   IGRint status, sts=OM_S_SUCCESS;
   IGRchar  locate_prompt[52], accept_prompt[52], relocate_prompt[52];
   IGRlong  locate_mask, accept_mask;
   IGRlong  object_was_located, display_flag;
   struct GRlc_locate  attributes;
   OM_S_CLASSLIST  rtree_classes,elig_classes;
   OMuword  rclass, eliclass[2], accept_classid[2];
   IGRlong size;
   struct GRid sect;
   
   /** LOCATE SECTION VIEW  **/
   display_flag = ALL_WINDOWS | ELEM_HILIGHT;
   locate_mask = GRm_DATA|GRm_BACK_UP| GRm_RESET;
   accept_mask = GRm_DATA|GRm_BACK_UP;
   
   strcpy(locate_prompt,"Locate Section View ");
   strcpy(accept_prompt,"Accept/Reject");
   strcpy(relocate_prompt,"Section View Not Found");
 
   attributes.properties = LC_LC_ONLY | LC_DP_ONLY;
 
   attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_OWNER | LC_FLEX_COMP | 
                             LC_RIGID_COMP; 
 
   strcpy(attributes.classes, "EMSasectvw");
 
   elig_classes.w_count = 1;
   elig_classes.w_flags = OM_CLST_subclass;
   eliclass[0] = OPP_EMSasectvw_class_id;
   elig_classes.p_classes = eliclass;
 
   rtree_classes.w_count = 1;
   rtree_classes.w_flags = OM_CLST_subclass;
   rclass = OPP_EMSasectvw_class_id;
   rtree_classes.p_classes = &rclass;

   accept_classid[0] = OPP_EMSasectvw_class_id;

   size = sizeof(struct GRevent);

   status = lc$locate(rc = &object_was_located,
                event1 = &me->locate_event,
                event2 = &me->acc_event,
                eventsize = &size,
                mask1 = locate_mask,
                mask2 = accept_mask,
                display_flag = display_flag,
                response = response,
                response_data = response_data,
                locate_prompt = locate_prompt,
                acc_prompt = accept_prompt,
                relocate_prompt = relocate_prompt,
                attributes = &attributes,
                stack = &me->locate_stack,
                rtree_classes = &rtree_classes,
                eligible_classes = &elig_classes);

   if (*response == EX_DATA || object_was_located)
   {
       /** PROCESS SECTION VIEW **/
       status = dp$erase_hilite(msg = &msg);

       sect.objid = me->acc_event.located_object[0].located_obj.objid;
       sect.osnum = me->acc_event.located_object[0].located_obj.osnum;

       {/* Intentional block */

          IGRuint                   i;
          OMuint                    num_cmpnts;
          struct GRmd_env           module_env; 
          IGRuint                   num_objects;
          OM_S_CHANSELECT           to_owners,to_cmpnt_chansel;
          IGRuint                   info_size, type;
          struct EMS_ASsectvw_info  *sect_view_info;
          OMuword                   classid;
          OM_S_OBJECT_LINKAGE       *f_ids ;
          enum GRdpmode             mode;
          IGRushort                 options;
 
          status = gr$get_module_env(buffer = &module_env);

          /** Get the recomp_info*/ 
          status = om$send(msg = message EMSassoc.EMget_info(&msg, NULL,
                                                             &type, &info_size,
                                                             NULL),
                           targetid =sect.objid,
                           targetos = sect.osnum);
 
          sect_view_info = (struct EMS_ASsectvw_info *)alloca(info_size);
 
          status = om$send(msg = message EMSassoc.EMget_info(&msg,
                                            NULL, &type,
                                            &info_size,
                                            (IGRchar **) &sect_view_info),
                           targetid =sect.objid,
                           targetos = sect.osnum);


          if (sect_view_info->view_info.flags & SV_SHOW_VISIBLE_LINES)
          {
             sect_view_info->view_info.flags=sect_view_info->view_info.flags & 
                                             ~SV_SHOW_VISIBLE_LINES;
          }

          status = om$send(msg = message EMSassoc.EMput_info(&msg,
                                                NULL, EMS_ASsectvw, 
                                               sizeof(struct EMS_ASsectvw_info),
                                                (IGRchar *) sect_view_info),
                           targetid =sect.objid,
                           targetos = sect.osnum);


          status = om$make_chanselect(channame = "GRcmpowner.to_components",
                                    p_chanselect = &to_cmpnt_chansel);
        
          status = om$get_channel_count(osnum=sect.osnum,
                                        objid =sect.objid,
                                        p_chanselect = &to_cmpnt_chansel,
                                        count = &num_cmpnts);
        
          f_ids = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
                                        num_cmpnts);

          status = om$get_channel_objects(objid = sect.objid,
                                          osnum = sect.osnum,
                                          p_chanselect = &to_cmpnt_chansel,
                                          list = f_ids,
                                          size = num_cmpnts,
                                          count = &num_objects);
          for(i=0;i<num_cmpnts;i++)
          {
             status = om$get_classid(osnum = f_ids[i].osnum,
                                     objid = f_ids[i].S_objid,
                                     p_classid = &classid);

            if(classid == OPP_EMSgensolid_class_id)
            {
              status = om$send(msg = message NDnode.NDdisconnect(0, NULL),
                               targetid =f_ids[i].S_objid,
                               targetos =f_ids[i].osnum);

              mode = GRbe;
              om$send(msg = message GRgraphics.GRdisplay(&msg,
                                    &module_env.md_env.matrix_type,
                                    module_env.md_env.matrix,&mode,
                                         &module_env.md_id),
                      targetid = f_ids[i].S_objid,
                      targetos = f_ids[i].osnum);
 
              status = om$send(msg = message GRgraphics.GRdelete(&msg, 
                                                                 &module_env),
                       targetid =f_ids[i].S_objid,
                       targetos =f_ids[i].osnum);
           
             }
          }

          mode = GRbd;
          om$send(msg = message GRgraphics.GRdisplay(&msg,
                                  &module_env.md_env.matrix_type,
                                  module_env.md_env.matrix,&mode,
                                  &module_env.md_id),
                  targetid = sect.objid,
                  targetos = sect.osnum);
       }
   }
   else
     if ( *response == CLEAR_STACK ||
          *response == EX_BACK_UP)
     {
         return(OM_S_SUCCESS);
     }
     else
         if (*response == EX_CMD_KEY)
         {
            return(OM_S_SUCCESS);
         }
         else
           if (*response == TERMINATE)
           {
              return(OM_S_SUCCESS);
           }
wrapup:
   return(OM_S_SUCCESS);
}

end implementation CODelSecSol;
