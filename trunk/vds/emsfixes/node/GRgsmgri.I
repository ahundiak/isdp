/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRgsmgr methods

Description
        This file contains graphic set manager methods.

History
        Gray Winn   10/05/86    Creation date
        Gray Winn   10/07/88    Updated for message interception
        mrm         10/24/89    Changed GRget_locate_criteria,
                                GRget_number_rtree_classes, and
                                GRget_number_eligible_classes to use the
                                LC criteria.
                    12/19/89    Mark LC criteria node as a pass node
                    07/01/91    Return local criteria if locate filter
                                doesn't have any.
        msm         07/09/92    ANSI-C conversion.
	gvk	    11/03/95    Search for .deleted only in currentOS.
*/

class implementation GRgsmgr;

#include "OMerrordef.h"
#include "msdef.h"
#include "madef.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exmacros.h"

/*
Name
   sleep

Description
   This method will empty the graphics set when the graphics set manager
   receives a sleep method.

Arguments
   *type_sleep    IGRint     i   if 1 temp sleep, wake up will follow
                                 if 0 real sleep
*/
method global_class.sleep (int type_sleep)
{
IGRlong              om_msg;
IGRint               status;
unsigned int         count;
IGRint               delete_gs_flag;
OM_S_CHANSELECT      chansel;
IGRint               ii, find_count = 0;
DIgrid              *grids;
DIspacenum           osnum;
DIchar               directory[DI_PATH_MAX];
DIchar             **filename;
struct GRmd_env      mod_env;

 
 int traceFlag = 1;

 if (traceFlag) {
   printf(">>> GRgsmgr.global_class.sleep\n");
 }
 
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgsmgr.select_set";

   /*
    *  Is a select set active?
    */

   om_msg = om$get_channel_count (object = me, p_chanselect = &chansel, 
            count = &count);

   if (traceFlag) {
     printf("Select Set Channel Count %d\n",count);
     fflush(stdout);
   }
   
   if (count)
   {
      /*
       * check to see if the delete graphics set flag is set; if it is,
       * delete the graphics set
       */
     
      GRset_inq_gs_flag(&om_msg,FALSE,&delete_gs_flag);
      if (traceFlag) {
	printf("Delete flag %d\n",delete_gs_flag);
      }
      
      if (delete_gs_flag)
      {
	if (traceFlag) {
	  printf("Emptying the set\n");
	  fflush(stdout);
	}
	
	gr$gsempty (msg = &om_msg, p_chanselect = &chansel);

	if (traceFlag) {
	  printf("Emptied  the set\n");
	  fflush(stdout);
	}
      }
   }

   /* 05/10/93 - JSD - Look for any object names that start with ".deleted_"
      and send that object a GRdelete message.  This is a precautionary step
      just in case the pre-delete protocall fails.
    */

   ex$get_cur_mod ( osnum = &osnum );

   if (traceFlag) {
     printf("Objects space numbers %d %d\n",osnum,OM_Gw_current_OS);
     fflush(stdout);
   }
   
   /* gvk    11/03/95    Search for .deleted only in currentOS. 
      TR# 119528102 **/

   if( osnum != OM_Gw_current_OS) {
     if (traceFlag) {
       printf("<<< GRgsmgr.global_class.sleep osnum not current os\n");
       fflush(stdout);
     }
     return ( OM_S_SUCCESS);	
   }

   di$give_pathname ( osnum = osnum, pathname = directory );

   strcat ( directory, ":usr:" );

   if (traceFlag) {
     printf("Getting .deleted directories '%s'\n",directory);
     fflush(stdout);
   }
#if 0
   om_msg = di$find ( start_dir = directory,
                      regexp    = ".deleted_*",
                      grids     = &grids,
                      lines     = &filename,
                      ptr       = &find_count,
                      options   = OPT_ALL );

   /******************* KLUDGE *************************/
   GRfindmod(&mod_env.md_id);
   mod_env.md_env.matrix_type = MAIDMX;
   MAidmx(&om_msg,mod_env.md_env.matrix);
   /****************************************************/

   if (traceFlag) {
     printf("About to delete %d items\n",find_count);
     fflush(stdout);
   }
   
   for ( ii=0; ii<find_count; ii++ )
   {
     status = om$send (msg      = message GRgraphics.GRdelete (&om_msg,
                                                               &mod_env),
                       senderid = my_id,
                       targetid = grids[ii].objid,
                       targetos = grids[ii].osnum);
   }
#endif

   if (traceFlag) {
     printf("<<< GRgsmgr.global_class.sleep %d\n",find_count);
     fflush(stdout);
   }
   
   return (OM_S_SUCCESS);
}

