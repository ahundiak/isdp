/* $Id: GRdpbi.I,v 1.3 2001/02/26 14:28:33 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsvisual/cmd//GRdpbi.I
 *
 * Description:
 *		TR 179528596 & 179601498
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: GRdpbi.I,v $
 *	Revision 1.3  2001/02/26 14:28:33  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/02/26 14:20:11  ramarao
 *	Created "Review Structural Objects" command.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/05/12  13:43:38  pinnacle
# TR179802375
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/05/09  16:02:52  pinnacle
# Created: vdvisual/cmd/GRdpbi.I by v240_int for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/21/95	Rama Rao	creation date
 *	05/08/96	adz		delete VDS Dir Cmd Form during save.
 *      05/11/99        ylong           TR179802375
 *      02/25/01	Rama Rao	Delete Review Structural Object Form.
 ***************************************************************************/

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
#include "exmacros.h"
#include "grdpbdef.h"
#include "exmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include "msmacros.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"
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


method delete(int f_defer_flag)
{
    return(OM_S_SUCCESS);    /* the dpb cannot be deleted */
}


method super_construct()
{
    IGRint i;
    IGRlong msg;
    struct GRdpbdata *dpb;

    msg = om$vla_set_dimension(varray = me->data,
                               size = sizeof(struct GRdpbdata));
    if (!(msg & 1))
    {
        fprintf(stderr, "Failed to construct the default parameter block\n");
        goto finish;
    }

    dpb = (struct GRdpbdata *)me->data;
    dpb->version = DPB_VERSION;
    for (i = 0 ; i < 32; i++)
    {
        me->layer[i] = 0xffffffff;
        dpb->locate_layers[i] = 0;
    }
    strcpy(dpb->dbtype, "3d");
    dpb->model_mode = DRAWING_MODE;
    dpb->proj_angle = 0;
    strcpy(dpb->cstype, "rectangular");
    dpb->bflags = DPB_LOCAL_ABS_FLAG |
                  DPB_ARC_DIRECTION |
                  DPB_BORE_LOCATE |
                  DPB_DYNAMICS_ON |
                  DPB_DYNAMICS_ALL_WINDOWS |
                  DPB_DYNAMICS_COPY_FLAG |
                  DPB_ASSOCIATIVE_FLAG |
                  DPB_AUTO_ACCEPT_FLAG |
                  DPB_CHANGE_ACS_TYPE |
                  DPB_INVIS_SO_ON |
                  DPB_HIDDEN_SO_ON |
                  DPB_MRP_LOCK |
                  DPB_ASSOC_READ_ONLY_REFFILE;
    dpb->name_mode = -1;
    dpb->layer = 1;
    dpb->objprops = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
    dpb->hidsurfsym = 0;
    dpb->locprops = 0;
    dpb->epdelta = 0.0;
    dpb->apdelta[0] = 0.0;
    dpb->apdelta[1] = 0.0;
    dpb->angle = 0.0;
    dpb->dit_tol = 5.0;
    BSEXTRACTPAR(&msg, BSTOLCHRDHT,  dpb->cht);
    BSEXTRACTPAR(&msg, BSTOLOFFSET,  dpb->offset_tol);
    BSEXTRACTPAR(&msg, BSTOLARCLEN,  dpb->arc_tol);
    BSEXTRACTPAR(&msg, BSTOLBASIS,   dpb->bastol);
    BSEXTRACTPAR(&msg, BSTOLMAXSTEP, dpb->maxstep);
    dpb->xhatch_spacing = 0.25;
    dpb->xhatch_angle = 0.78539816299999998;
    dpb->scale[0] = 1.0;
    dpb->scale[1] = 1.0;
    dpb->scale[2] = 1.0;
    dpb->module.md_id.osnum = OM_Gw_current_OS;
    dpb->module.md_env.matrix_type = 2;
    MAidmx(&msg, dpb->module.md_env.matrix);
    dpb->lastpoint.x = 0.0;
    dpb->lastpoint.y = 0.0;
    dpb->lastpoint.z = 0.0;
    dpb->lastpoint.objid = NULL_OBJID;
    dpb->unit_lock.on_off = FALSE;
    dpb->unit_lock.round_off = 1.0;
    dpb->display.color = 1;
    dpb->display.weight = 0;
    dpb->display.style = 0;
    dpb->textsym.Active_font = 0;
    dpb->textsym.Active_just = 1;
    dpb->textsym.Active_width = 50.0;
    dpb->textsym.Active_height = 50.0;
    dpb->textsym.Active_charspac = 1.0;
    dpb->textsym.Active_linespac = 1.0;
    dpb->textsym.Active_fraction_font = -1;
    dpb->textsym.Active_symbol_font = -1;
    dpb->textsym.Active_ascii_font = 0;
    dpb->textsym.Active_flags = 0;
    dpb->raster.brush_type = 15;
    dpb->raster.attr_num = 0;
    dpb->raster.auto_def = FALSE;
    dpb->raster.auto_init = TRUE;
    dpb->raster.rg_props = 0;
    dpb->raster.fill_mode = 1;
    dpb->raster.row_scale = 1.0;
    dpb->raster.column_scale = 1.0;
    dpb->raster.comprast_memory = 8000000;
    dpb->raster.bg = 0;
    dpb->raster.fg = 1;
    dpb->hesym.color = 1;
    dpb->hesym.weight = 0;
    dpb->hesym.style = 1;
    dpb->hesym.flags = DPB_USE_ORIG_COLOR;
    dpb->visible_edge_sym.color = 1;
    dpb->visible_edge_sym.weight = 0;
    dpb->visible_edge_sym.style = 0;
    dpb->visible_edge_sym.flags = DPB_USE_ORIG_COLOR |
                                  DPB_USE_ORIG_WEIGHT |
                                  DPB_USE_ORIG_STYLE;
    dpb->SmartSketchOn = 1 ;
    dpb->EligibleConstraints = 
      DPB_SS_HORIZONTAL |
      DPB_SS_VERTICAL |
      DPB_SS_ON_ELEMENT |
      DPB_SS_TANGENT |
      DPB_SS_PARALLEL |
      DPB_SS_PERPENDICULAR |
      DPB_SS_INTERSECTION |
      DPB_SS_KEYPOINT |
      DPB_SS_TEXTDISPLAYED;

finish:

    return(OM_S_SUCCESS);
}


