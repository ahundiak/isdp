/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSmerge 

Description
   This method will merge this graphics set into the graphics set
   passed in gs_id.

   *msg          IGRlong            return code
   *gs_id        struct GRid        The object id of the target graphics
                                    set.
   *owner_id     struct GRid        The object id of the owner channel.
   gs_sel        OM_p_CHANSELECT    graphics set channel select.
   owners_sel    OM_p_CHANSELECT    The owners channel select.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/16/86    Creation date.
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "grgsmacros.h"

method GSmerge (IGRlong *msg; struct GRid *gs_id; struct GRid *owners_id;
                OM_p_CHANSELECT gs_sel; OM_p_CHANSELECT owners_sel)
{
IGRlong           om_msg;
IGRlong           ret_msg;
IGRint            count;
IGRint            i;
IGRint            created_sv;
IGRchar           *buffer;
OM_S_CHANSELECT   chansel;
struct GRid       go_id;
struct GRid       sv_id;
         
   *msg = MSSUCC;
   buffer = (IGRchar *)NULL;
   created_sv = FALSE;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *    Get the objects from the members channel.
    */      

   om_msg = om$get_channel_count (object = me, p_chanselect = &chansel, 
            count = (IGRuint *) &count);

   if ((om_msg & 1) && (count))
   {
      /*
       *  Send the GSenv_compare message to graphics set.
       *  This method will return a save set.
       */

      om_msg = om$send (
               msg = message GRgrset.GSenv_compare ( &ret_msg,
               &me->path, &me->properties, &sv_id),
            targetid = gs_id->objid, targetos = gs_id->osnum);

      if ( !(om_msg & ret_msg & 1))
      {
         /*
          *  Create a saveset and connect it to the graphics set
          *  that this graphics set is merging with.
          */

         sv_id.osnum = me->path.md_id.osnum;
         om_msg = gr$gsinit ( msg = &ret_msg, senderid = gs_id->objid,
                  senderos = gs_id->osnum, p_chanselect = gs_sel, 
                  p_objid = &sv_id.objid, osnum = me->path.md_id.osnum);
   
         if (om_msg & ret_msg & 1)
         {
            /*
             *  Init the saveset.
             */

            om_msg = om$send (
                     msg = message GRsvset.GSsvinit(&ret_msg, &me->path,
                     &me->properties, &count),
                     targetid = sv_id.objid, 
                     targetos = sv_id.osnum);
   
            created_sv = TRUE;
         }
      }      
   
      if (om_msg & 1)
      {
         if (buffer = om$malloc (size = sizeof(OM_S_OBJECT_LINKAGE) 
                                 * count))
         {
            om_msg = om$get_channel_objects (object = me, 
                     p_chanselect = &chansel, 
                     list = (OM_S_OBJECT_LINKAGE *) buffer, size = count, 
                     count = (IGRuint *) &count);

            if (om_msg & 1)
            {
               for (i=0; i < count; ++i)
               {
                  /*
                   *  Send the GSadd message for each component
                   */

                  go_id.objid = ((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid;
                  go_id.osnum = ((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum;

                  om_msg = om$send (
                           msg = message GRgrset.GSadd (&ret_msg, &go_id, 
                           NULL), targetid = sv_id.objid, 
                           targetos = sv_id.osnum);
               }
            }
         }
      }
   }

   if (created_sv)
   {
      om_msg = om$send (msg = message GRsvset.GSunpreset (msg),
               targetid = sv_id.objid,
               targetos = sv_id.osnum);
   }

   if (buffer) om$dealloc (ptr = buffer);
   return(om_msg);
}
end implementation GRsvset;
