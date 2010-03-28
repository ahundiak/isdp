/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
   The following functions are called by macros.  These functions
   are used instead of sending directly to the objects since one
   must import the messages that are sent. 

History
   Gray Winn    10/05/86    Creation date.
   msm          07/10/92    ANSI-C conversion.
\*/

class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "grgs.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "msdef.h"
#include "OMerrordef.h"

from GRgrset   import   GSpass, GSdisplay, GScopy, GSdelete, GSdissolve, 
                        GSpost_processing, GSempty, GSinit, GSinqcount,
                        GSget_object, GSflatten_owners, GSremove_member;

/*\
Name
   GRgspass

Description
   This routine functions as the pass message server.

   *msg           IGRlong           Completion code.
   pass_msg       OM_p_MESSAGE      The message to be passed.
   *path          struct GRmd_env   The module environment that is 
                                    associated with the pass_msg;
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Notes
   The path may be NULL if it is not needed by the method.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

IGRint GRgspass (msg, pass_msg, path, senderid, senderos, p_chanselect,
                 object_id)
IGRlong           *msg;
OM_p_MESSAGE      pass_msg;
struct GRmd_env   *path;
GRobjid           senderid;
GRspacenum        senderos;
OM_p_CHANSELECT   p_chanselect;
struct GRid       *object_id;
{
IGRint   om_msg;

   if (p_chanselect)
   {
      om_msg = om$send (
               msg = message GRgrset.GSpass (msg, pass_msg, path),
               senderid = senderid, targetos = senderos,
               p_chanselect = p_chanselect);
   }else
   {
      om_msg = om$send (
               msg = message GRgrset.GSpass (msg, pass_msg, path),
               senderid = senderid, 
               targetid = object_id->objid,
               targetos = object_id->osnum);
   }
   return (om_msg);
}

/*\
Name
   GRgsdisplay

Description
   This routine will send the display message to the graphics set.

   *msg           IGRlong           Completion code.
   dpmode         enum GRdpmode     display mode
   display_id     struct GRid       The controlling display object 
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

IGRint GRgsdisplay (msg, dpmode, display_id, senderid, senderos,
                    p_chanselect, object_id)
IGRlong           *msg;
enum GRdpmode     dpmode;
struct GRid       *display_id;
GRobjid           senderid;
GRspacenum        senderos;
OM_p_CHANSELECT   p_chanselect;
struct GRid       *object_id;
{
IGRint   om_msg;

   if (p_chanselect)
   {
      om_msg = om$send ( 
               msg = message GRgrset.GSdisplay (msg, &dpmode, display_id),
               senderid = senderid, targetos = senderos, 
               p_chanselect = p_chanselect);
   }else
   {
      om_msg = om$send ( 
               msg = message GRgrset.GSdisplay (msg, &dpmode, display_id),
               senderid = senderid, 
               targetid = object_id->objid,
               targetos = object_id->osnum);
   }   
   return (om_msg);
}

/*\
Name
   GRgsflatten

Description
   This function is used to flatten an owner object into its components.
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
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Notes
   The owner_classes may be NULL.

   The owner_properties are applied if and only if the object was not
   specifically selected by the owner_classes.  If the owner_classes
   is a list of classes not to be flatted (i.e negation), the locate
   propeties of the classes not listed will be checked against the 
   owner_properties to determine if they should be flattened.

   The following are examples of how to use this method:
      To get the components of a graphic group:
         owner_classes.w_flags = OM_CLST_subclass;
         owner_classes.p_classes = "GRgrgrp";
         owner_properties = NULL;
      To get the components of all owners:
         owner_classes = NULL;
         owner_properties = 3;
      To get the components of all owners except symbol header objects.
         owner_classes.w_flags = OM_CLST_negation;
         owner_classes.p_classes = "GRsmhdr";
         owner_properties = 3;

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure
\*/

IGRint GRgsflatten (msg, attributes, eligible_classes, owner_classes, 
                    owner_properties, senderid, senderos, p_chanselect,
                    object_id)
IGRlong              *msg;
struct GRlc_locate   *attributes;
OM_S_CLASSLIST       *eligible_classes;
OM_S_CLASSLIST       *owner_classes;
IGRint               owner_properties;
GRobjid              senderid;
GRspacenum           senderos;
OM_p_CHANSELECT      p_chanselect;
struct GRid          *object_id;
{
IGRint         om_msg;
struct GRid    command_id;

   *msg = MSSUCC;
   command_id.osnum = senderos;
   command_id.objid = senderid;