method wake_up()
{
    IGRlong msg, sts;
    IGRdouble exponent;
    struct GRIOvar_def var_info;
    struct GRdpbdata *dpb;

    /* don't do anything unless this is the master file */

    if (ex$is_invis(mod_osnum = OM_Gw_current_OS)) goto finish;

    /* set up my id so that it is quick & easy to find */

    GRset_dpb_objid(my_id);

    /* 
        Set up the locate eligibility info - this has to be done in
        wakeup since the info depends on classids, which can change
        from one session to another.
    */

    GRdpb_elig_class_init(&msg,my_id,OM_Gw_current_OS);

    /*
        Clear out the abstract geometry buffer.  This is necessary so that
        closing one file and retrieving another will not cause confusion about
        whose geometry is in the buffer.  That could happen if an object in
        the retrieved file got the same object id and osnum as an object whose
        geometry had just been referenced in the closed file.  Depending on
        the object types, the consequences could range from invalid display to
        invalid memory references.
    */

    (IGRboolean)GRabsg_del_all();

    /* map the instance data vla to a structure for easy access */
    dpb = (struct GRdpbdata *)me->data;

    if (dpb->version < DPB_VERSION)
    {
        /*
            This is an existing file, created using a previous version
            of the dpb.  The file must be updated to include and
            initialize the new info.  The first step is to set the data
            vla to the necessary size.
        */

        sts = om$vla_set_dimension(varray = me->data,
                                   size = sizeof(struct GRdpbdata));

        if (!(sts & 1))
        {
            fprintf(stderr, "Failed to bring the dpb up to date ");
            fprintf(stderr, "(file version %d, ", dpb->version);
            fprintf(stderr, "software version %d)\n", DPB_VERSION);
            om$report_error(sts = sts);
        }
        else
        {
          /*
           * The data may have moved...
           */
          dpb = (struct GRdpbdata *)me->data;
          if (dpb->version == 0)
          {
            /* Version 1 changes - added visible edge symbology */
            dpb->visible_edge_sym.color = 1;
            dpb->visible_edge_sym.weight = 0;
            dpb->visible_edge_sym.style = 0;
            dpb->visible_edge_sym.flags = DPB_USE_ORIG_COLOR |
                                          DPB_USE_ORIG_WEIGHT |
                                          DPB_USE_ORIG_STYLE;
          }
          if (dpb->version == 2 || dpb->version == 1 || dpb->version == 0)
          {
            /*
             * Version 2/3 change: add the Smart Sketch elligible constraints
             * and turn the smart sketch on
             */
            dpb->SmartSketchOn = 1;
            dpb->EligibleConstraints = 
              DPB_SS_HORIZONTAL    |
              DPB_SS_VERTICAL      |
              DPB_SS_ON_ELEMENT    |
              DPB_SS_TANGENT       |
              DPB_SS_PARALLEL      |
              DPB_SS_PERPENDICULAR |
              DPB_SS_INTERSECTION  |
              DPB_SS_KEYPOINT      |
              DPB_SS_TEXTDISPLAYED;
          }

          /* mark the dpb as current */
          dpb->version = DPB_VERSION;
        }
    }

    if (!EX_batch_mode && ex$is_temp_wakeup())
    {
        // This is an interactive post-save wakeup.  The file startup command
        // that normally sets up the menus will not get hit in this case, so
        // make adjustments to the menus (popup intercepts, menu icons, ...)
        GRcustomize_menus();

#ifdef ENV5
        // Put the stop sign on the active screen.  TR11911971.
        GRmove_stopsign_to_active_screen();
#endif
    }

    /* other stuff */

    ex$get_cur_mod(id = &dpb->module.md_id.objid,
                   osnum = &dpb->module.md_id.osnum);

    BSchangepar(&msg, BSTOLCHRDHT, dpb->cht);
    BSchangepar(&msg, BSTOLOFFSET, dpb->offset_tol);
    BSchangepar(&msg, BSTOLARCLEN, dpb->arc_tol);
    BSchangepar(&msg, BSTOLMAXSTEP, dpb->maxstep);
    BSchgdeppar(dpb->bastol, &msg);

#ifndef IDRAW
    sts = co$cvtvar(msg = &msg,
                    alias = "GRcolorcal",
                    osnum = OM_Gw_current_OS,
                    var = &var_info);
    if (!(sts & 1))
    {
        var_info.type = GRIO_VAR_INT;
        var_info.contents.ivalue = 0;

        co$addvar(msg = &msg,
                  input_alias = "GRcolorcal",
                  input_string = &var_info);
    }
    else
    {
        if (var_info.contents.ivalue)
        {
            exponent = 0.45;

            RScalccalib(&msg,&exponent,&exponent,&exponent);
            DPset_load_vlt_ptr(RSloadvlt);
            ige$configure_color_table();
        }
    }
#endif

finish:

    return(OM_S_SUCCESS);
}

