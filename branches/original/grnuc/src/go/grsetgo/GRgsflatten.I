/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRflatten_owners

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
                                          0 - do not break down
                                          1 - break down rigid owners
                                          2 - break down flexible owners
                                          3 - break down all owners
   *obj_env          struct GRobj_env     The graphics object
   *gs_id            struct GRid          The graphics set
   gs_chansel        OM_p_CHANSELECT      The graphics set channel
   *sv_id            struct GRid          The saveset id
   *env_properties   IGRint               The save set env properties

Notes
   The owner_classes may be NULL.

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
   msm            07/13/92    ANSI-C conversion.
\*/

class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "growner.h"
#include "grgs.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "OMerrordef.h"
#include "exdef.h"
#include "lcmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "griomacros.h"
#include "grownerdef.h"
#include "dpdef.h"

from  GRgraphics  import   GRlocate;
from  GRowner     import   GRget_locate_properties, 
                           GRget_number_components, GRget_components,
                           GRget_context;
from  GRgrset     import   GSenv_compare, GSempty, GSinqcount;
from  GRsvset     import   GSsvinit, GSunpreset;

extern IGRint   GRgscriteria();

IGRint GRflatten_owners (msg, attributes, eligible_classes, owner_classes,
                         owner_properties, obj_env, gs_id, gs_chansel, 
                         sv_id, env_properties)