/*
Name
   wake_up

Description
   This method sets up message interception for the fence.
*/
method wake_up ()
{
IGRlong              om_msg;
unsigned int         count;
OM_S_OBJECT_LINKAGE  list;
OM_S_CHANSELECT      chansel;

   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Is a fence active?
    */

   om_msg = om$get_channel_objects (objid = my_id,
            p_chanselect = &chansel, list = &list, size = 1,
            count = &count);

   if ((om_msg & 1) && count)
   {
      /*
       *  Setup message interception for the fence.
       */

      om_msg = om$set_intercept (osnum = list.osnum, objid = list.S_objid,
               target_objid = my_id);
   }
   return (OM_S_SUCCESS);
}

/*
Name
   GRget_fence

Description
   This method returns the active fence.

Arguments
   *msg         IGRlong      o   completion code
   *fence_id    struct GRid  o   object id of the active fence.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
*/
method GRget_fence (IGRlong *msg; struct GRid *fence_id)
{
IGRlong  om_msg;
unsigned int  count;
OM_S_OBJECT_LINKAGE  list;
OM_S_CHANSELECT      chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   om_msg = om$get_channel_objects ( object = me,
            p_chanselect = &chansel, list = &list,
            size = 1, count = &count);

   if ((om_msg & 1) && count)
   {
      fence_id->objid = list.S_objid;
      fence_id->osnum = list.osnum;
   }else
   {
      *msg = MSFAIL;
   }
   return (OM_S_SUCCESS);
}

/*
Name
   GRput_fence

Description
   This method defines the given fence as the active fence.

Arguments
   *msg         IGRlong         o   completion code
   *mod_env     struct GRmd_env i   The active module environment.
   *fence_id    struct GRid     i   object id of the active fence.
   *window_id   struct GRid     i   object id of the window.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
*/
method GRput_fence (IGRlong *msg; struct GRmd_env *mod_env;
                    struct GRid *fence_id; struct GRid *window_id)
{
IGRlong           om_msg;
IGRlong           ret_msg;
IGRlong           connect_flag;
unsigned int      count;
IGRlong           index;
enum GRdpmode     dpmode;
OM_S_CHANSELECT   chansel;
OM_S_CHANSELECT   to_sel;
OM_S_CHANSELECT   from_sel;
struct GRid       my_GRid;

   *msg = MSSUCC;
   ret_msg = MSSUCC;
   index = OM_K_MAXINT;
   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;
   dpmode = GRbehe;  /* Erase the element */
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";
   to_sel.type = OM_e_name;
   to_sel.u_sel.name = "winsup";
   from_sel.type = OM_e_addr;
   from_sel.u_sel.addr = &me->gra_gad;

   /*
    *  Is a fence current active?
    */

   om_msg = om$get_channel_count (object= me, p_chanselect = &chansel,
            count = &count);

   if ((om_msg & 1) && count)
   {   
      /*
       *  Erase the current fence.
       */

      om_msg = om$send (
               msg = message GRgraphics.GRdisplay (&ret_msg, 
               &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
               &dpmode, &mod_env->md_id),
               p_chanselect = &chansel);

      if (om_msg & ret_msg & 1)
      {
         /*
          *  Delete the current fence.
          */

         om_msg = om$send(
                  msg = message GRgraphics.GRdelete (&ret_msg, mod_env),
                  p_chanselect = &chansel);
      }
   }

