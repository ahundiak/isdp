/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GScriteria_pass 

Description
   This method will check each of its objects for the given criteria
   if the object does not pass the criteria it will be removed from
   the graphics set.  This method will use the same structures
   as locate to define the search criteria.

   *msg              IGRlong              Return code
   *locate_env       struct GRmd_env      The environment for a locate
   *attributes       struct GRlc_locate   The attributes describing the
                                          criteria that the object must
                                          pass.
   *classinfo        struct GRlc_classes  The classes to be located
   *layers           IGRchar              The layers to search.

Notes
   If layers are NULL then elements on all layers will be accepted.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn   06/04/87    Creation date
   msm         07/13/92    ANSI-C conversion.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "lcdef.h"
#include "dpdef.h"

from GRconnector import GRflexconn;

method GScriteria_pass (IGRlong *msg; struct GRmd_env *locate_env;
                        struct GRlc_locate *attributes;
                        struct GRlc_classes *classinfo;
                        IGRchar *layers)
{
IGRlong           om_msg;
unsigned int      count;
IGRint            i;
IGRint            all_layers[DP_NUM_OF_LEVELS/32 + 1];
IGRchar           *buffer;
struct GRlc_cvl   cvl;
struct GRid       my_GRid;
OM_S_CHANSELECT   chansel;

IGRint   GRgscriteria();

   *msg = MSSUCC;
   buffer = (IGRchar *)NULL;
   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Get the objects.
    */

   om_msg = om$get_channel_count (object = me, p_chanselect = &chansel, 
            count = &count);

   if ((om_msg & 1) && count)
   {
      if (buffer = om$malloc (size = sizeof(OM_S_OBJECT_LINKAGE) * count))
      {
         om_msg = om$get_channel_objects (object = me, 
                  p_chanselect = &chansel, 
                  list = (OM_S_OBJECT_LINKAGE *) buffer, size = count, 
                  count = &count);
      }else
      {
         om_msg = 0;
      }
   }
   
   if (!count)
   {
      /* 
       *  No objects.
       */

      return (OM_S_SUCCESS);
   }else if (om_msg & 1)
   {
      om_msg = om$send(msg = message Root.wild_disconnect (chansel),
               targetid = my_id);

      if ( ((attributes->properties & LC_RW) == LC_WRITE_ONLY) &&
           (me->properties & GRIS_READ_ONLY) )
      {
         /*
          *  Do not add the object if save set has read only access
          *  and write access was requested.  Note that if read and
          *  write objects were requested then it is a read only 
          *  operation.
          */   

         return(om_msg);
      }

      if (layers)
      {
         cvl.levels = (IGRint *) layers;
      }else
      {
         for (i=0; i < DP_NUM_OF_LEVELS; i++)
         {
            all_layers[i/32] |= (1<<(i % 32));
         }
         cvl.levels = all_layers;
      }

      /*
       *   Build the cvl structure.
       */
 
      cvl.msg = MSSUCC;
      cvl.module = *locate_env;
      cvl.button.objid = NULL_OBJID;
      cvl.button.osnum = locate_env->md_id.osnum;
      cvl.attributes.type = GR_nam_loc;
      cvl.attributes.obj_attr = *attributes;
      cvl.attributes.acc_tolerance = 0;
      cvl.action_handler = GRgscriteria;
      cvl.act_parms = (IGRchar *)&my_GRid;
      cvl.classes = classinfo->eligible_classes;
      cvl.locate_args = NULL;
      cvl.prism_attr = NULL;

      for (i = 0; (i < count) && (om_msg & 1); ++i)
      {
         om_msg = om$send (
                  msg = message GRgraphics.GRlocate (&cvl, NULL),
                  targetid = ((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid,
                  targetos = ((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum);
      }
   }
   if (buffer) om$dealloc (ptr = buffer);
   return ( om_msg );
}
#argsused
IGRint GRgscriteria(sv_id, new_entry, locate_args, action)
struct GRid          *sv_id;
struct GRlc_info     *new_entry;
IGRchar              *locate_args;
enum GRlocate_action *action;
{
IGRlong           om_msg;
IGRlong           ret_msg;
IGRlong           connect_flag;
IGRlong           index;

   connect_flag = 1;    /* Override */
   index = OM_K_MAXINT;

   /*
    *  Add the object to the save set.
    */

   om_msg = om$send(
            msg = message GRconnector.GRflexconn (&ret_msg, 
            &connect_flag, sv_id, &index, &index),
            senderid = NULL_OBJID,
            targetid = new_entry->located_obj.objid, 
            targetos = new_entry->located_obj.osnum);

   return (om_msg);
}

end implementation GRsvset;
