/* #######################    APOGEE COMPILED   ######################## */
class implementation GRpart;

#include <stdio.h>
#include <grimport.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <dpdef.h>
#include <dp.h>
#include <dpmacros.h>
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <msdef.h>
#include <msmacros.h>
#include <partdef.h>
#include <part.h>
#include <partmacros.h>
#include <DItypedef.h>
#include <DIdef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <grmsg.h>

extern OMuword OPP_GRpart_class_id;
extern OMuword OPP_ACconst_class_id;
extern OMuword OPP_nci_macro_class_id;

%safe
IGRboolean PDMallow_delete = FALSE;
IGRint     PDMdload_kludge = 0;
%endsafe

/*
 * Function :
 *
 *     void PDMdload_kludge_func (int x)
 *
 * Abstract :
 *
 *      This routine is used to fix a Sun/SGI dload problem. This problem
 *      occurs when the dloaded stub function has less than 4 instructions.
 *      On the Sun the compiler is smart and figures out when statements
 *      don't really do anything. So to fool it I've declared a global
 *      variable which this function sets. Assuming that the Sun compiler
 *      boys don't go looking accross the executable for reference to 
 *      this global, they shouldn't optimize it out.
 *
 */
void PDMdload_kludge_func (int x)
{
    PDMdload_kludge = x;
}

#define PDMDLOAD_KLUDGE_MACRO(x) PDMdload_kludge_func(((int)OPP_GRpart_class_id)/2+(x))

/*
 * Function : 
 *
 *      PDMloaded
 *
 * Abstract :
 *
 *	    This routine determines whether the PDM system is load or not.
 *
 * Return Values :
 *
 *      TRUE  - PDM is loaded.
 *      FALSE - PDM isn't loaded.
 *
 * History :
 *
 *      Jay Wallingford     7/2/93   Creation data.
 *      jhw                 6/16/94  Added a number of instr to each stub
 *                                   to fix a dload problem.
 *
 */
IGRboolean PDMloaded ()
{
    PDMDLOAD_KLUDGE_MACRO((int)PDMloaded);
    return FALSE;
}


/*
 * Function : 
 *
 *      PDMpart_check
 *
 * Abstract :
 *
 *	    This routine determines whether the input part is an EDM
 *      part or not.
 *
 * Arguments :
 *
 *      *part_id    struct GRid     Part's id.
 *
 * Return Values :
 *
 *      TRUE  - part is EDM part.
 *      FALSE - part isn't EDM part.
 *
 * History :
 *
 *      Jay Wallingford     7/2/93   Creation data.
 *
 */
IGRboolean PDMpart_check (struct GRid * part_id)
{
    IGRlong om_msg, msg = MSSUCC;
    IGRchar buffer[MAX_VALUE];
    OMuword classid;
    
    om_msg = om$get_classid (objid = part_id->objid,
                             osnum = part_id->osnum,
                             p_classid = &classid);
    
    if (!(om_msg & 1))
    {
        goto quit;
    }
    
    if (om$is_ancestry_valid (superclassid = OPP_GRpart_class_id,
                              subclassid = classid) == OM_S_SUCCESS)
    {
        om_msg = co$part_get_attr (msg = &msg,
                                   part = part_id,
                                   attr = "attach_flag",
                                   value = buffer);
    }
    /* 
     * Might be a PDM macro part. 
     *
     * This is not very elegant, but we want to make sure that
     * only PDM macro parts are allowed to pass the part check
     * and without undo influence on the rest of the macro system.
     *
     * At present PDM only allows the following macro classes
     * to be instantiated in their products. It's not possible
     * to do an is_ancestry_valid because ACmodel and ACheader
     * classes are subclasses of ACconst.
     */
    else if ((classid == OPP_ACconst_class_id) ||
             (classid == OPP_nci_macro_class_id))
    {
        IGRchar   macro_name[DI_PATH_MAX];
        IGRchar   macros_dir[DI_PATH_MAX];
        
        /* 
         * Construct path to macro_parts.
         */
        di$give_pathname (osnum = part_id->osnum,
                          pathname = macros_dir);

        strcat(macros_dir, ":PDU:macro_parts");

        om_msg = di$untranslate (objname = macro_name,
                                 path = macros_dir,
                                 objid = part_id->objid,
                                 osnum = part_id->osnum);

        if (om_msg == DIR_S_SUCCESS)
        {
            IGRint    len;
            IGRchar * obj_name;
            GRobjid   objid;
            
            /* 
             * Strip out last ':', if any.
             */
            if (macro_name[(len = strlen(macro_name))-1] == ':')
            {
                macro_name[len-1] = '\0';
            }

            /* 
             * Extract object name.
             */
            obj_name = (IGRchar *)strrchr(macro_name, ':');
            ++obj_name;

            /* 
             * Translate object under macro_parts directory.
             */
            strcat(macros_dir, ":");
            strcat(macros_dir, obj_name);
            om_msg = di$translate (objname = macros_dir,
                                   p_objid = &objid);

            if (om_msg != DIR_S_SUCCESS)
            {
                msg = MSFAIL;
            }
        }
        else
        {
            msg = MSFAIL;
        }
    }
    else
    {
        msg = MSFAIL;
    }
    
 quit:
    
    return (om_msg & msg & 1) ? TRUE : FALSE;
}

