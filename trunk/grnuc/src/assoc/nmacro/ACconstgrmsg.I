/*
Name

    GRdisyourself

Abstract

        This method will create pointers (class EMSpointer) for each
    component object that is subclassed from EMSsubbs if a flag indicates
    this should be done.  The element is then displayed.

Synopsis

        Type                   Name           I/O       Description
 --------------------- ---------------------- --- --------------------------
 IGRlong               *msg                    O  Return code.
 IGRshort              *mx_type                I  Type of matrix.
 IGRmatrix             matrix                  I  Environment matrix of the
                                                  element to be displayed.
 enum GRdpmode         *mode                   I  A mode indicating how the
                                                  element is to be displayed.
 struct IGRaltdisplay  *alt_symb               I  Alternate display
                                                  attributes.
 struct DP_information *sp_info                I  Special display
                                                  information.
 OM_p_KEY_DESC         range_key               I  Element's range key;
                                                  send NULL pointer if it's
                                                  unknown.

Description

        This method displays its object.  This method also checks to
    see if the flag that indicates pointers (and model space counterparts)
    are to be created is set, and if it is then it creates pointers
    (class EMSpointer) for each component of its object, and each of the
    component's components on down to the lowest component, if the component
    is subclassed from EMSsubbs.

Keywords

    display method

History

    06/15/93  :  WBC  :  Creation date.

Justification

        Inherited display method does not handle creation of pointers.
*/

class implementation ACconst;

#define AS_DEBUG

#include "ASmacroi.h"
#include "parametric.h"
#include "macro.h"
#include "grownmacros.h"
#include "grdpbmacros.h"

extern IGRint ASgive_size_st();
extern char *strpbrk();
extern OMuword OPP_GRundo_class_id;

from ACmacro_defn import ACintpt_foot,	ACintpt_foot_dir, 	
		ACgive_feet_desc,	ACgive_upscan, 		
		ACgive_temp_desc,		
	 	ACgive_name,
		ACconstruct_feet,ACcontext_compute_feet;


/* ========================================================================= */

method GRdisyourself(IGRlong *msg; IGRshort *mx_type; 
                     IGRmatrix matrix;  enum GRdpmode *mode;
                     struct IGRaltdisplay *alt_symb; 
                     struct DP_information *sp_info; 
                     OM_p_KEY_DESC range_key)
{
  IGRint            EFmake_pointers();

  IGRlong           OM_stat = OM_S_SUCCESS,
                    temp_msg;
  struct GRid       my_grid;
  IGRboolean        create_ptrs;

  /* create a pointer for each component if they don't already exist */

  gr$get_assoc_ro_reffile(buffer = &create_ptrs);

  if (create_ptrs)
  {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    EFmake_pointers(&temp_msg, &my_grid, FALSE);
  }

  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message ASnode.GRdisyourself(msg, mx_type, 
                                                       matrix, mode,
                                                       alt_symb, sp_info,
                                                       range_key),
                    targetid = my_id);

  return (OM_stat);
}

/*
 * Method :
 *
 *      GRdelete
 *
 * Abstract :
 *
 *      This routine deletes a macro. This override will call the
 *      PDM hooks for delete.
 *
 * Arguments :
 *
 *      *msg        IGRlong         return code.
 *      *mod_env    struct GRmd_env module environment.
 *
 * Return values :
 *
 *      MSSUCC - successful completion
 *
 * History :
 *
 *      Jay Wallingford     10/15/93 Creation.
 *
 */
method GRdelete (IGRlong * msg; struct GRmd_env * mod_env)
{
    IGRlong om_msg = OM_S_SUCCESS;
    struct GRid macro_id;

    *msg = MSSUCC;
    
    /*
     * If this isn't a delete of a dynamic copy ...
     */
    if (mod_env->md_id.objid != NULL_OBJID)
    {
        macro_id.objid = my_id;
        macro_id.osnum = OM_Gw_current_OS;
        
        /*
         * Make sure it's ok with PDM to delete this macro.
         */
        if (!PDMpre_delete (&macro_id, mod_env))
        {
            om_msg = OM_E_ABORT;
        }
    }

    if (om_msg & 1)
    {
        /*
         * Delete the macro.
         */
        om_msg = om$send (msg = message ASnode.GRdelete (msg, mod_env),
                          mode = OM_e_wrt_message,
                          targetid = my_id);

        /*
         * If this isn't a delete of a dynamic copy ...
         */
        if (mod_env->md_id.objid != NULL_OBJID)
        {
            /*
             * Notify PDM that the macro has been deleted.
             */
            PDMpost_delete (&macro_id, mod_env);
        }
    }
    
    return om_msg;
}

