/*\
Description
   This command allows a user to file the elements in a graphic group.
The graphic group can be created using any of the group generators.

HISTORY
   Gray Winn    05/14/87       Creation date.
   WBC          03/30/89       Added action to delete the graphics objects
                               not connected to the graphics set.
   SCW          07/10/92       Ansi conversion
\*/

class           COsaveelem
super_class     COgrpevent
spec_path       "$grnuc/co/spec"
start_state     terminate
product_name    "$SOURCE"
options         "SItc"

specification

#include "dpdef.h"
#include "dpmacros.h"

instance
{
    struct gs_members
    {
        IGRint            num_objects;
        struct GRobj_env  *obj_env;
        struct GRmd_env   mod_env;
        GRclassid         clippoly_classid;
    } gs_info;
    struct GRevent  stored_event;
}

implementation

#include "coimport.h"
#include "gomacros.h"
#include "growner.h"
#include "grdpbmacros.h"

from GRgraphics   import GRfunction, GRdelete;
from GRgrset      import GSupdate_path, GSdissolve;

extern IGRint        GRdel_obj_not_listed();

/*\
Description
   This action constructs a list of graphics objects that are not to be deleted
   in the saved file.
\*/

action get_select_set ()
{
    IGRlong                      nbytes_in_buffer;
    IGRlong                      nbytes_transferred;
    OMuint                       count;
    IGRint                       nbytes;
    OM_S_CLASSLIST               owner_classes;
    GRclassid                    GRgrgrp_classid;
    struct GRid                  graphics_set_id;
    struct GRid                  fence_id;
    struct OM_sd_object_linkage  object_linkage;

    /*
     * must find the object id of the graphics set connected to this command
     * object via the "located_graphics" channel
     */

    status = om$get_channel_count(osnum = OM_Gw_current_OS,
                                  objid = my_id,
                                  p_chanselect = &me->located_chansel,
                                  count = &count);

    if ((status & 1) &&
        (count == 1))
    {
        count = 0;

        status = om$get_channel_objects(osnum = OM_Gw_current_OS,
                                        objid = my_id,
                                        p_chanselect = &me->located_chansel,
                                        list = &object_linkage,
                                        size = 1,
                                        count = &count);

        if ((status & 1) &&
            (count == 1))
        {
            nbytes_in_buffer = sizeof(me->gs_info.mod_env);

            status = gr$get_module_env(msg = &me->ret,
                                       sizbuf = &nbytes_in_buffer,
                                       buffer = &me->gs_info.mod_env,
                                       nret = &nbytes_transferred);

            /*
             * the osnum and objid of the module environment should be the
             * same as that of the current module
             */

            ex$get_cur_mod(id = &me->gs_info.mod_env.md_id.objid,
                           osnum = &me->gs_info.mod_env.md_id.osnum);

            /*
             * want to work with the graphics set in the current object space
             */

            graphics_set_id.objid = object_linkage.S_objid;
            graphics_set_id.osnum = me->gs_info.mod_env.md_id.osnum;

            /*
             * send a message to the graphics set that will update the module
             * environment information in the save set(s)
             */

            status = om$send(msg = message GRgrset.GSupdate_path
                                                   (&me->ret,
                                                    &me->gs_info.mod_env),
                             targetid = graphics_set_id.objid,
                             targetos = graphics_set_id.osnum);

            /*
             * flatten any graphic group(s) located
             */

            status = om$get_classid(classname = "GRgrgrp",
                                    p_classid = &GRgrgrp_classid);

            owner_classes.w_count = 1;
            owner_classes.w_flags = OM_CLST_subclass;
            owner_classes.p_classes = &GRgrgrp_classid;

            status = gr$gsflatten_owners(msg = &me->ret,
                                         attributes = &me->attributes,
                                         eligible_classes = me->locate_eligible,
                                         owner_classes = &owner_classes,
                                         object_id = &graphics_set_id);

            /*
             * clip the objects in the graphics set if necessary
             */

            status = gr$gspost_processing(msg = &me->ret,
                                          object_id = &graphics_set_id);

            if (status & me->ret & 1)
            {
                /*
                 * find the objids and osnums of the objects owned by the
                 * graphics set (user defined select set)
                 */

                status = gr$gsinqcount(msg = &me->ret,
                                       count = &me->gs_info.num_objects,
                                       object_id = &graphics_set_id);

                if (status & me->ret & 1)
                {
                    /*
                     * allocate memory for the object environment array
                     */

                    nbytes = me->gs_info.num_objects * sizeof(struct GRobj_env);

                    if (me->gs_info.obj_env = (struct GRobj_env *)om$malloc(size = nbytes))
                    {
                        status = gr$gsget_objects(msg = &me->ret,
                                                  array = me->gs_info.obj_env,
                                                  size = nbytes,
                                                  count = &me->gs_info.num_objects,
                                                  object_id = &graphics_set_id);

                        if (status & me->ret & 1)
                        {
                            /*
                             * find the classid of the class GRclippoly to be
                             * used in checking objects to be deleted in
                             * GRdel_obj_not_listed()
                             */

                            om$get_classid(classname = "GRclippoly",
                                           p_classid = &me->gs_info.clippoly_classid);

                            /*
                             * send a message to the graphics set to delete
                             * itself (does not delete the graphics objects)
                             */

                            status = om$send(msg = message GRgrset.GSdissolve
                                                   (&me->ret),
                                             targetid = graphics_set_id.objid,
                                             targetos = graphics_set_id.osnum);

                            /*
                             * delete the fence object if it exists
                             */

                            status = gr$gsget_fence(msg = &me->ret,
                                                    fence_id = &fence_id);

                            if (status & me->ret & 1)
                            {
                                om$send(msg = message GRgraphics.GRdelete
                                                      (&me->ret,
                                                       &me->gs_info.mod_env),
                                        targetid = fence_id.objid,
                                        targetos = fence_id.osnum);
                            }

                            me->ret = OM_S_SUCCESS;
                        }
                        else
                        {
                            me->ret = OM_E_ABORT;
                            om$dealloc(ptr = me->gs_info.obj_env);
                        }
                    }
                    else  /* no memory was allocated */
                    {
                        me->ret = OM_E_ABORT;
                    }
                }
                else  /* gr$gsinqcount failed */
                {
                    me->ret = OM_E_ABORT;
                }
            }
            else  /* gr$gspost_processing failed */
            {
                me->ret = OM_E_ABORT;
            }
        }
        else  /* om$get_channel_objects failed */
        {
            me->ret = OM_E_ABORT;
        }
    }
    else  /* om$get_channel_count failed */
    {
        me->ret = OM_E_ABORT;
    }
}

