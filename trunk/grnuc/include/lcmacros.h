/*
Name
        lcmacros.h

Description
        This file contains macros used for access into the locate system.

History
        rc      01/01/88    creation
        mrm     09/12/91    added lc$action and lc$select
*/

#ifndef lcmac_include
#define lcmac_include



/*
Name
        lc$locate

Description
        This is the generic locate filter.

Synopsis
        IGRlong *rc                     O return code; see lcdef.h
        struct GRevent *event1          O locate event
        struct GRevent *event2          O accept event
        struct GRevent *event3          O event causing filter exit
        IGRint *nbytes1                 O from co$getevent for event1
        IGRint *nbytes2                 O from co$getevent for event2
        IGRlong mask1                   I input mask for event1
        IGRlong mask2                   I input mask for event2
        IGRchar *value_type1            O from co$getevent for event1
        IGRchar *value_type2            O from co$getevent for event2
        IGRlong *eventsize              I sizeof(struct GRevent)
        IGRlong display_flag            I see lcdef.h
        IGRint hilight_mode             I mode to highlight with
        IGRint unhilight_mode           I mode to unhighlight with
        IGRint *response                O from co$getevent
        IGRchar *response_data          O from co$getevent
        IGRchar *locate_prompt          I event1 prompt string
        IGRint locate_key               I event1 prompt key
        IGRchar *acc_prompt             I event2 prompt string
        IGRint acc_key                  I event2 prompt key
        IGRchar *relocate_prompt        I message displayed in status
        IGRint relocate_key             I field if nothing found
        struct GRlc_locate *attributes  I properties and owner info
        struct GRlc_stack *stack        O locate stack
        struct GRlc_dynamics *dyn       I for accept dynamics
        IGRint *act_handler()           I action handler function
        IGRchar *act_args               I action handler arguments
        IGRint *select()                I accept/reject function
        IGRchar *select_args            I accept/reject arguments
        IGRint *range_handler()         I range locate function
        IGRchar *range_args             I passed to range_handler
        IGRint stack_size               I max stack size
        OM_p_CLASSLIST rtree_classes    I specifies classes to be sent the
                                          locate message during the rtree pass
        OM_p_CLASSLIST eligible_classes I specifies classes to be
                                          located / not located
        IGRint regex                    I for name locate
        IGRint type                     I boreline or point
        IGRint scale_flag               I for co$getevent (see griodef.h)
*/

#omdef lc$locate(rc,
                 event1, 
                 event2,
                 event3            = NULL,
                 nbytes1           = NULL, 
                 nbytes2           = NULL, 
                 mask1             = NULL,
                 mask2             = NULL,
                 value_type1       = NULL,
                 value_type2       = NULL,
                 eventsize         = NULL,
                 display_flag      = 0,
                 hilight_mode      = -1,
                 unhilight_mode    = -1,
                 response          = response, 
                 response_data     = response_data,
                 locate_prompt     = NULL
                 ^ locate_key      = LC_NO_MSG,
                 acc_prompt        = NULL
                 ^ acc_key         = LC_NO_MSG, 
                 relocate_prompt   = NULL
                 ^ relocate_key    = LC_NO_MSG,
                 attributes        = attributes, 
                 stack,
                 dyn               = NULL,
                 act_handler       = NULL,
                 act_args          = NULL,
                 select            = NULL,
                 select_args       = NULL,
                 range_handler     = NULL,
                 range_args        = NULL,
                 stack_size        = 1,
                 rtree_classes     = NULL,
                 eligible_classes  = NULL,
                 regex             = 0,
                 type              = 0,
                 scale_flag        = GRIO_X_SCALE)

        LClocate((rc), (event1), (event2), (event3), (mask1), (mask2),
                 (eventsize), (display_flag), (response),
                 (response_data), (locate_prompt), (acc_prompt),
                 (relocate_prompt), (attributes), (stack), (dyn),
                 (type), (act_handler), (act_args), (rtree_classes),
                 (eligible_classes), (select), (select_args),
                 (stack_size), (regex), (locate_key), (acc_key),
                 (relocate_key), (hilight_mode), (unhilight_mode),
                 (nbytes1), (nbytes2), (range_handler), (range_args),
                 (value_type1), (value_type2), (scale_flag))
