#ifndef  lcobjmacros_include
#define  lcobjmacros_include


/*\
Name
   lc$multiple_connect

Description
   This routine provides the ability to connect several objects to one 
   intermediate object.  This can be used in conjunction with the 
   lc$wild_disconnect, lc$get_channel_count, lc$get_channel_objects,
   and the lc$is_objid_on_channel macros.

   osnum                GRspacenum        The command's osnum
   objid                OM_S_OBJID        The command's objid
   p_chanselect         OM_p_CHANSELECT   The command's channel
   index                IGRint            The command's index 
   go_objid             OM_S_OBJID        The objid of the graphics object
   go_osnum             GRspacenum        The osnum of the graphics object
   go_index             IGRint            The index of the graphics object
   preset               IGRint            If none zero, preset the channel.

Return Values
   OM_S_SUCCESS
   OM_E_ABORT
\*/
#omdef lc$multiple_connect ( osnum = OM_Gw_current_OS,
                             objid = my_id,
                             p_chanselect,
                             index = OM_K_MAXINT,
                             go_objid,
                             go_osnum,
                             go_index = OM_K_MAXINT,
                             preset = NULL)

   LCmultiple_connect ((osnum), (objid), (p_chanselect), (index), 
                       (go_objid), (go_osnum), (go_index), (preset) )
#endomdef

#endif
