class implementation EMSasectvw;

#include "bserr.h"
#include "bsparameters.h"
#include "emssfintdef.h" /* For EMSINT_TRIM... */
#include "EMSasectvw.h"
#include "OMmacros.h"
#include <alloca.h>
#include "detaildef.h"
#include "exmacros.h"
#include "emsbool.h"
#include "EMSdef.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "asmacros.h"
#include "EMSconstruct.h"
#include "ma.h"
#include "matypemx.h"
#include "matrlmx.h"
#include "maptsxfor.h"
#include "maptscent.h"
#include "maptlnpro.h"
#include "maoptsxfo.h"
#include "maidmx.h"
#include "magscamx.h"
#include "magrotmx.h"
#include "macrossvc.h"
#include "maang2vc.h"
#include "bsparameters.h"
#include "bscrossp.h"
#include "bschangepar.h"


#define  ISECT_INCR_BUF    20

from GRlistener import GRnotifylis;
from GRdrawview import GRget_model_geometry,
                       GRget_projection_angle,
                       GRget_drawview_scale,
                       GRget_drawing_attachment_id;
from GRdvattach import GRget_drawing_view_id;
from GRreffile  import GRgetscale;
from EMSgencompsf import EMmake_comp;
from EMSsurface   import EMmk_nat_bdry,
                         EMget_point_on_surface,
                         EMgetedges,
                         EMfix_creator_id,
                         EMintsurf_saveside,
                         EMgetactiveid, 
                         EMputLsIfNotThere;
from EMSdpr       import EMmake_primitive1;
from EMSedge      import EMget_props,
                         EMset_props;
from EMSsubbs     import EMproject_curve_onto_surface;
from EMSpointer import EMget_pointer_info,EMput_pointer_info;

extern OMuword OPP_EMSslboolean_class_id;
/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;


%safe
static perform_intersect_elements(); 
%endsafe

method EMconstruct_associative(IGRlong *EMmsg;
                               IGRushort const_options;
                               OM_S_OBJID old_objid;
                               IGRint nb_root;
                               IGRchar *parent_info;
                               IGRint type;
                               IGRchar *recomp_info;
                               struct GRvg_construct *construct_list)

/* ************************************************************************

Description

 This method constructs an associative sectional view object.  This object
parents are:  a cutting plane line, a drawing view and one or more model
(solid) objects.  The cutting plane line is used in conjuction with a view
z vector to create cutting plane(s).  The cutting plane(s) are then
intersected with the model objects.  The resulting intersection elements are
them made planar with the first cutting plane and the intersection elements
are connected and closed.  The intersection elements are then rotated to be
normal to the above mentioned z vector, and the origin of the drawing view
is used as this elements origin.

Arguments
 Input
  nb_root : Number of roots.
  type : Type to interpret the recomputation information.
  old_objid : Objid of the object which has gotten a recompute message.
  const_options : Currently can be set to NULL.
  parent_info : Information about parents.
  construct_list : construction information
  info : Recomputation information. This better not be NULL.

 Output
  EMmsg : Completion message.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_Fail : If there is failure

History
 09/21/91 : WBC  : Creation
 Sudha   06/01/93: modified to handle BSprototype headers
 KNAP    06/16/94: Added a static function to perform intersect between
                   the plane and the model. In case of failure during 
                   closing the open groups, a re-try is performed using
                   double_chk option.
 SpB     09/09/96  modified to handle recreate solid after deletion

*********************************************************************** */