#endomdef



/*
Name
        lc$classchek

Description
        The following macro is for supporting locate by classes. 
        The macro is expected to be useful in the GRlocate or
        GRlocate_processing method of graphic objects.  The two
        arguments which should be supplied are classid_to_check,
        a classid of type OMuword, and eligible_classes, a pointer
        to an OM_S_CLASSLIST structure.  This structure needs to be
        filled in properly. 

        The eligible_classes->w_flags field determines the type of
        check which will be used to compare classid_to_check and
        eligible_classes->p_classes.  The values OM_CLST_subclass and
        OM_CLST_negation may be used to obtain the desired check.

Synopsis
        IGRlong         *rc                 o   return code
        OMuword         classid_to_check    i   class is of object to check
        OM_p_CLASSLIST  eligible_classes    i   determines valid classes
	IGRint          mode                i   LC_DPB or LC_NO_DPB

Return Values
        A returned value of one from the function call indicates 
        that the object passed the class check; a value of zero indicates
        that the object did not pass the class check.

        The results will be unpredictable if w_count is set to a value 
        greater than the number of classids pointed to by the field 
        p_classes.  In case of calls with nonexistent classid a value 
        of zero is returned. The error status can be found out using 
        the argument rc.
*/

#omdef  lc$classchek(rc,
		     classid_to_check, 
	             eligible_classes,
	             mode = 0)
       
        LCclasschek((rc), (classid_to_check), (eligible_classes), (mode))

#endomdef



/*
Name
        lc$query

Description
        The following macro defines a common interface point to
        a function that sends the GRlocate and GRdisyourself message 
        through the Rtree.  These message are sent in the cases of locate
        and update respectively.
    
Synopsis
        IGRlong		    *rc;
        struct GRmd_env	    *mod;
        enum GRlocate_types *locate_type;
        IGRchar		    *loc_parms;
        IGRint		    (*action_handler)();
        IGRchar		    *act_parms;
        GRlc_classptrs	    classptr;
        IGRint		    levels[];
             
	The default settings for the arguments have the following
	implications:
	
		action_handler		Use the action handler provided
					by the locate subsystem.
					
					This action handler will insert
					elements into the stack based on 
					distance.
					
		act_parms		Use the arguments provided by the 
					locate subsystem.
					
		classptr		Locate all classes.
		
		levels			Inquire the active levels from the
					window during a locate operation.
*/

#omdef  lc$query(rc,
                 mod,
                 locate_type, 
                 loc_parms, 
                 act_handler = NULL,
                 act_parms = NULL, 
                 classptr = NULL,
                 levels = NULL)

        LCquery((rc), (mod), (locate_type), (loc_parms), (act_handler),
	        (act_parms), (classptr), (levels), NULL)

#endomdef


/*
Name
        lc$check_id

Description
        This macro is used to keep track of objects already processed
        during a single locate operation.  This will prevent, for
        example, objects with multiple owners from processing more than
        once.  It is not intended to work between discrete calls to the
        locate filter. 
*/

#omdef  lc$check_id(rc,
                    objid = NULL_OBJID,
                    osnum = OM_Gw_current_OS,
                    mode = LC_ADD_CHECK)

        LC_check_id((rc), (objid), (osnum), (mode))

#endomdef


/*
Name
        lc$post_id
*/

#omdef  lc$post_id(rc,
                   objid = NULL_OBJID,
                   osnum = OM_Gw_current_OS,
                   mode = LC_ADD_CHECK)

        LC_post_id((rc), (objid), (osnum), (mode))

#endomdef