/*
 * Method :
 *
 *      GRcopy
 *
 * Abstract :
 *
 *      This method copies a macro to the object space described
 *      in the structure new_dsenv. It will also call the PDM hooks
 *      for copy.
 *
 * Arguments :
 *
 *      *obj_dsenv  GRmd_env      struct describing object's environment
 *      *new_dsenv  GRmd_env      struct describing copy's environment
 *      msg         IGRlong       completion code
 *      *newobjid   GRobjid       objid of the copied object
 *
 * Return Values :
 *
 *      MSSUCC if successful
 *  MSFAIL (severe) if failure
 *
 * History :
 *
 *      Jay Wallingford     10/15/93  Creation data.
 *
 */
method GRcopy (IGRlong *msg;
               struct GRmd_env *obj_dsenv;
               struct GRmd_env *new_dsenv;
               GRobjid * newobjid)
{
    IGRlong             om_msg = OM_S_SUCCESS;
    struct GRid         macro_id;
    
    *msg = MSSUCC;

    macro_id.objid = my_id;
    macro_id.osnum = OM_Gw_current_OS;

    /*
     * If this isn't a dynamic copy ...
     */
    if (new_dsenv->md_id.objid != NULL_OBJID)
    {
        /*
         * Make sure it's ok with PDM to copy the macro.
         */
        if (!PDMpre_copy (&macro_id, obj_dsenv, new_dsenv))
        {
            om_msg = OM_E_ABORT;
        }
    }

    if (om_msg & *msg & 1)
    {
        /* 
         * Copy the macro.
         */
        om_msg = om$send (msg = message ACcpx.GRcopy (msg,
                                                      obj_dsenv,
                                                      new_dsenv,
                                                      newobjid),
                          mode = OM_e_wrt_message,
                          targetid = my_id);

        /*
         * If this isn't a dynamic copy ...
         */
        if ((om_msg & *msg & 1) && (new_dsenv->md_id.objid != NULL_OBJID))
        {
            struct GRid new_macro_id;
            
            new_macro_id.objid = *newobjid;
            new_macro_id.osnum = new_dsenv->md_id.osnum;
            
            /*
             * Notify EDM that the macro has been copied.
             */
            PDMpost_copy (&macro_id, &new_macro_id, obj_dsenv, new_dsenv);
        }
    }

    return om_msg;
}

/*
 * Method :
 *
 *      GRcptform
 *
 * Abstract :
 *
 *      This method copies and transforms a macro to the object space described
 *      in the structure new_dsenv.
 *
 * Arguments :
 *
 *      msg         IGRlong       completion code
 *      *obj_dsenv  GRmd_env      struct describing object's environment
 *      *new_dsenv  GRmd_env      struct describing copy's environment
 *      matrix      IGRmatrix     transformation matrix
 *      *newobjid   GRobjid       objid of the copied object
 *
 * Return Values :
 *
 *      MSSUCC if successful
 *  MSFAIL (severe) if failure
 *
 * History :
 *
 *      Jay Wallingford     10/15/93  Creation data.
 *
 */