{
    extern OMuword OPP_GRcurve_class_id,
                   OPP_EMSplane_class_id,
                   OPP_GRgrgrp_class_id,
                   OPP_GRcontext_class_id;

    extern IGRdouble  fabs();

    extern IGRlong EMintersect_two_element(), EFget_cut_line_segs(),
                   EFfind_non_orthogonal_segments(), EFclose_planar_elems();


    IGRlong status, rc, num_points = 2;
    unsigned int root_count;
    OMuint dv_attach_index;
    int ii,i, ret_code;
    IGRint num_segments, num_seg_pts, index1, index2, num_models, 
           num_elems, invalid_segment, num_isect_elems, proj_angle,
           num_connect_planes, orig_num_segs, buf_size, num_edges,
           connect_index, count, orig_num_seg_pts, align_seg_index,
           isect_buf_size, num_objects, first_sect_model_index,
           first_unsect_model_index, total_num_planes, total_num_isect_elems,
           num_non_isect_elems;
    IGRdouble save_cht, *plane_nrml_vec, poles[12], u_knots[4], v_knots[4],
              cur_seg_vec[3], align_matrix[16], rot_axis[3], angle,
              proj_pt[3], tparm, direction_vec[3], center_pt[3], delta_vec[3],
              aligned_seg[6], *aligned_seg_ptr, origin[3], view_z_vector[3],
              chord_height_tol, proj_plane_segment[6], view_scale[3],
              model_scale, tmp_matrix[16], scale_array[4], angle_array[3],
              rotation_angle,dt_vec[3];
    GRrange   model_range,
              total_range;
    IGRpoint  *segments,
              *aligned_segments,
              tmp_point,
              first_plane_pt;
    IGRlong   number_of_objects = 0;
    GRobjid   newobjid;
    GRobjid   *proj_objects;
    GRobjid   *plane_ids;
    OM_S_OBJECT_LINKAGE  coincedent_edge,
                        *listener_list;
    struct    GRid  cutting_surface_grid;
    struct    GRid *grids = NULL;
    struct    GRid *intersect_elems;
    struct    GRid my_GRid;
    struct    GRid *elems;
    struct    GRid *parent_grids;
    struct    GRid  comp_surface_grid;
    struct    GRid  boolean_grid;
    struct    GRid *edges;
    struct    GRid *tmp_grid_ptr;
    struct    GRid  dv_grid;       /* drawing view id */
    struct    GRid  dv_attach_grid;
    struct    GRid  source_grid,
                    source_grid2;
    struct    GRid  saveside_grid;
    struct    GRid  *non_isect_elems;
    struct    EMSsect_view_info *info = NULL;
    struct    EMS_ASsect_view_info *sect_view_info = NULL;
    struct    EMS_ASsection_view_info *section_view_info = NULL,
                                       sect_vw_info;
    struct    EMS_ASsectvw_info *sectvw_info = NULL;
    struct    EMS_ASsectvw_tran_info *sectvw_tran_info = NULL;
    struct    GRlc_info *model_info_ptr, *line_info_ptr,
                        curve_info, surface_info;
    struct    IGRbsp_surface plane_geom;
    struct    GRvg_construct const_list;
    struct    IGRline        rot_axis_line,
                             alignment_line;
    struct    IGRlbsys       lbsys;
    struct EMS_SVconstruct_info *sv_construct_info;
    struct EMSdataselect         cutting_surf_data;
    struct GRmd_env             *dv_module_env;
    union EMSparent_info *roots = NULL;
    IGRuint *root_type = NULL;
    OM_S_CHANSELECT to_comps,
                    to_common_edge,
                    chansel;
    IGRushort trimming_options, inters_opt, edge_props;
    OMuword   classid;
    IGRshort matrix_type,
             props,
             action;
    GRspacenum plane_osnum;
    IGRboolean recreate_solid,pl_mdl_int, world, ret_value, trimming_required,
               first_seg_align, first_angle_proj, null_modid, parallel_line,
               have_comp_surface,show_visible_lines, project_intersections,
               project_aligned, segments_parallel, have_graphic_group,
               *line_seg_type, process_model, double_chk = FALSE;
    IGRmatrix tr_matrix,trans_matrix;

    status = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;
    segments = NULL;
    elems = NULL;
    plane_ids = NULL;
    total_num_planes = 0;
    num_connect_planes = num_isect_elems = num_elems =
    total_num_isect_elems = 0;
    have_comp_surface = FALSE;
    connect_index = OM_K_MAXINT;

    BSEXTRACTPAR(&rc, BSTOLCHRDHT, save_cht);
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;
    root_count = nb_root;
    root_type = (unsigned int *) alloca(sizeof(IGRint) * root_count);
    EMerr_hndlr(!root_type, *EMmsg, EMS_E_NoStackMemory, wrapup);

    status = om$send (msg = message EMSagrp.EMget_parent_type(EMmsg, type,
                                                              root_count,
                                                              root_type),
                      targetid = my_id);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

    roots = (union EMSparent_info *)alloca(root_count*
                                              sizeof(union EMSparent_info));
    EMerr_hndlr(!roots, *EMmsg, EMS_E_NoStackMemory, wrapup);

    status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg, NULL,
                                                               root_count,
                                                               parent_info,
                                                               root_type,
                                                               roots),
                      targetid = my_id);

    if ((type == EMS_ASsectvw || type == EMS_ASsectvw_tran) ||
        (type == EMS_ASsection_view) ||
        (type == EMS_ASsect_view))
    {
        /* if parent type == EMS_ASsectvw or EMS_ASsection_view, a GRdvattach
         * object is a parent of the Section View, else if
         * type == EMS_ASsect_view a EMSdrawview object is a parent
         * of the Section View
         */

        if ((type == EMS_ASsectvw || type == EMS_ASsectvw_tran) ||
            (type == EMS_ASsection_view))
        {
            /* find the drawing view attachment object */

            for (dv_attach_index = CUT_PLN_LINE_INDEX + 1;
                 dv_attach_index < root_count; dv_attach_index++)
            {
                status = om$get_classid(osnum = roots[dv_attach_index].lc_info.located_obj.osnum,
                                        objid = roots[dv_attach_index].lc_info.located_obj.objid,
                                        p_classid = &classid);
                EMerr_hndlr(!(1 & status), *EMmsg, EMS_E_Fail, wrapup);

                if (classid == OPP_GRdvattach_class_id)
                {
                    dv_attach_grid.objid = roots[dv_attach_index].lc_info.located_obj.objid;
                    dv_attach_grid.osnum = roots[dv_attach_index].lc_info.located_obj.osnum;
                    break;
                }
            }
            EMerr_hndlr((dv_attach_index >= root_count), *EMmsg, EMS_E_Fail,
                        wrapup);

            /* get the drawing view's id from the drawing view attachment */

            status = om$send (msg = message GRdvattach.GRget_drawing_view_id(
                                                           &rc, &dv_grid),
                              targetid = dv_attach_grid.objid,
                              targetos = dv_attach_grid.osnum);
            EMerr_hndlr(!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

            dv_module_env = &roots[dv_attach_index].lc_info.module_info;

            if (type == EMS_ASsectvw)
            {
                sectvw_info = (struct EMS_ASsectvw_info *) recomp_info;
                sect_view_info = &sectvw_info->view_info;
                rotation_angle = sectvw_info->rot_angle;
            }
            else 
            if(type == EMS_ASsectvw_tran)
              {
                sectvw_tran_info = (struct EMS_ASsectvw_tran_info *)recomp_info;
                sect_view_info = &sectvw_tran_info->view_info;
                rotation_angle = sectvw_tran_info->rot_angle;
                if(old_objid != NULL_OBJID)
                  for(ii = 0; ii < 16;ii++)
                  trans_matrix[ii]= sectvw_tran_info->rot_matrix[ii];
              }
            else  /* type == EMS_ASsection_view */
            {
                section_view_info =
                               (struct EMS_ASsection_view_info *) recomp_info;
                sect_view_info = &section_view_info->view_info;
                rotation_angle = section_view_info->rot_angle;
            }
        }
        else if (type == EMS_ASsect_view)
        {
            sect_view_info = (struct EMS_ASsect_view_info *) recomp_info;
            dv_grid.objid = roots[DRAW_VIEW_INDEX].lc_info.located_obj.objid;
            dv_grid.osnum = roots[DRAW_VIEW_INDEX].lc_info.located_obj.osnum;
            dv_module_env = &roots[DRAW_VIEW_INDEX].lc_info.module_info;
            dv_attach_index = DRAW_VIEW_INDEX;
        }

        first_sect_model_index = dv_attach_index + 1;
        first_unsect_model_index = CUT_PLN_LINE_INDEX + 1;
        trimming_required = (sect_view_info->flags & SV_TRIMMING_REQUIRED) ?
                            TRUE : FALSE;
        first_seg_align = (sect_view_info->flags & SV_FIRST_SEG_ALIGN) ? TRUE :
                          FALSE;
      
        show_visible_lines = (sect_view_info->flags & SV_SHOW_VISIBLE_LINES) ? 
                              TRUE : FALSE;

        /** check whether recreation is required or not -SpB : 09/09/96**/
        if(const_options & EMSasconst_recompute)
        {
           if (!show_visible_lines)
           {
             if (sect_view_info->flags & SV_RECREATE_SOLID)
             {
                show_visible_lines = 1;
             }
           }
        }

        project_intersections=(sect_view_info->flags & SV_PROJ_INTERSECTIONS)?
                              TRUE : FALSE;

        chord_height_tol = sect_view_info->cht;
        view_z_vector[0] = sect_view_info->z_vec[0];
        view_z_vector[1] = sect_view_info->z_vec[1];
        view_z_vector[2] = sect_view_info->z_vec[2];

        status = om$send (msg = message GRdrawview.GRget_projection_angle(
                                               &rc, &proj_angle),
                          senderid = NULL_OBJID,
                          targetid = dv_grid.objid,
                          targetos = dv_grid.osnum);
        EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

        first_angle_proj = (proj_angle == GR_DS_FIRST_ANGLE) ? TRUE : FALSE;

        if (type == EMS_ASsectvw || type == EMS_ASsectvw_tran)
        {
            /* the origin is stored in the section view's instance data */

            if(type == EMS_ASsectvw)
              {
              origin[0] = sectvw_info->origin[0];
              origin[1] = sectvw_info->origin[1];
              origin[2] = sectvw_info->origin[2];
              }
            else
              {
              origin[0] = sectvw_tran_info->origin[0];
              origin[1] = sectvw_tran_info->origin[1];
              origin[2] = sectvw_tran_info->origin[2];
              }
        }
        else
        {
            /* get the origin of the associated drawing view which is to
             * be used as the origin of this section view
             */

            status = om$send (msg = message GRdrawview.GRget_model_geometry(&rc,
                                                           dv_module_env,
                                                           &lbsys),
                              senderid = NULL_OBJID,
                              targetid = dv_grid.objid,
                              targetos = dv_grid.osnum);
            EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

            origin[0] = lbsys.matrix[3];
            origin[1] = lbsys.matrix[7];
            origin[2] = lbsys.matrix[11];
        }
    }
    else if ( (type == EMS_ASintersect_elements) ||
              (type == EMS_ASintersect_elements1))
    {
        info = (struct EMSsect_view_info *) recomp_info;
        trimming_required = (info->props & EMS_TRIMMING_REQUIRED) ? TRUE : FALSE;
        first_seg_align = (info->flags & FIRST_SEG_ALIGN) ? TRUE :
                          FALSE;
        first_angle_proj = (info->flags & SV_FIRST_ANGLE_PROJ) ? TRUE : FALSE;
        show_visible_lines = project_intersections = FALSE;

        chord_height_tol = info->cht;

        view_z_vector[0] = info->z_vec[0];
        view_z_vector[1] = info->z_vec[1];
        view_z_vector[2] = info->z_vec[2];

        origin[0] = info->placement_pt[0];
        origin[1] = info->placement_pt[1];
        origin[2] = info->placement_pt[2];
    }

    trimming_options =  (trimming_required) ?
                         EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA |
                         EMSINT_TRIM_COPLANAR | EMSINT_TRIM_PROCOVERLAP : 
                         NULL;

    /*
     * If this is the first construction, handle stop otherwise do not handle
     * stop.
     */

    if (!(const_options & EMSasconst_recompute))
        {trimming_options |= EMSINT_TRIM_HANDLESTOP;
         }
    BSchangepar(&rc, BSTOLCHRDHT, chord_height_tol);

    /* the first root object is the cutting plane line and the second one
     * is the model object
     */

    line_info_ptr = &roots[CUT_PLN_LINE_INDEX].lc_info;

    plane_geom.poles = poles;
    plane_geom.u_knots = u_knots;
    plane_geom.v_knots = v_knots;
    world = TRUE;

    /* get the line segments of the cutting plane line */

    status = EFget_cut_line_segs(EMmsg, &line_info_ptr->located_obj,
                                 &line_info_ptr->module_info,
                                 &num_segments, &segments);
    if (!(1&status&*EMmsg)) goto wrapup;

    num_seg_pts = num_segments * 2;  /* need the number of points */

    /* if the last segment is to be used for alignment, swap the points in
     * the segments to reverse the order of the segments
     */

    if (! (first_seg_align))
    {
        for (i = 0; i < num_segments; i++)
        {
            OM_BLOCK_MOVE(segments[i], tmp_point, sizeof(IGRpoint));
            OM_BLOCK_MOVE(segments[num_seg_pts - i - 1], segments[i],
                          sizeof(IGRpoint));
            OM_BLOCK_MOVE(tmp_point, segments[num_seg_pts - i - 1],
                          sizeof(IGRpoint));
        }
    }

    /* get an array of flags that indicates whether of not each of  the line
     * segments are orthogonal to the first line segment; the non-orthogonal
     * line segments will be used to create cutting planes
     */

    line_seg_type = NULL;
    line_seg_type = (IGRboolean *) alloca(num_segments * sizeof(IGRboolean));
    EMerr_hndlr(!line_seg_type, *EMmsg, EMS_E_NoStackMemory, wrapup);

    orig_num_segs = num_segments;
    orig_num_seg_pts = num_segments * 2;

    status = EFfind_non_orthogonal_segments(EMmsg, orig_num_segs, segments,
                                            &num_segments, line_seg_type,
                                            &invalid_segment);
    if (!(1&status&*EMmsg)) goto wrapup;

    if (*EMmsg == EMS_S_Success)
        parallel_line = TRUE;
    else
        parallel_line = FALSE;

    num_seg_pts = num_segments * 2;  /* # of segments may have changed */

    /* allocate memory for an array of aligned segments; can copy in the first
     * segment because it is what the other segments are aligned with
     */

    aligned_segments = NULL;
    aligned_segments = (IGRpoint *) alloca(num_seg_pts * sizeof(IGRdouble) * 3);
    EMerr_hndlr(!aligned_segments, *EMmsg, EMS_E_NoStackMemory, wrapup);

    OM_BLOCK_MOVE(segments, aligned_segments, sizeof(IGRdouble) * 6);

    /* allocate memory for the intersection objects */

    intersect_elems = NULL;
    isect_buf_size = num_segments * 8;
    intersect_elems = (struct GRid *) alloca(isect_buf_size *
                                             sizeof(struct GRid));
    EMerr_hndlr(!intersect_elems, *EMmsg, EMS_E_NoStackMemory, wrapup);

    plane_nrml_vec = NULL;
    plane_nrml_vec = (IGRdouble *) alloca(orig_num_segs *
                                          sizeof(IGRdouble) * 3);
    EMerr_hndlr(!plane_nrml_vec, *EMmsg, EMS_E_NoStackMemory, wrapup);

    for (i = 0; i < orig_num_seg_pts; i += 2)
    {
        /* for each cutting plane line segment, need to construct a cutting
         * plane
         */

        for (index1 = 0; index1 < 3; index1++)
            cur_seg_vec[index1] = segments[i + 1][index1] -
                                    segments[i][index1];

        status = BScrossp(&rc, cur_seg_vec, view_z_vector,
                          &plane_nrml_vec[(i/2) * 3]);
        EMerr_hndlr(!status || rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    }

    if (old_objid == NULL_OBJID)
    {
        /* keeping track of which objects don't intersect any of the cutting
         * planes; this is done only at the initial creation of the section
         * view object (during recomputes construct_list->class_attr is not
         * a pointer to struct EMS_SVconstruct_info); need to set class_attr
         * to NULL so that EMintersect_two_element will determine the
         * appropriate class specific info; two lists are being created:
         * sv_construct_info is passed back so that the caller of
         * EMinit_associative can take the appropriate action, and
         * non_isect_elems is used in this method keep track of the models
         * that aren't intersected by any of the cutting planes; these lists
         * are not identical since sv_construct_info may contain intermediate
         * objects such as ASsourcein objects, whereas non_isect_elems will
         * only contain the ids of the actual solids
         */

        sv_construct_info = (struct EMS_SVconstruct_info *) construct_list->class_attr;
        sv_construct_info->num_ni_parents = 0;
        construct_list->class_attr = NULL;
        non_isect_elems = NULL;
        non_isect_elems = (struct GRid *) alloca((root_count -
                                                  first_sect_model_index) *
                                                 sizeof(struct GRid));
        EMerr_hndlr(!non_isect_elems, *EMmsg, EMS_E_NoStackMemory, wrapup);
        num_non_isect_elems = 0;
    }

    for (num_models = first_unsect_model_index; num_models < root_count;
         num_models++)
    {
        if (num_models != dv_attach_index)
        {
            model_info_ptr = &roots[num_models].lc_info;

            status = om$send(msg = message GRgraphics.GRgetrang (&rc,
                               &model_info_ptr->module_info.md_env.matrix_type,
                               model_info_ptr->module_info.md_env.matrix,
                               &world, model_range), 
                             senderid = NULL_OBJID,
                             targetid = model_info_ptr->located_obj.objid,
                             targetos = model_info_ptr->located_obj.osnum);
            EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

            if ((num_models == first_unsect_model_index) ||
                ((first_unsect_model_index == dv_attach_index) &&
                 (num_models == first_sect_model_index)))
                OM_BLOCK_MOVE(model_range, total_range, sizeof(GRrange));
            else
                EFunion_ranges(model_range, total_range);
        }
    }

    /* allocate array of GRobjids to hold the ids of the cutting planes */

    plane_ids = (GRobjid *) alloca(sizeof(GRobjid) * orig_num_segs);
    EMerr_hndlr(!plane_ids, *EMmsg, EMS_E_NoStackMemory, wrapup);

    /* initialize */

    const_list.msg = &rc;
    const_list.env_info = construct_list->env_info;
    const_list.newflag = FALSE;
    const_list.level = 1;
    const_list.properties = 0;
    const_list.geometry = (IGRchar *) &plane_geom;
    const_list.display = construct_list->display;
    const_list.class_attr = NULL;
    const_list.name = NULL;

    /* if this is an aligned section and the flag to project intersections
     * is set, create a plane (section view plane) onto which intersection
     * elements will be projected that are not planar to the section view plane
     */

    if ((num_segments > 1) &&
        (! parallel_line) &&    /* aligned section view */
        (project_intersections))
    {
        /* create a line segment to be used in defining the projection
         * plane; the first point will be the first point of the first
         * cutting plane line segment and the second point will be generated
         * by projecting the last point of the last cutting plane line
         * segment onto the the line defined by the first cutting plane line
         * segment (the segment about which the section view is aligned)
         */

        OM_BLOCK_MOVE(segments[0], proj_plane_segment, sizeof(IGRdouble) * 3);

        alignment_line.point1 = segments[0];
        alignment_line.point2 = segments[1];

        ret_value = MAptlnproj(&rc, segments[orig_num_seg_pts - 1],
                               &alignment_line, &proj_plane_segment[3], &tparm);

        EMerr_hndlr (!(1 & rc & ret_value), *EMmsg, EMS_E_Fail, wrapup);

        EFconstruct_xs_plane(&rc, total_range, proj_plane_segment,
                             &plane_nrml_vec[0], view_z_vector, 1.05,
                             &plane_geom, &pl_mdl_int);
        EMerr_hndlr (!(1 & rc), *EMmsg, EMS_E_Fail, wrapup);

        status = om$construct(classid = OPP_EMSplane_class_id,
                              osnum = construct_list->env_info->md_id.osnum,
                              p_objid = &surface_info.located_obj.objid,
                              msg = message GRgraphics.GRconstruct
                                                             (&const_list));
        EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_OMerror, wrapup);
        surface_info.located_obj.osnum = construct_list->env_info->md_id.osnum;
        OM_BLOCK_MOVE(construct_list->env_info, &surface_info.module_info,
                      sizeof(struct GRmd_env));
        OM_BLOCK_MOVE(construct_list->env_info, &curve_info.module_info,
                      sizeof(struct GRmd_env));
        project_aligned = TRUE;

        rc = EMmake_chanselect(GRcmpowner_to_components, &to_comps);
        EMerr_hndlr (!(1 & rc), *EMmsg, EMS_E_Fail, wrapup);
    }
    else
        project_aligned = FALSE;

    plane_osnum = construct_list->env_info->md_id.osnum;

    if (root_count > first_sect_model_index)
    {
        for (index1 = 0; index1 < orig_num_seg_pts; index1 += 2,
                                                    total_num_planes++)
        {
            /* construct cutting planes for all of the segments if visible
             * lines are to be shown and this is not a rotated aligned view
             * since these planes will be joined together as a composite
             * surface to be used in a boolean operation with the solids;
             * otherwise just construct planes for the non-orthogonal segments
             */

            if (line_seg_type[index1/2] ||   /* non-orthogonal segment */
                (show_visible_lines &&
                 parallel_line ||
                 project_intersections))
            {
                EFconstruct_xs_plane(&rc, total_range, segments[index1],
                                     &plane_nrml_vec[(index1/2) * 3],
                                     view_z_vector, 1.05,
                                     &plane_geom, &pl_mdl_int);
                EMerr_hndlr (!(1 & rc), *EMmsg, EMS_E_Fail, wrapup);

                status = om$construct(classid = OPP_EMSplane_class_id,
                                      osnum = construct_list->env_info->md_id.osnum,
                                      p_objid = &line_info_ptr->located_obj.objid,
                                      msg = message GRgraphics.GRconstruct
                                                             (&const_list));
                EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_OMerror, wrapup);

                plane_ids[index1/2] = line_info_ptr->located_obj.objid;

                if (! index1)
                    OM_BLOCK_MOVE(plane_geom.poles, first_plane_pt,
                                  sizeof(IGRdouble) * 3);
            }
            else
                plane_ids[index1/2] = NULL_OBJID;
        }
    }

    inters_opt = NULL;
    for (num_models = first_sect_model_index; num_models < root_count;
         num_models++)
    {
        model_info_ptr = &roots[num_models].lc_info;

     try_double_chk:

        for (num_isect_elems = 0, i = 0, align_seg_index = 0;
             i < orig_num_segs; i++)
        {
            if (line_seg_type[i])
            {
                proj_objects = NULL;
                line_info_ptr->located_obj.objid = plane_ids[i];
                line_info_ptr->located_obj.osnum = plane_osnum;
                double_chk = inters_opt & EMS_SFINT_DOUBLECHECK;
             /*
              * Made a new static function specific to Create Section View.
              * This was done to facilitate double check processing, when
              * there is an error while closing of the open curves. The
              * original call to EMintersect_two_element is now commented out.
              * --- knap (06/15/94).
              */
                perform_intersect_elements( EMmsg, model_info_ptr,
                                            line_info_ptr, trimming_options,
                                            inters_opt, construct_list, 
                                            &number_of_objects, &grids);
/****************************************************************************
                status = EMintersect_two_element(model_info_ptr, line_info_ptr,
                                                 trimming_options,
                                                 construct_list,
                                                 &number_of_objects,
                                                 &grids, EMmsg);
*****************************************************************************/
                if (!(const_options & EMSasconst_recompute) &&
                    (*EMmsg == EMS_I_Interrupt))
                    goto wrapup;

                if (!(1 & status & *EMmsg))
                    goto wrapup;

                /* find a matrix that will align the intersection elements;  the
                 * intersection elements should be planar to the first cross
                 * section plane and aligned (end-to-end) with the elements of
                 * the previous plane; the elements from the first plane don't
                 * need to be changed.
                 */

                if (i)
                {
                    /* the following alignment of the cutting plane line segment
                     * needs to be done even if the corresponding plane did not
                     * intersect the solid
                     */

                    status = EFget_alignment_matrix(aligned_segments[align_seg_index],
                                                    segments[i*2], align_matrix,
                                                    &segments_parallel);
                    EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_Fail, wrapup);
 
                    ret_value = MAtypemx(&rc, align_matrix, &matrix_type);
                    EMerr_hndlr (!(1 & ret_value), *EMmsg, EMS_E_Fail, wrapup);

                    /* align the segment; only need to first time through */

                    align_seg_index += 2;

                    if (num_models == first_sect_model_index)
                    {
                        ret_value = MAoptsxform(&rc, &num_points, &matrix_type,
                                                align_matrix, segments[i*2],
                                                aligned_segments[align_seg_index]);
                        EMerr_hndlr (!(1 & rc & ret_value), *EMmsg, EMS_E_Fail,
                                     wrapup);
                    }

                    if (*EMmsg != EMS_I_NoIntersection)
                    {
                        for (index1 = 0; index1 < number_of_objects; index1++)
                        {
                            if ((! segments_parallel) &&
                                  (project_aligned))
                            {
                                /* project the intersection elements onto the
                                 * section view plane (projection plane)
                                 * constructed above; if the object returned from
                                 * EMintersect_two_element is a graphic group,
                                 * process each of its components
                                 */

                                status = om$get_classid(osnum = grids[index1].osnum,
                                                        objid = grids[index1].objid,
                                                        p_classid = &classid);
                                EMerr_hndlr(!(1 & status), *EMmsg, EMS_E_Fail,
                                            wrapup);

                                status = om$is_ancestry_valid(subclassid = classid,
                                                              superclassid = OPP_GRgrgrp_class_id);
 
                                EMerr_hndlr(!(1 & status), *EMmsg, EMS_E_Fail,
                                            wrapup);

                                if (status == OM_S_SUCCESS)
                                {
                                    have_graphic_group = TRUE;

                                    status = om$get_channel_count(osnum = grids[index1].osnum,
                                                                  objid = grids[index1].objid,
                                                                  p_chanselect = &to_comps,
                                                                  count = (OMuint *)&num_elems);
                                    EMerr_hndlr(!(1 & status), *EMmsg, EMS_E_Fail,
                                                wrapup);
                                }
                                else
                                {
                                    have_graphic_group = FALSE;
                                    num_elems = 1;
                                }

                                num_objects = 0;
                                proj_objects = NULL;

                                for (index2 = 0; index2 < num_elems; index2++)
                                {
                                    if (have_graphic_group)
                                    {
                                        status = om$get_objid_at_index(
                                                    osnum = grids[index1].osnum,
                                                    objid = grids[index1].objid,
                                                    p_chanselect = &to_comps,
                                                    index = index2,
                                                    objidaddr = &curve_info.located_obj.objid,
                                                    osnumaddr = &curve_info.located_obj.osnum);
                                    }
                                    else
                                    {
                                        curve_info.located_obj.osnum = grids[index1].osnum;
                                        curve_info.located_obj.objid = grids[index1].objid;
                                    }

                                    /* project the intersection element onto the
                                     * projection (section view) plane
                                     */

                                    status = om$send (msg = message EMSsubbs.EMproject_curve_onto_surface(
                                                          &curve_info,
                                                          &surface_info,
                                                          construct_list,
                                                          plane_nrml_vec, 0, 0,
                                                          (IGRlong *)&num_objects,
                                                          &proj_objects, &rc),
                                                      senderid = NULL_OBJID,
                                                      targetid = surface_info.located_obj.objid,
                                                      targetos = surface_info.located_obj.osnum);
                                    EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail,
                                                 wrapup);
                                }  /* for (index2 = 0;index2 < num_elems;index2++)*/

                                /* delete the original intersection objects
                                 * since we only want the projection objects
                                 */

                                om$send(msg = message GRgraphics.GRdelete(&rc,
                                                      construct_list->env_info),
                                        targetid = grids[index1].objid,
                                        targetos = grids[index1].osnum);
                            }
                            else
                            {
                                status = om$send (msg = message GRgraphics.GRxform(&rc,
                                                   construct_list->env_info,
                                                   &matrix_type, align_matrix,
                                                   &newobjid),
                                                  senderid = NULL_OBJID,
                                                  targetid = grids[index1].objid,
                                                  targetos = grids[index1].osnum);
                                EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail,
                                             wrapup);

                                /* only expecting one object; either a graphic
                                 * group or a curve
                                 */

                                if (number_of_objects != 1)
                                {
                                    *EMmsg = EMS_E_Fail;
                                    goto wrapup;
                                }
                                num_objects = 1;
                            }
                        }
                    }
                }
                else
                    num_objects = number_of_objects;

                if (*EMmsg != EMS_I_NoIntersection)
                {
                    if (num_isect_elems + num_objects > isect_buf_size)
                    {
                        tmp_grid_ptr = (struct GRid *) alloca((isect_buf_size +
                                        num_objects + ISECT_INCR_BUF) *
                                        sizeof(struct GRid));
                        EMerr_hndlr(!tmp_grid_ptr, *EMmsg,
                                   EMS_E_NoStackMemory, wrapup);
                        OM_BLOCK_MOVE(intersect_elems, tmp_grid_ptr,
                                      num_isect_elems * sizeof(struct GRid));
                        intersect_elems = tmp_grid_ptr;
                        isect_buf_size += num_objects + ISECT_INCR_BUF;
                    }

                    /* if proj_objects is non-null, the intersections objects
                     * have been projected and are in the om$malloc'd array
                     * proj_objects
                     */

                    if (proj_objects)
                    {
                        for (index2 = 0; index2 < num_objects; index2++)
                        {
                            intersect_elems[num_isect_elems + index2].objid = proj_objects[index2];
                            intersect_elems[num_isect_elems + index2].osnum = curve_info.located_obj.osnum;
                        }

                        om$dealloc(ptr = proj_objects);
                        proj_objects = NULL;
                    }
                    else  /* non-projected intersection elements */
                    {
                        intersect_elems[num_isect_elems].objid = grids[0].objid;
                        intersect_elems[num_isect_elems].osnum = grids[0].osnum;
                    }
                    num_isect_elems += num_objects;
                    total_num_isect_elems += num_objects;
                    if (grids)
                    {
                        om$dealloc (ptr = grids);
                        grids = NULL;
                        num_objects = 0;
                    }
                }
            }

        }  /* for (num_isect_elems = 0; i = 0; i < num_seg_pts; i += 2) */

        if (! num_isect_elems)
        {
            /* none of the cutting line planes intersected this model;
             * if this is not a recompute, record which model this is in
             * struct EMS_SVconstruct_info (which is struct GRid's -
             * a kludge until an argument is added to
             * EMinit_associative and EMconstruct_associative for returning
             * info) so that the model can be disconnected as a parent by
             * the caller of EMinit_associative - must set the objid of the
             * next enty to NULL_OBJID to indicate end of the array
             */

            if (old_objid == NULL_OBJID)
            {
                if (parent_info)
                {
                    parent_grids = (struct GRid *) parent_info;
                    sv_construct_info->ni_parents[sv_construct_info->num_ni_parents].osnum = parent_grids[num_models].osnum;
                    sv_construct_info->ni_parents[sv_construct_info->num_ni_parents].objid = parent_grids[num_models].objid;
                }
                else
                {
                    sv_construct_info->ni_parents[sv_construct_info->num_ni_parents].osnum = model_info_ptr->located_obj.osnum;
                    sv_construct_info->ni_parents[sv_construct_info->num_ni_parents].objid = model_info_ptr->located_obj.objid;
                }
                sv_construct_info->num_ni_parents++;
                sv_construct_info->ni_parents[sv_construct_info->num_ni_parents].objid = NULL_OBJID;
                non_isect_elems[num_non_isect_elems].objid =
                                           model_info_ptr->located_obj.objid;
                non_isect_elems[num_non_isect_elems].osnum =
                                           model_info_ptr->located_obj.osnum;
                num_non_isect_elems++;
            }

            continue;
        }

        /* try to close all open intersection elements by first connecting any
         * adjacent elements and then constructing line segments to close the
         * remaining elements (the elements will be connected using a composite
         * curve); need to first get a bspline surface (plane) structure that
         * encompasses all the elements
         */

        if (num_segments > 1)
        {
            if (num_models == first_sect_model_index)
            {
                OM_BLOCK_MOVE(aligned_segments, aligned_seg,
                              sizeof(IGRdouble) * 3);
                OM_BLOCK_MOVE(aligned_segments[num_seg_pts - 1],
                              &aligned_seg[3], sizeof(IGRdouble) * 3);
            }

            aligned_seg_ptr = aligned_seg;
        }
        else
        {
            aligned_seg_ptr = segments[0];
        }

        EFconstruct_xs_plane(&rc, model_range, aligned_seg_ptr,
                             plane_nrml_vec, view_z_vector, 1.05,
                             &plane_geom, &pl_mdl_int);
        EMerr_hndlr (!(1 & rc), *EMmsg, EMS_E_Fail, wrapup);

        status = EFclose_planar_elems(&rc, num_isect_elems, intersect_elems,
                                      construct_list, &plane_geom, &num_elems,
                                      &elems);
        /*
         * On error free all the composite curve grids, and try 
         * generating the composites with double check option set.
         * ---knap (06/15/94).
         */
        if ( EMSerror(1&status&rc))
        {   
           if (!double_chk)
           {
              if (grids) om$dealloc(ptr = grids);grids = NULL;
              inters_opt = EMS_SFINT_DOUBLECHECK;
              goto try_double_chk;
           }
           else
              goto wrapup;
        }

        if(old_objid == NULL_OBJID)
          {
          if(num_elems)
            {
            struct GRid total_group;
            IGRlong msg,flag=1,graph_index = OM_K_MAXINT;
            total_group.osnum = elems[0].osnum;
            status = EFbuild_graphic_group(num_elems,
                                        NULL,
                                        elems,
                                        construct_list,
                                        &total_group.objid,
                                        &msg);
            if (!(1 & status & msg))
                 goto wrapup;

            status = om$send (msg = message GRconnector.GRflexconn(EMmsg,
                                                    &flag,&my_GRid,
                                                    (IGRlong *)&connect_index,
							&graph_index),
                                targetid = total_group.objid,
                                targetos = total_group.osnum);
            if (!(1 & status & *EMmsg))
                 goto wrapup;
            }
          }
	else
	  {
          struct GRid grap_grid;
          IGRlong flag=1,graph_index=OM_K_MAXINT;
          grap_grid.osnum = construct_list->env_info->md_id.osnum;
          status = om$construct( classid = OPP_GRgrgrp_class_id,
                                msg = message GRvg.GRconstruct(
                                        construct_list),
                                p_objid = &grap_grid.objid,
                                osnum = construct_list->env_info->md_id.osnum);
                        if (! ( 1 & status))
                        {
                        *EMmsg = MSFAIL;
                        goto wrapup;
                        }

          for(index1 = 0; index1  < num_elems ; index1++)
            {
            status = om$send (msg = message GRconnector.GRrigidconn(EMmsg,
                                                   &my_GRid,
                                                   (IGRlong *)&connect_index),
                               targetid = elems[index1].objid,
                               targetos = elems[index1].osnum);
            if (!(1 & status & *EMmsg))
                  goto wrapup;
            status = om$send (msg = message GRconnector.GRflexconn(EMmsg,
                                                 &flag, &grap_grid,
                                                 (IGRlong *)&connect_index,
                                                 &graph_index),
                               senderid = NULL_OBJID,
                               targetid = elems[index1].objid,
                               targetos = elems[index1].osnum);
 
            if (!(1 & status & *EMmsg))
                 goto wrapup;
            }
          }
  
        if (elems)
        {
            om$dealloc(ptr = elems);
            elems = NULL;
        }
    }  /* for (num_models = first_sect_model_index; num_models < root_count;
               num_models++) */

    /* if there is no intersection between any of the cutting planes and the
     * elements to be sectioned, and there are no unsectioned elements,
     * cleanup and exit
     */

    if ((! total_num_isect_elems) &&
        (first_unsect_model_index == dv_attach_index))
    {
        *EMmsg = EMS_E_NoIntersection;
        goto wrapup;
    }

    /* if no elements are being sectioned but there is at least one object
     * that will not be sectioned, must get the alignment vector here since
     * it is usually found in the "for" loop above, but we will not have gone
     * through the for loop if there are no elements to section
     */

    if (((root_count <= first_sect_model_index) ||
         (! total_num_isect_elems))                   &&
        (first_unsect_model_index < dv_attach_index))
    {
        if (num_segments > 1)
        {
            /* starting at index 1 since the first aligned segment has already
             * been initialized using the first (alignment) segment
             */

            for (i = 1, align_seg_index = 0; i < orig_num_segs; i++)
            {
                if (line_seg_type[i])
                {
                    status = EFget_alignment_matrix(aligned_segments[align_seg_index],
                                                    segments[i*2], align_matrix,
                                                    &segments_parallel);
                    EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_Fail, wrapup);

                    ret_value = MAtypemx(&rc, align_matrix, &matrix_type);
                    EMerr_hndlr (!(1 & ret_value), *EMmsg, EMS_E_Fail, wrapup);

                    /* align the segment; only need to first time through */

                    align_seg_index += 2;

                    ret_value = MAoptsxform(&rc, &num_points, &matrix_type,
                                            align_matrix, segments[i*2],
                                            aligned_segments[align_seg_index]);
                    EMerr_hndlr (!(1 & rc & ret_value), *EMmsg, EMS_E_Fail,
                                 wrapup);
                }
            }

            OM_BLOCK_MOVE(aligned_segments, aligned_seg,
                          sizeof(IGRdouble) * 3);
            OM_BLOCK_MOVE(aligned_segments[num_seg_pts - 1],
                          &aligned_seg[3], sizeof(IGRdouble) * 3);

            aligned_seg_ptr = aligned_seg;
        }
        else
        {
            aligned_seg_ptr = segments[0];
        }
    }

    if (type == EMS_ASsectvw || type == EMS_ASsectvw_tran ||
        type == EMS_ASsection_view)
    {
        /* determine the direction vector based on the view z vector, the
         * alignment segment and the rotation angle
         */

        for (index1 = 0; index1 < 3; index1++)
            rot_axis[index1] = segments[1][index1] - segments[0][index1];

        status = BScrossp(&rc, view_z_vector, rot_axis, direction_vec);
        EMerr_hndlr(!status || rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

        ret_value = MAang2vc(&rc, view_z_vector, direction_vec, angle_array);
        EMerr_hndlr (!(1 & rc & ret_value), *EMmsg, EMS_E_Fail, wrapup);

        if (fabs(angle_array[0] - rotation_angle) > (PI / 2))
        {
            /* need to reverse the direction and rotation axis vectors */

            for (index1 = 0; index1 < 3; index1++)
            {
                direction_vec[index1] = -direction_vec[index1];
            }
        }
    }
    else  /* pre 2.1 version section view object */
    {
        /* project the origin onto the rotation axis line to get the
         * direction vector - assuming this is an update, not creating a new
         * object - all new objects should be of type EMS_ASsection_view
         */

        rot_axis_line.point1 = (IGRdouble *) segments;
        rot_axis_line.point2 = (IGRdouble *) segments[1];

        ret_value = MAptlnproj(&rc, origin, &rot_axis_line,
                               proj_pt, &tparm);
        EMerr_hndlr (!(1 & rc & ret_value), *EMmsg, EMS_E_Fail, wrapup);

        for (index1 = 0; index1 < 3; index1++)
            direction_vec[index1] = proj_pt[index1] - origin[index1];

        /* update the associative info of the old object to have the info of
         * the newest type section view - type EMS_ASsection_view; the info
         * from the old object will be stored in the new object during the
         * NDupdate, so this will effectively update (or convert) myself to
         * the new type object; also need to change the drawing view root
         * (parent) to the drawing view's drawing view attachment - this was
         * done so that Section Views will recompute when the drawing view
         * attachment, as well as the drawing view, is moved
         */

        if ((old_objid != NULL_OBJID) &&
            (type == EMS_ASsect_view))
    {
            sect_vw_info.view_info.flags=sect_view_info->flags;
            sect_vw_info.view_info.cht = sect_view_info->cht;
            sect_vw_info.view_info.z_vec[0] = sect_view_info->z_vec[0];
            sect_vw_info.view_info.z_vec[1] = sect_view_info->z_vec[1];
            sect_vw_info.view_info.z_vec[2] = sect_view_info->z_vec[2];

            ret_value = MAang2vc(&rc, view_z_vector, direction_vec,
                                 angle_array);
            EMerr_hndlr (!(1 & rc & ret_value), *EMmsg, EMS_E_Fail, wrapup);

            sect_vw_info.rot_angle = angle_array[0];

            status = om$send (msg = message EMSassoc.EMput_info(&rc, NULL,
                                                  EMS_ASsection_view,
                                                  sizeof(sect_vw_info),
                                                  (IGRchar *) &sect_vw_info),
                              targetid = old_objid,
                              targetos = OM_Gw_current_OS);
            EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

            if (parent_info)
            {
                parent_grids = (struct GRid *) parent_info;
                source_grid = parent_grids[DRAW_VIEW_INDEX];
            }
            else  /* get the parent object at the first model index */
            {
                rc = EMmake_chanselect(NDfather_father, &chansel);
                EMerr_hndlr (!(1 & rc), *EMmsg, EMS_E_Fail, wrapup);

                status = om$get_objid_at_index(objid = my_id,
                                               p_chanselect = &chansel,
                                               index = DRAW_VIEW_INDEX,
                                               objidaddr = &source_grid.objid,
                                               osnumaddr = &source_grid.osnum);
                EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_Fail, wrapup);
            }

            status = om$send (msg = message GRdrawview.GRget_drawing_attachment_id(
                                                     &rc, &dv_attach_grid),
                              senderid = NULL_OBJID,
                              targetid = dv_grid.objid,
                              targetos = dv_grid.osnum);
            EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

            ret_code = as$make_source(go_grid = dv_attach_grid,
                                      mod_env = dv_module_env,
                                      as_os = dv_attach_grid.osnum,
                                      as_grid = &source_grid2);
            EMerr_hndlr (!(1 & ret_code), *EMmsg, EMS_E_Fail, wrapup);

            status = om$send (msg = message NDnode.NDchange_connect(
                                            1, &source_grid, &source_grid2),
                              targetid = old_objid,
                              targetos = OM_Gw_current_OS);
            EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_Fail, wrapup);
        }
    }

    /* any parent objects that are between the cutting line plane segment
     * and the drawing view attachment parents are solid models which are
     * not to be sectioned; these objects should just be copied and connected
     * to the Section View as components
     */

    for (num_models = first_unsect_model_index; num_models < dv_attach_index;
         num_models++)
    {
        model_info_ptr = &roots[num_models].lc_info;

        status = om$send(msg = message GRgraphics.GRcopy(&rc,
                                   &model_info_ptr->module_info,
                                   construct_list->env_info,
                                   &newobjid), 
                         senderid = NULL_OBJID,
                         targetid = model_info_ptr->located_obj.objid,
                         targetos = model_info_ptr->located_obj.osnum);
        EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

        status = om$send(msg = message EMSsurface.EMgetactiveid(&rc,
                                                      &saveside_grid, NULL),
                         senderid = NULL_OBJID,
                         targetid = newobjid,
                         targetos = construct_list->env_info->md_id.osnum);
        EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

        status = om$send(msg = message EMSdpr.EMmake_primitive1(&rc,
                            construct_list->env_info, &boolean_grid),
                         senderid = NULL_OBJID,
                         targetid = saveside_grid.objid,
                         targetos = saveside_grid.osnum);

        if (status == OM_W_UNKNOWN_MSG)  /* solid already a primitive */
            boolean_grid = saveside_grid;
        else if (!(1 & status & rc))
        {
            *EMmsg = EMS_E_Fail;
            goto wrapup;
        }

       {
        status = om$send (msg = message GRconnector.GRrigidconn(EMmsg,
                                                   &my_GRid,
                                                   (IGRlong *)&connect_index
                                                    ),
                          targetid = boolean_grid.objid,
                          targetos = boolean_grid.osnum);
        if (!(1 & status & *EMmsg))
            goto wrapup;
       }

        /* set all of the edges' and loops' creator ids to NULL
         * so that they will be regenerated next time they're accessed;
         * their creator id should now be the section view, not the
         * boolean solid
         */

        status = om$send(msg = message EMSsurface.EMfix_creator_id(
                                             EMmsg, NULL, NULL_OBJID, NULL),
                         targetid = boolean_grid.objid,
                         targetos = boolean_grid.osnum);
        if (!(1 & status & *EMmsg))
            goto wrapup;
    }

    /* If the flag to show visible lines is set and either the cutting
     * segments of the cutting plane line are parallel or the intersections are
     * being projected (for aligned sections), create a composite surface from
     * all the cutting planes constructed earlier.  Next determine which
     * direction from the composite surface we should go to remove the
     * sections of the solid models that are supposed to appear removed in the
     * section view.  Create a copy of each of the solid models and do a
     * boolean difference operation on each using the composite surface and
     * the direction determined above.  Reduce the resulting boolean to a
     * primitive solid to save space and connect this object to the section
     * view object as a component.
     */

    if ((root_count > first_sect_model_index) &&
        (show_visible_lines) &&
        ((parallel_line) || (project_intersections)) &&
        (total_num_isect_elems))  /* at least one of the cutting planes */
    {                             /* intersected at least one of the solids */
        if (orig_num_segs > 1)
        {
            /* create a composite surface from the generated planes */

            status = om$construct(classid = OPP_EMSgencompsf_class_id,
                                  osnum = construct_list->env_info->md_id.osnum,
                                  p_objid = &comp_surface_grid.objid,
                                  msg = message GRgraphics.GRconstruct(
                                                &const_list));
            EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_OMerror, wrapup);

            comp_surface_grid.osnum = construct_list->env_info->md_id.osnum;

            /* must make natural boundaries for all the planes so that
             * EMmake_comp works - it gets the edges of each of the input
             * surfaces
             */

            for (index1 = 0; index1 < total_num_planes; index1++)
            {
                status = om$send(msg = message EMSsurface.EMmk_nat_bdry(EMmsg,
                                           &const_list.env_info->md_env, NULL),
                                 targetid = plane_ids[index1],
                                 targetos = plane_osnum);
                EMerr_hndlr (!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
            }

            status = om$send(msg = message EMSgencompsf.EMmake_comp(EMmsg,
                                              total_num_planes,
                                              plane_ids,
                                              const_list.env_info),
                             targetid = comp_surface_grid.objid,
                             targetos = comp_surface_grid.osnum);
            EMerr_hndlr (!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

            have_comp_surface = TRUE;
        }  /* if (num_segments > 1) */
        else
        {
            comp_surface_grid.osnum = plane_osnum;
            comp_surface_grid.objid = plane_ids[0];
            have_comp_surface = TRUE;

            /* must make the natural boundaries of the plane so that
             * EMintsurf_saveside works correctly
             */

            status = om$send(msg = message EMSsurface.EMmk_nat_bdry(EMmsg,
                                           &const_list.env_info->md_env, NULL),
                             targetid = comp_surface_grid.objid,
                             targetos = comp_surface_grid.osnum);
            EMerr_hndlr (!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
        }

        /* create a point that indicates which side of the surface is to be
         * removed - this point is created by either adding or subtracting
         * (according to whether first or third projection angle is being
         * used) the direction vector from one of the poles of the first
         * cutting plane surface
         */

        for (index1 = 0; index1 < 3; index1++)
            first_plane_pt[index1] += first_angle_proj ?
                                      -direction_vec[index1] :
                                       direction_vec[index1];

        /* create copies of the model solids and do a boolean difference
         * between each of the solids and a copy of the composite surface
         * created above (need to make copies of the composite surface since
         * the boolean operation changes them); when creating a new section
         * view, only process model solids that were intersected by at least
         * one of the cutting planes
         */

        action = 0;
        props = GRIS_DISPLAYABLE;
        cutting_surface_grid.osnum = comp_surface_grid.osnum;

        for (num_models = first_sect_model_index; num_models < root_count;
             num_models++)
        {
            model_info_ptr = &roots[num_models].lc_info;
            process_model = TRUE;

            if (old_objid == NULL_OBJID)
            {
                for (index1 = 0; index1 < num_non_isect_elems; index1++)
                {
                    if ((non_isect_elems[index1].objid ==
                         model_info_ptr->located_obj.objid)  &&
                        (non_isect_elems[index1].osnum ==
                         model_info_ptr->located_obj.osnum))
                    {
                        process_model = FALSE;
                        break;
                    }
                }
            }

            if (process_model)
            {
                status = om$send(msg = message GRgraphics.GRcopy(&rc,
                                       &model_info_ptr->module_info,
                                       construct_list->env_info,
                                       &newobjid),
                                 senderid = NULL_OBJID,
                                 targetid = model_info_ptr->located_obj.objid,
                                 targetos = model_info_ptr->located_obj.osnum);
                EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

                if (num_models == root_count - 1)
                    cutting_surface_grid.objid = comp_surface_grid.objid;
                else
                {
                    status = om$send(msg = message GRgraphics.GRcopy(&rc,
                                           construct_list->env_info,
                                           construct_list->env_info,
                                           &cutting_surface_grid.objid),
                                     senderid = NULL_OBJID,
                                     targetid = comp_surface_grid.objid,
                                     targetos = comp_surface_grid.osnum);
                    EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);
                }

                /* if there are more than two cutting planes, save the ids of
                 * the connecting planes constructed (or copied) above which
                 * will be needed later to turn off the display of these
                 * planes - this can't be done yet because display is turned
                 * on by EMmake_primitive1
                 */

                if (total_num_planes > 2)
                {
                    rc = EMmake_chanselect(GRcmpowner_to_components, &to_comps);

                    EMerr_hndlr (!(1 & rc), *EMmsg, EMS_E_Fail, wrapup);

                    for (index1 = 1; index1 < total_num_planes; index1 += 2)
                    {
                        /* the connecting planes will be at the odd indices
                         * of the composite surface
                         */

                        status = om$get_objid_at_index(
                                          osnum = comp_surface_grid.osnum,
                                          objid = cutting_surface_grid.objid,
                                          p_chanselect = &to_comps,
                                          index = index1,
                                          objidaddr = &plane_ids[index1],
                                          osnumaddr = &plane_osnum);

                        EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_Fail, wrapup);
                    }
                }

                cutting_surf_data.datatype = EMSdata_object;
                cutting_surf_data.data.object = &cutting_surface_grid;

                status = om$send(msg = message EMSsurface.EMintsurf_saveside(&rc,
                                    &const_list, &cutting_surf_data,
                                    construct_list->env_info, first_plane_pt,
                                    2 /* use saveside_point argument */,
                                    EMSsfbool_opt_retryDisjoint, NULL, NULL,
                                    FALSE, NULL),
                                 targetid = newobjid,
                                 targetos = construct_list->env_info->md_id.osnum);

                if (1 & status & rc)
                {
                    status = om$send(msg = message EMSsurface.EMgetactiveid(&rc,
                                                      &saveside_grid, NULL),
                                     senderid = NULL_OBJID,
                                     targetid = newobjid,
                                     targetos = construct_list->env_info->md_id.osnum);
                    EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

                    status = om$send(msg = message EMSdpr.EMmake_primitive1(&rc,
                                       construct_list->env_info, &boolean_grid),
                                     senderid = NULL_OBJID,
                                     targetid = saveside_grid.objid,
                                     targetos = saveside_grid.osnum);

                    if (status == OM_W_UNKNOWN_MSG)  /* solid already a primitive */
                        boolean_grid = saveside_grid;
                    else if (!(1 & status & rc))
                    {
                        *EMmsg = EMS_E_Fail;
                        goto wrapup;
                    }

                    status = om$send (msg = message GRconnector.GRrigidconn(EMmsg,
                                                             &my_GRid,
                                                             (IGRlong *)&connect_index
                                                              ),
                                      targetid = boolean_grid.objid,
                                      targetos = boolean_grid.osnum);
                    if (!(1 & status & *EMmsg))
                        goto wrapup;

                    /* set all of the edges' and loops' creator ids to NULL
                     * so that they will be regenerated next time they're
                     * accessed; their creator id should now be the section
                     * view, not the boolean solid
                     */

                    status = om$send(msg = message EMSsurface.EMfix_creator_id(
                                             EMmsg, NULL, NULL_OBJID, NULL),
                                     targetid = boolean_grid.objid,
                                     targetos = boolean_grid.osnum);
                    if (!(1 & status & *EMmsg))
                        goto wrapup;

                    /* if there are more than two cutting planes, turn off the
                     * display of the connecting planes constructed above,
                     * otherwise these planes would appear as vertical lines
                     * through the section view, which is undesirable
                     */

                    if (total_num_planes > 2)
                    {
                        for (index1 = 1; index1 < total_num_planes; index1 += 2)
                        {
                            /* if the following send fails with the OM return
                             * code OM_E_NOSUCHOBJ, do not exit since the
                             * connecting plane would be deleted if it did not
                             * intersect the current solid
                             */

                            status = om$send(msg = message GRgraphics.GRchgprops(
                                                         &rc, &action, &props),
                                             targetid = plane_ids[index1],
                                             targetos = plane_osnum);

                            if (status & rc & 1)
                            {
                                /* make sure none of the edges are subordinate
                                 * edges else a common edge may be displayed
                                 */

                                buf_size = num_edges = 0;

                                status = om$send(msg = message EMSsurface.EMgetedges(
                                                  EMmsg, EMS_OPT_ALL,
                                                  &edges, &buf_size, &num_edges,
                                                  NULL, NULL, NULL, NULL),
                                                 targetid = plane_ids[index1],
                                                 targetos = plane_osnum);
                                EMerr_hndlr (!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

                                for (i = 0; i < num_edges; i++)
                                {
                                    status = om$send(msg = message EMSedge.EMget_props(
                                                         EMmsg, &edge_props),
                                                     targetid = edges[i].objid,
                                                     targetos = edges[i].osnum);
                                    EMerr_hndlr (!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

                                    if (edge_props & EMED_SUBORDINATE)
                                    {
                                        status = EMmake_chanselect(EMSedge_to_common_edge, &to_common_edge);
                                        EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_Fail, wrapup);

                                        status = om$get_channel_objects(osnum = edges[i].osnum,
                                                                        objid = edges[i].objid,
                                                                        p_chanselect = &to_common_edge, 
                                                                        list = &coincedent_edge,
                                                                        size = 1,
                                                                        count = (OMuint *)&count);
                                        EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_Fail, wrapup);

                                        edge_props = EMED_SUBORDINATE;

                                        status = om$send(msg = message EMSedge.EMset_props(
                                                            EMmsg, edge_props, 0),
                                                         targetid = edges[i].objid,
                                                         targetos = edges[i].osnum);
                                        EMerr_hndlr (!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

                                        status = om$send(msg = message EMSedge.EMset_props(
                                                             EMmsg, edge_props, 1),
                                                         targetid = coincedent_edge.S_objid,
                                                         targetos = edges[i].osnum);
                                        EMerr_hndlr (!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
                                    }
                                }
                            }
                            else if ((status != OM_E_NOSUCHOBJ) &&
                                     (! (1 & status & rc)))
                            {
                                *EMmsg = EMS_E_Fail;
                                goto wrapup;
                            }
                        }
                    }
                }
                else
                {
                    /* this return code error probably resulted from the fact
                     * that the cutting plane surface (or composite surface)
                     * did not completely divide the solid so we cannot do a
                     * difference operation; clean up the objects created to
                     * construct the sectioned solid and continue to finish
                     * creating the section view since this is not a fatal
                     * error, it just means we can't create the sectioned solid
                     */

                    om$send(msg = message GRgraphics.GRdelete(&rc,
                                                   construct_list->env_info),
                            targetid = newobjid,
                            targetos = construct_list->env_info->md_id.osnum);

                    status = OM_S_SUCCESS;
                    rc = EMS_S_Success;
                }
            }
        }
    }

    /* the cross product of the direction vector and the
     * view's z vector will produce the rotation axis vector which is used
     * to rotate the section view object to be planar to the view - the
     * rotation axis vector is used instead of the rotation axis points
     * to ensure the section view object is rotated in the correct direction
     */

    ret_value = MAcrossvc(&rc, direction_vec, view_z_vector, rot_axis);
    EMerr_hndlr (!(1 & rc & ret_value), *EMmsg, EMS_E_Fail, wrapup);

    if (first_angle_proj)
        angle = PI / 2;
    else                   /* third angle projection */
        angle = PI * 1.5;

    ret_value = MAgrotmx(&rc, rot_axis, segments[0], &angle, align_matrix);
    EMerr_hndlr (!(1 & rc & ret_value), *EMmsg, EMS_E_Fail, wrapup);

    ret_value = MAtypemx(&rc, align_matrix, &matrix_type);
    EMerr_hndlr (!(1 & ret_value), *EMmsg, EMS_E_Fail, wrapup);

      status = om$send (msg = message GRgraphics.GRxform(&rc,
                                               construct_list->env_info, 
                                               &matrix_type, align_matrix,
                                               &newobjid),
                      senderid = NULL_OBJID,
                      targetid = my_id,
                      targetos = OM_Gw_current_OS);
      EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

    EFconstruct_xs_plane(&rc, total_range, aligned_seg_ptr,
                         plane_nrml_vec, view_z_vector, 1.05,
                         &plane_geom, &pl_mdl_int);
    EMerr_hndlr (!(1 & rc), *EMmsg, EMS_E_Fail, wrapup);

    num_points = 4;

    ret_value = MAptsxform(&rc, &num_points, align_matrix, plane_geom.poles,
                           plane_geom.poles);
    EMerr_hndlr (!(1 & ret_value), *EMmsg, EMS_E_Fail, wrapup);

    /* find the center point of the section view object; we currently have
     * a bspline surface (plane) that encompasses the sections, so just need
     * to find the center of the plane
     */

    ret_value = MAptscentroid(&rc, plane_geom.poles, &num_points, center_pt);
    EMerr_hndlr (!(1 & ret_value), *EMmsg, EMS_E_Fail, wrapup);

    if ((type == EMS_ASintersect_elements) || 
        (type == EMS_ASintersect_elements1) || /* "old" section view type */
        ((! (const_options & EMSasconst_recompute)) &&
         (sv_construct_info->flags & EMS_ALIGN_SECTION_VIEW)))
    {
        /* create an alignment line from the center point of the section view
         * and the direction vector; the placement point will be projected onto
         * this line to find the desired center of the section view
         */

        for (index1 = 0; index1 < 3; index1++)
            tmp_point[index1] = center_pt[index1] + direction_vec[index1];

        alignment_line.point1 = center_pt;
        alignment_line.point2 = tmp_point;

        if ((type == EMS_ASsectvw) ||
            (type == EMS_ASsectvw_tran) ||
            (type == EMS_ASsect_view) ||
            (type == EMS_ASsection_view))
            OM_BLOCK_MOVE(origin, proj_pt, sizeof(IGRdouble) * 3);

        ret_value = MAptlnproj(&rc, origin, &alignment_line,
                               origin, &tparm);
        EMerr_hndlr (!(1 & rc & ret_value), *EMmsg, EMS_E_Fail, wrapup);

        if ((type == EMS_ASsectvw) ||
            (type == EMS_ASsectvw_tran) ||
            (type == EMS_ASsect_view) ||
            (type == EMS_ASsection_view))
        {
            /* move the drawing view from its current position to the aligned
             * origin; need to make sure the module id of the module
             * evironment structure is set (not NULL_OBJID) so that the
             * R-tree is updated
             */

            if (dv_module_env->md_id.objid == NULL_OBJID)
            {
                ex$get_modid(mod_osnum = dv_module_env->md_id.osnum,
                             mod_id = &dv_module_env->md_id.objid);
                null_modid = TRUE;
            }
            else
                null_modid = FALSE;

            for (index1 = 0; index1 < 3; index1++)
                delta_vec[index1] = origin[index1] - proj_pt[index1];

            MAtrlmx(&rc, delta_vec, align_matrix);

            ret_value = MAtypemx(&rc, align_matrix, &matrix_type);
            EMerr_hndlr (!(1 & ret_value), *EMmsg, EMS_E_Fail, wrapup);

            status = om$send(msg = message GRgraphics.GRxform(&rc,
                                               dv_module_env,
                                               &matrix_type, align_matrix,
                                               &newobjid),
                             senderid = NULL_OBJID,
                             targetid = dv_grid.objid,
                             targetos = dv_grid.osnum);
            EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

            if (null_modid)
                dv_module_env->md_id.objid = NULL_OBJID;
        }
    }

    /* create a translation vector that goes from the section view's center
     * point to the desired center point, create a translation matrix from that 
     * vector and translate the section view
     */

    for (index1 = 0; index1 < 3; index1++)
        delta_vec[index1] = origin[index1] - center_pt[index1];

    MAtrlmx(&rc, delta_vec, align_matrix);

    ret_value = MAtypemx(&rc, align_matrix, &matrix_type);
    EMerr_hndlr (!(1 & ret_value), *EMmsg, EMS_E_Fail, wrapup);

      status = om$send (msg = message GRgraphics.GRxform(&rc,
                                               construct_list->env_info, 
                                               &matrix_type, align_matrix,
                                               &newobjid),
                      senderid = NULL_OBJID,
                      targetid = my_id,
                      targetos = OM_Gw_current_OS);
      EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

    /* find the scale of the section view's drawing view and the scale of
     * the drawing view the model objects came from - if they aren't equal,
     * scale the section view so that it has the same scale as its drawing
     * view
     */

    status = om$send (msg = message GRdrawview.GRget_drawview_scale(&rc,
                                    construct_list->env_info,
                                    NULL, view_scale),
                      senderid = NULL_OBJID,
                      targetid = dv_grid.objid,
                      targetos = dv_grid.osnum);
    EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

    /* getting the scale of the drawing view the model objects are in
     * assuming that all the model objects are from the same drawing view;
     * find the scale by assuming the model parent object is an ASsourcein
     * object which is connected to a GRcontext object which is connected to
     * a GRreffile object - the scale of the GRreffile object has the same
     * scale as the drawing view, so use its scale - it's not necessary to
     * go all the way back to the drawing view
     */

    index1 = (root_count > first_sect_model_index) ? first_sect_model_index :
                                                     first_unsect_model_index;

    if (parent_info)
    {
        parent_grids = (struct GRid *) parent_info;
        source_grid = parent_grids[index1];
    }
    else  /* get the parent object at the first model index */
    {
        rc = EMmake_chanselect(NDfather_father, &chansel);
        EMerr_hndlr (!(1 & rc), *EMmsg, EMS_E_Fail, wrapup);

        status = om$get_objid_at_index(objid = my_id,
                                       p_chanselect = &chansel,
                                       index = index1,
                                       objidaddr = &source_grid.objid,
                                       osnumaddr = &source_grid.osnum);
        EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_Fail, wrapup);
    }

    chansel.type = OM_e_name;
    chansel.u_sel.name = "ASsource.listeners";

    status = om$get_channel_count(osnum = source_grid.osnum,
                                  objid = source_grid.objid,
                                  p_chanselect = &chansel,
                                  count = (OMuint *)&num_elems);
    EMerr_hndlr(!(1 & status), *EMmsg, EMS_E_Fail, wrapup);

    listener_list = NULL;
    listener_list = (OM_S_OBJECT_LINKAGE *) stackalloc(num_elems *
                                                sizeof(OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!(listener_list), *EMmsg, EMS_E_Fail, wrapup);

    status = om$get_channel_objects(osnum = source_grid.osnum,
                                    objid = source_grid.objid,
                                    p_chanselect = &chansel, 
                                    list = listener_list,
                                    size = num_elems,
                                    count = (OMuint *)&count);
    EMerr_hndlr ((!(1 & status) || !count), *EMmsg, EMS_E_Fail, wrapup);

    for (index1 = 0; index1 < count; index1++)
    {
        status = om$get_classid(osnum = listener_list[index1].osnum,
                                objid = listener_list[index1].S_objid,
                                p_classid = &classid);
        EMerr_hndlr(!(1 & status), *EMmsg, EMS_E_Fail, wrapup);

        status = om$is_ancestry_valid(subclassid = classid,
                                      superclassid = OPP_GRcontext_class_id);
 
        if (status == OM_S_SUCCESS)
        {
            /* get the reference file scale by sending the message out the
             * GRcontext object's to_reffile channel
             */

            chansel.u_sel.name = "GRcontext.to_reffile";

            status = om$send (msg = message GRreffile.GRgetscale(&rc,
                                                               &model_scale),
                              senderid = listener_list[index1].S_objid,
                              p_chanselect = &chansel,
                              targetos = listener_list[index1].osnum);
            EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

            if (model_scale != view_scale[0])
            {
                scale_array[0] = view_scale[0] / model_scale;
                scale_array[1] = view_scale[1] / model_scale;
                scale_array[2] = view_scale[2] / model_scale;
                scale_array[3] = 1.0;

                MAidmx(&rc, tmp_matrix);
                ret_value = MAgscamx(&rc, tmp_matrix, origin, scale_array,
                                     align_matrix);
                EMerr_hndlr (!(1 & ret_value & rc), *EMmsg, EMS_E_Fail, wrapup);

                ret_value = MAtypemx(&rc, align_matrix, &matrix_type);
                EMerr_hndlr (!(1 & ret_value), *EMmsg, EMS_E_Fail, wrapup);

                status = om$send (msg = message GRgraphics.GRxform(&rc,
                                                   construct_list->env_info, 
                                                   &matrix_type, align_matrix,
                                                   &newobjid),
                                  targetid = my_id,
                                  targetos = OM_Gw_current_OS);
                EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);
            }
            break;
        }
    }

    if (type == EMS_ASsectvw)
    {
        /* update the section view object's origin with the new origin;
         * if this is an old section view its info is put into the new
         * section view (during NDupdate)
         */

        sectvw_info->origin[0] = origin[0];
        sectvw_info->origin[1] = origin[1];
        sectvw_info->origin[2] = origin[2];

        status = om$send (msg = message EMSassoc.EMput_info(&rc, NULL,
                                             EMS_ASsectvw,
                                             sizeof(struct EMS_ASsectvw_info),
                                             (IGRchar *) sectvw_info),
                          targetid = (old_objid == NULL_OBJID) ? my_id :
                                                                  old_objid,
                          targetos = OM_Gw_current_OS);
        EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);
    }
    if(type == EMS_ASsectvw_tran)
     {
 
     if(old_objid != NULL_OBJID)
       {
       IGRpoint tr_pt;
       ret_value = MAtypemx(&rc, trans_matrix, &matrix_type);
       EMerr_hndlr (!(1 & ret_value), *EMmsg, EMS_E_Fail, wrapup);
 
       status = om$send (msg = message GRgraphics.GRxform(&rc,
                                                   construct_list->env_info,
                                                   &matrix_type, trans_matrix,
                                                   &newobjid),
                                  targetid = my_id,
                                  targetos = OM_Gw_current_OS);
       EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);


       status = om$send (msg = message GRdrawview.GRget_model_geometry(&rc,
                                                           dv_module_env,
                                                           &lbsys),
                              senderid = NULL_OBJID,
                              targetid = dv_grid.objid,
                              targetos = dv_grid.osnum);
       EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);


       num_points = 1;
 
       ret_value = MAptsxform(&rc, &num_points,  
			sectvw_tran_info->rot_matrix, sectvw_tran_info->origin,
                           tr_pt);
       EMerr_hndlr (!(1 & ret_value), *EMmsg, EMS_E_Fail, wrapup);

       dt_vec[0] = lbsys.matrix[3] - tr_pt[0];
       dt_vec[1] = lbsys.matrix[7] - tr_pt[1];
       dt_vec[2] = lbsys.matrix[11] -tr_pt[2];
 
        MAtrlmx(&rc, dt_vec, tr_matrix);
 
        ret_value = MAtypemx(&rc, tr_matrix, &matrix_type);
        status = om$send (msg = message GRgraphics.GRxform(&rc,
                                                   construct_list->env_info,
                                                   &matrix_type, tr_matrix,
                                                   &newobjid),
                                  targetid = my_id,
                                  targetos = OM_Gw_current_OS);
       EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

       }
     sectvw_tran_info->origin[0] = lbsys.matrix[3];
     sectvw_tran_info->origin[1] = lbsys.matrix[7];
     sectvw_tran_info->origin[2] = lbsys.matrix[11];

     status = om$send (msg = message EMSassoc.EMput_info(&rc, NULL,
                                          EMS_ASsectvw_tran,
                                          sizeof(struct EMS_ASsectvw_tran_info),
                                          (IGRchar *) sectvw_tran_info),
                          targetid = (old_objid == NULL_OBJID) ? my_id :
                                                                  old_objid,
                    targetos = OM_Gw_current_OS);
     EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);
     }