/*
Name
        lc$connect

Description
        This routine provides the connect mechanism between a command
        and a graphics object.

Synopsis
        GRspacenum      osnum           The command's osnum
        OM_S_OBJID      objid           The command's objid
        OM_p_CHANSELECT p_chanselect    The command's channel
        IGRint          index           The command's index 
        OM_S_OBJID      go_objid        The objid of the graphics object
        GRspacenum      go_osnum        The osnum of the graphics object
        IGRint          go_index        The index of the graphics object

Return Values
        OM_S_SUCCESS
        OM_E_ABORT
*/

#omdef  lc$connect(osnum = OM_Gw_current_OS,
                   objid = my_id,
                   p_chanselect,
                   index = OM_K_MAXINT,
                   go_objid,
                   go_osnum,
                   go_index = OM_K_MAXINT)

        LCconnect((osnum), (objid), (p_chanselect), (index), 
                  (go_objid), (go_osnum), (go_index))

#endomdef


/*
Name
        lc$wild_disconnect

Description
        This routine severs the connection between a command and all 
        graphics objects on a specified command channel.

Synopsis
        GRspacenum      osnum           The command's osnum
        OM_S_OBJID      objid           The command's objid
        OM_p_CHANSELECT p_chanselect    The command's channel

Return Values
        OM_S_SUCCESS
        OM_E_ABORT
*/

#omdef  lc$wild_disconnect(osnum = OM_Gw_current_OS,
                           objid = my_id,
                           p_chanselect)

        LCwild_disconnect((osnum), (objid), (p_chanselect))

#endomdef


/*
Name
        lc$range_disconnect

Description
        This routine provides the mechanism for commands to disconnect 
        the graphics objects within a certain range on the command
        object's channel.

Synopsis
        GRspacenum      osnum           The command's osnum
        OM_S_OBJID      objid           The command's objid
        OM_p_CHANSELECT p_chanselect    The command's channel
        IGRint          low_index       The low index of the disconnect range
        IGRint          high_index      The high index of the disconnect range

Return Values
        OM_S_SUCCESS
        OM_E_ABORT
*/

#omdef  lc$range_disconnect(osnum = OM_Gw_current_OS,
                            objid = my_id,
                            p_chanselect,
                            low_index = NULL,
                            high_index = OM_K_MAXINT)

        LCrange_disconnect((osnum), (objid), (p_chanselect), (low_index),
                           (high_index))
#endomdef


/*
Name
        lc$get_channel_count

Description
        This routine provides the mechanism for commands to inquire the 
        number of graphics objects on its channel.

Synopsis
        GRspacenum      osnum           The command's osnum
        OM_S_OBJID      objid           The command's objid
        OM_p_CHANSELECT p_chanselect    The command's channel
        IGRint          *count          The number of graphics objects
                                        on the channel

Return Values
        OM_S_SUCCESS
        OM_E_ABORT
*/

#omdef  lc$get_channel_count(osnum = OM_Gw_current_OS,
                             objid = my_id,
                             p_chanselect,
                             count)

        LCget_channel_count((osnum), (objid), (p_chanselect), (count))

#endomdef


/*
Name
        lc$get_channel_objects

Description
        This routine provides the mechanism for commands to get the 
        graphics objects on its channel.

Synopsis
        GRspacenum          osnum           The command's osnum
        OM_S_OBJID          objid           The command's objid
        OM_p_CHANSELECT     p_chanselect    The command's channel
        OM_S_OBJECT_LINKAGE list[]          An array of object linkages
        IGRint              size            The number of elements in the list
        IGRint              *count          The number of graphics objects
                                            on the channel
Return Values
        OM_S_SUCCESS
        OM_E_ABORT
*/

#omdef  lc$get_channel_objects(osnum = OM_Gw_current_OS,
                               objid = my_id,
                               p_chanselect,
                               list,
                               size,
                               count)

        LCget_channel_objects((osnum), (objid), (p_chanselect),
                              (list), (size), (count))
#endomdef