   /*
    *  Connect the fence to the manager.
    */

   if (om_msg & ret_msg & 1)
   {
      connect_flag = 1;    /* Override */
      om_msg = om$send(
               msg = message GRconnector.GRflexconn (&ret_msg, 
               &connect_flag, &my_GRid, &index, 
               &index),
               targetid = fence_id->objid, targetos = fence_id->osnum);

      /*
       *  Set up message interception for the fence object.
       */

      om_msg = om$set_intercept (osnum = fence_id->osnum,
               objid = fence_id->objid, target_objid = my_id);

      /*
       *  Empty the channel to the window.
       */

      om_msg = om$send (msg = message Root.wild_disconnect (from_sel),
               targetid = my_id);

      /*
       *  Connect the fence manager to the window in which it is 
       *  associated.
       */

      om_msg = om$send(msg = message Root.connect (to_sel, NULL, 
               my_id, OM_Gw_current_OS, from_sel, NULL),
               senderid = my_id, 
               targetos = window_id->osnum,
               targetid = window_id->objid);
   }
   return ( om_msg );
}

/*
Name
   GRget_select_set

Description
   This method returns the active select set.

Arguments
   *msg           IGRlong       o   completion code
   *select_set_id struct GRid   o   object id of the active select set.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
*/
method GRget_select_set (IGRlong *msg; struct GRid *select_set_id)
{
IGRlong  om_msg;
unsigned int   count;
OM_S_OBJECT_LINKAGE  list;
OM_S_CHANSELECT      chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_addr;
   chansel.u_sel.addr = &me->select_set;

   om_msg = om$get_channel_objects ( object = me, p_chanselect = &chansel,
            list = &list, size = 1, count = &count);

   if ((om_msg & 1) && count)
   {
      select_set_id->objid = list.S_objid;
      select_set_id->osnum = list.osnum;
   }else
   {
      *msg = MSFAIL;
   }
   return (OM_S_SUCCESS);
}

/*
Name
   GRput_select_set

Description
   This method defines the given graphics set as the active select set.

Arguments
   *msg         IGRlong         o   completion code
   *mod_env     struct GRmd_env i   The active module environment.
   *select_set_id struct GRid   i   object id of the active select set.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
*/
method GRput_select_set (IGRlong *msg; struct GRmd_env *mod_env;
                         struct GRid *select_set_id)
{
IGRlong              om_msg;
IGRlong              ret_msg;
unsigned int         count;
OM_S_CHANSELECT      to_select_set;
OM_S_CHANSELECT      to_owners;

   *msg = MSSUCC;
   ret_msg = MSSUCC;
   to_select_set.type = OM_e_addr;
   to_select_set.u_sel.addr = &me->select_set;
   to_owners.type = OM_e_name;
   to_owners.u_sel.name = "GRgrset.to_owners";

   /*
    *  Is a select set active?
    */

   om_msg = om$get_channel_count (object= me, 
            p_chanselect = &to_select_set, count = &count);

   if ((om_msg & 1) && count)
   {
      om_msg = gr$gsempty (msg = &ret_msg, p_chanselect = &to_select_set);
   }

   if (om_msg & ret_msg & 1)
   {
      om_msg = om$send(
               msg = message Root.connect (to_owners, NULL, 
               my_id, OM_Gw_current_OS, to_select_set, NULL),
               targetid = select_set_id->objid,
               targetos = select_set_id->osnum);
   }
   return ( om_msg );
}

