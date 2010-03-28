/*
Name
        COgenset

Description
        This code drives the Generate Set command.

History
        mrm     01/08/91    creation
        jjm     02/18/92    changed linestyle form to 2.0 form;
        scw     05/01/92    added code to check for sub-forms in the
                            execute method;
        dhm     06/19/92    added code to handle layer sub-form
        scw     07/10/92    ansi conversion
        elp     01/12/93    port to NT.  reset color, weight, style, and
                            layer buttons to off state when main form is
                            dismissed.  I did this because when the main
                            form is displayed it will enter a modal loop
                            and will not exit the loop until it has been
                            erased.  Returning from the display the subforms
                            are displayed if the corresponding button state
                            is on.
        mrm     02/02/93    added function to delete forms, to be used during
                            a save so the journal file will sync up
        scw     08/09/94    clarified the sleep method
*/

class implementation COgenset;

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#if defined( NT )
#  ifndef alloca
#    define alloca _alloca
#  endif
#else
#  include <alloca.h>
#endif
#include "OMmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "csmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "griodef.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "exmacros.h"
#include "godef.h"
#include "ex.h"
#include "exmacros.h"
#include "execmsg.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "lydef.h"
#include "grpgendef.h"
#include "grpgen.h"
#include "adpdef.h"
#include "grgsdef.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "dpdls.h"

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0  /* because opp can not handle it */
#  if defined( X11 )
#    include <XFIproto_pub.h>
#  elif defined( ENV5 )
#    include <FIproto_pub.h>
#  elif defined( NT )
#    include <shampub.h>
#  endif
#else
#  include <FI.h>
#endif
#else
#  include <FI.h>
#endif

from GRgsmgr import GRget_prism_extents, GRget_prism, GRget_prism_size;
from GRgrset import GSstart_transition, GSend_transition;

extern IGRint COsymbology_action();
extern IGRint GRchg_adp_line_weight();
extern IGRint GRnumber_conversion(), GRcolor_conversion();
extern IGRushort dp_bit_pattern[MAX_STYLES];

#define OUTSIDE         0
#define INSIDE          1
#define MAX_WINDOWS     40
#define MAX_WIN_NAME    128

%safe
static IGRshort num_colors = 0;
static Form genset_form = NULL;
static Form color_form = NULL;
static Form weight_form = NULL;
static Form style_form = NULL;
static Form layer_form = NULL;
static struct COgenset_info *genset_info = NULL;
static int list_id = -1;
static char *win_names, *win_ptrs[MAX_WINDOWS];
%endsafe

/*
Name
        COdelete_genset_forms

Description
        This function deletes the forms used by the genset command.  These
        forms are normally not deleted between command invocations for
        efficiency reasons, but they need to be deleted during any save
        operation so that the new journal file syncs up its window pointers
        correctly.  This function is invoked from GRdpb.sleep.

History
        mrm     02/02/93    creation
*/

void COdelete_genset_forms()
{
    if (genset_form)
    {
        FIf_delete(genset_form);
        genset_form = NULL;
    }
    if (color_form)
    {
        FIf_delete(color_form);
        genset_form = NULL;
    }
    if (weight_form)
    {
        FIf_delete(weight_form);
        genset_form = NULL;
    }
    if (style_form)
    {
        FIf_delete(style_form);
        genset_form = NULL;
    }
    if (layer_form)
    {
        FIf_delete(layer_form);
        genset_form = NULL;
    }
}

