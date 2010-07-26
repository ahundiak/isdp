/*
Name
        GRdpb methods

Description
        This file contains the following methods for the dpb.

            GRdpb$GRget
*/

class implementation GRdpb;

#include <stdio.h>
#include "OMerrordef.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "gr.h"
#include "ex.h"

#ifndef NT
#include "exmacros.h"
#endif

#include "grdpbdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include "msmacros.h"
#include "igewindef.h"
#include "igecolordef.h"

#ifndef NT
#include "igecolor.h"
#include "igecolmacros.h"
#endif

#include "godef.h"
#include "lcmacros.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "bstypes.h"
#include "grerr.h"

#ifndef IDRAW
extern IGRint RSloadvlt();
extern IGRboolean RScalccalib();
#endif
extern void BSchgdeppar();
extern IGRboolean BSchangepar();
extern IGRboolean GRabsg_del_all();
extern int EX_batch_mode;


method GRget(IGRint *msg, parameter; IGRchar *buffer)
{
    IGRlong i, *l;
    struct GRdpbdata *dpb;

    *msg = MSSUCC;
    dpb = (struct GRdpbdata *)me->data;
    switch (parameter)
    {
      case grdpb_change_acs_type:
        *(IGRboolean *)buffer = dpb->bflags & DPB_CHANGE_ACS_TYPE ? TRUE : FALSE;
        break;

      case grdpb_auto_accept_flag:
        *(IGRboolean *)buffer = dpb->bflags & DPB_AUTO_ACCEPT_FLAG ? TRUE : FALSE;
        break;

      case grdpb_associative_flag:
        *(IGRboolean *)buffer = dpb->bflags & DPB_ASSOCIATIVE_FLAG ? TRUE : FALSE;
        break;

      case grdpb_ref_shrink_wrap_flag:
        *(IGRboolean *)buffer = dpb->bflags & DPB_REF_SHRINK_WRAP_FLAG ? TRUE : FALSE;
        break;

      case grdpb_ref_background_flag:
        *(IGRboolean *)buffer = dpb->bflags & DPB_REF_BACKGROUND_FLAG ? TRUE : FALSE;
        break;

      case grdpb_mrp_lock:
        *(IGRboolean *)buffer = dpb->bflags & DPB_MRP_LOCK ? TRUE : FALSE;
        break;

      case grdpb_assoc_read_only_reffile:
        *(IGRboolean *)buffer = dpb->bflags & DPB_ASSOC_READ_ONLY_REFFILE ?
                                                                TRUE : FALSE;
        break;

      case grdpb_dynamics_copy_flag:
        *(IGRboolean *)buffer =	dpb->bflags & DPB_DYNAMICS_COPY_FLAG ? TRUE : FALSE;
        break;

      case grdpb_dynamics_on:
        *(IGRboolean *)buffer =	dpb->bflags & DPB_DYNAMICS_ON ? TRUE : FALSE;
        break;

      case grdpb_bore_locate:
        *(IGRboolean *)buffer = dpb->bflags & DPB_BORE_LOCATE ? TRUE : FALSE;
        break;

      case grdpb_arc_direction:
        *(IGRboolean *)buffer = dpb->bflags & DPB_ARC_DIRECTION ? TRUE : FALSE;
        break;

#ifndef IDRAW
      case grdpb_dynamics_all_windows:
        *(IGRboolean *)buffer = dpb->bflags & DPB_DYNAMICS_ALL_WINDOWS ? TRUE : FALSE;
        break;

      case grdpb_apparent_flag:
        *(IGRboolean *)buffer = dpb->bflags & DPB_APPARENT_FLAG ? TRUE : FALSE;
        break;

      case grdpb_local_abs:
        *(IGRboolean *)buffer =	dpb->bflags & DPB_LOCAL_ABS_FLAG ? TRUE : FALSE;
        break;
#endif
      case grdpb_projection_angle:
        *(IGRchar *)buffer = dpb->proj_angle;
        break;

      case grdpb_active_level:
        *(IGRshort *)buffer = dpb->layer;
        break;

      case grdpb_active_prop:
        *(unsigned short *)buffer = dpb->objprops;
        break;

      case grdpb_active_cs_type:
        strcpy(buffer, dpb->cstype);
        break;

      case grdpb_hidden_surf_sym:
        *(IGRlong *)buffer = dpb->hidsurfsym;
        break;

      case grdpb_locate_levels:
        l = (IGRlong *)buffer;
        for (i = 0; i < 32 ; i++) l[i] = me->layer[i];
        break;

      case grdpb_chord_height_tolerance:
        *(IGRdouble *)buffer = dpb->cht;
        break;

      case grdpb_offset_tolerance:
        *(IGRdouble *)buffer = dpb->offset_tol;
        break;

      case grdpb_arclength_tolerance:
        *(IGRdouble *)buffer = dpb->arc_tol;
        break;

      case grdpb_basis_tolerance:
        *(IGRdouble *)buffer = dpb->bastol;
        break;

      case grdpb_maximum_step_size:
        *(IGRdouble *)buffer = dpb->maxstep;
        break;

      case grdpb_active_angle:
        *(IGRdouble *)buffer = dpb->angle;
        break;

      case grdpb_dit_tolerance:
        *(IGRdouble *)buffer = dpb->dit_tol;
        break;

      case grdpb_active_display:
        *(struct IGRdisplay *)buffer = dpb->display;
        break;

      case grdpb_last_point:
        *(struct EX_button *)buffer = dpb->lastpoint;
        break;

      case grdpb_module_env:
      case grdpb_model_env:
      case grdpb_locate_env:
      case grdpb_display_env:
        *(struct GRmd_env *)buffer = dpb->module;
        break;

      case grdpb_active_scale:
        OM_BLOCK_MOVE(dpb->scale, buffer, 3 * sizeof(IGRdouble));
        break;

      case grdpb_text_symb:
        *(struct GRdpb_text_symb *)buffer = dpb->textsym;
        break;

#ifndef IDRAW
      case grdpb_unit_lock:
        *(struct GRunit_lock *)buffer =	dpb->unit_lock;
        break;
#endif
      case grdpb_name_mode:
        *(IGRboolean *)buffer = dpb->name_mode;
        break;

      case grdpb_locate_properties:
        *(IGRlong *)buffer = dpb->locprops;
        break;

      case grdpb_raster_graphics:
        *(struct GRrgdpb *)buffer = dpb->raster;
        break;

      case grdpb_patrn_edge_delta:
        *(IGRdouble *)buffer = dpb->epdelta;
        break;

      case grdpb_patrn_area_deltas:
        ((struct Patrn_area_deltas *)buffer)->x = dpb->apdelta[0];
        ((struct Patrn_area_deltas *)buffer)->y = dpb->apdelta[1];
        break;

      case grdpb_model_mode:
        *(IGRchar *)buffer = dpb->model_mode;
        break;

      case grdpb_database_type:
        strcpy(buffer, dpb->dbtype);
        break;

      case grdpb_xhatch_spacing:
        *(IGRdouble *)buffer = dpb->xhatch_spacing;
        break;

      case grdpb_xhatch_angle:
        *(IGRdouble *)buffer = dpb->xhatch_angle;
        break;

      case grdpb_brush_type:
        *(IGRint *)buffer = dpb->raster.brush_type;
        break;

      case grdpb_hesym:
        *(struct GRhesym *)buffer = dpb->hesym;
        break;

      case grdpb_visible_edge_sym:
        *(struct GRhesym *)buffer = dpb->visible_edge_sym;
        break;

      case grdpb_invis_so_on:
        *(IGRboolean *)buffer =	dpb->bflags & DPB_INVIS_SO_ON ? TRUE : FALSE;
        break;

      case grdpb_hidden_so_on:
        *(IGRboolean *)buffer =	dpb->bflags & DPB_HIDDEN_SO_ON ? TRUE : FALSE;
        break;

      case grdpb_smart_sketch_constraints:
        *(int *)buffer = dpb->EligibleConstraints;
        break;

      case grdpb_smart_sketch_on:
        *(int *)buffer = dpb->SmartSketchOn;
        break;

      default:
        *msg = MSFAIL;
        *(IGRint *)buffer = -1;
        printf("Unknown parameter requested from the dpb: %d\n", parameter);
        break;
    }

    return(OM_S_SUCCESS);
}

end implementation GRdpb;
