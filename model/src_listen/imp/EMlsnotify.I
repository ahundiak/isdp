class implementation EMSlistener;

#include "EMS.h"
/*
 History   RC     11/18/87       Creation date

           AIC    03 December 87    Add default case to switch.
*/

# ifndef OMerrordef_include
# include "OMerrordef.h"
# endif

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

# ifndef EMSerrordef_include
# include "EMSerrordef.h"  
# endif

# ifndef emsmacros_include
# include "emsmacros.h"
# endif

# ifndef emserr_include
# include "emserr.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

from EMSboundary import EMintcopy;
from EMSsurface  import EMintcopy;

extern OMuword   OPP_EMSboundary_class_id;
extern OMuword   OPP_EMSsurface_class_id;

method GRnotifylis(IGRlong *EMmsg; IGRlong *OMmsg; IGRlong *mask;
                   OM_p_MESSAGE graphics_msg)
{
   IGRboolean         *sender_copy_exists;
   struct    GRid     sender_copy;
   struct EMcp_info   *copy_info;
   void              EMcpsearch();

   *OMmsg = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

   /*
    * Translate the incoming message
    */

   switch (*mask)
   {
     case GR_DELETED:
        *OMmsg = om$send(msg = message Root.delete(1),
                         senderid = sender_id, targetid = my_id);
        EMerr_hndlr (!(1 & *OMmsg), *EMmsg, EMS_E_OMerror, wrapup);
        break;

     case GR_COPIED:

      /*
       * It is assumed that the incoming message
       * is EMintcopy.
       * If the incoming message is decalred at EMSboundary,
       * it is coming from a boundary object. otherwise
       * it is coming from a subclass of EMSsurface.
       * This info is used in extracting the copied object
       * osnum and copy_info as the arguments are different for these 
       * definitions.
       */
      if (graphics_msg->select.DefClassid == OPP_EMSboundary_class_id)
      {
        struct EMSboundary_EMintcopy_Msg   *parglist;
      
        parglist = (struct EMSboundary_EMintcopy_Msg *) 
                                             graphics_msg->p_arglist;

        sender_copy.osnum = parglist->new_osnum;
        copy_info = parglist->copy_info;

      }/*if(graphics_msg->select.DefClassid==OPP_EMSboundary_class_id)*/
       
      else if (graphics_msg->select.DefClassid == OPP_EMSsurface_class_id)
      {
         struct EMSsurface_EMintcopy_Msg  *parglist;

         parglist = (struct EMSsurface_EMintcopy_Msg *) 
                                          graphics_msg->p_arglist;
         sender_copy.osnum = parglist->new_mdenv->md_id.osnum;
         copy_info = parglist->copy_info;
         
      }/*if (graphics_msg->select.DefClassid == OPP_EMSsurface_class_id)*/
      else
      {
         *EMmsg = EMS_E_InvalidArg;
         goto wrapup;
      }

      /*     
       * get the sender's copy id from the copy_info.
       */

      EMcpsearch (EMmsg, sender_id, &sender_copy.objid, 
                     copy_info, 0, &sender_copy_exists);
      EMerr_hndlr (!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

      if (!sender_copy_exists)
      {
         *EMmsg = EMS_E_InvalidArg;
         goto wrapup;
      }

      *OMmsg = om$send (msg = message EMSlistener.EMascopy (         
                        EMmsg, &sender_copy, copy_info),
                           targetid = my_id);
      EMerr_hndlr (!(1&*OMmsg&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);
      break;

    default:
      break;

   } /* switch (*mask) */

wrapup:

/*
  EMWRAPUP (*EMmsg, *OMmsg, "In EMSlistener.GRnotifylis");
*/

  return (*OMmsg);
}

end implementation EMSlistener;