int COgenset_generate(form, grset, grset_mod, obj_count, mod_count)
Form form;
OM_S_OBJID *grset;
struct GRmd_env *grset_mod;
IGRint *obj_count, *mod_count;
{
    IGRuchar color_mask[COLOR_MASK_SIZE];
    IGRuchar style_mask[STYLE_MASK_SIZE];
    IGRuchar weight_mask[WEIGHT_MASK_SIZE];
    OMuword *rtree_classids, *eligible_classids;
    IGRlong msg;
    IGRint criteria_flag, addfence = FALSE;
    IGRint sts, ii, jj, state, rel, symbset = 0;
    IGRint in_state, out_state, ovl_state, clip_state;
    IGRint usedfence = FALSE, in_out;
    IGRint type, size;
    IGRint layers[LAYER_MASK_SIZE];
    IGRchar *prism = NULL, buf[BUFSIZ];
    IGRdouble vw_volume[6];
    IGRdouble prism_points[15];  /* five points for the prism */
    OM_S_OBJID fence = NULL_OBJID;
    OM_S_CLASSLIST rtree_classes, eligible_classes;
    struct IGRrt_prism *right_prism;
    struct GRid window, fngrid;
    struct var_list vlist[2];
    struct GRmd_env mod, locmod;
    struct COgenset_info *info;
    struct GRelclass_f *original_dpb = NULL;
#ifdef V200
    struct GRlc_criteria criteria;
#endif
    struct GRlc_classes classinfo;
    struct GRlc_locate attributes;
    struct COsymbact symbact;
    
    sts = MSSUCC;
    *obj_count = 0;
    *mod_count = 0;

    gr$get_module_env(buffer = &mod);
    ex$message(msgnumb = GR_I_Working, buff = buf);
    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);

    /* get the pointer to this form's data */

    FIf_get_user_pointer(form, (char **) &info);

    if (info->classlist_changed)
    {
        /* save the current dpb settings and substitute the local values */

        ii = sizeof(struct GRelclass_f) * info->elclass_count;
        original_dpb = (struct GRelclass_f *) alloca( ii );
        vlist[0].var = DPB_GET_CLASSES;
        vlist[0].var_ptr = (IGRchar *)original_dpb;
        vlist[1].var = END_PARAM;
        gr$set_inq(msg = &msg, var_list = vlist);
        vlist[0].var = DPB_SET_PROPERTIES;
        vlist[0].var_ptr = (IGRchar *)info->elclass;
        gr$set_inq(msg = &msg, var_list = vlist, set_inq = DPB_SET);
    }

    /* figure out what volume to search (fence, window, or file) */

    FIg_get_state(form, FENCE_CHECK, &state);

    if (state)
    {
        usedfence = TRUE;

        /* fence selected - make sure one is around */

        sts = gr$gsget_fence (msg = &msg, fence_id = &fngrid);

        if (!(sts & msg & 1))
        {
            ex$message(msgnumb = GR_F_NoActFncDfn);
            goto finish;
        }

        fence = fngrid.objid;

        /* find out how much memory the fence prism requires */

        sts = om$send (msg = message GRgsmgr.GRget_prism_size
                            (&msg, &mod, &type, &size,
                             NULL, NULL, NULL, NULL),
                       senderid = NULL_OBJID,
                       targetid = fence,
                       targetos = mod.md_id.osnum);

        if (!(sts & msg & 1)) goto finish;

        /* allocate the memory */

        prism = (IGRchar *) alloca( size );

        /* get a prism from the active fence */

        sts = om$send (msg = message GRgsmgr.GRget_prism
                            (&msg, &mod, FALSE, prism, &window),
                       senderid = NULL_OBJID,
                       targetid = fence,
                       targetos = mod.md_id.osnum);

        if (!(sts & msg & 1)) goto finish;

        /* check the check (har-har) boxes for desired prism relationship */

        rel = 0;
        FIg_get_state(form, IN_CHECK, &in_state);
        FIg_get_state(form, OUT_CHECK, &out_state);
        FIg_get_state(form, OVL_CHECK, &ovl_state);
        FIg_get_state(form, CLIP_CHECK, &clip_state);
        if (in_state)
        {
            in_out = INSIDE;
            symbact.rp_relation = GO_INSIDE;
            if (ovl_state)
            {
                rel = GO_INSIDE | GO_OVERLAP;
                symbact.rp_relation |= GO_OVERLAP;
            }
            else if (clip_state)
            {
                rel = TRUE_REL;
                symbact.rp_relation |= GO_OVERLAP;
            }
            else
            {
                rel = GO_INSIDE;
                addfence = TRUE;
            }
        }
        else if (out_state)
        {
            in_out = OUTSIDE;
            symbact.rp_relation = GO_OUTSIDE;
            if (ovl_state)
            {
                rel = GO_OUTSIDE | GO_OVERLAP;
                symbact.rp_relation |= GO_OVERLAP;
            }
            else if (clip_state)
            {
                rel = TRUE_REL;
                symbact.rp_relation |= GO_OVERLAP;

            }
            else
            {
                rel = GO_OUTSIDE;
                addfence = TRUE;
            }
        }
        else /* assume overlap */
        {
            rel = GO_OVERLAP;
            symbact.rp_relation = GO_OVERLAP;
            in_out = INSIDE;
        }
    }
    else
    {
        FIg_get_state(form, WINDOW_CHECK, &state);

        if (state)
        {
            /* window selected - make sure the name displayed is valid */

            FIfld_get_text(form, WINDOW_FIELD, 0, 0, BUFSIZ,
                           (unsigned char *) buf, &ii, &jj );
            sts = dp$get_gragad_id(msg = &msg,
                                   name = buf,
                                   array_size = 1,
                                   total_num = &ii,
                                   numberofids = &jj,
                                   found_GRids = &window);
            if (!(sts & msg & 1) || (ii == 0))
            {
                ex$message(msgnumb = GR_E_WinNotFnd);
                goto finish;
            }
            else if (ii > 1)
            {
                ex$message(msgnumb = GR_E_AmbNme);
                goto finish;
            }

            prism = (IGRchar *) alloca( sizeof( struct IGRrt_prism ) );
            right_prism = (struct IGRrt_prism *) prism;
            type = GR_RIGHT_PRISM;

            sts = GRbuild_prism_helper(&msg, &window, NULL, vw_volume, NULL,
                                       NULL, NULL, right_prism->matrix, NULL,
                                       &right_prism->height);

            /* build the polyline that represents the clip polygon */

            vw_volume[3] -= vw_volume[0];
            vw_volume[4] -= vw_volume[1];
            vw_volume[5] -= vw_volume[2];
            vw_volume[0] = 0.0;
            vw_volume[1] = 0.0;
            vw_volume[2] = 0.0;
            right_prism->polygon.num_points = 5;
            right_prism->polygon.points = prism_points;
            prism_points[0] = prism_points[12] = 0.0;
            prism_points[1] = prism_points[13] = 0.0;
            prism_points[2] = prism_points[14] = 0.0;
            prism_points[3] = 0.0;
            prism_points[4] = vw_volume[4];
            prism_points[5] = 0.0;
            prism_points[6] = vw_volume[3];
            prism_points[7] = vw_volume[4];
            prism_points[8] = 0.0;
            prism_points[9] = vw_volume[3];
            prism_points[10] = 0.0;
            prism_points[11] = 0.0;

            /* check the desired prism relationship */

            FIg_get_state(form, IN_CHECK, &in_state);
            FIg_get_state(form, OUT_CHECK, &out_state);
            FIg_get_state(form, OVL_CHECK, &ovl_state);
            if (in_state)
            {
                in_out = INSIDE;
                rel = GO_INSIDE;
                symbact.rp_relation = GO_INSIDE;
                if (ovl_state)
                {
                    rel |= GO_OVERLAP;
                    symbact.rp_relation |= GO_OVERLAP;
                }
            }
            else if (out_state)
            {
                in_out = OUTSIDE;
                rel = GO_OUTSIDE;
                symbact.rp_relation = GO_OUTSIDE;
                if (ovl_state)
                {
                    rel |= GO_OVERLAP;
                    symbact.rp_relation |= GO_OVERLAP;
                }
            }
            else /* assume overlap */
            {
                in_out = INSIDE;
                rel = GO_OVERLAP;
                symbact.rp_relation = GO_OVERLAP;
            }
        }
        else
        {
            /* assume entire design file */

            window.objid = NULL_OBJID;
            window.osnum = mod.md_id.osnum;
            prism = (IGRchar *) alloca( sizeof( struct IGRrt_prism ) );
            right_prism = (struct IGRrt_prism *) prism;
            type = GR_RIGHT_PRISM;
            rel = GO_INSIDE | GO_OVERLAP;
            symbact.rp_relation = GO_INSIDE | GO_OVERLAP;
            in_out = INSIDE;
            MAidmx(&msg, right_prism->matrix);
            right_prism->matrix[11] = GRDGNLIMITS_MIN_D;
            right_prism->height = GRDGNLIMITS_MAX_D - GRDGNLIMITS_MIN_D;
            right_prism->polygon.num_points = 5;
            right_prism->polygon.points = prism_points;
            prism_points[0] = prism_points[12] = GRDGNLIMITS_MIN_D;
            prism_points[1] = prism_points[13] = GRDGNLIMITS_MIN_D;
            prism_points[2] = prism_points[14] = 0;
            prism_points[3] = GRDGNLIMITS_MIN_D;
            prism_points[4] = GRDGNLIMITS_MAX_D;
            prism_points[5] = 0;
            prism_points[6] = GRDGNLIMITS_MAX_D;
            prism_points[7] = GRDGNLIMITS_MAX_D;
            prism_points[8] = 0;
            prism_points[9] = GRDGNLIMITS_MAX_D;
            prism_points[10] = GRDGNLIMITS_MIN_D;
            prism_points[11] = 0;
        }
    }

    /* set up color, style, and weight */

    FIfld_get_text(form, COLOR_FIELD, 0, 0, BUFSIZ, (unsigned char *) buf,
                   &ii, &jj );
    if (! COall(buf))
    {
        sts = GRparse_multiple_entry_keyin(buf, color_mask, GRcolor_conversion,
                                           TRUE, LO_COLOR, HI_COLOR,
                                           mod.md_id.osnum);
        if (sts & 1)
        {
            symbset |= COLOR_DEFINED;
        }
        else
        {
            ex$message(msgnumb = GR_E_InvCo, buff = buf);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
            /*
             * Removed sequencing code that used to be here because 
	     * journalling will not support it.  Shelley Heard 4/10/93
             */    
            goto finish;
        }
    }

    FIfld_get_text(form, WEIGHT_FIELD, 0, 0, BUFSIZ, (unsigned char *) buf,
                   &ii, &jj );
    if (! COall (buf))
    {
        sts = GRparse_multiple_entry_keyin(buf, weight_mask,
                                           GRnumber_conversion, FALSE,
					   LO_WEIGHT, HI_WEIGHT,
                                           mod.md_id.osnum);
        if (sts & 1)
        {
            symbset |= WEIGHT_DEFINED;
        }
        else
        {
            ex$message(msgnumb = GR_E_InvWt, buff = buf);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
            /*
             * Removed sequencing code that used to be here because 
	     * journalling will not support it.  Shelley Heard 4/10/93
             */    
            goto finish;
        }
    }

    FIfld_get_text(form, STYLE_FIELD, 0, 0, BUFSIZ, (unsigned char *) buf,
                   &ii, &jj );
    if (! COall(buf))
    {
        sts = GRparse_multiple_entry_keyin(buf, style_mask, GRnumber_conversion,
                                           FALSE, LO_STYLE, HI_STYLE,
                                           mod.md_id.osnum);
        if (sts & 1)
        {
            symbset |= STYLE_DEFINED;
        }
        else
        {
            ex$message(msgnumb = GR_E_InvSt, buff = buf);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
            /*
             * Removed sequencing code that used to be here because 
	     * journalling will not support it.  Shelley Heard 4/10/93
             */    
            goto finish;
        }
    }

    /* set up layers */

    FIfld_get_text(form, LAYER_FLD, 0, 0, BUFSIZ, (unsigned char *) buf,
                   &ii, &jj );
    if (!COlykytomask(&msg, &mod, buf, layers))
    {
        ex$message(msgnumb = GR_E_InvLy, buff = buf);
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
        /*
         * Removed sequencing code that used to be here because 
	 * journalling will not support it.  Shelley Heard 4/10/93
         */    
        goto finish;
    }

