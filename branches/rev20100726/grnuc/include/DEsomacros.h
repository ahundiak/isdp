#ifndef demacros_include
#define demacros_include

#include <sys/types.h>
#include "DEso.h"


                                                                            
/*
   Name
     de$create_soo ( msg,
                     osnum = OM_Gw_current_OS,
                     p_objid = NULL );

     This macro create the soo for osnum.  If that soo already exists
     its objid is returned and nothing gets created.

   Return status: MSSUCC: the soo has bee returned (created)
                  MSFAIL: cannot create the soo

   Argument description :
   --------------------

     ushort osnum       : the os the soo is for				(IN)

     OM_S_OBJID *p_objid: the objid of the soo         			(IN)
                          NULL_OBJID is returned if it failed
*/

#omdef de$create_soo ( msg,
                       p_objid = NULL,
                       osnum = OM_Gw_current_OS )

  DEcreate_soo ( (msg), (p_objid), (osnum) )

#endomdef


/*
Name
    de$place_override ( msg,
                        type = DE_SOE,
                        symbology,
                        u1 = 0.0,
                        u2 = 1.0,
                        go_grid,
                        window_grid,
                        module,
                        interference = 1 )

Abstract
        This macro places a symbology override on the specified object 
        in the specified view of the specified symbology.
                                                                            
Arguments

    long           *msg
        return codes

    int type
        the type of the entry
        
    struct IGRdisplay *symbology
        the weight, style, and color of the override

    double         u1, u2
        the u parms (Must be in the interval 0, 1); note that the default
        will place a total symbology override.

    struct GRid       *go_grid
        the graphic object be overridden

    struct GRid       *window_grid
        the window id of the view to be overridden

    struct GRmd_env   *module
        context of graphic object
        
    int               interference
        check if this override intersects with any other one.  This should
        always 1 unless the calling software can guarantee that the new
        override doesn't intersect.


Example call

    de$place_override( msg = &msg,
                       symbology = &display_struct,
                       go_grid = &located_object,
                       window_grid = &gragad_id,
                       module = &ME.my_command->module );

Status returns

        MSSUCC - success
        MSFAIL - failure

*/

#omdef de$place_override( msg,
                          type = DE_SOE,
                          symbology,
                          u1 = 0.0,
                          u2 = 1.0,
                          go_grid,
                          window_grid,
                          module,
                          interference = 1 )

DEplace_so ( (msg),
             (type),
             (symbology),
             (u1),
             (u2),
             (go_grid),
             (window_grid),
             (module),
             (interference) )

#endomdef


/*
Name
    de$change_override ( msg,
                         old_type = DE_SOE,
                         old_symbology,
                         old_u1 = 0.0,
                         old_u2 = 1.0,
                         old_window_grid,
                         old_module,
                         type = DE_SOE,
                         symbology,
                         u1 = 0.0,
                         u2 = 1.0,
                         go_grid,
                         window_grid,
                         module,
                         interference = 1 )

Abstract
        This macro modifies an existing symbology override on the 
        specified object in the specified view of the specified symbology.
                                                                            
Arguments

    long *msg
        return code

    int old_type
        the old type of the entry

    struct IGRdisplay *old_symbology
        the weight, style, and color of the override

    double old_u1, old_u2
        the (old) u parms (Must be in the interval 0, 1)

    struct GRid *old_window_grid
        the (old) window id of the view with the override

    struct GRmd_env *old_module
        (old) context of graphic object
        
    struct IGRdisplay *symbology
        the weight, style, and color of the override

    double u1, u2
        the u parms (Must be in the interval 0, 1); note that the default
        will place a total symbology override.

    struct GRid *go_grid
        the graphic object be overridden

    struct GRid *window_grid
        the window id of the view to be overridden

    struct GRmd_env *module
        context of graphic object
        
    int interference
        check if this override intersects with any other one.  This should
        always 1 unless the calling software can guarantee that the new
        override doesn't intersect.


Example call

    de$change_override( msg = &msg,
                        old_symbology = &old_display_struct,
                        old_window_grid = &gragad_id,
                        old_module = &ME.my_command->module1,
                        symbology = &display_struct,
                        go_grid = &located_object,
                        window_grid = &gragad_id,
                        module = &ME.my_command->module2 );

Status returns

        MSSUCC - success
        MSFAIL - failure

*/