/*
 * Function : 
 *
 *      PDMpre_delete
 *
 * Abstract :
 *
 *	    This routine before a part is deleted to make sure it's ok
 *      to delete the part.
 *
 * Arguments :
 *
 *      *part_id    struct GRid Part's id.
 *
 * Return Values :
 *
 *      TRUE  - ok to delete part.
 *      FALSE - not ok to delete part.
 *
 * History :
 *
 *      Jay Wallingford     7/2/93   Creation data.
 *
 */
#argsused
IGRboolean PDMpre_delete (struct GRid     * part_id,
                          struct GRmd_env * mod_env)
{
    /*
     * If the PDMallow_delete flag isn't set..
     */
    if (!PDMallow_delete)
    {
        /*
         * If PDM isn't loaded and this is a PDM part, don't
         * allow it to be deleted.
         */
        if (!PDMloaded() && PDMpart_check(part_id))
        {
            /*
             * If this is a displayable module ...
             */
            if (!(ex$is_invis(mod_osnum = part_id->osnum)))
            {
                IGRlong         ok;
                IGRint          in, out;
                struct GRid     mod_id;
                struct GRmd_env disp_env;
                enum GRdpmode   dpmode;

                /*
                 * Issue error message stating that PDM parts cannot be
                 * deleted in EMS.
                 */
                ex$message (msgnumb = GR_E_PDMPrtNoDel);
             
                sleep(1);

                /*
                 * Redisplay the part.
                 */
                ex$get_cur_mod (id = &mod_id.objid, osnum = &mod_id.osnum);

                in = sizeof(disp_env);
                gr$get_display_env (msg = &ok,
                                    sizbuf = &in,
                                    buffer = &disp_env,
                                    nret = &out);
                dpmode = GRbd;
                om$send (msg = message GRgraphics.GRdisplay 
                                           (&ok,
                                            &disp_env.md_env.matrix_type,
                                            disp_env.md_env.matrix,
                                            &dpmode,
                                            &mod_id),
                         senderid = NULL_OBJID,
                         targetid = part_id->objid,
                         targetos = part_id->osnum);
            }
        
            return FALSE;
        }
    }

    return TRUE;
}

/*
 * Function : 
 *
 *      PDMpost_delete
 *
 * Abstract :
 *
 *	    This routine is after a part has been deleted. It serves to
 *      notify the EDM application that the part has been deleted.
 *
 * Arguments :
 *
 *      *part_id    struct GRid Part's id.
 *
 * History :
 *
 *      Jay Wallingford     7/2/93   Creation data.
 *
 */
#argsused
void PDMpost_delete (struct GRid     * part_id,
                     struct GRmd_env * mod_env)
{
    PDMDLOAD_KLUDGE_MACRO((int)PDMpost_delete);
    return;
}

/*
 * Function : 
 *
 *      PDMpre_copy
 *
 * Abstract :
 *
 *	    This routine is called before a part is copied to make sure it's 
 *      ok to copy it.
 *
 * Arguments :
 *
 *      *part_id    struct GRid         Part's id.
 *      *from_env   struct GRmd_env     From environment
 *      *to_env     struct GRmd_env     To environment
 *
 * Return Values :
 *
 *      TRUE  - ok to copy part.
 *      FALSE - not ok to copy part.
 *
 * History :
 *
 *      Jay Wallingford     7/2/93   Creation data.
 *
 */