#ifdef V200
    /* set up action handler */

    gr$init_prismact(prismact = &symbact.prismact,
                     mod = &mod,
                     prism = prism,
                     prism_type = type,
                     prism_rel = rel);

    symbact.symb_set = symbset;
    symbact.color_bitmask = color_mask;
    symbact.style_bitmask = style_mask;
    symbact.weight_bitmask = weight_mask;

    /* set up locate criteria */

    sts = LCretrieve_criteria(&msg, &criteria.regex, &criteria.display_flag,
                              &criteria.hilite_mode, &criteria.unhilite_mode,
                              &criteria.attributes, &criteria.nclasslists,
                              criteria.classlist, criteria.classids,
                              &criteria.rtree_classes,
                              criteria.rtree_classids);
    if (sts & 1)
    {
        classinfo.nclasslists = criteria.nclasslists;
        classinfo.eligible_classes = criteria.classlist;
        classinfo.rtree_classes = &criteria.rtree_classes;
        addfence = usedfence && !(criteria.display_flag & LC_EXCLUDE_FENCE);
    }
    else
    {
        /* set up default criteria */

        rel |= GR_APPLY_CRITERIA;
        criteria.classlist[0].w_count = 1;
        criteria.classlist[0].w_flags = OM_CLST_subclass;
        criteria.classlist[0].p_classes = &OPP_GRgraphics_class_id;
        classinfo.nclasslists = 1;
        classinfo.eligible_classes = criteria.classlist;
        classinfo.rtree_classes = criteria.classlist;
        criteria.attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP;
        criteria.attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                         IGN_PLANAR_BIT;
    }

    /* invoke a prism locate */

    sts = gr$prism_locate(msg = &msg,
                          mod = &mod,
                          window_id = window.objid,
                          window_os = window.osnum,
                          attributes = &criteria.attributes,
                          classinfo = &classinfo, 
                          prism_type = type, 
                          prism = prism,
                          prism_rel = rel, 
                          inside_outside = TRUE,
                          layers = layers, 
                          action_handler = COsymbology_action, 
                          action_args = &symbact);
/*
    sts = GRprism_locate(&msg, &mod, window.objid, window.osnum,
                          &criteria.attributes, &classinfo, type, prism, rel,
                          1, layers, COsymbology_action, &symbact,
                          NULL, NULL, NULL);
*/

    if (!(sts & msg & 1))
    {
#ifdef DEBUG
        printf("COgenset: gr$prism_locate failed\n");
#endif
        goto finish;
    }

    if (symbact.prismact.top_gs != NULL_OBJID)
    {
        /*  always treat the fence object itself as part of the
            desired set, so add it the graphic set if it is not
            already there, unless the locate criteria of a stacked
            command excludes it */

        if (addfence && fence != NULL_OBJID)
        {
            stupid_grid.objid = symbact.prismact.top_gs;
            stupid_grid.osnum = mod.md_id.osnum;

            sts = om$send(msg = DImember$DIadd
                               (&msg, NULL, &stupid_grid, OM_K_MAXINT, NULL),
                           senderid = NULL_OBJID,
                           targetid = fence,
                           targetos = mod.md_id.osnum);

            (*obj_count)++;
        }

        if (*grset != NULL_OBJID)
        {
            /* check whether the set needs to be intersected with another */

            newset = NULL_OBJID;
            FIg_get_state(form, INTERSECT_CHECK, &state);
            if (state)
            {
                sts = om$send(msg = GRset$GRand
                                   (&msg, symbact.prismact.top_gs,
                                     symbact.prismact.top_os, &newset),
                               senderid = NULL_OBJID,
                               targetid = *grset,
                               targetos = grset_mod->md_id.osnum);

                if (sts & msg & 1) symbact.prismact.top_gs = newset;
            }
            else
            {
                /* check whether the set needs to be unioned with another */

                FIg_get_state(form, UNION_CHECK, &state);
                if (state)
                {
                    sts = om$send(msg = GRset$GRor
                                       (&msg, symbact.prismact.top_gs,
                                         symbact.prismact.top_os, NULL),
                                   senderid = NULL_OBJID,
                                   targetid = *grset,
                                   targetos = grset_mod->md_id.osnum);

                    if (sts & msg & 1) symbact.prismact.top_gs = *grset;
                }
            }
        }

        /* set output arguments */

        *grset = symbact.prismact.top_gs;
        *grset_mod = mod;
        *obj_count = symbact.prismact.obj_count;
        *mod_count = symbact.prismact.mod_count;

    }
    else
    {
        *grset = NULL_OBJID;
        *grset_mod = mod;
        *obj_count = 0;
        *mod_count = 0;
    }

