#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "igrdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "dpstruct.h"
#include "lc.h"
#include "lcmsg.h"
#include "lcmacros.h"
#include "grownerdef.h"
#include "msdef.h"
#include "OMmacros.h"

extern unsigned int OM_Gf_verbose_warning;

/*
Name
        GRcomponent_eligibility

Description
        This is a helper function for the locate processing method for
        owners.  It will determine if a component on an owner is
        eligible for locate.

Notes
        The LC_RW and IGN_RW_BIT options are not equivalent, although they
        would seem to be.  LC_RW is used by the command to communicate to the
        graphic object that either a readable or writable object is desired.
        IGN_RW_BIT is used to say that the command wants object irregardless
        of that object's desire to remain unlocatable.  This differentiation
        allows graphic objects the option of remaining unlocatable by all but
        the most insistent commands, which would use the IGN_RW_BIT option.

Synopsis
        IGRlong *msg            < completion code
        struct GRlc_cvl *cvl    > locate structure
        struct GRlc_path path[] > path structure
        IGRint *path_position   > position in the path
        OM_S_OBJID objid        > object id of owner
        OMuword osnum           > osnum of owner
        IGRint properties       > locate properties of owner

Return Values
        FALSE -  components are not eligible
        TRUE  -  components are eligible

History
        Gray Winn   12/15/87    Creation Date
        mrm         07/10/91    declare ALL input args
        mrm         05/07/92    added GRLocInfo
        mrm         06/25/93    reworked read/write checks to equate LC_RW and
                                IGN_RW_BIT
        mrm         07/21/93    reworked above again
        mrm         07/23/93    added option for locating rigid components
        mrm         09/16/93    removed LC_RW/IGN_RW_BIT equation - see Notes
*/

IGRint GRcomponent_eligibility(msg, cvl, path, path_position,
                               objid, osnum, properties)
IGRlong *msg;
struct GRlc_cvl *cvl;
struct GRlc_path path[];
IGRint *path_position;
OM_S_OBJID objid;
OMuword osnum;
IGRint properties;
{
    IGRint passes_owner, passes_read_write = FALSE;
    IGRlong loc_prop;
    unsigned long owner_action;

    *msg = MSSUCC;
    owner_action = cvl->attributes.obj_attr.owner_action;

    /* check specification for owner action */

    passes_owner = 
        (((owner_action & LC_FLEX_COMP) && (properties & GR_LC_FLEXIBLE)) ||
         ((owner_action & LC_RIGID_COMP) && (properties & GR_LC_RIGID)));

    if (passes_owner)
    {
        /*
            If this is a read only operation and I allow this type of
            read operation OR if this is a write operation and I allow
            this type of write operation.  
        */

        loc_prop = cvl->attributes.obj_attr.properties & LC_RW;

        if ((cvl->attributes.type == GR_rp_loc) || 
            (cvl->attributes.type == GR_cv_loc) ||
            (cvl->attributes.type == GR_crit_loc))
        {
            passes_read_write = ((properties & GR_LC_CMP_PRM_WRITE) ||
                                 (loc_prop == IGN_RW_BIT) ||
                                 ((properties & GR_LC_CMP_PRM_READ) &&
                                  (loc_prop & LC_READ_ONLY)));

            if ((!passes_read_write) &&
                (cvl->attributes.type == GR_crit_loc) &&
                (loc_prop & LC_READ_ONLY))
                passes_read_write = TRUE;
            
            /*
             * For read-only purposes, we let intermediate owners go through
             * HGB - 12/10/1992 for EMauto_nester to work.
             */
            if (!passes_read_write)
                if ((owner_action & LC_INTERMEDIATE) &&
                    (loc_prop & LC_READ_ONLY))
                    passes_read_write = TRUE;

            // Allow rigid components for read-only commands that ask for
            // them.  Good for locating only geometric objects.  TR11923927

            if (!passes_read_write && 
                (owner_action & LC_RIGID_COMP_PRISM) &&
                (loc_prop != LC_WRITE_ONLY))
                passes_read_write = TRUE;
        }
        else
        {
            if ((cvl->attributes.type == GR_nam_loc) &&
                (path[*path_position].name_entry))
            {
                passes_read_write = FALSE;
            }
            else
            {
                passes_read_write = ((properties & GR_LC_CMP_WRITE) ||
                                     (loc_prop == IGN_RW_BIT) ||
                                     ((properties & GR_LC_CMP_READ) && 
                                      (loc_prop & LC_READ_ONLY)));
            }
        }
        if (!passes_read_write)
            GRLocInfo(GRObjectIneligible, LC_E_InvOwnerRW, osnum, objid);
    }
    else
        GRLocInfo(GRObjectIneligible, LC_E_InvOwnerRel, osnum, objid);

    return((passes_owner && passes_read_write) ? TRUE : FALSE);
}