#argsused
IGRboolean PDMpre_copy (struct GRid     * part_id,
                        struct GRmd_env * from_env,
                        struct GRmd_env * to_env)
{
    PDMDLOAD_KLUDGE_MACRO((int)PDMpre_copy);

    /*
     * Allow a PDM part to be copied but the PDMpost_copy will
     * drop it.
     */
    return TRUE;
}

/*
 * Function : 
 *
 *      PDMpost_copy
 *
 * Abstract :
 *
 *	    This routine is called after a part has been copy. It 
 *      serves to notify the EDM application that the part has 
 *      been copied.
 *
 * Arguments :
 *
 *      *part_id        struct GRid     Part's id.
 *      *new_part_id    struct GRid New Part's id.
 *      *from_env       struct GRmd_env From environment.
 *      *to_env         struct GRmd_env To environment.
 *
 * History :
 *
 *      Jay Wallingford     7/2/93   Creation data.
 *
 */
#argsused
void PDMpost_copy (struct GRid     * part_id,
                   struct GRid     * new_part_id,
                   struct GRmd_env * from_env,
                   struct GRmd_env * to_env)
{   
    /*
     * If PDM isn't loaded and this is a PDM part, drop
     * the part to it's graphics.
     */
    if (!PDMloaded() && PDMpart_check(new_part_id))
    {
        IGRlong ok;
        OMuword classid;
        
        /*
         * If this is a GRpart drop the copy to it's graphic
         * components. There is no need to drop a macro part
         * to it's graphics since it is converted into a root
         * macro when copied by the macro code.
         */
        om$get_classid (objid = new_part_id->objid,
                        osnum = new_part_id->osnum,
                        p_classid = &classid);
        
        if (om$is_ancestry_valid (superclassid = OPP_GRpart_class_id,
                                  subclassid = classid) == OM_S_SUCCESS)
        {
            PDMallow_delete = TRUE;
        
            om$send (msg = message GRowner.GRdrop (&ok, to_env),
                     senderid = NULL_OBJID,
                     targetid = new_part_id->objid,
                     targetos = new_part_id->osnum);

            PDMallow_delete = FALSE;
        }
    }
    
    return;
}

/*
 * Function : 
 *
 *      PDMsetup_reffile_display
 *
 * Abstract :
 *
 *	    This routine is called from the wake method of the master file's
 *      Super_rfmgr object. PDM may dynamically override this function 
 *      and invoke specific behavior, by default this function does 
 *      nothing.
 *
 * Arguments :
 *
 *      *rfmgr_id       struct GRid     Reference file manager's id.
 *
 * History :
 *
 *      Jay Wallingford     7/2/93   Creation data.
 *
 */
void PDMsetup_reffile_display ()
{   
    PDMDLOAD_KLUDGE_MACRO((int)PDMsetup_reffile_display);
    return;
}

/*
 * Function : 
 *
 *      PDMset_reffile_display
 *
 * Abstract :
 *
 *	    This routine is called from the GRrfinit method of reference
 *      files. It may be used by PDM to change either the display
 *      or loaded behavior of the reference file that is being
 *      initialized. By default the reference file isn't updated.
 *
 * Input :
 *
 *      construct       IGRboolean      Is reffile being constructed?
 *      mount_name      IGRchar *       Reffile full path name.
 *      *ref_id         struct GRid     Reference file's id.
 *      *context_id     struct GRid     Context object for the file.
 *      depth           IGRulong        BOM depth.
 *      *displayed      IGRboolean      Is reffile displayed?
 *      *loaded         IGRboolean      Is reffile loaded?
 *
 * Output:
 *
 *      *displayed      IGRboolean      Should reffile be displayed?
 *      *loaded         IGRboolean      Should reffile be loaded?
 *
 * Return Values:
 *
 *      TRUE    Update the reffile based on the loaded, displayed flags.
 *      FALSE   Don't update the reffile.
 *
 * History :
 *
 *      Jay Wallingford     7/2/93   Creation data.
 *      jhw                 9/20/93  Modified argument list.
 *
 */
#argsused
IGRboolean PDMset_reffile_display (IGRboolean    construct,
                                   IGRchar     * mount_name,
                                   struct GRid * ref_id,
                                   struct GRid * context_id,
                                   IGRulong      depth,
                                   IGRboolean  * displayed,
                                   IGRboolean  * loaded)
{
    PDMDLOAD_KLUDGE_MACRO((int)PDMset_reffile_display);
    return FALSE;
}

end implementation GRpart;














