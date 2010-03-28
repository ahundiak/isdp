/* #######################    APOGEE COMPILED   ######################## */
/*
Name
   GRdv_sync_tan_ed_disp_func


Description
   This function will send the GRdv_sync_tan_ed_disp method
   to all drawing views in the master object space.


Arguments
   *msg           IGRlong          completion code 


History
   Jack  07/10/92  Creation
   scw   07/20/92  ansi conversion

*/

class implementation GRdrawview;

from OMObjSpace import pass;

#include "grdpbdef.h"
#include "grdpbmacros.h"

#argsused
void GRdv_sync_tan_ed_disp_func(msg,window,all,drawing_view)

IGRlong *msg;              /* return code */
struct GRid *window;       /* window for display */
IGRint all;                /* sync for all drawing views that have layer on */
struct GRid *drawing_view; /* only sync for this drawing view if its layer is on */

{

  IGRint  size_buf,
          bytes_ret;
  struct GRmd_env md_env;
  IGRlong  status;
  OM_S_CLASSLIST classlist;
  OMuword classid;
  OM_S_OBJID os_objid;


   size_buf = sizeof(struct GRmd_env);
   gr$get_module_env(msg    =  msg,
                     sizbuf = &size_buf,
                     buffer = &md_env,
                     nret   = &bytes_ret);


   /*
    * build the class list
    */
   classlist.w_count = 1; 
   classlist.w_flags = 0;
   classid =  OPP_GRdrawview_class_id;
   classlist.p_classes = &classid;

   status = om$osnum_to_oso_objid(osnum = md_env.md_id.osnum,
                                  p_objid = &os_objid);


   /*
    * send the display message to each drawing view in the master 
    * object space.
    */
   status = om$send(msg = message OMObjSpace.pass
                              (&classlist, 
                                OM_e_wrt_object,
                                message GRdrawview.GRdv_sync_tan_ed_disp(msg,window)),
                    senderid = NULL_OBJID,
                    targetos = md_env.md_id.osnum,
                    targetid = os_objid);
   if(! (1 & status & *msg)) goto wrapup;


wrapup:
    return;
}
end implementation GRdrawview;