/* Dummy Function. Original Function is in struct/vscmdsup directory. */
void VSdelete_RevObj_form()
{
}

method global_class.sleep(IGRint type)
{
    OMuword cur_os;

    /* delete static forms so journaling syncs up properly */
    VDdelete_LocateByName();      /* added by ylong for TR179802375 */
    VDdelete_dir_form();
    VSdelete_RevObj_form();

    COdelete_dir_list_form();
    COdelete_dir_form();
    COdelete_note_book_form();
    COdelete_rev_coord_sys_form();
    COdelete_genset_forms();
    GRdelete_current_point_form();

    ex$get_cur_mod( osnum = &cur_os);  // As per TR#179528596 - RR 12/21/95
    if(cur_os == OM_Gw_current_OS)     // IF THE CURENNT FILE OSNUM IS SAME
    {                                  // AS THE OSNUM OF THE GRdpb OBJECT
    COdelete_rev_lib_forms();          // THEN ONLY DELETE IT.
    }                                  // OTHERWISE NOT.

    /* invalidate the dpb objid lookup function */

    if (!(ex$is_invis(mod_osnum = OM_Gw_current_OS)))
    {
        GRset_dpb_objid(-1);
    }

    return(OM_S_SUCCESS);
}


method GRput(IGRint *msg, parameter; IGRchar *buffer)
{
    IGRint levels[1], i;
#ifdef NOTIFICATION
    IGRint notify = FALSE;
#endif
    IGRlong *l;
    struct GRdpbdata *dpb;

    *msg = MSSUCC;
    dpb = (struct GRdpbdata *)me->data;
    switch (parameter)
    {
      case grdpb_bore_locate:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_BORE_LOCATE;
        else
            dpb->bflags &= ~DPB_BORE_LOCATE;
        break;

      case grdpb_dynamics_copy_flag:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_DYNAMICS_COPY_FLAG;
        else
            dpb->bflags &= ~DPB_DYNAMICS_COPY_FLAG;
        break;

      case grdpb_dynamics_on:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_DYNAMICS_ON;
        else
            dpb->bflags &= ~DPB_DYNAMICS_ON;
        break;

      case grdpb_arc_direction:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_ARC_DIRECTION;
        else
            dpb->bflags &= ~DPB_ARC_DIRECTION;
        break;

      case grdpb_associative_flag:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_ASSOCIATIVE_FLAG;
        else
            dpb->bflags &= ~DPB_ASSOCIATIVE_FLAG;
        break;

      case grdpb_ref_shrink_wrap_flag:
        if (*(IGRboolean *)buffer)
            dpb->bflags |= DPB_REF_SHRINK_WRAP_FLAG;
        else
            dpb->bflags &= ~DPB_REF_SHRINK_WRAP_FLAG;
        break;

      case grdpb_ref_background_flag:
        if (*(IGRboolean *)buffer)
            dpb->bflags |= DPB_REF_BACKGROUND_FLAG;
        else
            dpb->bflags &= ~DPB_REF_BACKGROUND_FLAG;
        break;

      case grdpb_mrp_lock:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_MRP_LOCK;
        else
            dpb->bflags &= ~DPB_MRP_LOCK;
        break;

      case grdpb_assoc_read_only_reffile:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_ASSOC_READ_ONLY_REFFILE;
        else
            dpb->bflags &= ~DPB_ASSOC_READ_ONLY_REFFILE;
        break;

      case grdpb_auto_accept_flag:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_AUTO_ACCEPT_FLAG;
        else
            dpb->bflags &= ~DPB_AUTO_ACCEPT_FLAG;
        break;

      case grdpb_change_acs_type:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_CHANGE_ACS_TYPE;
        else
            dpb->bflags &= ~DPB_CHANGE_ACS_TYPE;
        break;

#ifndef IDRAW
      case grdpb_apparent_flag:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_APPARENT_FLAG;
        else
            dpb->bflags &= ~DPB_APPARENT_FLAG;
        break;

      case grdpb_dynamics_all_windows:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_DYNAMICS_ALL_WINDOWS;
        else
            dpb->bflags &= ~DPB_DYNAMICS_ALL_WINDOWS;
        break;

      case grdpb_local_abs:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_LOCAL_ABS_FLAG;
        else
            dpb->bflags &= ~DPB_LOCAL_ABS_FLAG;
        break;
#endif
      case grdpb_chord_height_tolerance:
        dpb->cht = *(IGRdouble *)buffer;
        BSchangepar(msg, BSTOLCHRDHT, *(IGRdouble *)buffer);
        *msg = (*msg == BSSUCC) ? MSSUCC : MSFAIL;
        break;

      case grdpb_offset_tolerance:
        dpb->offset_tol = *(IGRdouble *)buffer;
        BSchangepar(msg, BSTOLOFFSET, *(IGRdouble *)buffer);
        *msg = (*msg == BSSUCC) ? MSSUCC : MSFAIL;
        break;

      case grdpb_arclength_tolerance:
        dpb->arc_tol = *(IGRdouble *)buffer;
        BSchangepar(msg, BSTOLARCLEN, *(IGRdouble *)buffer);
        *msg = (*msg == BSSUCC) ? MSSUCC : MSFAIL;
        break;

      case grdpb_basis_tolerance:
        dpb->bastol = *(IGRdouble *)buffer;
        BSchgdeppar(*(IGRdouble *)buffer, msg);
        *msg = (*msg == BSSUCC) ? MSSUCC : MSFAIL;
        break;

      case grdpb_maximum_step_size:
        dpb->maxstep = *(IGRdouble *)buffer;
        BSchangepar(msg, BSTOLMAXSTEP, *(IGRdouble *)buffer);
        *msg = (*msg == BSSUCC) ? MSSUCC : MSFAIL;
        break;

      case grdpb_hidden_surf_sym:
        dpb->hidsurfsym = *(IGRlong *)buffer;
        break;

      case grdpb_locate_levels:
        l = (IGRlong*)buffer;
        for (i = 0; i < 32; i++) me->layer[i] = l[i];
        break;

#ifndef IDRAW
      case grdpb_unit_lock:
        dpb->unit_lock = *(struct GRunit_lock *)buffer;
        break;
#endif
      case grdpb_active_display:
        dpb->display = *(struct IGRdisplay *)buffer;
        if (EX_active_OS_num == OM_Gw_current_OS)
        {
#ifdef NOTIFICATION
            notify = TRUE;
#else
            GRupdate_adp_forms(msg,grdpb_active_display,buffer);
#endif
        }
        break;

      case grdpb_active_level:
        dpb->layer = *(IGRshort *)buffer;
        if (EX_active_OS_num == OM_Gw_current_OS)
        {
            levels[0] = (IGRint) *(IGRshort *)buffer;
            dp$levels_on_off(msg = msg,
                             levels = levels,
                             num_of_levels = 1);
#ifdef NOTIFICATION
            notify = TRUE;
#else
            GRupdate_adp_forms(msg, grdpb_active_level, buffer);
#endif
        }
        break;

      case grdpb_projection_angle:
        dpb->proj_angle = *buffer;
        break;

      case grdpb_active_angle:
        dpb->angle = *(IGRdouble *)buffer;
        if (EX_active_OS_num == OM_Gw_current_OS)
        {
#ifdef NOTIFICATION
            notify = TRUE;
#else
            GRupdate_adp_forms(msg, grdpb_active_angle, buffer);
#endif
        }
        break;

      case grdpb_dit_tolerance:
        dpb->dit_tol = *(IGRdouble *)buffer;
        break;

      case grdpb_last_point:
        dpb->lastpoint = *(struct EX_button *)buffer;
#ifdef NOTIFICATION
        notify = TRUE;
#endif
        break;

      case grdpb_active_scale:
        OM_BLOCK_MOVE(buffer, dpb->scale, 3 * sizeof(IGRdouble));
        if (EX_active_OS_num == OM_Gw_current_OS)
        {
#ifdef NOTIFICATION
            notify = TRUE;
#else
            GRupdate_adp_forms(msg, grdpb_active_scale, buffer);
#endif
        }
        break;

      case grdpb_active_cs_type:
        strcpy(dpb->cstype, buffer);
        break;

      case grdpb_text_symb:
        dpb->textsym = *(struct GRdpb_text_symb *)buffer;
        break;

      case grdpb_active_prop:
        dpb->objprops = *(unsigned short *)buffer;
        break;

      case grdpb_name_mode:
        dpb->name_mode = *(IGRboolean *)buffer;
        break;

      case grdpb_locate_properties:
        dpb->locprops = *(IGRlong *)buffer;
        break;

      case grdpb_raster_graphics:
        dpb->raster = *(struct GRrgdpb *)buffer;
        break;

      case grdpb_patrn_edge_delta:
        dpb->epdelta = *(IGRdouble *)buffer;
        break;

      case grdpb_patrn_area_deltas:
        dpb->apdelta[0] = ((struct Patrn_area_deltas *)buffer)->x;
        dpb->apdelta[1] = ((struct Patrn_area_deltas *)buffer)->y;
        break;

      case grdpb_model_mode:
        dpb->model_mode = *(IGRchar *)buffer;
        break;

      case grdpb_database_type:
        strncpy(dpb->dbtype, buffer, 3);
        break;

      case grdpb_xhatch_spacing:
        dpb->xhatch_spacing = *(IGRdouble *)buffer;
        break;

      case grdpb_xhatch_angle:
        dpb->xhatch_angle = *(IGRdouble *)buffer;
        break;

      case grdpb_brush_type:
        dpb->raster.brush_type = *(IGRint *)buffer;
        break;

      case grdpb_hesym:
        dpb->hesym = *(struct GRhesym *)buffer;
        break;

      case grdpb_visible_edge_sym:
        dpb->visible_edge_sym = *(struct GRhesym *)buffer;

        /* update the symbology of all drawing views */
        GRdvuphesym ( &dpb->visible_edge_sym );
        break;

      case grdpb_invis_so_on:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_INVIS_SO_ON;
        else
            dpb->bflags &= ~DPB_INVIS_SO_ON;
        break;

      case grdpb_hidden_so_on:
        if (*(IGRboolean*)buffer)
            dpb->bflags |= DPB_HIDDEN_SO_ON;
        else
            dpb->bflags &= ~DPB_HIDDEN_SO_ON;
        break;

      case grdpb_smart_sketch_constraints:
        dpb->EligibleConstraints = *(int *)buffer;
        break;

      case grdpb_smart_sketch_on:
        dpb->SmartSketchOn = *(int *)buffer;
        break;

      default:
        *msg = MSFAIL;
        printf("Unknown parameter sent to the dpb: %d\n", parameter);
        break;
    }

#ifdef NOTIFICATION

    This code was written for 2.0.0 notification of parameter changes

    if (notify)
    {
        long rc;
        struct GRdpb_notify changed;
        struct BMbatchQueue args;
        NDdependent$$NDupdate_msgPkt;

        changed.parameter = parameter;
        changed.value = buffer;
        args.pGenInfo = (char *)&changed;
        om$send(msgPkt = NDdependent$$NDupdate(&rc,&args),
                p_chanselect = &NDparent$notification_chanselect);
    }
#endif

    return(OM_S_SUCCESS);
}

end implementation GRdpb;
