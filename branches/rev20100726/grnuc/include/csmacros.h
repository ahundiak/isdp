/*
Name
        csmacros.h

Description
        This file contains macros to access coordinate system (cs) objects
        and coordinate system manager (csmgr) objects.  All of the macros
        return IGRlong values.

Dependencies
        csdef.h

History
        mrm     03/03/88    creation
                10/12/88    added cs$get_scale, cs$set_scale
                07/24/89    added cs$cvt_to_lcl, cs$cvt_to_wld
        dhm     08/06/91    added type argument to cs$get_active_info
        dhm     08/12/91    added cs$change_type
*/

#ifndef csmacros_include

#define csmacros_include


/*
Name
        cs$get_mgr

Description
        This macro returns the id of the coordinate system manager in the
        specified object space.  If the module id is unknown, it may be
        defaulted to NULL.

Synopsis
        IGRlong        *msg         O   return code
        GRspacenum      osnum       I   of the desired manager
        GRobjid         module      I   module id, if known
        GRobjid        *csmgr       O   cs manager in the specified object space

Return Value
        IGRlong ()      OM_S_SUCCESS if successful
        IGRlong *msg    MSSUCC if successful
*/

#omdef  cs$get_mgr (msg,
                    osnum = OM_Gw_current_OS,
                    module = NULL,
                    csmgr)

        GRcsget_mgr ((msg), (osnum), (module), (csmgr))
#endomdef

/* 
Name
        cs$get_active_info

Description
        This macro returns the name, description, and/or the objid of the
        active coordinate system in the specified object space.  If the
        module id and/or the coordinate system manager is unknown, they may
        be defaulted to NULL.

Synopsis
        IGRlong    *msg             O   return code
        GRspacenum  osnum           I   in which to find the active cs
        GRobjid     module          I   module id, if known
        GRobjid     csmgr           I   coordinate system manager, if known
        IGRint      namebuf_size    I   size of the input name buffer
        IGRchar    *name            O   buffer in which to put name
        IGRint     *namebytes_ret   O   size of name
        IGRint      descbuf_size    I   size of the input description buffer
        IGRchar    *desc            O   buffer in which to put name
        IGRint     *descbytes_ret   O   size of description
        IGRshort   *type            O   type of the active coordinate system
        GRobjid    *objid           O   objid of the active coordinate system

Return Value
        IGRlong ()      OM_S_SUCCESS if successful
        IGRlong *msg    MSSUCC if successful
                        MSFAIL if unsuccessful
*/

#omdef  cs$get_active_info (msg,
                            osnum         = OM_Gw_current_OS,
                            module        = NULL,
                            csmgr         = NULL,
                            namebuf_size  = NULL,
                            name          = NULL,
                            namebytes_ret = NULL,
                            descbuf_size  = NULL,
                            desc          = NULL,
                            descbytes_ret = NULL,
                            type          = NULL,
                            objid         = NULL)

        GRcsget_active_info ((msg), (osnum), (module), (csmgr),
                             (namebuf_size), (name), (namebytes_ret),
                             (descbuf_size), (desc), (descbytes_ret),
                             (type), (objid))
#endomdef

/*
Name
        cs$make_active

Description
        This macro makes the indicated coordinate system active.  Note that
        since there can be only one active coordinate system per object
        space, the macro by default redisplays the old active coordinate
        system with a zero weight and displays the new active coordinate
        system with the default cs weight.

Note
        The display_old and display_new flags are not yet implemented.
        Currently the display operations are always performed.

Synopsis
        IGRlong            *msg             O   return code
        GRobjid             objid           I   to make active
        struct GRmd_env    *module_info     I   of coordinate system
        GRobjid             csmgr           I   cs manager, if known
        IGRint              display_old     I   redraw old active cs
        IGRint              display_new     I   display new active cs
*/

#omdef  cs$make_active (msg,
                        objid,
                        module      = NULL,
                        csmgr       = NULL,
                        display_old = TRUE,
                        display_new = TRUE)

        GRcsmake_active ((msg), (objid), (module), (csmgr),
                         (display_old), (display_new))
#endomdef

/*
Name
        cs$get_scale

Description
        This macro may be used to retrieve the scale values associated with
        a coordinate system.  If cs_id is NULL, then the scale of the active
        coordinate system in the specified object space is returned.

Synopsis
        IGRlong         *msg;           O   return code MSSUCC - always succeeds
        GRobjid          cs_id;         I   id of cs in question
        GRspacenum       cs_os;         I   object space number of cs
        IGRdouble        scale[3];      O   scale values
*/