method GRcptform(IGRlong         * msg;
                 struct GRmd_env * obj_dsenv;
                 IGRmatrix         matrix;
                 struct GRmd_env * new_dsenv;
                 GRobjid         * newobjid)
{
    IGRlong             om_msg = OM_S_SUCCESS;
    struct GRid         macro_id;
    
    *msg = MSSUCC;

    macro_id.objid = my_id;
    macro_id.osnum = OM_Gw_current_OS;

    /*
     * If this isn't a dynamic copy ...
     */
    if (new_dsenv->md_id.objid != NULL_OBJID)
    {
        /*
         * Make sure it's ok with PDM to copy the macro.
         */
        if (!PDMpre_copy (&macro_id, obj_dsenv, new_dsenv))
        {
            om_msg = OM_E_ABORT;
        }
    }

    if (om_msg & *msg & 1)
    {
        /* 
         * Copy and transform the macro.
         */
        om_msg = om$send (msg = message GRgraphics.GRcptform (msg,
                                                              obj_dsenv,
                                                              matrix,
                                                              new_dsenv,
                                                              newobjid),
                          mode = OM_e_wrt_message,
                          targetid = my_id);

        /*
         * If this isn't a dynamic copy ...
         */
        if ((om_msg & *msg & 1) && (new_dsenv->md_id.objid != NULL_OBJID))
        {
            struct GRid new_macro_id;
            
            new_macro_id.objid = *newobjid;
            new_macro_id.osnum = new_dsenv->md_id.osnum;
            
            /*
             * Notify EDM that the macro has been copied.
             */
            PDMpost_copy (&macro_id, &new_macro_id, obj_dsenv, new_dsenv);
        }
    }

    return om_msg;
}

/*
 * Method :
 *
 *      GRchgname
 *
 * Abstract :
 *
 *      This method changes the name for the element in the current 
 *      directory. The override is intended to stop the object from
 *      being named during a delete for undo if it's a PDM part.
 *
 * Arguments :
 *
 *      *msg              IGRlong            Return code.
 *      name              GRname             Name of the object.
 *
 * Return Values :
 *
 *      MSSUCC  - successful
 *      MSFAIL  - failure
 *
 */
method GRchgname ( IGRlong * msg; 
                   struct GRmd_env * env;
                   IGRchar * name )
{
    IGRint  om_msg = OM_S_SUCCESS;
    struct GRid my_grid;
    
    *msg = MSSUCC;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    /*
     * If this is a PDM part and PDM isn't loaded and this is being done 
     * for undo delete don't allow the name to be changed.
     */
    if (!strncmp(name, ".deleted_", 9) && 
        PDMpart_check(&my_grid) && 
        !PDMloaded())
    {
        goto quit;
    }
    
    om_msg = om$send (msg = message ACncpx.GRchgname (msg, env, name),
                      mode = OM_e_wrt_message,
                      targetid = my_id);

 quit:
    
    return om_msg;
}

/*
 * Method :
 *
 *      GRflexconn
 *
 * Abstract :
 *
 *      This method will connect this macro flexible to an owner.
 *      The override is intended to prevent a PDM macro part from
 *      being connected to the undo object.
 *
 * Arguments :
 *
 *      *msg              IGRlong           Return code
 *      *flag             IGRlong           Flag 
 *      *owners_id        struct GRid       The owners objid, osnum
 *      *owners_index     IGRlong           The index on the flexible
 *                                          owners channel
 *      *graphics_index   IGRlong           The index on the graphics
 *                                          object channel
 * Return Values :
 *
 *      MSSUCC  - successful
 *      MSFAIL  - failure
 */
method GRflexconn ( IGRlong *msg; 
                    IGRlong *flag; 
                    struct GRid *owners_id; 
                    IGRlong *owners_index; 
                    IGRlong *graphics_index )
{
    IGRlong           om_msg = OM_S_SUCCESS;
    struct GRid       macro;
    
    macro.objid = my_id;
    macro.osnum = OM_Gw_current_OS;
    
    /*
     * If this is a PDM part and PDM isn't loaded ...
     */
    if (PDMpart_check(&macro) && !PDMloaded())
    {
        OMuword classid;
        
        if (om$get_classid (objid = owners_id->objid,
                            osnum = owners_id->osnum,
                            p_classid = &classid) & 1)
        {
            /*
             * If this is being done for a delete undo, don't allow it ...
             */
            if (om$is_ancestry_valid (superclassid = OPP_GRundo_class_id,
                                      subclassid = classid) == OM_S_SUCCESS)
            {
                *msg = MSFAIL;
                goto quit;
            }
        }
    }
    
    om_msg = om$send (msg = message GRconnector.GRflexconn (msg, 
                                                            flag, 
                                                            owners_id,
                                                            owners_index,
                                                            graphics_index),
                      mode = OM_e_wrt_message,
                      targetid = my_id);
 quit:
    
    return(om_msg);
}

end implementation ACconst;