/*
Name
	GRowner_eligibility

Description
	This is a helper function for the locate processing method for
        owners.  It will determine the owner is eligible for locate.

Synopsis
        IGRlong *msg            < Completion code
        struct GRlc_cvl *cvl    > Locate structure
        struct GRlc_path path[] > The path structure
        IGRint *path_position   > The position in the path
        OM_S_OBJID objid        > The object id of owner
        OMuword osnum           > The osnum of owner
        IGRint properties       > The locate properties of the owner

Return Values
	FALSE - owner is not eligible
	TRUE - owner is eligible

Notes
        The first four owner_action checks have a long and storied history.
        In the Dark Ages (1987), none of them were there, so no matter what
        the caller asked for, owners would locate.  Around 1990 or 1991, this
        was rectified, but that promptly broke dozens of commands which had
        been written expecting the buggy behavior.  The fix was backed out in
        exchange for the promise that the commands would be changed
        eventually.  A warning print statement was installed here then to help
        identify offending commands.  However, none of the commands were ever
        fixed, and applications began squawking.  After passing the buck
        around for a while, the two ..._WORKS checks were added to give
        applications the functionality they needed.  The warning statements
        were left in place mainly to annoy the command writers into fixing the
        commands, but that will probably never happen now that there is a
        nifty workaround.

History
        Gray Winn   12/15/87    Creation Date 
        mrm         07/10/91    Added rigid/flexible owner checks
        mrm         07/23/91    Print warning but allow locate for owners
                                even if LC_xxx_OWNER not specified - this
                                is to give developers a chance to fix their
                                code.
        mrm         05/07/92    added GRLocInfo
        mrm         06/11/93    added _WORKS checks to work around
                                long-standing bug that allowed owners to
                                always locate
        mrm         09/16/93    removed LC_RW/IGN_RW_BIT equation
        WBC         12/27/93    When calling the action handler to see if an
                                object has been processed, initialize the
                                module info as well as the object id and osnum.
*/


IGRint GRowner_eligibility(msg, cvl, path, path_position,
                           objid, osnum, properties)