/*
Name
   GRput_locate_criteria

Description
   This method will put the locate criteria.

Arguments
   *msg              IGRlong             o   Return code
   *locate_env       struct GRmd_env     i   The environment for a locate
   *attributes       struct GRlc_locate  i   The attributes describing the
                                             criteria that the object must
                                             pass.
   rtree_classes     OM_p_CLASSLIST      i   The rtree classes
   eligible_classes  OM_p_CLASSLIST      i   The eligible classes
   *levels           IGRint              i   The levels to search.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
*/
method GRput_locate_criteria (IGRlong *msg; struct GRmd_env *locate_env;
                               struct GRlc_locate *attributes;
                               OM_p_CLASSLIST rtree_classes;
                               OM_p_CLASSLIST eligible_classes;
                               IGRint  *levels)
{
    IGRint i;

    *msg = MSSUCC;
    me->posted_info_properties = NULL;

    if (locate_env)
    {
        me->posted_info_properties |= GSPUT_LOCATE_ENV;
        me->locate_env = *locate_env;
    }

    if (attributes)
    {
        me->posted_info_properties |= GSPUT_ATTRIBUTES;
        me->attributes = *attributes;
    }


    if (rtree_classes)
    {
        me->posted_info_properties |= GSPUT_RTREE_CLASSES;
        me->rtree_classlist = *rtree_classes;
        om$vla_set_dimension(varray = me->rtree_classes,
                             size = rtree_classes->w_count);
        for (i = 0; i < (IGRint)rtree_classes->w_count; ++i)
        {
            me->rtree_classes[i] = rtree_classes->p_classes[i];
        }      
    }


    if (eligible_classes)
    {
        me->posted_info_properties |= GSPUT_ELIGIBLE_CLASSES;
        me->eligible_classlist = *eligible_classes;
        om$vla_set_dimension(varray = me->eligible_classes,
                             size = eligible_classes->w_count);
        for (i = 0; i < (IGRint)eligible_classes->w_count; ++i)
        {
            me->eligible_classes[i] = eligible_classes->p_classes[i];
        }      
    }

    if (levels)
    {
        me->posted_info_properties |= GSPUT_LEVELS;
        for (i = 0; i < DP_NUM_OF_LEVELS/32 + 1; ++i)
        {
            me->levels[i] = levels[i];
        }
    }
    return(OM_S_SUCCESS);
}

/*
Name
        GRget_number_rtree_classes

Description
        This method will get the number of rtree classes in the posted
        locate criteria.  This method ignores the GRgsmgr criteria in
        favor of the LC criteria, since one set of data is enough and
        the LC criteria is better maintained.

Arguments
        IGRlong          *msg              o   Return code.
        IGRint           *count            o   The number of rtree classes

Return Values
        MSSUCC  -- successful completion
*/

method GRget_number_rtree_classes (IGRlong *msg; IGRint *count)
{
    IGRlong display_flag;
    struct GRlc_locate attributes;
    OM_S_CLASSLIST rtree_classes, eligible_classes;
    IGRint regex, hilite_mode, unhilite_mode;

    *msg = MSSUCC;

    rtree_classes.w_count = 0;

    LCmark_node (LC_PASS_CRITERIA);

    LCget_prev_criteria (&display_flag, &attributes, &rtree_classes,
                         &eligible_classes, &regex, &hilite_mode,
                         &unhilite_mode);

    *count = rtree_classes.w_count;

    return (OM_S_SUCCESS);
}

/*
Name
        GRget_number_eligible_classes

Description
        This method will get the number of eligible classes in the posted
        locate criteria.  This method ignores the GRgsmgr criteria in
        favor of the LC criteria, since one set of data is enough and
        the LC criteria is better maintained.

Arguments
        IGRlong          *msg              o   Return code.
        IGRint           *count            o   The number of rtree classes

Return Values
        MSSUCC  -- successful completion
*/
method GRget_number_eligible_classes (IGRlong *msg; IGRint *count)
{
    IGRlong display_flag;
    struct GRlc_locate attributes;
    OM_S_CLASSLIST rtree_classes, eligible_classes;
    IGRint regex, hilite_mode, unhilite_mode;

    *msg = MSSUCC;

    eligible_classes.w_count = 0;

    LCmark_node (LC_PASS_CRITERIA);

    LCget_prev_criteria (&display_flag, &attributes, &rtree_classes,
                         &eligible_classes, &regex, &hilite_mode,
                         &unhilite_mode);

    *count = eligible_classes.w_count;

    return (OM_S_SUCCESS);
}