#else

    /* construct a graphic set */

    symbact.gs_id.osnum = mod.md_id.osnum;

    sts = gr$gsinit(msg = &msg,
                    flag = 2,   /* indicates select set */
		    osnum = mod.md_id.osnum,
                    senderid = NULL_OBJID,
		    p_objid = &symbact.gs_id.objid);

    if (!(sts & msg & 1))
    {
#ifdef DEBUG
        printf("COgenset_generate: gr$gsinit failed: %#x, %#x\n", sts, msg);
#endif
        goto finish;
    }

    /* start transition for the graphic set */

    ii = 0;  /* no properties */

    sts = om$send(msg = message GRgrset.GSstart_transition
                       (&msg, &mod, &ii, NULL, &symbact.sv_id),
                  senderid = NULL_OBJID,
                  targetid = symbact.gs_id.objid,
                  targetos = symbact.gs_id.osnum);

    if (!(sts & msg & 1))
    {
#ifdef DEBUG
        printf("COgenset_generate: GSstart_transition: %#x, %#x\n", sts, msg);
#endif
        goto finish;
    }

    /* retrieve the previous command's locate criteria */

    sts = gr$gsget_locate_criteria(msg = &msg,
                                   criteria_flag = &criteria_flag,
                                   locate_env = &locmod,
                                   attributes = &attributes,
                                   rtree_classes = &rtree_classes,
                                   eligible_classes = &eligible_classes);

    if (!(criteria_flag & GSPUT_LOCATE_ENV)) locmod = mod;

    if (!(criteria_flag & GSPUT_ATTRIBUTES))
    {
        /* assign defaults */
        attributes.properties = LC_LC_ONLY | LC_RW | LC_DP_ONLY;
        attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP;
    }

    if (criteria_flag & GSPUT_RTREE_CLASSES)
    {
        /* copy the classids to local memory */
        ii = sizeof(OMuword) * rtree_classes.w_count;
        rtree_classids = (OMuword *) alloca( ii );
        OM_BLOCK_MOVE(rtree_classes.p_classes,rtree_classids,ii);
    }
    else
    {
        /* assign defaults */
        rtree_classids = (OMuword *) alloca( sizeof( OMuword ) );
        rtree_classids[0] = OPP_GRgraphics_class_id;
        rtree_classes.w_count = 1;
        rtree_classes.w_flags = OM_CLST_subclass;
    }
    rtree_classes.p_classes = rtree_classids;

    if (criteria_flag & GSPUT_ELIGIBLE_CLASSES)
    {
        /* copy the classids to local memory */
        ii = sizeof(OMuword) * eligible_classes.w_count;
        eligible_classids = (OMuword *) alloca( ii );
        OM_BLOCK_MOVE(eligible_classes.p_classes,eligible_classids,ii);
    }
    else
    {
        /* assign defaults */
        eligible_classids = (OMuword *) alloca( sizeof( OMuword ) );
        eligible_classids[0] = OPP_GRgraphics_class_id;
        eligible_classes.w_count = 1;
        eligible_classes.w_flags = OM_CLST_subclass;
    }
    eligible_classes.p_classes = eligible_classids;

    classinfo.rtree_classes = &rtree_classes;
    classinfo.eligible_classes = &eligible_classes;

    /* set up the action handler information */

    symbact.clip_flag = (rel & (FC_OUTSIDE_CLIP | FC_OUTSIDE_CLIP))?TRUE:FALSE;
    symbact.symb_set = symbset;
    symbact.color = color_mask;
    symbact.style = style_mask;
    symbact.weight = weight_mask;

    /* invoke a prism locate */

    sts = gr$gsprism_locate(msg = &msg,
                            mod_env = &locmod,
                            window_id = &window,
                            attributes = &attributes,
                            classinfo = &classinfo,
                            prism_type = type,
                            prism = prism,
                            prism_attr = rel,
                            inside_outside = in_out,
                            layers = layers,
                            action_handler = COsymbology_action,
                            action_args = &symbact);
    if (!(sts & msg & 1))
    {
#ifdef DEBUG
        printf("COgenset: gr$gsprism_locate failed\n");
#endif
        goto finish;
    }

    /* end the transition for the graphic set */

    sts = om$send(msg = message GRgrset.GSend_transition (&msg, NULL),
                  senderid = NULL_OBJID,
                  targetid = symbact.gs_id.objid,
                  targetos = symbact.gs_id.osnum);

    if (!(sts & msg & 1))
    {
#ifdef DEBUG
        printf("COgenset_generate: GSend_transition: %#x, %#x\n", sts, msg);
#endif
        goto finish;
    }

    sts = gr$gsinqcount(msg = &msg, 
                        senderid = NULL_OBJID,
                        object_id = &symbact.gs_id,
                        count = &ii );

    if ((sts & msg & 1) && ii)
    {
        /* set the output arguments */

        *grset = symbact.gs_id.objid;
        *grset_mod = mod;
        *obj_count = ii;

        sprintf(buf,"%d object%s located", ii, (ii > 1) ? "s" : "");

        /* define the set as the active select set */

        gr$gsput_select_set(msg = &ii,
                            mod_env = &mod,
                            select_set_id = &symbact.gs_id);
    }
    else
    {
        ex$message(msgnumb = GR_E_EleNotFnd, buff = buf);
        *grset = NULL_OBJID;
        *grset_mod = mod;
        *obj_count = 0;
    }

    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);

#endif

finish:

    if (info->classlist_changed)
    {
        /* restore the original dpb settings */

        vlist[0].var = DPB_SET_PROPERTIES;
        vlist[0].var_ptr = (IGRchar *)original_dpb;
        gr$set_inq(msg = &msg, var_list = vlist, set_inq = DPB_SET);
    }

    return(sts & msg & 1);
}

