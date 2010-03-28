/*
Name
        grgsmacros.h

Description
        This include file defines om macros for the graphics set package.

History
        hgw     ??/??/86    creation
        mrm     05/22/89    added scale_flag to gr$gslocate
*/

#ifndef  grgsmacros_include
#define  grgsmacros_include

#include "grgsdef.h"


/*
 *  Defines for the functions that are invoked.
 */

#define  GSGET_FENCE          0
#define  GSPUT_FENCE          1
#define  GSGET_SELECT_SET     2
#define  GSPUT_SELECT_SET     3
#define  GSPUT_CRITERIA       4
#define  GSGET_CRITERIA       5
#define  GSGET_NUM_RTREE      6
#define  GSGET_NUM_ELIGIBLE   7

#define  GSINQ_COUNT          0
#define  GSPOST_PROCESSING    1
#define  GSDISSOLVE           2
#define  GSDELETE             3
#define  GSEMPTY              4
#define  GSCOPY               5
#define  GSCPTFORM            6
#define  GSGET_OBJECTS        7

/*
 *  Macros.
 */

/*\
Name
   gr$gspass

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
#omdef gr$gspass ( msg,
                   pass_msg = NULL,
                   path = NULL,
                   senderid = my_id,
                   senderos = OM_Gw_current_OS,
                   p_chanselect = NULL ^
                   object_id = NULL)

#if !om$specified (p_chanselect) && !om$specified (object_id)
#  omerror "Must specify <p_chanselect> or <object_id>"
#else 
   GRgspass ((msg), (pass_msg), (path), (senderid), (senderos),
             (p_chanselect), (object_id) )
#endif
#endomdef

/*\
Name
   gr$gsdisplay

Description
   This macro will send the display message to the graphics set.

   *msg           IGRlong           Completion code.
   dpmode         enum GRdpmode     display mode
   *display_id    struct GRid       The controlling display object 
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gsdisplay ( msg,
                      dpmode,
                      display_id = &me->ModuleInfo.md_id,
                      senderid = my_id,
                      senderos = OM_Gw_current_OS,
                      p_chanselect = NULL ^
                      object_id = NULL)

#if !om$specified (p_chanselect) && !om$specified (object_id)
#  omerror "Must specify <p_chanselect> or <object_id>"
#else 
   GRgsdisplay ((msg), (dpmode), (display_id), (senderid),
                (senderos), (p_chanselect), (object_id) )
#endif
#endomdef

/*\
Name
   gr$gsis_graphics_set

Description
   This macro is used to check if a specific object is a graphics
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

#omdef gr$gsis_graphics_set ( msg,
                              senderid = my_id,
                              senderos = OM_Gw_current_OS,
                              p_chanselect = NULL ^
                              object_id = NULL)

#if !om$specified (p_chanselect) && !om$specified (object_id)
#  omerror "Must specify <p_chanselect> or <object_id>"
#else 
   GRgs_is_graphics_set ((msg), (senderid), (senderos), (p_chanselect),
                         (object_id))
#endif
#endomdef

/*\
Name
   gr$gsempty

Description
   This macro is used to empty or (clear) the command object
   channel.

   *msg           IGRlong           Completion code.
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Notes
   The owner_chansel and owner_id can be NULL.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gsempty ( msg,
                    senderid = my_id,
                    senderos = OM_Gw_current_OS,
                    p_chanselect = NULL ^ 
                    object_id = NULL)

#if !om$specified (p_chanselect) && !om$specified (object_id)
#  omerror "Must specify <p_chanselect> or <object_id>"
#else 
   GRgs_fun ((msg), GSEMPTY, (senderid), (senderos), (p_chanselect),
             (object_id) )
#endif
#endomdef

/*\
Name
   gr$gsinit

Description
   This routine will construct a save set and then send the init method
   to the saveset.  The saveset will connect itself to the supplied 
   channel.

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
                                           highlight
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *p_objid       GRobjid           The object id of the saveset.
   osnum          GRspacenum        The object space number to construct
                                    the saveset in.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gsinit ( msg,
                   senderid = my_id,
                   senderos = OM_Gw_current_OS,
                   flag = NULL,
                   p_chanselect = NULL,
                   p_objid = NULL,
                   osnum = OM_Gw_current_OS)

#if om$specified (p_chanselect) || om$specified (p_objid)
      GRgsinit( (msg), (senderid), (senderos), (flag), (p_chanselect),
                (p_objid), (osnum) )
#else
#     omerror "Must specify <p_chanselect> or <p_objid>"
#endif
#endomdef

/*\
Name
   gr$gsflatten_owners

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
         owner_classes.p_classes = &GRgrgrp_classid;
         owner_properties = NULL;
      To get the components of all owners:
         owner_classes = NULL;
         owner_properties = 3;
      To get the components of all owners except symbol header objects.
         owner_classes.w_flags = OM_CLST_negation;
         owner_classes.p_classes = &GRsmhdr_classid;
         owner_properties = 3;

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure
\*/
#omdef gr$gsflatten_owners ( msg,
                             attributes,
                             eligible_classes,
                             owner_classes = NULL,
                             owner_properties = NULL,
                             senderid = my_id,
                             senderos = OM_Gw_current_OS,
                             p_chanselect = NULL ^
                             object_id = NULL)

