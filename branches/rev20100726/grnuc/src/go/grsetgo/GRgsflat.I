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

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"

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
unsigned int      count;
IGRchar           *buffer;
struct GRid       my_GRid;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   buffer = (IGRchar *)NULL;
   my_GRid.objid = my_id;   
   my_GRid.osnum = OM_Gw_current_OS;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_sets";
   
   /*
    *  Get the save sets on the members channel.
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

         /*
          *  Disconnect all the savesets from my channel.
          */

         om_msg = om$send (msg = message Root.wild_disconnect(chansel),
                  targetid = my_id);

         for (i=0; (i < count) && (om_msg & *msg & 1); ++i)
         {
            /*
             *  Send the GSflatten_owners message to each saveset.
             */

            om_msg = om$send(
                     msg = message GRgrset.GSflatten_owners (msg,
                     attributes, eligible_classes, owner_classes, 
                     owner_properties, &my_GRid, &chansel, NULL, NULL, 
                     NULL),
                     targetid = ((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid,
                     targetos = ((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum);
         }
      }
   }
   if (buffer) om$dealloc (ptr = buffer);
   return ( om_msg );
}
end implementation GRgrset;
