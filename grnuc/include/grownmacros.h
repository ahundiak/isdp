/*\
Description
   This include file represents om macros defined for the active owner.
\*/

#ifndef  gractive_owner_macros_include
#define  gractive_owner_macros_include


/*
 *  Defines for the functions that are invoked.
 */

#define  GRGET_ACTIVE_OWNER   0
#define  GRPUT_ACTIVE_OWNER   1
#define  GRCLEAR_ACTIVE_OWNER 2

/*
 *  Macros.
 */

/*\
Name
   gr$get_active_owner

Description
   This macro returns the active owner.

   *msg           IGRlong           Completion code.
   *mod_id        struct GRid       module object id
   *active_owner  struct GRid       The active owner

Notes
   The mod_id may be NULL.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$get_active_owner ( msg,
                             mod_id = NULL,
                             active_owner)

   GRactive_owner_fun ((msg), GRGET_ACTIVE_OWNER, (mod_id), (active_owner))
#endomdef


/*\
Name
   gr$put_active_owner

Description
   This macro defines the active owner.

   *msg           IGRlong           Completion code.
   *mod_id        struct GRid       module object id
   *active_owner  struct GRid       The active owner

Notes
   The mod_id may be NULL.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$put_active_owner ( msg,
                             mod_id = NULL,
                             active_owner)

   GRactive_owner_fun ((msg), GRPUT_ACTIVE_OWNER, (mod_id), (active_owner))
#endomdef

/*\
Name
   gr$clear_active_owner

Description
   This macro clears (i.e. turns off) the active owner.

   *msg           IGRlong           Completion code.
   *mod_id        struct GRid       module object id

Notes
   The mod_id may be NULL.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$clear_active_owner ( msg,
                               mod_id = NULL)

   GRactive_owner_fun ((msg), GRCLEAR_ACTIVE_OWNER, (mod_id), NULL)
#endomdef

/*\
Name
   gr$add_to_active_owner

Description
   This macro adds an object to the active owner.

   *msg           IGRlong           Completion code.
   *mod_env       struct GRmd_env   Object's module environment.
   objid          GRobjid           Object's id
   osnum          GRspacenum        Object's space number

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
#omdef gr$add_to_active_owner ( msg,
                                mod_env,
                                objid = my_id,
                                osnum = OM_Gw_current_OS)

   GRadd_component_to_active_owner ( (msg), (mod_env), (osnum), (objid) )
#endomdef

#endif