#omdef de$change_override ( msg,
                            old_type = DE_SOE,
                            old_symbology,
                            old_u1 = 0.0,
                            old_u2 = 1.0,
                            old_window_grid,
                            old_module,
                            type = DE_SOE,
                            symbology,
                            u1 = 0.0,
                            u2 = 1.0,
                            go_grid,
                            window_grid,
                            module,
                            interference = 1 )

DEchange_so ( (msg),
              (old_type),
              (old_symbology),
              (old_u1),
              (old_u2),
              (old_window_grid),
              (old_module),
              (type),
              (symbology),
              (u1),
              (u2),
              (go_grid),
              (window_grid),
              (module),
              (interference) );

#endomdef


/*
Name
    de$lock_view ( msg, view_id )

Abstract
        This macro locks a view for symbology override: the view will ignore
        any override that was placed by software (soe->type & DE_SOFT).
                                                                            
Arguments

    long *msg
        return code: MSSUCC the view was locked, MSFAIL the view couldn't
        be locked (probably overflow).

    GRobjid viewid: The view to lock
*/

#omdef de$lock_view ( mag, viewid )

DElock_view ( (msg), (viewid) )

#endomdef
/*
Name
    de$unlock_view ( msg, viewid )

Abstract
        This macro unlocks a locked view.
                                                                            
Arguments:

    long *msg
        return code: MSSUCC the view was unlocked, MSFAIL the view was not
        locked.

    GRobjid viewid: The view to unlock
*/

#omdef de$unlock_view ( msg, viewid )

DElock_view ( (msg), (viewid) )

#endomdef

/*
Name
    de$delete_override ( msg,
                         symbology,
                         u1 = 0.0,
                         u2 = 1.0,
                         go_grid,
                         window_grid,
                         module )

Abstract
        This macro deletes a symbology override on the specified object 
        in the specified view of the specified symbology.
                                                                            
Arguments

    long              *msg
        return codes

    int               type
        the type of the entry (DE_SOE, ...)

    struct IGRdisplay *symbology
        the weight, style, and color of the override

    double            u1, u2
        the u parms (Must be in the interval 0, 1); note that the default
        will delete a total symbology override.

    struct GRid       *go_grid
        the graphic object

    struct GRid       *window_grid
        the window id

    struct GRmd_env   *module
        context of graphic object


Example call

    de$delete_override( msg = &msg,
                        symbology = 0,
                        go_grid = &located_object,
                        window_grid = &gragad_id,
                        module = &ME.my_command->module );

Status returns

        MSSUCC - success
        MSFAIL - failure

*/

#omdef de$delete_override( msg,
                           type = DE_SOE,
                           symbology,
                           u1 = 0.0,
                           u2 = 1.0,
                           go_grid,
                           window_grid,
                           module )

DEdelete_so ( (msg),
              (type), 
              (symbology),
              (u1),
              (u2),
              (go_grid),
              (window_grid),
              (module) );

#endomdef

/*
Name
    de$delete_by_objid ( msg,
                         osnum = OM_Gw_current_OS,
                         objid )

Abstract
        This macro deletes all the symbology override on the specified object.
                                                                            
Arguments

    long    *msg
        return codes

    uword   osnum
    GRobjid objid
        the graphic object

Example call

    de$delete_by_objid ( msg = &msg, objid = my_id );

Status returns

        MSSUCC - success
        MSFAIL - failure

*/

#omdef de$delete_by_objid ( msg, osnum = OM_Gw_current_OS, objid )

DEdelete_by_objid ( (msg), (osnum), (objid) )

#endomdef


/*
Name
    de$delete_soo_in_view ( msg,
                            go_grid,
                            window_grid,
                            module )

Abstract
        This macro deletes all the symbology override on the specified object
        in the specified view and for the specified context.
                                                                            
Arguments

    long    *msg
        return codes

    struct GRid       *go_grid
        the graphic object

    struct GRid       *window_grid
        the window id (it applies to all windows if not specified).

    struct GRmd_env   *module
        context of graphic object (it applies to all contexts if not specified)

Example call

    de$delete_soo_in_view ( msg = &msg, go_grid = &line_grid )

Status returns

        MSSUCC - success
        MSFAIL - failure

*/