#omdef  cs$get_scale (msg,
                      cs_id = NULL,
                      cs_os = OM_Gw_current_OS,
                      scale)

        GRcsget_scale ((msg), (cs_id), (cs_os), (scale))
#endomdef

/*
Name
        cs$set_scale

Description
        This macro may be used to set the scale values associated with a
        coordinate system.  If cs_id is NULL, then the scale of the active
        coordinate system in the specified object space is altered.  According
        to the abs_rel flag, the cs scale vector is either replaced with the
        input scale vector (absolute scale setting) or combined with the
        input scale vector (relative scale setting).  The file csdef.h
        contains #defines for the proper flag settings.

Synopsis
        IGRlong         *msg;           O   return code
                                            MSSUCC on successful completion
                                            MSFAIL on error
                                            MSINARG if abs_rel not set properly
        IGRint           abs_rel;       I   indicates how to alter scale
        GRobjid          cs_id;         I   id of cs in question
        GRspacenum       cs_os;         I   object space number of cs
        IGRdouble        scale[3];      I   scale values
*/

#omdef  cs$set_scale (msg,
                      abs_rel = CS_ABSOLUTE,
                      cs_id = NULL,
                      cs_os = OM_Gw_current_OS,
                      scale)

        GRcsset_scale ((msg), (abs_rel), (cs_id), (cs_os), (scale))
#endomdef

/*
Name
        cs$cvt_to_lcl

Description
        This macro converts world rectangular coordinate system points to
        local coordinates, in the specified coordinate system type.  All
        conversion is actually performed in rectangular coordinates.  If
        no coordinate system is specified, the active coordinate system is
        assumed.

Synopsis
        IGRlong *msg        O   return code
                                MSSUCC success; conversion complete
                                MSFAIL failed conversion
                                MSINARG failed; invalid coordinate system type
                                MANOMEMORY failed to allocate intermediate array
        GRobjid cs_id       I   id of cs to use for the conversion
        GRspacenum cs_os    I   object space number of the cs
        IGRchar *cstype     I   type of coordinates to return
        IGRint npts         I   number of coordinates to convert
        IGRdouble *wld      I   world coordinates
        IGRdouble *lcl      O   local coordinates
*/

#omdef  cs$cvt_to_lcl (msg,
                       cs_id = NULL,
                       cs_os = OM_Gw_current_OS,
                       cstype = "rectangular",
                       npts,
                       wld,
                       lcl)

        GRcscvt_coords ((msg), (0), (cs_id), (cs_os), (cstype),
                        (npts), (lcl), (wld))
#endomdef

/*
Name
        cs$cvt_to_wld

Description
        This macro accepts points in a specified coordinate system type
        and converts them to the rectangular world system.  If no coordinate
        system is specified, the active coordinate system is assumed.

Synopsis
        IGRlong *msg        O   return code
                                MSSUCC success; conversion complete
                                MSFAIL failed conversion
                                MSINARG failed; invalid coordinate system type
                                MANOMEMORY failed to allocate intermediate array
        GRobjid cs_id       I   id of cs in question
        GRspacenum cs_os    I   object space number of cs
        IGRchar *cstype     I   type of coordinates to return
        IGRint npts         I   number of coordinates to convert
        IGRdouble *lcl      I   local coordinates
        IGRdouble *wld      O   world coordinates
*/

#omdef  cs$cvt_to_wld (msg,
                       cs_id = NULL,
                       cs_os = OM_Gw_current_OS,
                       cstype = "rectangular",
                       npts,
                       lcl,
                       wld)

        GRcscvt_coords ((msg), (1), (cs_id), (cs_os), (cstype),
                        (npts), (lcl), (wld))
#endomdef

/*
Name
	cs$change_type

Description
	This macros changes the type of the specified coordinate system.  If no
	coordinate system is specified (NULL), then it changes the active
	coordiante system's type.

Synopsis
	IGRlong		*msg		O  return code
					   MSSUCC - okay
					   MSINARG - invalid type
	GRobjid		cs_id		I  CS objid
	GRspacenum	cs_os		I  CS osnum
	IGRshort   	*type		I  CS type. Defined in csdef.h
	IGRchar     *type_string 	I  CS type string. Defined in csdef.h
*/

#omdef cs$change_type(msg,
                      cs_id = NULL,
                      cs_os = OM_Gw_current_OS,
                      type = NULL,
                      type_string = NULL)

       GRcschange_type((msg), (cs_id), (cs_os), (type), (type_string))
#endomdef


#endif