   if (p_chanselect)
   {
      om_msg = om$send ( 
               msg = message GRgrset.GSflatten_owners (msg, attributes,
               eligible_classes, owner_classes, owner_properties, NULL,
               NULL, &command_id, p_chanselect, NULL),
               senderid = senderid, targetos = senderos,
               p_chanselect = p_chanselect);
   }else
   {
      om_msg = om$send (
               msg = message GRgrset.GSflatten_owners (msg, attributes,
               eligible_classes, owner_classes, owner_properties, NULL,
               NULL, NULL, NULL, object_id),
               senderid = senderid,
               targetid = object_id->objid,
               targetos = object_id->osnum);
   }   
   return (om_msg);
}

/*\
Name
   GRgsremove_fence

Description
   This function will remove the fence object from a graphics set.

   *msg           IGRlong           Completion code.
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

IGRint GRgsremove_fence (msg, senderid, senderos, p_chanselect, object_id)
IGRlong              *msg;
GRobjid              senderid;
GRspacenum           senderos;
OM_p_CHANSELECT      p_chanselect;
struct GRid          *object_id;
{
IGRlong        om_msg;
IGRlong        ret_msg;
struct GRid    fence_id;

   *msg = MSSUCC;

   om_msg = gr$gsget_fence ( msg = &ret_msg, fence_id = &fence_id);

   if (om_msg & ret_msg & 1)
   {
      if (p_chanselect)
      {
         om_msg = om$send ( 
                  msg = message GRgrset.GSremove_member (msg, &fence_id),
                  senderid = senderid, targetos = senderos,
                  p_chanselect = p_chanselect);
      }else
      {
         om_msg = om$send (
                  msg = message GRgrset.GSremove_member (msg, &fence_id),
                  senderid = senderid,
                  targetid = object_id->objid,
                  targetos = object_id->osnum);
      }
   }
   return (OM_S_SUCCESS);
}

/*\
Name
   GRgsinit

Description
   This routine will construct a graphics set and then send the init 
   method to the graphics set.  The graphics set will connect itself to
   the supplied  channel.

   *msg           IGRlong           Completion code.
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   flag           IGRint            The flag specifing what type of
                                    graphic set to construct.
                                       0 - Save set.
                                       1 - Reusable Graphics set.
                                       2 - Graphics set for formation
                                           of select set
                                       3 - Graphics set for formation
                                           of select set that allows
                                           highlight.
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *p_objid       GRobjid           The object id of the saveset.
   osnum          GRspacenum        The object space number to construct
                                    the saveset in.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

IGRint GRgsinit (msg, senderid, senderos, flag, p_chanselect, p_objid, 
                 osnum )
IGRlong           *msg;
GRobjid           senderid;
GRspacenum        senderos;
IGRint            flag;
OM_p_CHANSELECT   p_chanselect;
GRobjid           *p_objid;
GRspacenum        osnum;
{
IGRlong     om_msg;
IGRint      properties;
IGRchar     classname[10];
GRobjid     gs_objid;
struct GRid owner;

   *msg = MSSUCC;
   owner.objid = senderid;
   owner.osnum = senderos;

   /*
    *  Construct the graphics set.
    */

   if (flag == 0)
   {
      properties = GRIS_DISPLAY_ALL;
      strcpy (classname, "GRsvset");
   }else if (flag == 1)
   {
      properties = GRIS_DISPLAY_ALL | GRIS_REUSABLE;
      strcpy (classname, "GRgrset");
   }else if (flag == 2)
   {
/*
      properties = GRIS_BACKGROUND_DISPLAY;
*/
      properties = GRIS_DISPLAY_ALL;
      strcpy (classname, "GRgrset");
   }else
   {
      properties = GRIS_DISPLAY_ALL;
      strcpy (classname, "GRgrset");
   }

   om_msg = om$construct (classname = classname, osnum = osnum,
            p_objid = &gs_objid);

   if (p_objid) *p_objid = gs_objid;

   /*
    *  Initilaze the saveset (i.e. connect to channel).
    */

   om_msg = om$send (
            msg = message GRgrset.GSinit (msg, &properties, &owner,
            p_chanselect), senderid = senderid, targetid = gs_objid,
            targetos = osnum);

   return (om_msg);
}