/*\
Description
   This action sends a GRfuction message to the elements in the file,
   which will call a fuction to determine if the object is connected to
   the graphics set.  If it is not, the object will be sent a delete
   message; otherwise it will be sent a clip message.
\*/

action delete_no_connect ()
{
    IGRlong                   tmp_msg;
    struct   GRfunction_info  user_info;
    IGRint   i, j;
    OMuint   in_cnt;
    struct   GRid             new_obj;
    GRclassid  new_classid, xhgg_classid;
    OM_S_CHANSELECT         own_chan, chanselect;

    go$build_user_function_buffer(buffer = &user_info,
                                  pass_on = FALSE,
                                  your_info = (IGRchar *)&me->gs_info);
    

    /* 
       Check whether objects to be saved are a part of crosshatch pattern.
       If yes, disconnect those objects from GRxhgg object. This is necessary
       because whenever parent composite curve is deleted, the crosshatch
       pattern gets deleted. By disconnecting from GRxhgg, we will be able to
       save the pattern as a bunch of lines in the given file. 
       -- TR# 11922292  Mrudula.
    */

    status = om$make_chanselect(channame = "GRconnector.to_owners",
                                   p_chanselect = &own_chan);
    if (!(status & 1)) {
             goto quit;
    }
    status = om$make_chanselect(channame = "GRcmpowner.to_components",
                                   p_chanselect = &chanselect);
    if (!(status & 1)) {
             goto quit;
    }
    status = om$get_classid (classname = "GRxhgg",
                             p_classid = &xhgg_classid);
    if (!(status & 1)) {
             goto quit;
    }

    for (i=0; i<me->gs_info.num_objects; i++) {
       status = om$get_channel_count(osnum = me->gs_info.obj_env[i].obj_id.osnum,
                                     objid = me->gs_info.obj_env[i].obj_id.objid,
                                     p_chanselect = &own_chan,
                                     count = &in_cnt);
       if (!(status & 1)) {
             goto quit;
       }
       if (in_cnt) {
         for (j=0; j<in_cnt; j++) {
           status = om$get_objid_at_index(
                            osnum = me->gs_info.obj_env[i].obj_id.osnum,
                            objid = me->gs_info.obj_env[i].obj_id.objid,
                            p_chanselect = &own_chan,
                            index = j,
                            objidaddr = &new_obj.objid,
                            osnumaddr = &new_obj.osnum);
           if (!(status & 1)) {
             goto quit;
           }
           status = om$get_classid (osnum = new_obj.osnum,
                                    objid = new_obj.objid,
                                    p_classid = &new_classid);
           if (!(status & 1)) {
             goto quit;
           }
           if (new_classid == xhgg_classid) {
              status = om$send(msg = message Root.disconnect(own_chan, 
                               new_obj.objid,
                               new_obj.osnum,
			       chanselect),
			targetid=me->gs_info.obj_env[i].obj_id.objid,
                        targetos=me->gs_info.obj_env[i].obj_id.osnum);
              if (!(status & 1)) {
                  goto quit;
              }
              break;
           }
         }
       }
    }

    /*
     * pass the GRfunction message to all the object in the current file
     */

    status = gr$gspass(msg = &me->ret,
                       pass_msg = message GRgraphics.GRfunction
                                             (&tmp_msg,
                                              GRdel_obj_not_listed,
                                              (IGRchar *)&user_info),
                       object_id = &me->event1.located_object[0].located_obj);

    /*
     * delete the graphics set
     */

    status = gr$gsdissolve(msg = &tmp_msg,
                           object_id = &me->event1.located_object[0].located_obj);

    /*
     * dealloc the memory for the array of object environments
     */

    if (me->gs_info.obj_env)
    {
        om$dealloc(ptr = me->gs_info.obj_env);
    }
}