#if !om$specified (p_chanselect) && !om$specified (object_id)
#  omerror "Must specify <p_chanselect> or <object_id>"
#else 
   GRgsflatten ((msg), (attributes), (eligible_classes), (owner_classes),
                (owner_properties), (senderid), (senderos), (p_chanselect),
                (object_id) )
#endif
#endomdef

/*\
Name
   gr$gsremove_fence

Description
   This function will remove the fence object from a graphics set.

   *msg           IGRlong           Completion code.
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the graphics set

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gsremove_fence ( msg,
                           senderid = my_id,
                           senderos = OM_Gw_current_OS,
                           p_chanselect = NULL ^
                           object_id = NULL)

#if !om$specified (p_chanselect) && !om$specified (object_id)
#  omerror "Must specify <p_chanselect> or <object_id>"
#else 
   GRgsremove_fence ((msg), (senderid), (senderos), (p_chanselect),
                     (object_id) )
#endif
#endomdef

/*\
Name
   gr$gsdelete

Description
   This macro is used to delete the graphics sets and the elements 
   owned by the graphics sets.

   *msg           IGRlong           Completion code.
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gsdelete ( msg,
                     senderid = my_id,
                     senderos = OM_Gw_current_OS,
                     p_chanselect = NULL ^
                     object_id = NULL)


#if !om$specified (p_chanselect) && !om$specified (object_id)
#  omerror "Must specify <p_chanselect> or <object_id>"
#else 
   GRgs_fun ((msg), GSDELETE, (senderid), (senderos), (p_chanselect),
             (object_id) )
#endif
#endomdef

/*\
Name
   gr$gsdissolve

Description
   This macro is used to delete the graphics sets on the command object
   channel.  This method does not delete the graphics objects owned by
   the graphics sets.

   *msg           IGRlong           Completion code.
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gsdissolve ( msg,
                       senderid = my_id,
                       senderos = OM_Gw_current_OS,
                       p_chanselect = NULL ^
                       object_id = NULL)

#if !om$specified (p_chanselect) && !om$specified (object_id)
#  omerror "Must specify <p_chanselect> or <object_id>"
#else 
   GRgs_fun ((msg), GSDISSOLVE, (senderid), (senderos), (p_chanselect),
             (object_id) )
#endif
#endomdef

/*\
Name
   gr$gspost_processing

Description
   This macro is used to perform any post processing (clipping) needed
   by the command object.  This method should be called if the command
   does not do a display erase or a copy operation.

   *msg           IGRlong           Completion code.
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gspost_processing ( msg,
                              senderid = my_id,
                              senderos = OM_Gw_current_OS,
                              p_chanselect = NULL ^
                              object_id = NULL)

#if !om$specified (p_chanselect) && !om$specified (object_id)
#  omerror "Must specify <p_chanselect> or <object_id>"
#else 
   GRgs_fun ((msg), GSPOST_PROCESSING, (senderid), (senderos), 
            (p_chanselect), (object_id) )
#endif
#endomdef

/*\
Name
   gr$gsinqcount

Description
   This macro is used to find the number of objects owned by the 
   graphics set.

   *msg           IGRlong           Completion code.
   *count         IGRint            The number of objects owned by
                                    the graphics set.
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gsinqcount ( msg,
                       count = &count,
                       senderid = my_id,
                       senderos = OM_Gw_current_OS,
                       p_chanselect = NULL ^ 
                       object_id = NULL)

#if !om$specified (p_chanselect) && !om$specified (object_id)
#  omerror "Must specify <p_chanselect> or <object_id>"
#else 
   GRgs_fun ((msg), GSINQ_COUNT, (senderid), (senderos), (p_chanselect),
             (object_id), (count) )
#endif
#endomdef

/*\
Name
   gr$gscopy

Description
   This macro is used to copy the components of a graphics set.

   *msg           IGRlong           Completion code.
   *target_env    struct GRmd_env   The environment to copy to.
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Notes
   As the copy is performed the original elements are disconnected
   from the graphics sets and the copies are connected to the graphics
   sets.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gscopy ( msg,
                   target_env = &me->ModuleInfo,
                   senderid = my_id,
                   senderos = OM_Gw_current_OS,
                   p_chanselect = NULL ^
                   object_id = NULL)

#if !om$specified (p_chanselect) && !om$specified (object_id)
#  omerror "Must specify <p_chanselect> or <object_id>"
#else 
   GRgs_fun ((msg), GSCOPY, (senderid), (senderos), (p_chanselect),
             (object_id), (target_env) )
#endif
#endomdef

/*\
Name
   gr$gscptform

Description
   This macro is used to copy and transform the components of a 
   graphics set. This method is more efficient than coping and 
   then transforming because it will avoid double rtree manipulations.

   *msg           IGRlong           Completion code.
   *target_env    struct GRmd_env   The environment to copy to.
   matrix         IGRmatrix         The transformation matrix 
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Notes
   As the copy and transform is performed the original elements are 
   disconnected from the graphics sets and the copies are connected 
   to the graphics sets.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gscptform ( msg,
                      target_env = &ME.COroot->ModuleInfo,
                      matrix = NULL,
                      senderid = my_id,
                      senderos = OM_Gw_current_OS,
                      p_chanselect = NULL ^
                      object_id = NULL)

#if !om$specified (p_chanselect) && !om$specified (object_id)
#  omerror "Must specify <p_chanselect> or <object_id>"
#else 
   GRgs_fun ((msg), GSCPTFORM, (senderid), (senderos), (p_chanselect),
             (object_id), (target_env), (matrix) )
#endif
#endomdef

/*\
Name
   gr$gsget_objects

Description
   This method will return the object and module environment for the
   objects between from_obj and to_obj.

   *msg           IGRlong           return code
   array[]        struct GRobj_env  An array of GRid's and module
                                    environments.
   size           IGRint            Size of array in bytes.
   *count         IGRint            The number of objects returned.
   from_obj       IGRint            The base index
   to_obj         IGRint            The high index
   senderid       GRobijd           The calling object id.
   senderos       GRspacenum        The calling object space number
   p_chanselect   OM_p_CHANSELECT   The calling object channel selector
   *object_id     struct GRid       The GRid of the object to be checked.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gsget_objects ( msg,
                          array,
                          size,
                          count,
                          from_obj = NULL,
                          to_obj = OM_K_MAXINT,
                          senderid = my_id,
                          senderos = OM_Gw_current_OS,
                          p_chanselect = NULL ^ 
                          object_id = NULL)

#if !om$specified (p_chanselect) && !om$specified (object_id)
#  omerror "Must specify <p_chanselect> or <object_id>"
#else 
   GRgs_fun ((msg), GSGET_OBJECTS, (senderid), (senderos), (p_chanselect),
             (object_id), (array), (size), (count), (from_obj),
             (to_obj) )
#endif
#endomdef

/*
Name
        gr$gslocate

Description
        This locate filter is a super set of the locate filter provided 
        by the locate package.  This locate filter allows for the located
        object to be added to a graphics set.

        To use the results from a group event generate, a command must or in
        GRm_OBJID in the event masks used by this filter.  The GRm_OBJID is
        returned from the group event generator and if it is an allowable
        event type, it is accepted and returned to the command object.

        If the p_chanselect is supplied then a graphics set containing the
        locate object(s) will be connected to the channel.  This channel should
        be a many-to-many and unrestricted.

        If a group event generator is selected by the user, the results
        from the group generator are automatically accepted.  However,
        additional inputs are often needed.  These inputs may be gathered
        by specifing the number of additional inputs needed (num_inputs) and
        the prompts (input1_key, input1_prompt, input2_key, input2_prompt)
        and masks (input1_mask, input2_mask) for each of these inputs.

Synopsis
        See the locate document for the desciption of the first few dozen
        locate arguments.  Note that locate_event is the same as event3, that 
        eventsize is passed by value not by address, and that regex default
        is 1 instead of 0.

        IGRint         *locate_state        Instance variable containting the 
                                            current state of the locate filter.
        IGRint          num_inputs          The number of inputs to be returned
                                            if the first input was a specified 
                                            object. (Excluding the first point).
        IGRlong         input1_mask         Input mask for first event, if 
                                            specified object.
        IGRlong         input2_mask         Input mask for second event, if 
                                            specified object.
        IGRchar        *input1_prompt       Prompt for input event 1.
        IGRlong         input1_key          The message key prompt for input
                                            event 1.
        IGRchar        *input2_prompt       Prompt for input event 2.
        IGRlong         input2_key          The message key prompt for input
                                            event 2.
        GRobjid         senderid            Object id of the calling object.
        GRspacenum      senderos            OS of the calling object.
        OM_p_CHANSELECT chansel             Channel select of calling object
                                            where the save set is connected.

Notes
        The num_inputs argument is used in conjunction with the EX_OBJID
        (SPECIFIED_OBJ) event.  If a SPECIFIED_OBJ is located then:
        num_inputs -   0  Returns the SPECIFIED_OBJ event in the locate_event.
                   -   1  Returns the SPECIFIED_OBJ event in the locate_event.
                          Returns input 1 event in event 2.
                   -   2  Returns the SPECIFIED_OBJ event in the locate_event.
                          Returns input 1 event in event 1.
                          Returns input 2 event in event 2 .

        otherwise the following is returned:
            -   Returns input 1 event in event 1
                Returns input 2 event in event 2 
                Returns the located object in locate_event
   
Return Values
        status : 0 - OM error.
        status : 1 - OM success.
        msg    : 0 - Object not connected to graphics set.
        msg    : 1 - Object connected to graphics set.
*/