/*
Name
        lc$is_objid_on_channel

Description
        This routine checks whether a given objid is on the specified channel.

Synopsis
        GRspacenum      osnum               The command's osnum
        OM_S_OBJID      objid               The command's objid
        OM_p_CHANSELECT p_chanselect        The command's channel
        OM_S_OBJID      go_objid            The graphics object id
        GRspacenum      go_osnum            The graphics object osnum

Return Values
        OM_S_SUCCESS
        OM_E_ABORT
*/

#omdef  lc$is_objid_on_channel(osnum = OM_Gw_current_OS,
                               objid = my_id,
                               p_chanselect,
                               go_objid,
                               go_osnum)

        LCis_objid_on_channel((osnum), (objid), (p_chanselect),
                              (go_objid), (go_osnum))
#endomdef


/*
Name
        lc$get_objid_at_index

Description
        This routine returns the objid and osnum of the object at the
        specified index in an ordered channel.

Synopsis
        GRspacenum      osnum           The command's osnum
        OM_S_OBJID      objid           The command's objid
        OM_p_CHANSELECT p_chanselect    The command's channel
        IGRint          index           The command's index
        OM_S_OBJID      *go_objid       The graphics object id
        GRspacenum      *go_osnum       The graphics object osnum

Return Values
        OM_S_SUCCESS
        OM_E_ABORT
*/

#omdef  lc$get_objid_at_index(osnum = OM_Gw_current_OS,
                              objid = my_id,
                              p_chanselect,
                              index,
                              go_objid,
                              go_osnum)

        LCget_objid_at_index((osnum), (objid), (p_chanselect), (index),
                             (go_objid), (go_osnum))
#endomdef


/*
Name
        lc$get_index

Description
        This routine returns the relative or absolute index of a go_objid
        and go_osnum on a channel.

Synopsis
        GRspacenum      osnum           The command's osnum
        OM_S_OBJID      objid           The command's objid
        OM_p_CHANSELECT p_chanselect    The command's channel
        OM_S_OBJID      go_objid        The graphics object id
        GRspacenum      go_osnum        The graphics object osnum
        IGRint          *index          The command's index at which
                                        the graphics object resides

Return Values
        OM_S_SUCCESS
        OM_E_ABORT
*/

#omdef  lc$get_index(osnum = OM_Gw_current_OS,
                     objid = my_id,
                     p_chanselect,
                     go_objid,
                     go_osnum,
                     index)

        LCget_index((osnum), (objid), (p_chanselect), (go_objid),
                    (go_osnum), (index))
#endomdef


/*
Name
        lc$disconnect

Description
        This routine provides the mechanism for commands to disconnect 
        a graphics object from its channel.

Synopsis
        GRspacenum      osnum           The command's osnum
        OM_S_OBJID      objid           The command's objid
        OM_p_CHANSELECT p_chanselect    The command's channel
        OM_S_OBJID      go_objid        The objid of the graphics object
        GRspacenum      go_osnum        The osnum of the graphics object

Return Values
        OM_S_SUCCESS
        OM_E_ABORT
*/

#omdef  lc$disconnect(osnum = OM_Gw_current_OS,
                      objid = my_id,
                      p_chanselect,
                      go_objid,
                      go_osnum)

        LCdisconnect((osnum), (objid), (p_chanselect), (go_objid), (go_osnum))
#endomdef


/*
Name
        lc$delete

Description
        This routine provides the mechanism for commands to delete the
        command ISO object.  This routine should be called if a message
        was sent to delete the graphics object.

Synopsis
        GRspacenum      osnum           The command's osnum
        OM_S_OBJID      objid           The command's objid
        OM_p_CHANSELECT p_chanselect    The command's channel

Return Values
        OM_S_SUCCESS
        OM_E_ABORT
*/

#omdef  lc$delete(osnum = OM_Gw_current_OS,
                  objid = my_id,
                  p_chanselect)

        LCdelete((osnum), (objid), (p_chanselect))

#endomdef