wrapup:

    if (old_objid == NULL_OBJID)
    {
        /* must reset the pointer to the structure containing the models
         * that were not intersected by the cutting planes; this is a 
         * kludged way to pass info back to the caller of EMinit_associative
         * since a argument is not currently provided to do this
         */

        construct_list->class_attr = (IGRchar *) sv_construct_info;
    }

    /* if cross section planes were created but were not used as a composite
     * surface to be used in EMintsurf_saveside, delete them since they are
     * no longer needed
     */

    if ((! have_comp_surface) &&
        plane_ids)
    {
        for (index1 = 0; index1 < total_num_planes; index1++)
        {
            om$send(msg = message GRgraphics.GRdelete(&rc,
                                                      const_list.env_info),
                    targetid = plane_ids[index1],
                    targetos = plane_osnum);
        }
    }
    else
        *EMmsg = EMS_I_NoxsectionPlane;

    /* if there was an error during construction of the section view, clean
     * up by deleting any intersection objects that were created and the
     * cutting plane composite surface, if any
     */

    if (! (1 & status & *EMmsg))
    {
        if (grids)
        {
            for (index1 = 0; index1 < number_of_objects; index1++)
            {
                om$send(msg = message GRgraphics.GRdelete(&rc,
                                                      construct_list->env_info),
                        targetid = grids[index1].objid,
                        targetos = grids[index1].osnum);
            }
        }

        for (index1 = 0; index1 < num_isect_elems; index1++)
        {
            om$send(msg = message GRgraphics.GRdelete(&rc,
                                                      construct_list->env_info),
                    targetid = intersect_elems[index1].objid,
                    targetos = intersect_elems[index1].osnum);
        }

        if (elems)
        {
            for (index1 = 0; index1 < num_elems; index1++)
            {
                om$send(msg = message GRgraphics.GRdelete(&rc,
                                                    construct_list->env_info),
                        targetid = elems[index1].objid,
                        targetos = elems[index1].osnum);
            }
        }

        /* delete any intersection objects (composite curves) I own */

        rc = EMmake_chanselect(GRcmpowner_to_components, &to_comps);

        if (1 & rc)
        {
            om$send(msg = message GRgraphics.GRdelete(&rc,
                                                      construct_list->env_info),
                    p_chanselect = &to_comps);
        }
    }

    if (grids) free(grids);
    if (segments) om$dealloc(ptr = segments);
    if (elems) om$dealloc(ptr = elems);



    BSchangepar(&rc, BSTOLCHRDHT, save_cht);
    EMWRAPUP (*EMmsg, status, "In EMSagrp: EMintersect_elements error");

    return (status);
}