int COgenset_notify(f_label, g_label, value, form)
int f_label, g_label;
double value;
Form form;
{
    IGRuchar *p_mask;
    IGRuchar color_mask[COLOR_MASK_SIZE];
    IGRuchar style_mask[STYLE_MASK_SIZE];
    IGRuchar weight_mask[WEIGHT_MASK_SIZE];
    IGRchar *c, buf[BUFSIZ], buf2[16], ly_num[5];
    IGRlong msg, nbytes;
    IGRint ii, jj, kk, sts, alpha, (*func)();
    IGRint response;
    IGRint row, depth, state;
    IGRint layers[LAYER_MASK_SIZE];
    struct GRid window, fngrid, ids[MAX_WINDOWS];
    struct GRmd_env mod;
    struct GRelclass_f *e;
    struct COgenset_info *info;
    IGRdouble tmp_dbl;
    char pattern_buff[20];

    gr$get_module_env(buffer = &mod);
    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, "", 0);

    /* get the pointer to the main form's data */

    FIf_get_user_pointer(genset_form, (char **) &info);

    switch (f_label)
    {
      case GENSET_FORM:

        switch (g_label)
        {
          case FI_ACCEPT:
            /* no break! */

          case FI_EXECUTE:
            COgenset_generate(form, info->grset, info->mod,
                              info->obj_count, info->mod_count);
#ifdef SET_OPERATIONS
            if (g_label == FI_EXECUTE)
            {
                FIg_reset(form, g_label);
                if (info->grset[0] != NULL_OBJID)
                {
                    FIg_get_state(form, CLIP_CHECK, &state);
                    if (state)
                        info->grset[0] = NULL_OBJID;
                    else
                    {
                        FIg_enable(form, SET_OPERATOR_GROUP);
                        FIg_get_state(form, INTERSECT_CHECK, &state);
                        j = (state) ? GR_I_AddSetsIntersect : GR_I_AddSetsUnion;
                        ex$message(msgnumb = jj, buff = buf);
                        i = *info->obj_count;
                        c = &buf[strlen(buf)];
                        sprintf(c,"; %d object%s located", ii, (ii > 1) ? "s":"");
                        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
                    }
                }
                break; /* FI_EXECUTE exits here */
            }
#endif
            if (*info->obj_count)
            {
                /* put the graphic set object on the queue */

                COputset(&msg, *info->grset, info->mod, NULL_OBJID, NULL);

                ii = *info->obj_count;
                sprintf(buf,"%d object%s located", ii, (ii > 1) ? "s" : "");
                ex$message(field = ERROR_FIELD, in_buff = buf);
            }
            else
            {
                ex$message(msgnumb = GR_E_EleNotFnd);
            }

            /* no break! */

          case FI_CANCEL:
            FIg_reset(form, g_label);
            FIf_erase(form);
#if 1
             /* turn these off so next time command is executed
                the subforms will not be displayed.  elp 01/12/93 */
            FIg_set_state_off( form, COLOR_BUTTON );
            FIg_set_state_off( form, WEIGHT_BUTTON );
            FIg_set_state_off( form, STYLE_BUTTON );
            FIg_set_state_off( form, LAYER_BUTTON );
#endif
            response = EX_FORM_FINISHED;
            ex$putque(msg = &msg, response = &response);
            break;

          case FENCE_CHECK:
            FIfld_set_text(form, FILE_FIELD, 0, 0, "", 0);
            FIfld_set_text(form, WINDOW_FIELD, 0, 0, "", 0);
            FIg_get_state(form, IN_CHECK, &state);
            if (!state)
            {
                FIg_get_state(form, OUT_CHECK, &state);
                if (!state)
                {
                    FIg_get_state(form, OVL_CHECK, &state);
                    if (!state)
                    {
                        FIg_set_state_on(form, IN_CHECK);
                    }
                }
            }

            sts = gr$gsget_fence (msg = &msg, fence_id = &fngrid);

            if (!(sts & msg & 1))
            {
                response = EX_CMD_KEY;
                c = "GRPRcFn";
                nbytes = strlen(c) + 1;
                ex$putque(msg = &msg,
                          response = &response,
                          byte = &nbytes,
                          buffer = c);
            }
            break;

          case IN_CHECK:
          case OUT_CHECK:
          case OVL_CHECK:
            if (value)
            {
                if (g_label == IN_CHECK) FIg_set_state_off(form, OUT_CHECK);
                if (g_label == OUT_CHECK) FIg_set_state_off(form, IN_CHECK);
                if (g_label == OVL_CHECK) FIg_set_state_off(form, CLIP_CHECK);
                FIg_set_state_off(form, FILE_CHECK);
                FIg_get_state(form, WINDOW_CHECK, &state);
                if (!state)
                {
                    FIg_set_state_on(form, FENCE_CHECK);
                    COgenset_notify(f_label, FENCE_CHECK, value, form);
                }
            }
            break;

          case CLIP_CHECK:
            if (value)
            {
                FIg_get_state(form, WINDOW_CHECK, &state);
                if (state)
                {
                    /* won't clip elements in window */

                    FIg_set_state_off(form, g_label);
                    ex$message(msgnumb = GR_I_CantClipWin, buff = buf);
                    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
                    break;
                }

                FIg_set_state_off(form, FILE_CHECK);
                FIg_set_state_on(form, FENCE_CHECK);
                FIg_set_state_off(form, OVL_CHECK);
                if (info->grset[0] != NULL_OBJID)
                {
                    ex$message(msgnumb = GR_P_AbandonSet, buff = buf);
                    ex$message(msgnumb = GR_I_Notice, buff = buf2);

                    msg = FI_confirm_box(FI_CURRENT_SCREEN, -1, -1,
                                         buf2, FI_YELLOW, "swiss742b", 20.0,
                                         buf, FI_BLACK, "swiss742b", 15.0,
                                         FI_LEFT_JUSTIFIED,
                                         FI_ACCEPT | FI_CANCEL, 40);
                    if (msg)
                    {
                        info->grset[0] = NULL_OBJID;
                        FIg_disable(form, SET_OPERATOR_GROUP);
                        FIg_set_state_off(form, WINDOW_CHECK);
                        FIg_set_state_off(form, FILE_CHECK);
                        FIg_set_state_on(form, FENCE_CHECK);
                        COgenset_notify(f_label, FENCE_CHECK, value, form);
                    }
                    else
                    {
                        FIg_set_state_off(form, g_label);
                        break;
                    }
                }
            }
            COgenset_notify(f_label, FENCE_CHECK, value, form);
            break;

          case FILE_CHECK:
            FIg_set_state_off(form, IN_CHECK);
            FIg_set_state_off(form, OUT_CHECK);
            FIg_set_state_off(form, OVL_CHECK);
            FIg_set_state_off(form, CLIP_CHECK);
            FIfld_set_text(form, WINDOW_FIELD, 0, 0, "", 0);
            ex$filename(name = buf, len = BUFSIZ);
            c = (c = strrchr(buf, '/')) ? c + 1 : buf;
            FIfld_set_text(form, FILE_FIELD, 0, 0, c, 0);
            FIg_set_state_on(form, FILE_CHECK);
            break;

          case WINDOW_CHECK:
            FIfld_set_text(form, FILE_FIELD, 0, 0, "", 0);
            FIg_set_state_off(form, FILE_CHECK);
            FIg_set_state_off(form, CLIP_CHECK);
            FIg_get_state(form, IN_CHECK, &state);
            if (!state)
            {
                FIg_get_state(form, OUT_CHECK, &state);
                if (!state)
                {
                    FIg_get_state(form, OVL_CHECK, &state);
                    if (!state)
                    {
                        FIg_set_state_on(form, IN_CHECK);
                        FIg_set_state_on(form, OVL_CHECK);
                    }
                }
            }

            /* check for active windows */

            sts = COgetwin(&msg, &mod, &window, buf);
            if (sts & msg & 1)
            {
                FIfld_set_text(form, WINDOW_FIELD, 0, 0, buf, 0);
                FIg_set_state_on(form, WINDOW_CHECK);
            }
            else
            {
                ex$message(msgnumb = GR_P_IdWin, buff = buf);
                FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
            }
            break;

          case SELECT_WINDOW:

            /* delete the previous list */

            if (list_id != -1)
            {
                GRdelete_pull_down_list(list_id);
                om$dealloc(ptr = win_names);
                list_id = -1;
            }

            /* check for active windows */

            jj = MAX_WINDOWS;
            sts = dp$get_gragad_id(msg = &msg,
                                   mod_GRid = &mod,
                                   name = "*",
                                   array_size = MAX_WINDOWS,
                                   total_num = &kk,
                                   numberofids = &jj,
                                   found_GRids = ids,
                                   type_gragad = IGE_GG | ACTIVE_GG);

            if ((sts & msg & 1) && kk)
            {
                char *c;
                struct var_list vlist[2];

                vlist[0].var = GRAGAD_NAME;
                vlist[0].num_bytes = MAX_WIN_NAME;
                vlist[0].bytes_returned = (IGRlong *) &jj;
                vlist[1].var = END_PARAM;

                ii = sizeof(char) * MAX_WINDOWS * MAX_WIN_NAME;
                win_names = om$malloc(size = ii);

                if ( kk > MAX_WINDOWS )
                  kk = MAX_WINDOWS;

                for ( ii = 0; ii < kk; ii++ )
                {
                    /* get the window name */

                    c = &win_names[ii * MAX_WIN_NAME];
                    vlist[0].var_ptr = win_ptrs[ii] = c;
                    sts = dp$inq_set_gragad(msg = &msg,
                                            which_error = &jj,
                                            osnum = ids[ii].osnum,
                                            gragad_objid = ids[ii].objid,
                                            var_list = vlist);
                }
                ii = (kk < 8) ? kk : 8;
                GRcreate_pull_down_list(GENSET_FORM, form, WINDOW_FIELD,
                                        kk, ii, win_ptrs, kk, 1, &list_id);
                FIg_set_state_off(form,g_label);
                GRproc_pull_down_list(list_id);
            }
            else
            {
                ex$message(msgnumb = GR_E_WinNotFnd, buff = buf);
                FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
            }
            FIg_reset(form, g_label);
            break;

          case WINDOW_FIELD:
            FIg_set_state_off(form, CLIP_CHECK);
            FIfld_get_text(form, g_label, 0, 0, BUFSIZ, (unsigned char *) buf,
                           &ii, &jj );
            sts = dp$get_gragad_id(msg = &msg,
                                   mod_GRid = &mod,
                                   name = buf,
                                   array_size = 1,
                                   total_num = &ii,
                                   numberofids = &jj,
                                   found_GRids = &window,
                                   type_gragad = IGE_GG | ACTIVE_GG);
            if (!(sts & msg & 1) || (jj == 0))
            {
                ex$message(msgnumb = GR_E_WinNotFnd, buff = buf);
                FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
                /*
                 * Removed sequencing code that used to be here because 
	         * journalling will not support it.  Shelley Heard 4/10/93
                 */    
            }
            break;

          case COLOR_BUTTON:
            if (!info->forms[COLOR_INDEX])
            {
                if (!color_form)
                {
                    if (FIf_new(COLOR_FORM, GRCOLOR_FORM_FILENAME,
                                COgenset_notify, &color_form))
                    {
                        ex$message(msgnumb = GR_E_ErrEnc, buff = buf);
                        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
                        FIg_reset(form, g_label);
                        break;
                    }
                }
                info->forms[COLOR_INDEX] = color_form;
                COpositionform(form, color_form);
            }

            /* Call a function to create/update a color palette that reflects
               the active color table. */

            GRdyncolorpal(&msg,
                          GRCOLOR_PALETTE_LABEL,
                          GRCOLOR_PALETTE_X1,
                          GRCOLOR_PALETTE_Y1,
                          GRCOLOR_PALETTE_X2,
                          GRCOLOR_PALETTE_Y2,
                          info->forms[COLOR_INDEX],
                          &num_colors);

            /* allow multiple selections */

            FIgrp_set_single_select_off(info->forms[COLOR_INDEX],
                                         GRCOLOR_PALETTE_LABEL);

            /* pop up the buttons of colors selected */

            FIfld_get_text(form, COLOR_FIELD, 0, 0, BUFSIZ,
                           (unsigned char *) buf, &ii, &jj );

            COactgad(buf, info->forms[COLOR_INDEX], color_mask,
                     COLOR_MASK_SIZE, COLOR_SYMB, LO_COLOR, HI_COLOR,
                     mod.md_id.osnum, COLOR_FORM, GRCOLOR_PALETTE_LABEL,
                     GRCOLOR_PALETTE_LABEL + num_colors);

            FIf_display(info->forms[COLOR_INDEX]);
            break;

          case WEIGHT_BUTTON:
            if (!info->forms[WEIGHT_INDEX])
            {
                if (!weight_form)
                {
                    if (FIf_new(WEIGHT_FORM, GRWEIGHT_FORM_FILENAME,
                                COgenset_notify, &weight_form))
                    {
                        ex$message(msgnumb = GR_E_ErrEnc, buff = buf);
                        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
                        FIg_reset(form, g_label);
                        break;
                    }
                }
                info->forms[WEIGHT_INDEX] = weight_form;
                COpositionform(form, weight_form);
            }

            /* set the form to the first weight in the ascii field */

            FIfld_get_text(form, WEIGHT_FIELD, 0, 0, BUFSIZ,
                           (unsigned char *) buf, &ii, &jj );
            GRupdweightform(&msg, atoi(buf), info->forms[WEIGHT_INDEX]);

            FIf_display(info->forms[WEIGHT_INDEX]);
            break;

          case STYLE_BUTTON:
           if (! info->forms[STYLE_INDEX])
           {
	       if (!style_form)
	       {
                    if (FIf_new(STYLE_FORM, "GRDefineLine",
                                COgenset_notify, &style_form))
		   {
		       ex$message(msgnumb = GR_E_ErrEnc, buff = buf);
		       FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
		       FIg_reset(form, g_label);
		       break;
		   }
	       } 
	       info->forms[STYLE_INDEX] = style_form;
	       COpositionform(form, style_form);


	       /*
		* Erase the other title for this form, and other gadgets we
		* won't use.
		*/

	       FIg_erase(style_form,11); 
	       FIg_erase(style_form,14); 
	       FIg_erase(style_form,15); 
	       FIg_erase(style_form,16); 
	       for ( ii = 19; ii < 36; ii++) FIg_erase(style_form,ii);

	       /*
		* Set the number of rows.
		*/

	       FIfld_set_max_num_rows(style_form, LINESTYLE_FIELD, MAX_STYLES);
           }

	   /*
	    * Get the linestyle patterns.
	    */

	   for ( ii = 0; ii < MAX_STYLES; ii++)
	   {
	     DPinq_style(ii, &dp_bit_pattern[ii]);
	   }

	   /*
	    * Set the linestyle field with the index and the corresponding 
            * linestyle pattern.
	    */

	   for( ii = 0; ii < MAX_STYLES; ii++ )
	   {
	       tmp_dbl = (IGRdouble) ii;
	       FIfld_set_value(style_form, LINESTYLE_FIELD, ii, 0, tmp_dbl,
                               FALSE);
	       DPpattern(dp_bit_pattern[ii], pattern_buff);
	       FIfld_set_text(style_form, LINESTYLE_FIELD, ii, 1, pattern_buff,
                              FALSE);
	   }
  
            FIfld_get_text(form, STYLE_FIELD, 0, 0, BUFSIZ,
                           (unsigned char *) buf, &ii, &jj );
            COactgad(buf, style_form, style_mask,
                     STYLE_MASK_SIZE, STYLE_SYMB, LO_STYLE, HI_STYLE,
                     mod.md_id.osnum, STYLE_FORM, LO_STYLE, HI_STYLE);
  

           FIf_display(style_form);
           break;

          case LAYER_BUTTON:
           if (! info->forms[LAYER_INDEX])
           {
               if (!layer_form)
               {
                    if (FIf_new(LAYER_FORM, "GRLayers",
                                COgenset_notify, &layer_form))
                    {
                       ex$message(msgnumb = GR_E_ErrEnc, buff = buf);
                       FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
                       FIg_reset(form, g_label);
                       break;
                    }
               }

               info->forms[LAYER_INDEX] = layer_form;
               COpositionform(form, layer_form);

               /* Erase the gadgets we don't need.  */

               FIg_erase(layer_form, ACT_LAYER_TEXT);
               FIg_erase(layer_form, ACT_LAYER);
               FIg_erase(layer_form, MODE_TOGGLE);
               FIg_erase(layer_form, SORT_TOGGLE);
               FIg_erase(layer_form, DELETE_BUTTON);
               FIg_erase(layer_form, ELIG_ROLL);
               FIg_erase(layer_form, OCCUPIED_ROLL);
               FIg_erase(layer_form, SEARCH_BUTTON);
               FIg_erase(layer_form, OCCUPIED_TOGGLE);
               FIg_erase(layer_form, DISPLAY_TEXT);
               FIg_erase(layer_form, ELIG_TEXT);
               FIg_erase(layer_form, DISPLAY_TEXT_ROLL);
               FIg_erase(layer_form, ELIG_TEXT_ROLL);
               FIg_erase(layer_form, 13);
               FIg_erase(layer_form, 14);
               FIg_erase(layer_form, 28);
               FIg_erase(layer_form, 19);
               FIg_erase(layer_form, 26);
               FIg_erase(layer_form, 24);
 
               FIfld_set_max_num_rows(layer_form, 16, 1024);

               for ( ii = 0; ii < 1024; ii++ )
               {
                 sprintf( ly_num, "%d", ii );
                 FIfld_set_text(layer_form, 16, ii, 1, ly_num, FALSE);
               }

               FIfld_set_mode(layer_form, 16, 0, FI_MULTI_SELECT);
               FIfld_set_mode(layer_form, 16, 1, FI_MULTI_SELECT);
               FIfld_set_mode(layer_form, 16, 2, FI_MULTI_SELECT);
           }

           FIfld_get_text(form, LAYER_FLD, 0, 0, BUFSIZ, (unsigned char *) buf,
                          &ii, &jj );
           COactgad(buf, layer_form, (IGRuchar *) layers,
                    (4 * LAYER_MASK_SIZE), LAYER_SYMB, LO_LAYER, HI_LAYER,
                    mod.md_id.osnum, LAYER_FORM, LO_LAYER, HI_LAYER);

           FIf_display(layer_form);
           break;

          case COLOR_FIELD:
          case WEIGHT_FIELD:
          case STYLE_FIELD:
            FIfld_get_text(form, g_label, 0, 0, BUFSIZ, (unsigned char *) buf,
                           &ii, &jj );
            if (COall(buf))
            {
                ex$message(msgnumb = GR_I_All, buff = buf);
                FIfld_set_text(form, g_label, 0, 0, buf, 0);
            }
            else                
            {
                if (g_label == COLOR_FIELD)
                {
                    func = GRcolor_conversion;
                    alpha = TRUE; ii = LO_COLOR; jj = HI_COLOR;
                    p_mask = color_mask;
                    msg = GR_E_InvCo;
                }
                else if (g_label == WEIGHT_FIELD)
                {
                    func = GRnumber_conversion;
                    alpha = FALSE; ii = LO_WEIGHT; jj = HI_WEIGHT;
                    p_mask = weight_mask;
                    msg = GR_E_InvWt;
                }
                else /* STYLE_FIELD */
                {
                    func = GRnumber_conversion;
                    alpha = FALSE; ii = LO_STYLE; jj = HI_STYLE;
                    p_mask = style_mask;
                    msg = GR_E_InvSt;
                }
                sts = GRparse_multiple_entry_keyin(buf, p_mask, func, alpha,
                                                   ii, jj, mod.md_id.osnum);
                if (!(sts & 1))
                {
                    ex$message(msgnumb = msg, buff = buf);
                    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
                    /*
                     * Removed sequencing code that used to be here because 
	             * journalling will not support it.  Shelley Heard 4/10/93
                     */    
                }
            }
            break;

          case LAYER_FLD:
            FIfld_get_text(form, g_label, 0, 0, BUFSIZ, (unsigned char *) buf,
                           &ii, &jj );
            if (!COlykytomask(&msg, &mod, buf, NULL))
            {
                ex$message(msgnumb = GR_E_InvLy, buff = buf);
                FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
                /*
                 * Removed sequencing code that used to be here because 
	         * journalling will not support it.  Shelley Heard 4/10/93
                 */    
            }
            break;

          case CLEAR_BUTTON:
          case SET_BUTTON:
            row = 0;
            depth = -1;
            info->classlist_changed = TRUE;
            e = &info->elclass[row];
            if (g_label == SET_BUTTON)
                e->properties |= DPB_LOCATABLE;     /* set */
            else
                e->properties &= ~DPB_LOCATABLE;    /* clear */
            state = e->properties;
            while (row < info->elclass_count && e->depth > depth)
            {
               (e++)->properties = state;
                FIfld_set_select(form, TYPE_FIELD, row++, 0, state);
            }
            FIg_set_state_off(form, g_label);
            break;

          case TYPE_FIELD:
            row =(int) value;
            info->classlist_changed = TRUE;
            e = &info->elclass[row];
            e->properties ^= DPB_LOCATABLE;     /* toggle */
            state = e->properties;
            depth = e->depth;

            /* check for owners and turn them on also */

            if (e->depth &&(state & DPB_LOCATABLE))
            {
                while (--row >= 0 &&(--e)->depth >= 0)
                {
                    if (e->depth < depth)
                    {
                        e->properties = state;
                        FIfld_set_select(form, TYPE_FIELD, row, 0, state);
                        depth--;
                    }
                }
            }

            /* toggle subcategories */

            row =(int) value;
            e = &info->elclass[row];
            depth = e->depth;
            while (++row < info->elclass_count &&(++e)->depth > depth)
            {
                e->properties = state;
                FIfld_set_select(form, TYPE_FIELD, row, 0, state);
            }
            
            break;

          case INTERSECT_CHECK:
            ex$message(msgnumb = GR_I_AddSetsIntersect, buff = buf);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
            break;

          case UNION_CHECK:
            ex$message(msgnumb = GR_I_AddSetsUnion, buff = buf);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
            break;

          default:
            break;
        }
        break;  /* end case GENSET_FORM */

      case COLOR_FORM:
        switch(g_label)
        {
          case FI_ACCEPT:
            FIg_reset(form, g_label);
            FIf_erase(form);
            COgadtostr(form, COLOR_FORM, GRCOLOR_PALETTE_LABEL + 1,
                        GRCOLOR_PALETTE_LABEL + num_colors + 1, buf);
            FIfld_set_text(info->forms[GENSET_INDEX], COLOR_FIELD,
                            0, 0, buf, 0);
            FIg_reset(info->forms[GENSET_INDEX], COLOR_BUTTON);
            break;
        }
        break;

      case WEIGHT_FORM:
        switch(g_label)
        {
          case FI_ACCEPT:
            FIg_reset(form, g_label);
            FIf_erase(form);
            FIg_get_value(form, GRWEIGHT_SLIDER, &value);
            sprintf(buf, "%d",(int)value);
            FIfld_set_text(info->forms[GENSET_INDEX], WEIGHT_FIELD, 0, 0, buf, 0);
            FIg_reset(info->forms[GENSET_INDEX], WEIGHT_BUTTON);
            break;
        }
        break;

      case STYLE_FORM:
        switch(g_label)
        {
          case FI_ACCEPT:
            FIg_reset(form, g_label);
            FIf_erase(form);
            COgadtostr(form, STYLE_FORM, LO_STYLE,
                        HI_STYLE , buf);
            FIfld_set_text(info->forms[GENSET_INDEX], STYLE_FIELD,
                            0, 0, buf, 0);
            FIg_reset(info->forms[GENSET_INDEX], STYLE_BUTTON);
            break;
         case EXIT_BTN:
            FIg_reset(form, g_label);
            FIf_erase(form);
            FIg_reset(info->forms[GENSET_INDEX], STYLE_BUTTON);
            break;
            
        }
        break;

      case LAYER_FORM:
        switch(g_label)
        {
          case FI_ACCEPT:
            FIg_reset(form, g_label);
            FIf_erase(form);
            COgadtostr(form, LAYER_FORM, LO_LAYER, HI_LAYER, buf);
            FIfld_set_text(info->forms[GENSET_INDEX], LAYER_FLD,
                            0, 0, buf, 0);
            FIg_reset(info->forms[GENSET_INDEX], LAYER_BUTTON);
            break;

          case FI_CANCEL:
            FIg_reset(form, g_label);
            FIf_erase(form);
            FIg_reset(info->forms[GENSET_INDEX], LAYER_BUTTON);
            break;

        }
        break;

      default:
        break;
    }

    return(FI_SUCCESS);
}

