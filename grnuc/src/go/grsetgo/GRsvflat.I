/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSflatten_owners

Description
   This method is used to flatten an owner object into its components.
   A three stage check is performed upon an object to see if it should
   be flattened.  The first check is to see if the object is a subclass
   of GRowner.  If it passes the first check, the object is compared to 
   the list of owner classes to be flattened.  If the owner object is
   not found within the class list, the owner object will be compared 
   against the requested properties (i.e rigid or flexible) to determine
   if it should be flattened.
   
   *msg              IGRlong              Return code
   *attributes       struct GRlc_locate   The attributes describing the
                                          criteria that the object must
                                          pass.
   *eligible_classes OM_S_CLASSLIST       The eligible classes
   *owner_classes    OM_S_CLASSLIST       The owner classes
   owner_properties  IGRint               The owner properties
                                          0 - do not flatten
                                          1 - flatten rigid owners
                                          2 - flatten flexible owners
                                          3 - flatten all owners
   *gs_id            struct GRid          The graphics set
   gs_chansel        OM_p_CHANSELECT      The graphics set channel
   *command_id       struct GRid          The command id
   command_chansel   OM_p_CHANSELECT      The command channel
   *object_id        struct GRid          The id of the new graphics set

Notes
   The owner_classes may be NULL.
   One of the following sets of information must be supplied the other
   sets may be NULL:
      -  The gs_id and gs_chansel
      -  The command_id and the command_chansel
      -  The object_id

   The owner_properties are applied if and only if the object was not
   specifically selected by the owner_classes.  If the owner_classes
   is a list of classes not to be flatted (i.e negation), the locate
   propeties of the classes not listed will be checked against the 
   owner_properties to determine if they should be flattened.

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   Gray Winn      04/26/88    Creation Date
   msm            07/10/92    ANSI-C conversion.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "growner.h"
#include "grgsmacros.h"

method GSflatten_owners (IGRlong *msg; struct GRlc_locate *attributes;
                         OM_S_CLASSLIST *eligible_classes;
                         OM_S_CLASSLIST *owner_classes;
                         IGRint owner_properties; struct GRid *gs_id;
                         OM_p_CHANSELECT gs_chansel; 
                         struct GRid *command_id; 
                         OM_p_CHANSELECT command_chansel;
                         struct GRid *object_id)
{
IGRlong           om_msg;
IGRint            i;
IGRint            count;
IGRchar           *buffer;
OM_S_CHANSELECT   chansel;
OM_S_CHANSELECT   my_gs_chansel;
struct GRid       my_gs_id;
struct GRid       my_sv_id;
struct GRobj_env  obj_env;

   *msg = MSSUCC;
   buffer = (IGRchar *)NULL;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Create the graphics set.
    */

   if (gs_id && gs_chansel)
   {
      my_gs_id = *gs_id;
      my_gs_chansel = *gs_chansel;
   }else if (command_id && command_chansel)
   {
      my_gs_chansel.type = OM_e_name;
      my_gs_chansel.u_sel.name = "GRgrset.to_sets";
      my_gs_id.osnum = OM_Gw_current_OS;
      om_msg = gr$gsinit (msg = msg, flag = 2, 
               senderos = command_id->osnum, senderid = command_id->objid,
               p_chanselect = command_chansel, p_objid = &my_gs_id.objid);
   }else if (object_id)
   {
      my_gs_chansel.type = OM_e_name;
      my_gs_chansel.u_sel.name = "GRgrset.to_sets";
      my_gs_id.osnum = OM_Gw_current_OS;
      om_msg = gr$gsinit (msg = msg, flag = 2, p_objid = &my_gs_id.objid);
      *object_id = my_gs_id;
   }else
   {
      *msg = MSFAIL;
      return (OM_E_ABORT);
   }

   /*
    *  Get the number of graphics objects.
    */

   om_msg = om$get_channel_count (object = me, p_chanselect = &chansel,
            count = (IGRuint *) &count);

   /*
    *  Create a saveset and connect it to the graphics set.
    */

   my_sv_id.osnum = OM_Gw_current_OS;
   om_msg = gr$gsinit (msg = msg, senderid = my_gs_id.objid,
            senderos = my_gs_id.osnum, p_chanselect = &my_gs_chansel,
            osnum = my_sv_id.osnum, p_objid = &my_sv_id.objid);

   om_msg = om$send (msg = message GRsvset.GSsvinit(msg, &me->path, 
            &me->properties, &count),
            targetid = my_sv_id.objid,
            targetos = my_sv_id.osnum);

   /*
    *  Get the graphics objects.
    */

   if ((om_msg & 1) && count)
   {
      if (buffer = om$malloc (size = sizeof(OM_S_OBJECT_LINKAGE) * count))
      {
         om_msg = om$get_channel_objects (object = me,
                  p_chanselect = &chansel, 
                  list = (OM_S_OBJECT_LINKAGE *) buffer, size = count,
                  count = (IGRuint *) &count);

         obj_env.mod_env = me->path;
         for (i=0; (i < count) && (om_msg & *msg &1); ++i)
         {
            /*
             *  Call the flatten function for each graphics object.
             */
         
            obj_env.obj_id.objid = 
               ((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid;
            obj_env.obj_id.osnum = 
               ((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum;
            om_msg = GRflatten_owners (msg, attributes, eligible_classes,
                     owner_classes, owner_properties, &obj_env, &my_gs_id,
                     &my_gs_chansel, &my_sv_id, &me->properties);
         }
      }
   }

   om_msg = om$send (msg = message GRsvset.GSunpreset(msg),
            targetid = my_sv_id.objid,
            targetos = my_sv_id.osnum);

   /*
    *  Empty (i.e delete) my_self.
    */

   om_msg = om$send (msg = message GRgrset.GSempty (msg, NULL, NULL),
            targetid = my_id); 

   if (buffer) om$dealloc (ptr = buffer);
   return ( om_msg );
}
end implementation GRsvset;