#ifndef IDRAW
extern IGRboolean _use_infinite_plane;
#endif
extern IGRboolean WANT_POST220_BEHAVIOR;

static perform_intersect_elements( msg, object_1, object_2, trim_opts,
                                   inters_opts, construct_list, num_inters,
                                   inters)
IGRlong       *msg;
struct        GRlc_info *object_1;
struct        GRlc_info *object_2;
IGRushort     trim_opts, inters_opts;
struct        GRvg_construct  *construct_list;
IGRlong       *num_inters;
struct        GRid  **inters;
{
  IGRlong     sts;
  IGRshort    outworld_opt, outparam_opt;
  struct      GRid  obj1, obj2;
  struct      GRmd_env  *env1, *env2;
  struct      EMSdataselect other_data;
  extern      IGRlong EMintersect_surfaces();
  IGRboolean  save_pathway_trim, save_pathway_orient;


  sts = OM_S_SUCCESS;
  *msg = EMS_S_Success;
  *num_inters = 0;
  if(inters) *inters = NULL;

  OM_BLOCK_MOVE(&object_1->located_obj, &obj1, sizeof(struct GRid));
  env1 = &object_1->module_info;

  OM_BLOCK_MOVE(&object_2->located_obj, &obj2, sizeof(struct GRid));
  env2 = &object_2->module_info;