IGRlong *msg;
struct GRlc_cvl *cvl;
struct GRlc_path path[];
IGRint *path_position;
OM_S_OBJID objid;
OMuword osnum;
IGRint properties;
{
    IGRshort prop;
    IGRint locate_prop;
    IGRlong sts, object_passed, loc_prop;
    GRclassid classid;
    enum GRlocate_action action;
    struct GRlc_info lc_info;

    *msg = MSSUCC;
    loc_prop = cvl->attributes.obj_attr.properties & LC_RW;

    if ((properties & GR_LC_RIGID) &&
        (cvl->attributes.obj_attr.owner_action & LC_NO_RIGID_OWNER_WORKS))
    {
        GRLocInfo(GRObjectIneligible, LC_E_RigidOwner, osnum, objid);
        return(FALSE);
    }

    if ((properties & GR_LC_FLEXIBLE) &&
        (cvl->attributes.obj_attr.owner_action & LC_NO_FLEX_OWNER_WORKS))
    {
        GRLocInfo(GRObjectIneligible, LC_E_FlexOwner, osnum, objid);
        return(FALSE);
    }

    if ((properties & GR_LC_RIGID) &&
        !(cvl->attributes.obj_attr.owner_action & LC_RIGID_OWNER))
    {
#ifdef THE_WAY_IT_OUGHTTA_BE
        if (OM_Gf_verbose_warning)
            printf("(%d,%d) rejected: rigid owner disallowed by locator\n",
                   osnum, objid);
        GRLocInfo(GRObjectIneligible, LC_E_RigidOwner, osnum, objid);
        return(FALSE);
#else /* leave the bug in place */
        if (OM_Gf_verbose_warning)
            printf
             ("Locating rigid owner (%d,%d), LC_RIGID_OWNER not specified\n", 
              osnum, objid);
#endif
    }

    if ((properties & GR_LC_FLEXIBLE) &&
        !(cvl->attributes.obj_attr.owner_action & LC_FLEX_OWNER))
    {
#ifdef THE_WAY_IT_OUGHTTA_BE
        if (OM_Gf_verbose_warning)
            printf("(%d,%d) rejected: flexible owner disallowed by locator\n",
                   osnum, objid);
        GRLocInfo(GRObjectIneligible, LC_E_FlexOwner, osnum, objid);
        return(FALSE);
#else /* leave the bug in place */
        if (OM_Gf_verbose_warning)
            printf
             ("Locating flexible owner (%d,%d), LC_FLEX_OWNER not specified\n",
              osnum, objid);
#endif
    }

    if ((cvl->attributes.type == GR_rp_loc) || 
        (cvl->attributes.type == GR_cv_loc) ||
        (cvl->attributes.type == GR_crit_loc))
    {
        /* check to see if the object allows himself */

        object_passed = ((properties & GR_LC_OWN_PRM_WRITE) ||
                         (loc_prop == IGN_RW_BIT) ||
                         ((properties & GR_LC_OWN_PRM_READ) &&
                          (loc_prop & LC_READ_ONLY)));

        if (object_passed)
        {
            /* check to see if the object has been proccessed */

            action = check_object;
            lc_info.located_obj.osnum = osnum;
            lc_info.located_obj.objid = objid;
            lc_info.module_info.md_id.objid = cvl->module.md_id.objid;
            lc_info.module_info.md_id.osnum = cvl->module.md_id.osnum;
            lc_info.module_info.md_env.matrix_type = cvl->module.md_env.matrix_type;
            OM_BLOCK_MOVE(cvl->module.md_env.matrix,
                          lc_info.module_info.md_env.matrix,
                          (sizeof(IGRdouble) * 16));

            sts = (*cvl->action_handler)((cvl->act_parms), &lc_info, 
                                         (cvl->locate_args), &action);
   
            object_passed = (sts & 1) ? FALSE : TRUE;
        }
        else 
            GRLocInfo(GRObjectIneligible, LC_E_OwnerProps, osnum, objid);
    }
    else
    {
        if ((cvl->attributes.type == GR_nam_loc) &&
            (!path[*path_position].name_entry))
        {
            object_passed = FALSE;
        }
        else
        {
            /* check to see if the object allows himself */

            object_passed = ((properties & GR_LC_OWN_WRITE) ||
                             (loc_prop == IGN_RW_BIT) ||
                             ((properties & GR_LC_OWN_READ) &&
                              (loc_prop & LC_READ_ONLY)));
        }
    }

    /* if the object passed the first set of criteria continue checking */

    if (object_passed)
    {
        sts = om$get_classid (osnum = osnum,
                              objid = objid, 
                              p_classid = &classid);

        if (sts & 1)
        {
            sts = lc$classchek(rc = msg,
                               classid_to_check = classid,
                               eligible_classes = cvl->classes);

            if (sts & *msg & 1)
            {
                /*
                    This is a KLUDGE for version 1.1.  If the
                    GR_LC_CHECK_PLANAR bit is set then check to see if
                    the owner is planar.  
                */

                if (properties & GR_LC_CHECK_PLANAR)
                {
                    prop = NULL;
                    locate_prop = cvl->attributes.obj_attr.properties &
                        LC_PLANAR_NON_PLANAR;

                    sts = GRcheck_props (&cvl->module.md_env.matrix_type,
                                         cvl->module.md_env.matrix, &objid,
                                         &prop, &locate_prop);
                }

                if (sts & *msg & 1)
                {
                    return(TRUE);
                }
            }
            else
                GRLocInfo(GRObjectIneligible,LC_E_InvOwnerClass,osnum,objid);
        }
    }      
    return(FALSE);
}