method init(int type; char *str_ptr)
{
    long mask;

    me->state = 0;
    me->mytype = type;
    me->top_gs = NULL_OBJID;

    /*
        If any form has been converted to a permanent window by a
        previous invocation of the command object, convert it back to a
        save/restore form.
    */

    if (genset_form)
    {
        FIf_get_attr(genset_form,&mask);
        if (!(mask & FI_SAVE_RESTORE))
        {
            mask |= FI_SAVE_RESTORE;
            FIf_set_attr(genset_form,mask);
        }
    }
    if (color_form)
    {
        FIf_get_attr(color_form,&mask);
        if (!(mask & FI_SAVE_RESTORE))
        {
            mask |= FI_SAVE_RESTORE;
            FIf_set_attr(color_form,mask);
        }
    }
    if (weight_form)
    {
        FIf_get_attr(weight_form,&mask);
        if (!(mask & FI_SAVE_RESTORE))
        {
            mask |= FI_SAVE_RESTORE;
            FIf_set_attr(weight_form,mask);
        }
    }
    if (style_form)
    {
        FIf_get_attr(style_form,&mask);
        if (!(mask & FI_SAVE_RESTORE))
        {
            mask |= FI_SAVE_RESTORE;
            FIf_set_attr(style_form,mask);
        }
    }
    if (layer_form)
    {
        FIf_get_attr(layer_form,&mask);
        if (!(mask & FI_SAVE_RESTORE))
        {
            mask |= FI_SAVE_RESTORE;
            FIf_set_attr(layer_form,mask);
        }
    }

    return (OM_S_SUCCESS);
}