IGRlong              *msg;
struct GRlc_locate   *attributes;
OM_S_CLASSLIST       *eligible_classes;
OM_S_CLASSLIST       *owner_classes;
IGRint               owner_properties;
struct GRobj_env     *obj_env;
struct GRid          *gs_id;
OM_p_CHANSELECT      gs_chansel;
struct GRid          *sv_id;
IGRint               *env_properties;
{
IGRlong              om_msg;
IGRint               i;
IGRint               count;
IGRint               flatten;
IGRint               selected;
IGRint               go_properties;
IGRint               created_sv;
IGRint               all_layers[DP_NUM_OF_LEVELS/32 + 1];
IGRchar              *buffer;
GRclassid            classid;
struct GRlc_cvl      cvl;
struct GRobj_env     temp_obj_env;
struct GRid          temp_sv_id;

   *msg = MSSUCC;
   flatten = FALSE;
   selected = FALSE;
   buffer = (IGRchar *)NULL;
   
   om_msg = om$get_classid (osnum = obj_env->obj_id.osnum, 
            objid = obj_env->obj_id.objid, p_classid = &classid);

   om_msg = om$is_ancestry_valid (subclassid = classid,
            superclassname = "GRowner");

   if ((om_msg != OM_I_INVANCESTRY) && (om_msg & 1))
   {
      if (owner_classes)
      {
         /*
          *  A list of owners was supplied.
          */

         if (owner_classes->w_flags == OM_CLST_subclass)
         {
            /*
             *  Looking to break down subclasses of these classes.
             */

            for (i = 0; i < (IGRint)owner_classes->w_count; ++i)
            {
               om_msg = om$is_ancestry_valid (subclassid = classid,
                        superclassid = owner_classes->p_classes[i]);

               if ((om_msg != OM_I_INVANCESTRY) && (om_msg & 1))
               {
                  flatten = TRUE;
                  selected = TRUE;
                  break;
               }
            }
         }else if (owner_classes->w_flags == OM_CLST_negation)
         {
            /*
             *  Looking to break down classes not listed in these classes.
             */

            flatten = TRUE;
            for (i = 0; i < (IGRint)owner_classes->w_count; ++i)
            {
               om_msg = om$is_ancestry_valid (subclassid = classid,
                        superclassid = owner_classes->p_classes[i]);

               if ((om_msg != OM_I_INVANCESTRY) && (om_msg & 1))
               {
                  flatten = FALSE;
                  selected = TRUE;
                  break;
               }
            }
         }else
         {
            /*
             *  Looking for these specific classes.
             */

            for (i = 0; i < (IGRint)owner_classes->w_count; ++i)
            {
               if (owner_classes->p_classes[i] == classid)
               {
                  flatten = TRUE;
                  selected = TRUE;
                  break;
               }
            }
         }
      }

      /*
       *  The owner object was compared against the class criteria.  If
       *  the owner object was not explicitly selected by the criteria,
       *  a second criteria check is performed to see if the object should
       *  be flattened based upon its rigid or flexible property.
       */

      if (!selected)
      {
         om_msg = om$send (
                  msg = message GRowner.GRget_locate_properties (msg,
                  &go_properties),
                  senderid = NULL_OBJID,
                  targetos = obj_env->obj_id.osnum, 
                  targetid = obj_env->obj_id.objid);

         if (((owner_properties & 1) && (go_properties & GR_LC_RIGID)) ||
             ((owner_properties & 2) && (go_properties & GR_LC_FLEXIBLE)))
         {
            flatten = TRUE;
         }else
         {
            flatten = FALSE;
         }
      }
   }

   if (flatten)
   {
      om_msg = om$send (
               msg = message GRowner.GRget_number_components (msg, &count),
               senderid = NULL_OBJID,
               targetos = obj_env->obj_id.osnum, 
               targetid = obj_env->obj_id.objid);

      if (buffer = om$malloc (size = sizeof(struct GRid) * count))
      {
         om_msg = om$send (
                  msg = message GRowner.GRget_components (msg,
                  &obj_env->mod_env, (struct GRid *) buffer, count, 
                  &count, NULL, 
                  OM_K_MAXINT),
                  senderid = NULL_OBJID,
                  targetos = obj_env->obj_id.osnum, 
                  targetid = obj_env->obj_id.objid);

         om_msg = om$send (
                  msg = message GRowner.GRget_context (msg,
                  &obj_env->mod_env, &temp_obj_env.mod_env),
                  senderid = NULL_OBJID,
                  targetos = obj_env->obj_id.osnum, 
                  targetid = obj_env->obj_id.objid);

         om_msg = om$send (
                  msg = message GRgrset.GSenv_compare (msg, 
                  &temp_obj_env.mod_env, env_properties, &temp_sv_id),
                  senderid = NULL_OBJID,
                  targetid = gs_id->objid,
                  targetos = gs_id->osnum);

         if (! (*msg & 1))
         {
            created_sv = TRUE;
            temp_sv_id.osnum = temp_obj_env.mod_env.md_id.osnum;
            om_msg = gr$gsinit (msg = msg, p_chanselect = gs_chansel,
                     senderid = gs_id->objid, senderos = gs_id->osnum,
                     osnum = temp_obj_env.mod_env.md_id.osnum,
                     p_objid = &temp_sv_id.objid);

            om_msg = om$send (
                     msg = message GRsvset.GSsvinit(msg,
                     &temp_obj_env.mod_env, env_properties, &count),
                     senderid = NULL_OBJID,
                     targetid = temp_sv_id.objid,
                     targetos = temp_sv_id.osnum);
         }else
         {
            created_sv = FALSE;
         }

         if (om_msg & *msg & 1)
         {
            for (i=0; i < count; ++i)
            {
               temp_obj_env.obj_id = ((struct GRid*)buffer)[i];
               GRflatten_owners (msg, attributes, eligible_classes, 
                  owner_classes, owner_properties, &temp_obj_env, gs_id, 
                  gs_chansel, &temp_sv_id, env_properties);
            }
         }

         if (created_sv)
         {
            om_msg = om$send (
                     msg = message GRsvset.GSunpreset(msg),
                     senderid = NULL_OBJID,
                     targetid = temp_sv_id.objid,
                     targetos = temp_sv_id.osnum);

            count = 0;
            om_msg = om$send (
                     msg = message GRgrset.GSinqcount (msg, &count),
                     senderid = NULL_OBJID,
                     targetid = temp_sv_id.objid,
                     targetos = temp_sv_id.osnum);

            if (!count)
            {
               om_msg = om$send (
                        msg = message GRgrset.GSempty (msg, NULL, NULL),
                        senderid = NULL_OBJID,
                        targetid = temp_sv_id.objid,
                        targetos = temp_sv_id.osnum);
            }
         }

         if (buffer) om$dealloc (ptr = buffer);
      }
   }else
   {
      if ( ((attributes->properties & LC_RW) == LC_WRITE_ONLY) &&
           (*env_properties & GRIS_READ_ONLY) )
      {
         /*
          *  Do not add the object if save set has read only access
          *  and write access was requested.  Note that if read and
          *  write objects were requested then it is a read only 
          *  operation.
          */   

         return(om_msg);
      }

      for (i=0; i < DP_NUM_OF_LEVELS; i++)
      {
         all_layers[i/32] |= (1<<(i % 32));
      }

      /*
       *  Perform criteria check on object and if it passes
       *  add it to the save set.
       */
 
      cvl.msg = MSSUCC;
      cvl.module = obj_env->mod_env;
      cvl.button.objid = NULL_OBJID;
      cvl.button.osnum = obj_env->mod_env.md_id.osnum;
      cvl.attributes.type = GR_nam_loc;
      cvl.attributes.obj_attr = *attributes;
      cvl.attributes.acc_tolerance = 0;
      cvl.action_handler = GRgscriteria;
      cvl.act_parms = (IGRchar *)sv_id;
      cvl.levels = all_layers;
      cvl.classes = eligible_classes;
      cvl.locate_args = NULL;
      cvl.prism_attr = NULL;

      om_msg = om$send (
               msg = message GRgraphics.GRlocate (&cvl, NULL),
               senderid = NULL_OBJID,
               targetid = obj_env->obj_id.objid,
               targetos = obj_env->obj_id.osnum);
   }
   return (om_msg);
}
end implementation Root;