/*\
Description
   This action puts the specified command (using a command key) on the
   front of the software queue.
\*/

action put_message_on_queue (char *cmd_key)
{
    IGRlong     nbytes;

    /*
     * command keys should be ten characters or less; if this command key
     * is not ten characters or less, can't put it on the software queue
     */

    if ((nbytes = strlen(cmd_key)) <= 10)
    {
        IGRint      response_type;

        me->ret = OM_S_SUCCESS;
        ++nbytes;  /* include the NULL terminator */
        response_type = EX_CMD_KEY;

        status = ex$putque(msg = &me->ret,
                           response = &response_type,
                           byte = &nbytes,
                           buffer = cmd_key);
    }
    else  /* cmd_key string too long */
    {
        me->ret = OM_E_ABORT;
    }
}

/*\
Description
   This action either set or clears the flag indicating whether to delete
   the current graphics set.
\*/

action delete_graphics_set_flag (int gs_flag)
{
    GRset_inq_gs_flag(&me->ret,TRUE,&gs_flag);
}

/*\
Description
   This action stores the accept event.
\*/


/*\
Description
   This action will erase the highlight plane.
\*/
action clear_highlight
{
   /*
    *  Erase the highlight plane
    */

   struct GRid modid;

   ex$get_cur_mod(id = &modid.objid,
            osnum = &modid.osnum);

   status = dp$erase_hilite (msg = sts,
            objid = modid.objid,
            osnum = modid.osnum);
}

action store_event ()
{
    me->stored_event = me->event1;
}

/*\
Description
   This action puts the stored event on the software queue.
\*/

action put_queue ()
{
    IGRlong  size;

    size = sizeof(struct GRevent) - (2 * (sizeof(IGRint)));

    status = ex$putque(msg = &me->ret,
                       pos = FRONT,
                       response = &me->stored_event.response,
                       byte = &size,
                       buffer = (IGRchar *)&me->stored_event.event);
}
