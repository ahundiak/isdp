/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRgsget_simple_object

Description
   This funcion will return an GRobj_env if there is an object on
   a saveset.  If there is not an object or if it is a 
   fence set/ graphics set then it will return failure.
 
   *msg                IGRlong            -  Completion code
   *owner_id           struct GRid        -  The owner of the channel.
   chansel             OM_p_CHANSELECT    -  The channel.
   *obj_env            struct GRobj_env   -  The object id to return.

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
     Gray Winn    01/14/87    Creation date.
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation Root;

#include <stdio.h>
#include "OMprimitives.h"
#include "OMmacros.h"
#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "grgs.h"
#include "msdef.h"

from  GRgrset  import   GSget_object, GSinqcount;

IGRint GRgsget_simple_object (msg, owner_id, chansel, obj_env)
IGRlong              *msg;
struct GRid          *owner_id;
OM_p_CHANSELECT      chansel;
struct GRobj_env     *obj_env;
{
IGRlong     om_msg;
IGRint      count;
IGRint      size;

   *msg = MSSUCC;

   om_msg = om$get_channel_count (osnum = owner_id->osnum,
            objid = owner_id->objid, p_chanselect = chansel,
            count = (IGRuint*) &count);

   if (count == 1)
   {
      count = 0;
      om_msg = om$send (
               msg = message GRgrset.GSinqcount (msg, &count),
               senderid = owner_id->objid, p_chanselect = chansel);

      if (count == 1)
      {
         size = sizeof (struct GRobj_env);
         count = 0;
         om_msg = om$send (
                  msg = message GRgrset.GSget_object (msg, obj_env, 
                  size, &count, 0, 0 ), 
                  senderid = owner_id->objid, p_chanselect = chansel);
      }else
      {
         *msg = MSFAIL;
         return(om_msg);
      }
   }else
   {
      *msg = MSFAIL;
      return(om_msg);
   }
   return (om_msg);
}

IGRint GRgsget_all_objects(msg, owner_id, chansel, obj_env,num_objects)
IGRlong              *msg;
struct GRid          *owner_id;
OM_p_CHANSELECT      chansel;
struct GRobj_env     **obj_env;
IGRint		     *num_objects;
{
IGRlong     om_msg,cl_msg,gr_msg,ac_msg;
IGRint      act_count = 0,count,count1=0;
IGRint      i,ii,size,temp_count = 0;
struct GRobj_env *ob_env=NULL;
OMuword              class_id;
struct GRobj_env *temp_objs = NULL;
OM_S_CHANSELECT      to_comp;

   *msg = MSSUCC;
   *num_objects = 0;

   om_msg = om$get_channel_count (osnum = owner_id->osnum,
            objid = owner_id->objid, p_chanselect = chansel,
            count = (IGRuint*) &count);

   if (count == 1)
   {
      count = 0;
      om_msg = om$send (
               msg = message GRgrset.GSinqcount (msg, &count),
               senderid = owner_id->objid, p_chanselect = chansel);
      size = count * sizeof (struct GRobj_env);
      ob_env = (struct GRobj_env *)om$malloc(size = size);
      om_msg = om$send (
                  msg = message GRgrset.GSget_object (msg, ob_env, 
                  size, &count1, 0, count ), 
                  senderid = owner_id->objid, p_chanselect = chansel);
      (*obj_env) = (struct GRobj_env *)om$malloc(size = size);
      for(ii = 0; ii < count1 ; ii++)
        {
        om_msg = om$get_classid (osnum = ob_env[ii].obj_id.osnum,
               objid = ob_env[ii].obj_id.objid, p_classid = &class_id);
        
        cl_msg = om$is_ancestry_valid (subclassid = class_id,
               superclassname = "GRclhdr");
        ac_msg = om$is_ancestry_valid (subclassid = class_id,
               superclassname = "ACconst");
        gr_msg = om$is_ancestry_valid (subclassid = class_id,
               superclassname = "GRpart");
        if (((cl_msg != OM_I_INVANCESTRY) && (cl_msg & 1)) ||
            ((ac_msg != OM_I_INVANCESTRY) && (ac_msg & 1)) ||
            ((gr_msg != OM_I_INVANCESTRY) && (gr_msg & 1))) 
           {
	   OM_S_OBJECT_LINKAGE *buffer=NULL;
	   count = 0;
           om$make_chanselect(channame ="GRcmpowner.to_components",
                         p_chanselect= &to_comp);

           om_msg = om$get_channel_count(osnum = ob_env[ii].obj_id.osnum,
            objid = ob_env[ii].obj_id.objid, 
	    p_chanselect = &to_comp,
           count = (IGRuint*) &count);
           buffer = (OM_S_OBJECT_LINKAGE *)om$malloc(size = count *
						sizeof(OM_S_OBJECT_LINKAGE));
           om_msg = om$get_channel_objects (osnum = ob_env[ii].obj_id.osnum,
               objid = ob_env[ii].obj_id.objid, 
	       p_chanselect = &to_comp,
               list = buffer,
               size = count, count = (OMuint *)&count);
           if(temp_objs == NULL)
             {
             temp_objs = (struct GRobj_env *)om$malloc(size = 
					 sizeof(struct GRobj_env )*count);
             if(!temp_objs) { 
               *msg = MSFAIL; return(om_msg); }
             }
           else
             {
             temp_objs = (struct GRobj_env *)om$realloc(
			   size = sizeof(struct GRobj_env )*(count + act_count),
			   ptr = (IGRchar  *)temp_objs);
             if(!temp_objs) { 
               *msg = MSFAIL; return(om_msg); }
             }
           for(i = 0;i < count; i++)
              {
              om_msg = om$get_classid (osnum = buffer[i].osnum,
                objid = buffer[i].S_objid, p_classid = &class_id);
              om_msg = om$is_ancestry_valid (subclassid = class_id,
                superclassname = "EMSsolid");
              if ((om_msg != OM_I_INVANCESTRY) && (om_msg & 1))
                 {
                 OM_BLOCK_MOVE(&ob_env[ii],&temp_objs[act_count],
				sizeof(struct GRobj_env));
                 temp_objs[act_count].obj_id.objid = buffer[i].S_objid;
		 temp_objs[act_count++].obj_id.osnum = buffer[i].osnum;
                 }
              }
             if(buffer)
               {
               om$dealloc(ptr = buffer); buffer = NULL;
               }
           }
        else
          {
          OM_BLOCK_MOVE(&ob_env[ii],&(*obj_env)[temp_count],
				sizeof(struct GRobj_env));
          temp_count++;
          }
        }
	if(act_count)
          {
          (*obj_env) = (struct GRobj_env *)om$realloc( size = 
		           sizeof(struct GRobj_env )*(temp_count + act_count),
                           ptr = (IGRchar *)(*obj_env));
          if(! *obj_env)
            {
            *msg = MSFAIL; return(om_msg);
            }
         i = temp_count;
         for(ii=0; ii <act_count; ii++)
           {
           OM_BLOCK_MOVE(&temp_objs[ii],&(*obj_env)[i],
				sizeof(struct GRobj_env));
           i++;
           }

         }
      *num_objects = temp_count + act_count;
   }else
   {
      *msg = MSFAIL;
      return(om_msg);
   }
   return (om_msg);
}
end implementation Root;