#omdef gr$gslocate  ( msg,
                      event1,
                      event2,
                      locate_event,
                      nbytes1 = NULL, 
                      nbytes2 = NULL, 
                      mask1 = NULL,
                      mask2 = NULL,
                      value_type1 = NULL,
                      value_type2 = NULL,
                      hilight_mode    = -1,
                      unhilight_mode  = -1,
                      eventsize = sizeof(struct GRevent),
                      display_flag = 0,
                      response = response,
                      response_data = response_data,
                      locate_prompt = NULL ^
                      locate_key = LC_NO_MSG,
                      acc_prompt = NULL ^
                      acc_key = LC_NO_MSG, 
                      relocate_prompt = NULL ^
                      relocate_key  = LC_NO_MSG,
                      attributes = attributes,
                      stack,
                      dyn = NULL,
                      action_handler = NULL,
                      action_args = NULL,
                      select = NULL,
                      select_args = NULL,
                      range_handler = NULL,
                      range_args = NULL,
                      stack_size = 1,
                      rtree_classes = NULL,
                      eligible_classes = NULL,
                      regex = LC_REGEX_ON,
                      type = 0,
                      scale_flag = GRIO_X_SCALE,
                      locate_state = NULL,
                      num_inputs = 0,
                      input1_mask = NULL,
                      input2_mask = NULL,
                      input1_prompt = NULL,
                      input1_key = LC_NO_MSG,
                      input2_prompt = NULL,
                      input2_key = LC_NO_MSG,
                      senderid = my_id,
                      senderos = OM_Gw_current_OS,
                      p_chanselect = chan$addr &me->to_graphics)
                                    