#omdef de$delete_soo_in_view ( msg,
                               go_grid,
                               window_grid = NULL,
                               module )

DEdelete_soo_in_view ( (msg), (go_grid), (window_grid), (module) )

#endomdef


/*
Name
    de$retrieve_override ( msg,
                           p_type = 0,
                           p_u1 = 0,
                           p_u2 = 0,
                           p_symbology,
                           u = 0.0,
                           go_grid,
                           window_grid,
                           module )

Abstract
        This macro retrieves a symbology override for the specified objid.
                                                                            
Arguments

    long             *msg
        return codes

    int              *p_type
        the type of the override

    double           *p_u1, *p_u2
        the u parms of the entry we found
        
    struct GRdisplay *p_symbology
        the symbology of the entry we found

    double           u
        the u parm

    struct GRid      *go_grid
        the graphic object with the override

    struct GRid      *window_grid
        the window id of the view to be overridden

    struct GRmd_env  *module
        context of graphic object.  This argument may be NULL.

Example call

    de$retrieve_override ( msg = &msg,
                           p_symbology = &display_struct,
                           go_grid = &located_object,
                           u = 0.5,
                           window_grid = &gragad_id,
                           module = &ME.my_command->module );

Status returns

        MSSUCC - success
        MSFAIL - failure

*/

#omdef de$retrieve_override ( msg,
                              p_type = 0,
                              p_symbology = 0,
                              p_u1 = 0,
                              p_u2 = 0,
                              go_grid,
                              u = 0.0,
                              window_grid,
                              module )

DEretrieve_so ( (msg),
                (p_type),
                (p_symbology),
                (p_u1),
                (p_u2),
                (go_grid),
                (u),
                (window_grid),
                (module) )
#endomdef


/*
Name
    de$next_override ( msg,
                       p_type = 0,
                       p_u1 = 0,
                       p_u2 = 0,
                       p_symbology )

Abstract
   This macro retrieves the next entry from the soo.  The next entry is
   only defined when we have a 1/0 overlap and it is defined as the twin
   entry, i.e. the other override to complete the overlap.  This message
   is sent right after a retrieve that returned a DE_OVERLAP type.
                                                                            
Arguments

    long             *msg
        return codes

    int              *p_type
        the type of the override

    double           *p_u1, *p_u2
        the u parms of the entry we found
        
    struct GRdisplay *p_symbology
        the symbology of the entry we found


Example call

    de$next_override ( msg = &msg, p_symbology = &display_struct );

Status returns

        MSSUCC - success
        MSFAIL - failure

*/

#omdef de$next_override ( msg,
                          p_type = 0,
                          p_symbology = 0,
                          p_u1 = 0,
                          p_u2 = 0 )

DEnext_so ( (msg),
            (p_type), 
            (p_symbology),
            (p_u1),
            (p_u2) )
#endomdef

/*
   Name
     de$copy_soos ( msg, from, to )

     This macro copies all the override form one window into the other.
   Note that copy is made regardless of the OS: all the override in the
   window are copied, even the ones of reference files.  The from and the
   to view MUST be in the module.

   Return status: MSSUCC: the soos have been copied
                  MSFAIL: cannot copy the soos

   Argument description :
   --------------------

     struct GRid *from: the window to copy from				(IN)
     
     struct GRid *to:   the window to copy to				(IN)
*/

#omdef de$copy_soos ( msg, from, to )

  DEcopy_soo ( (msg), (from), (to) )

#endomdef

/*
   Name
     de$objid_changed ( msg, old, new )

     This macro is called when the objid of an object is about (i.e.
   BEFORE) to change and the software wants to preserve the overrides.
   The osnums MUST be the same.

   Return status: MSSUCC: the soos have been transferred
                  MSFAIL: cannot transfer entries.

   Argument description :
   --------------------

     struct GRid *old: the old grid				(IN)

     struct GRid *old: the new grid				(IN)
*/

#omdef de$objid_changed ( msg, old, new )

  DEobjid_changed ( (msg), (old), (new) )

#endomdef

#endif