/*
Name
        lc$check_action

Description
        This macro will check the action handler and tell if it was
        specified by the command or the locate filter.  If it was
        specified by the locate filter the msg argument will contain
        a #define that will describe which of the 3 currently
        supported action handlers it is. 
    
Synopsis
        IGRlong *msg                If a locate filter action handler
     				    is specified this will tell which
     				    one it was otherwise the value
     				    will be MSSUCC.
     					
     					LC_EVENT_ACTION
     					LC_ACCEPT_ONE_ACTION
     					LC_PTBL_ACTION
     					
        IGRchar *action_handler     This will contain a pointer to a 
    				    function, the action handler.
Return Values
    	1 -- Command specified action handler
    	0 -- Locate filter specified action handler
*/    					

#omdef  lc$check_action(msg, action_handler)

        LCcheck_action((msg), (action_handler))

#endomdef


/*
Name
        lc$display

Description
        This macro will perform a display request for locate.  If a
        request for a display in all windows is requested, the
        graphic gadgets that are active and not delayed are found. 
        Then the first window is highlighted in.  This is the window
        that is passed in.  Then the remaining windows are sent a
        highlight request.  The defaults are set for element display
        instead of segment display. 

Synopsis
        O   struct GRparms *parms (only for segment display)
        O   IGRlong *msg             
        I   IGRshort *matrix_type    
        I   IGRmatrix matrix          
        I   enum DPmode highlight_mode  
        I   struct GRid *dis_id          
        I   OM_S_OBJID objid           
        I   OMuword osnum           
        I   IGRint element         
        I   IGRint window          
        I   struct GRid mod_id          
        I   IGRint *ext_o_element   

Return Values
        The return code of the function will be the om return code from the
        messages sent to display.
*/

#omdef  lc$display(msg,
                   matrix_type,
                   matrix,
                   highlight_mode,
                   window_id = NULL,
                   objid,
                   osnum,
                   mod_id = NULL,
                   element = 1,
                   window = 0,
                   parms = NULL,
                   ext_o_element = 1)

        LCdisplay((msg), (matrix_type), (matrix), (highlight_mode), 
                  (window_id), (objid), (osnum), (element), (window),
                  (mod_id), (parms), (ext_o_element))

#endomdef                   


/*
Name
        lc$add_class

Description
        This macro will add a type to the types that are available to
        the user to toggle.

Synopsis
        IGRchar *owner          The logical name of the field that this is
                                to be part of

        IGRint properties       Is the type locatable.  Default is yes.

        IGRchar *name           Logical name to be displayed in the form.

        OM_S_CLASSLIST classes  Structure describing the classes that are
                                affected by the logical name.

Return Values
        OM_S_SUCCESS
*/
 
#omdef  lc$add_class(owner = NULL,
                     properties = 1,
                     name,
                     classes, 
                     id = NULL_OBJID,
                     osnum = -1)

        LCadd_class((owner), (properties), (name), (classes), (id), (osnum))
    
#endomdef


/*
Name
        lc$action

Description
        This macro will invoke the default action handler.  It is
        provided to make it easy to override the default routine to
        provide special locate processing, and then invoke the normal
        action handler.

Synopsis
        IGRchar *user_args            I pointer to information specified in
                                        the call to lc$locate as "act_args"
        struct GRlc_info *entry       I the object being located
        struct LC_action_args *locate_args
                                      I information filled in by the locate
                                        system
        enum GRlocate_action *action  I the action the graphic object is
	                                requesting
*/

#omdef  lc$action(args, new_entry, locate_args, action)

        LCptlocact((args), (new_entry), (locate_args), (action))
#endomdef


/*
Name
        lc$select

Description
        This macro will invoke the default select handler.  It is
        provided to make it easy to override the default routine to
        provide special processing, and then invoke the normal select
        handler.

Synopsis
        IGRint *msg                     O   return code
        struct LC_select_args *args     I   object and event information
        IGRchar *user_data              I   one of the standard arguments to
                                            a select handler; not used by 
                                            this macro
*/

#omdef  lc$select(msg, args, user_data = NULL)

        LCcselect((msg), (args), (user_data))

#endomdef

#endif