#if om$specified (p_chanselect)
#   if om$specified (input1_prompt) && om$specified (input1_key)
#       omerror "Do not specify input1_prompt and input1_key"
#   else
#       if om$specified (input2_prompt) && om$specified (input2_key)
#           omerror "Do not specify both input2_prompt and input2_key"
#       else
            GRgslocate ((msg), (event1), (event2), (locate_event), (mask1), 
                        (mask2), (eventsize), (display_flag), (response), 
                        (response_data), (locate_prompt), (locate_key),
                        (acc_prompt), (acc_key), (relocate_prompt), 
                        (relocate_key), (attributes), (stack), (dyn), (type),
                        (action_handler), (action_args), (rtree_classes), 
                        (eligible_classes), (select), (select_args), 
                        (stack_size), (regex), (locate_state),
                        (num_inputs), (input1_mask), (input2_mask),
                        (input1_prompt), (input1_key), (input2_prompt),
                        (input2_key), (senderid), (senderos), (p_chanselect), 
                        (hilight_mode), (unhilight_mode), (nbytes1),  
                        (nbytes2), (range_handler), (range_args),
                        (value_type1), (value_type2), (scale_flag))
#       endif 
#   endif
#else
#   omerror "Must specify <p_chanselect> as OM_p_CHANSELECT"
#endif
#endomdef