  other_data.datatype = EMSdata_object;
  other_data.data.object = &obj2;

  if (trim_opts & EMSINT_TRIM_OUTPUT && !_use_infinite_plane)
   {
    if(inters)
     {
      outparam_opt = EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT |
                   (WANT_POST220_BEHAVIOR ? EMSINT_ORIENT_OUTPUT : NULL);
      outworld_opt = EMSINT_OUTPUT_WORLD;
     }
    else
     {
      outparam_opt = NULL;
      outworld_opt = NULL;
     }
   }
  else
   {
   outparam_opt = NULL;
   outworld_opt = inters ? EMSINT_OUTPUT_WORLD : NULL;
   inters_opts |= EMS_SFINT_NOREFINE;
   }

  if(inters)
   {
    *inters = (struct GRid *)om$malloc(size = sizeof(struct GRid));
    EMerr_hndlr(!*inters, *msg, EMS_E_NoDynamicMemory, wrapup);
    (*inters)->osnum = construct_list->env_info->md_id.osnum;
    (*inters)->objid = NULL_OBJID;
   }
  sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(msg,
        &env1->md_env, NULL, NULL, NULL, NULL), senderid = NULL_OBJID,
        targetid = obj1.objid, targetos = obj1.osnum);
  EMerr_hndlr(!(1&*msg&sts), *msg, EMS_E_Fail, wrapup);
  sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(msg,
        &env2->md_env, NULL, NULL, NULL, NULL), senderid = NULL_OBJID,
        targetid = obj2.objid, targetos = obj2.osnum);
  EMerr_hndlr(!(1&*msg&sts), *msg, EMS_E_Fail, wrapup);

  save_pathway_trim = _pathway_trim;
  save_pathway_orient = _pathway_orient;
  _pathway_trim = 0;
  _pathway_orient = 0;

  sts = EMintersect_surfaces (msg, &obj1, &env1->md_env, 1, &other_data,
                   &env2->md_env, inters_opts,
                   outworld_opt, outparam_opt, trim_opts,
                   construct_list,
                   num_inters,
                   NULL, NULL, NULL, NULL,
                   inters ? &(*inters)->objid : NULL, NULL, NULL);

  _pathway_trim = save_pathway_trim;
  _pathway_orient = save_pathway_orient;

  if (*msg == EMS_I_Interrupt)
   {
    *num_inters = 0;
    goto wrapup;
   }
  else if(!*num_inters || (*msg == EMS_I_NotFound))
   {
    *num_inters = 0;
    *msg = EMS_I_NoIntersection;
    goto wrapup;
   }
  else if(inters && !IF_NULL_OBJID((*inters)->objid)) *num_inters = 1;

  *msg = EMS_S_Success; 
  sts = OM_S_SUCCESS;

wrapup:
  return(sts);
}

end implementation EMSasectvw;