/*\
Name
   GRgs_is_graphics_set

Description
   This function is used to check if a specific object is a graphics
   set.

   *msg           IGRlong           Completion code.
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

IGRint GRgs_is_graphics_set (msg, senderid, senderos, p_chanselect, 
                             object_id)
IGRlong           *msg;
GRobjid           senderid;
GRspacenum        senderos;
OM_p_CHANSELECT   p_chanselect;
struct GRid       *object_id;
{
IGRint               om_msg;
IGRint               i;
unsigned int         count;
IGRint               malloc_flag;
OMuword              class_id;
OM_S_OBJECT_LINKAGE  *buffer;
OM_S_OBJECT_LINKAGE  list[1];

   *msg = MSSUCC;
   buffer = NULL;
   malloc_flag = FALSE;
   if (p_chanselect != NULL)
   {
      /*
       *  Get the channel count.
       */

      om_msg = om$get_channel_count (osnum = senderos, objid = senderid,
               p_chanselect = p_chanselect, count = &count);

      if ((om_msg & 1) && count)
      {
         if (buffer = (OM_S_OBJECT_LINKAGE *)om$malloc
                        (size = sizeof(OM_S_OBJECT_LINKAGE) * count))
         {
            malloc_flag = TRUE;
            om_msg = om$get_channel_objects (osnum = senderos,
                objid = senderid, p_chanselect = p_chanselect, 
                list = buffer, size = sizeof(OM_S_OBJECT_LINKAGE) * count,
                count = &count);
         
            if (!(om_msg & 1))
            {
               *msg = MSFAIL;
            }
         }else
         {
            *msg = MSFAIL;
         }
      }else
      {
         *msg = MSFAIL;
      }         
   }else 
   {
      count  = 1;
      buffer = list;
      list[0].S_objid = object_id->objid;
      list[0].osnum = object_id->osnum;
   }

   for (i=0; (i < count) && (*msg & 1); ++i)
   {
      om_msg = om$get_classid (osnum = buffer[i].osnum,
               objid = buffer[i].S_objid, p_classid = &class_id);

      om_msg = om$is_ancestry_valid (subclassid = class_id,
               superclassname = "GRgrset");

      if ((om_msg == OM_I_INVANCESTRY) || (!(om_msg & 1)) )
      {
         *msg = MSFAIL;
      }            
   }

   if (malloc_flag) om$dealloc (ptr = buffer);
   return(OM_S_SUCCESS);
}

/*\
Name
   GRgs_fun

Description
   This routine serves as the router for the user interface macros.

   *msg           IGRlong           Completion code.
   type           IGRint            The function to be performed.
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.
   *arg1          IGRchar           Arguments to be passed.
   *arg2          IGRchar           Arguments to be passed.
   *arg3          IGRchar           Arguments to be passed.
   *arg4          IGRchar           Arguments to be passed.
   *arg5          IGRchar           Arguments to be passed.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

IGRint GRgs_fun (msg, type, senderid, senderos, p_chanselect, 
                 object_id, arg1, arg2, arg3, arg4, arg5)
IGRlong           *msg;
IGRint            type;
GRobjid           senderid;
GRspacenum        senderos;
OM_p_CHANSELECT   p_chanselect;
struct GRid       *object_id;
IGRchar           *arg1;
IGRchar           *arg2;
IGRchar           *arg3;
IGRchar           *arg4;
IGRchar           *arg5;
{
IGRlong        om_msg;
struct   GRid  owner;      /* Structure used in GSEMPTY case */
OM_p_MESSAGE   pass_msg;

   *msg = MSSUCC;   
   pass_msg = NULL;

   switch (type)
   {
      case GSINQ_COUNT:
      {
         *(IGRint *)arg1 = 0;
         pass_msg = message GRgrset.GSinqcount (msg, 
                    (IGRint *)arg1);
      }
      break;

      case GSPOST_PROCESSING:
      {
         pass_msg = message GRgrset.GSpost_processing (msg, NULL,
                    NULL, NULL);
      }
      break;

      case GSDISSOLVE:
      {
         pass_msg = message GRgrset.GSdissolve (msg);
      }
      break;
   
      case GSDELETE:
      {
         pass_msg = message GRgrset.GSdelete (msg);
      }   
      break;

      case GSEMPTY:
      {
         owner.objid = senderid;
         owner.osnum = senderos;

         pass_msg = message GRgrset.GSempty (msg, &owner, p_chanselect);
      }
      break;

      case GSCOPY:
      {
         pass_msg = message GRgrset.GScopy (msg, (struct GRmd_env *) arg1, 
                                            NULL, NULL);
      }
      break;

      case GSCPTFORM:
      {
         pass_msg = message GRgrset.GScopy (msg, (struct GRmd_env *) arg1, 
                                            (IGRdouble *) arg2, NULL);
      }
      break;

      case GSGET_OBJECTS:
      {
         *(IGRint *)arg3 = 0;
         pass_msg = message GRgrset.GSget_object (msg, 
                    (struct GRobj_env *)arg1,
                    (IGRint) arg2,
                    (IGRint *) arg3,
                    (IGRint) arg4,
                    (IGRint) arg5);
      }
      break;
   }

   if (p_chanselect)
   {
      om_msg = om$send (msg = pass_msg, senderid = senderid, 
               targetos = senderos, p_chanselect = p_chanselect);
   }else
   {
      om_msg = om$send (msg = pass_msg, senderid = senderid, 
               targetid = object_id->objid,
               targetos = object_id->osnum);
   }   
   return (om_msg);
}
end implementation Root;