method wakeup(int pos)
{
    IGRint sts, msg, state;
    struct GRid fence;

    ex$message(msgnumb = GRC_M_GenSet);
    if (genset_form)
    {
        FIfld_set_text(genset_form, FI_MSG_FIELD, 0, 0, "", 0);
    
        /* make sure existing settings are still valid */

        FIg_get_state(genset_form, FENCE_CHECK, &state);
        if (state)
        {
            sts = gr$gsget_fence (msg = &msg, fence_id = &fence);
            if (!(sts & msg & 1))
            {
                /*
                    No fence, so make Window the active volume
                    criteria. Could invoke the Place Fence command, but
                    that is potentially confusing to a user who just
                    selected Generate Set 
                */

                FIg_set_state_off(genset_form, FENCE_CHECK);
                FIg_set_state_on(genset_form, WINDOW_CHECK);
            }
        }

        FIg_get_state(genset_form, WINDOW_CHECK, &state);
        if (state)
        {
            /* fake notification to find a window */

            COgenset_notify(GENSET_FORM, WINDOW_CHECK, 0.0, genset_form);
        }
    }

    return (OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
    IGRchar buf[BUFSIZ];
    IGRint sts, msg, ii, state;
    struct COgenset_info *p;
    struct var_list vlist[2];

    if (om$dimension_of(varray = me->form) == 0)
    {
        /* create the main form */

        om$vla_set_dimension(varray = me->form, size = NFORMS);
        for ( ii = 0; ii < NFORMS; ii++ ) me->form[ii] = NULL;
        if (genset_form == NULL)
        {
            sts = FIf_new(GENSET_FORM, "GRGenSet", 
                          COgenset_notify, &genset_form);
            if (sts != FI_SUCCESS)
            {
                ex$message(msgnumb = GR_E_ErrEncCmdTrm);
                *response = TERMINATE;
                goto finish;
            }

            /* set up a data pointer to associate with the form */

            ii = sizeof(struct COgenset_info);
            genset_info = p =(struct COgenset_info *) om$malloc(size = ii);
            p->elclass_count = 0;
            p->elclass = NULL;
            p->classlist_changed = FALSE;
            p->grset = NULL;
            p->mod = NULL;
            p->obj_count = NULL;
            p->mod_count = NULL;
            FIf_set_user_pointer(genset_form, (char *) p);

            /* initialize the form */

            COgenset_init_form(genset_form);
        }

        me->form[0] = genset_form;
        me->form_data =(IGRchar *)genset_info;
    }

    /* make sure pointers into instance data are set */

    p =(struct COgenset_info *)me->form_data;
    p->grset = &me->top_gs;
    p->mod = &me->top_mod;
    p->obj_count = &me->obj_count;
    p->mod_count = &me->mod_count;
    p->forms = me->form;

    if (me->top_gs == NULL_OBJID)
    {
        /* disable the set operations gadgets until a set is generated */

        FIg_disable(me->form[0], SET_OPERATOR_GROUP);
    }
   
    /* display the genset form */

    if (me->form[0])
    {
       FIf_is_displayed(me->form[0],&sts);
       if (!sts) FIf_display(me->form[0]);
    }


    /* see if a subform should be displayed */

    if (color_form)
    {
	FIg_get_state(me->form[0], COLOR_BUTTON, &state);
	if (state) 
	{
	    FIf_is_displayed(color_form,&state);
	    if (!state) FIf_display(color_form);
	    me->form[COLOR_INDEX]=color_form;
	}
    }
    if (weight_form)
    {
	FIg_get_state(me->form[0], WEIGHT_BUTTON, &state);
	if (state) 
	{
	    FIf_is_displayed(weight_form,&state);
	    if (!state) FIf_display(weight_form);
	    me->form[WEIGHT_INDEX]=weight_form;
	}
    }
    if (style_form)
    {
	FIg_get_state(me->form[0], STYLE_BUTTON, &state);
	if (state)
	{
	    FIf_is_displayed(style_form,&state);
	    if (!state) FIf_display(style_form);
	    me->form[STYLE_INDEX]=style_form;
	}
    }
    if (layer_form)
    {
        FIg_get_state(me->form[0], LAYER_BUTTON, &state);
        if (state)
        {
            FIf_is_displayed(layer_form,&state);
            if (!state) FIf_display(layer_form);
            me->form[LAYER_INDEX]=layer_form;
        }
    }

    while (TRUE)
    {
        /* stall until the form is dismissed */

        co$getevent(msg = &msg,
                    msgnum = EX_P_Clear,
                    event_mask = GRm_FORM_FINISHED | GRm_TEXT_VALUE | GRm_DATA,
                    response = response,
                    response_data = response_data,
                    event = &me->event[0]);

        if (me->event[0].response == EX_FORM_FINISHED)
        {
            *response = TERMINATE;
            break;
        }
        else if (me->event[0].response == EX_STRING)
        {
            IGRboolean no_sub_form = TRUE;

            FIg_get_state(me->form[0], WINDOW_CHECK, &state);

            /* check the state and check if any of the sub-forms
             * are presently up.  If there are, we do not want to
             * confuse the user by allowing the editing of the
             * main form while the sub-forms are up without a 
             * intentional data click in the main forms field.
             * Thank you and good night. scw 04/29/92
             */
            if( color_form != NULL )
            {
               FIf_is_displayed( color_form, &sts );
               if( sts )  no_sub_form = FALSE;
            }
            if( weight_form != NULL )
            {
               FIf_is_displayed( weight_form, &sts );
               if( sts )  no_sub_form = FALSE;
            }
            if( style_form != NULL )
            {
               FIf_is_displayed( style_form, &sts );
               if( sts )  no_sub_form = FALSE;
            }
            if (layer_form != NULL)
            {
               FIf_is_displayed(layer_form, &sts);
               if (sts)  no_sub_form = FALSE;
            }

            if( state && no_sub_form )
            {
                /* assume user is identifying a window with a name */

                FIfld_set_text(me->form[0], WINDOW_FIELD, 0, 0, 
                                me->event[0].event.keyin, 0);
                COgenset_notify(GENSET_FORM, WINDOW_FIELD, 0.0, me->form[0]);
            }
            else
                ex$message(msgnumb = GR_I_InpDiscard);
        }
        else if (me->event[0].response == EX_DATA)
        {
            FIg_get_state(me->form[0], WINDOW_CHECK, &state);

            if (state)
            {
                /* assume user is identifying a window with a data point */

                vlist[0].var = GRAGAD_NAME;
                vlist[0].var_ptr = buf;
                vlist[0].num_bytes = BUFSIZ;
                vlist[0].bytes_returned = (IGRlong *) &ii;
                vlist[1].var = END_PARAM;

                dp$inq_set_gragad(msg = &msg,
                              which_error = &ii,
                              osnum = me->event[0].event.button.osnum,
                              gragad_objid = me->event[0].event.button.objid,
                              var_list = vlist);
                if (msg & 1)
                {
#ifdef DEBUG
                    printf("dp$inq_set_gragad: %#x, :%s:\n", msg, buf);
#endif
                    FIfld_set_text(me->form[0], WINDOW_FIELD, 0, 0, buf, 0);
                    COgenset_notify(GENSET_FORM, WINDOW_FIELD, 0.0,
                                    me->form[0]);
                }
                else
                {
                    ex$message(msgnumb = GR_E_WinNotFnd, buff = buf);
                    FIfld_set_text(me->form[0], FI_MSG_FIELD, 0, 0, buf, 0);
                }
            }
            else
                ex$message(msgnumb = GR_I_InpDiscard);
        }
        else if (*response == EX_RJT_MOVEON ||
                 *response == EX_BACK_UP ||
                 *response == EX_RESTART ||
                 *response == EX_OBJID)
        {
            ex$message(msgnumb = GR_I_InpDiscard);
        }
	else if (*response == TERMINATE)
	{
	    FIg_set_state(me->form[0], COLOR_BUTTON, 0);
	    FIg_set_state(me->form[0], WEIGHT_BUTTON, 0);
	    FIg_set_state(me->form[0], STYLE_BUTTON, 0);
            FIg_set_state(me->form[0], LAYER_BUTTON, 0);
            break;
	}
	    
        else /* unknown input */
        {
            break;  /* return to command server */
        }
    }
finish:

    return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
    int i;

    if (list_id != -1)
    {
        /* delete the popup window name list */

        GRdelete_pull_down_list(list_id);
        om$dealloc(ptr = win_names);
        list_id = -1;
    }

    /* erase any forms that are displayed */

    for(i=4;i>=0;i--) if (me->form[i]) FIf_erase(me->form[i]);

    om$send(mode = OM_e_wrt_message,
            msg = message super_cmd.sleep(pos),
            targetid = my_id);

   return (OM_S_SUCCESS);
}

end implementation COgenset;