/*
Name
        GRget_locate_criteria

Description
        This method will return the locate criteria posted by the locate
        (LC) functions.

Arguments
        IGRlong            *msg               o Return code.
        IGRint             *criteria_flag     o A flag which has a bit set
                                                for each item returned.
        struct GRmd_env    *locate_env        o The environment for a locate
        struct GRlc_locate *attributes        o The attributes describing the
                                                criteria that the object must
                                                pass.
        OM_p_CLASSLIST     rtree_classes      o The rtree classes
        OM_p_CLASSLIST     eligible_classes   o The eligible classes
        IGRint             *levels            o The levels to search.

Return Values
        MSSUCC  -- successful completion
*/

method GRget_locate_criteria (IGRlong *msg; IGRint *criteria_flag;
                              struct GRmd_env *locate_env;
                              struct GRlc_locate *attributes;
                              OM_p_CLASSLIST rtree_classes;
                              OM_p_CLASSLIST eligible_classes;
                              IGRint  *levels)
{
    IGRlong display_flag;
    IGRint regex, hilite_mode, unhilite_mode, i;

    *msg = MSSUCC;
    *criteria_flag = NULL;

    display_flag = -1;

    LCmark_node (LC_PASS_CRITERIA);

    LCget_prev_criteria (&display_flag, attributes, rtree_classes,
                         eligible_classes, &regex, &hilite_mode,
                         &unhilite_mode);

    if (display_flag == -1)
    {
        /*
            No data in locate for the active command object, so use that
            stored here.  This situation probably came about because
            someone called gr$gsput_criteria to deposit their locate
            criteria, then used co$getevent as their input filter,
            accepting objids as input (those MODEL guys never do
            anything the easy way).  Since they never called lc$locate,
            LCget_prev_criteria had no info on that command.
        */

        if ((me->posted_info_properties & GSPUT_ATTRIBUTES) && attributes)
        {
            *criteria_flag |= GSPUT_ATTRIBUTES;
            *attributes = me->attributes;
        }

        if ((me->posted_info_properties & GSPUT_RTREE_CLASSES) &&
            rtree_classes)
        {
            *criteria_flag |= GSPUT_RTREE_CLASSES;
            me->rtree_classlist.p_classes = me->rtree_classes;
            *rtree_classes = me->rtree_classlist;
        }

        if ((me->posted_info_properties & GSPUT_ELIGIBLE_CLASSES) &&
            eligible_classes)
        {
            *criteria_flag |= GSPUT_ELIGIBLE_CLASSES;
            me->eligible_classlist.p_classes = me->eligible_classes;
            *eligible_classes = me->eligible_classlist;
        }
    }
    else
    {
      *criteria_flag = GSPUT_ATTRIBUTES |
                       GSPUT_RTREE_CLASSES |
                       GSPUT_ELIGIBLE_CLASSES;
    }

    if ((me->posted_info_properties & GSPUT_LOCATE_ENV) && locate_env)
    {
        *criteria_flag |= GSPUT_LOCATE_ENV;
        *locate_env = me->locate_env;
    }

    if ((me->posted_info_properties & GSPUT_LEVELS) && levels)
    {
        *criteria_flag |= GSPUT_LEVELS;
        for (i = 0; i < DP_NUM_OF_LEVELS / 32 + 1; ++i)
        {
            levels[i] = me->levels[i];
        }
    }

    return(OM_S_SUCCESS);
}

end implementation GRgsmgr;