/*\
Name
   gr$gsget_fence

Description
   This macro is used to retrieve the current fence.

   *msg           IGRlong           Completion code.
   *fence_id      struct GRid       The object id of the fence

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gsget_fence ( msg,
                        fence_id)

   GRgsmgr_fun ((msg), GSGET_FENCE, (fence_id) )
#endomdef

/*\
Name
   gr$gsput_fence

Description
   This macro is used to define (put) the current fence.

   *msg           IGRlong           Completion code.
   *mod_env       struct GRmd_env   The fence's environment
   *fence_id      struct GRid       The object id of the fence
   *window_id     struct GRid       The window id

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gsput_fence ( msg,
                        mod_env,
                        fence_id,
                        window_id)

   GRgsmgr_fun ((msg), GSPUT_FENCE, (mod_env), (fence_id), (window_id))
#endomdef

/*\
Name
   gr$gsget_select_set

Description
   This macro is used to retrieve the current select set.

   *msg           IGRlong           Completion code.
   *select_set_id struct GRid       The object id of the select set

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gsget_select_set( msg,
                            select_set_id)

   GRgsmgr_fun ((msg), GSGET_SELECT_SET, (select_set_id) )
#endomdef

/*\
Name
   gr$gsput_select_set

Description
   This macro is used to define (put) the current select set.

   *msg           IGRlong           Completion code.
   *mod_env       struct GRmd_env   The select set's environment
   *select_set_id struct GRid       The object id of the select set

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$gsput_select_set ( msg,
                             mod_env,
                             select_set_id)

   GRgsmgr_fun ((msg), GSPUT_SELECT_SET, (mod_env), (select_set_id))
#endomdef

/*\
Name
   gr$gsput_locate_criteria

Description
   This method will put the locate criteria.

   *msg              IGRlong              Return code
   *locate_env       struct GRmd_env      The environment for a locate
   *attributes       struct GRlc_locate   The attributes describing the
                                          criteria that the object must
                                          pass.
   *rtree_classes    OM_S_CLASSLIST       The rtree classes
   *eligible_classes OM_S_CLASSLIST       The eligible classes
   *levels           IGRint               The levels to search.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
 
#omdef gr$gsput_locate_criteria ( msg,
                                  locate_env = NULL,
                                  attributes = NULL,
                                  rtree_classes = NULL,
                                  eligible_classes = NULL,
                                  levels = NULL)

   GRgsmgr_fun ((msg), GSPUT_CRITERIA, (locate_env), (attributes),
                (rtree_classes), (eligible_classes), (levels))
#endomdef

/*\
Name
   gr$gsget_number_rtree_classes

Description
   This method will get the number of rtree classes in the posted
   locate criteria.

   *msg              IGRlong              Return code.
   *count            IGRint               The number of rtree classes

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

#omdef gr$gsget_number_rtree_classes ( msg,
                                       count)

   GRgsmgr_fun ((msg), GSGET_NUM_RTREE, (count))
#endomdef

/*\
Name
   gr$gsget_number_eligible_classes

Description
   This method will get the number of eligible classes in the
   posted locate criteria.

   *msg              IGRlong              Return code.
   *count            IGRint               The number of eligible classes

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

#omdef gr$gsget_number_eligible_classes ( msg,
                                          count)

   GRgsmgr_fun ((msg), GSGET_NUM_ELIGIBLE, (count))
#endomdef

/*\
Name
   gr$gsget_locate_criteria

Description
   This method will get the locate criteria.

   *msg              IGRlong              Return code.
   *criteria_flag    IGRint               A flag which has a bit set
                                          for each item returned.
   *locate_env       struct GRmd_env      The environment for a locate
   *attributes       struct GRlc_locate   The attributes describing the
                                          criteria that the object must
                                          pass.
   *rtree_classes    OM_S_CLASSLIST       The rtree classes
   *eligible_classes OM_S_CLASSLIST       The eligible classes
   *levels           IGRint               The levels to search.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

#omdef gr$gsget_locate_criteria ( msg,
                                  criteria_flag,
                                  locate_env = NULL,
                                  attributes = NULL,
                                  rtree_classes = NULL,
                                  eligible_classes = NULL,
                                  levels = NULL)

   GRgsmgr_fun ((msg), GSGET_CRITERIA, (criteria_flag), 
                (locate_env), (attributes), (rtree_classes), 
                (eligible_classes), (levels))
#endomdef

/*\
Name
   gr$gsprism_locate

Description
   This filter performs a prism locate.

Arguments
   *msg                 IGRlong              Completion code
   *mod_env             struct GRmd_env      The module environment
   *window_id           struct GRid          Object id of the window
   *attributes          struct GRlc_locate   Locate attributes
   *classinfo           struct GRlc_classes  The locate class lists.
   prism_type           IGRint               Prism type
                                                -  GR_RIGHT_PRISM
                                                -  GR_CURVE_PRISM
   *prism               IGRchar              Pointer to prism
   prism_attr           IGRint               Flag describing the relation-
                                             ship of the graphics objects
                                             being searched for to the 
                                             prism.
                                                -  TRUE_REL
                                                -  GO_INSIDE
                                                -  GO_OUTSIDE
                                                -  GO_OVERLAP
                                                -  GO_INSIDE | GO_OVERLAP
                                                -  GO_OUTSIDE | GO_OVERLAP
   inside_outside       IGRint               If 1 search inside prism
                                             If 0 search outside prism
   *layers              IGRint               Layers
   (*action_handler)()  IGRchar              Action handler.
   *action_args         IGRchar              Action handler arguments.

Notes
   If the layers variable is NULL the layers from the window will be
   inquired.

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure
\*/
#omdef gr$gsprism_locate ( msg,
                           mod_env,
                           window_id,
                           attributes,
                           classinfo,
                           prism_type,
                           prism,
                           prism_attr,
                           inside_outside,
                           layers = NULL,
                           action_handler,
                           action_args)

   GRprism_locate ((msg), (mod_env), (window_id), (attributes), 
                   (classinfo), (prism_type), (prism), (prism_attr),
                   (inside_outside), (layers), (action_handler), 
                   (action_args))
#endomdef

#endif
