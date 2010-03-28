/*

  Name

     GRrfshwrclip

  Abstract
     This function will Shrink/Wrap the clipping polygon of the reference 
     file.

  Arguments

     IGRlong      *msg     completion code
     struct GRid  *ref_id  GRid of the reference file

  Return Values

    -MSSUCC if successful
    -MSFAIL if failure

  History

     Gang     06/03/93    Design date.

*/

class implementation GRreffile;

#include "grimport.h"
#include "godef.h"
#include "msdef.h"
#include "dpdef.h"
#include "referr.h"
#include "refdef.h"
#include "refpriv.h"
#include "exdef.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "dpsavevw.h"
#include "OMmacros.h"
#include "grerr.h"
#include "go.h"
#include "grdpb.h"
#include "grdpbmacros.h"

from GRcontext import GRgetmodule_env;

IGRint GRrfshwrclip(msg, ref_id)
IGRlong *msg;        /* O return status */
struct GRid *ref_id; /* I GRid of the reference file */
{
  IGRlong  OMmsg;
  OM_S_CHANSELECT ctx_chan;
  IGRint          count,i;
  struct GRmd_env mod_env;
  struct GRid     ctx_id;
  OM_S_OBJECT_LINKAGE *list=NULL;

  OMmsg = OM_S_SUCCESS;
  *msg = MSSUCC;
  i = 0;
  count = 0;

        ctx_chan.type = OM_e_name;
        ctx_chan.u_sel.name = "GRreffile.to_context";

        om$get_channel_count(objid = ref_id->objid,
                             osnum = ref_id->osnum,
                             p_chanselect = &ctx_chan,
                             count = (OMuint *)&count);

        if(!count)
         {
            return OMmsg;
         }

        list = (OM_S_OBJECT_LINKAGE *) malloc(sizeof(OM_S_OBJECT_LINKAGE) *
                                                     count );

        /* get the context objectid for this attachment */

        OMmsg = om$get_channel_objects(objid = ref_id->objid,
                                       osnum = ref_id->osnum,
                                       p_chanselect = &ctx_chan,
                                       size = count,
                                       list = list,
                                       count = (OMuint *)&count); 
        ctx_chan.type = OM_e_name;
        ctx_chan.u_sel.name = "GRcontext.to_nested_files";
       
        /* get the correct context object */

        for(i=0; i < count; i++)
         {
             if(list[i].osnum == ref_id->osnum)
              {
                 ctx_id.objid = list[i].S_objid;
                 ctx_id.osnum = list[i].osnum;
                 break;
              }
         }

        /* get the module environment from the module context */

        OMmsg = om$send(msg = message GRcontext.GRgetmodule_env(msg,
                                                             &mod_env),
                        senderid = ctx_id.objid,
                        targetos = ref_id->osnum,
                        from = 0,
                        to = 0,
                        p_chanselect = &ctx_chan);

        free(list);

        mod_env.md_id.osnum = ref_id->osnum;

        ex$get_modid(mod_osnum = mod_env.md_id.osnum,
                     mod_id = &mod_env.md_id.objid);

        OMmsg = om$send(msg = message GRreffile.GRrfupdrtree(msg, &mod_env),
                      senderid = NULL_OBJID,
                      targetid = ref_id->objid,
                      targetos = ref_id->osnum);

  return OMmsg;
}


end implementation GRreffile;
