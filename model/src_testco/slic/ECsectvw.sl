/*\
Description
   This command contains the code needed to support the command Create
   Sectional View.

History
   WBC    09/25/91   Creation Date.
\*/

class               ECsectvw
super_class         ECaxhatch
super_class         COdetail
start_state         terminate
options             "SItc"

specification

#include "igr.h"
#include "madef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "madef.h"
#include "dp.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "grgsmacros.h"
#include "cotxmacros.h"
#include "detaildef.h"
#include "OMindex.h"
#include "ref.h"
#include "refdef.h"
#include "growner.h"
#include "grownmacros.h"
#include "csdef.h"
#include "msdef.h"
#include "msmacros.h"
#include <grmessage.h>
#include "detailcodef.h"
#include <refdef.h>
#include <ref.h>
#include "EMSasnuc.h"

#define DESC_SCALE_LEN  80

implementation

#include "coimport.h"
#include <DIdef.h>
#include <DItypedef.h>
#include <DIglob.h>
#include <DImacros.h>
#include <DIprims.h>
#include "gomacros.h"
#include "EMSasectvw.h"
#include "bserr.h"
#include "REagrp.h"
#include "EMSmsgdef.h"
#include "dimdef.h"
#include "dim.h"
#include "dimmacros.h"
#include "dimplcmacros.h"
#include "OMmacros.h"
#include "lcmacros.h"
#include "grxhatch.h"
#include "GRaxhatch.h"
#include "csmacros.h"
#include "refobj.h"
#include "grxhdef.h"
#include "ECmsg.h"
#include <alloca.h>
#include "detaildef.h"
#include "lcobjmacros.h"
#include <string.h>
#include "exfi.h"

%safe
static  double xhatch_angles[] = { 0.785398 ,-0.785398,
                                 1.047198 ,-1.047198,
                                 0.523599 ,-0.523599
                               };
%endsafe

#define ARROW_OFFSET_FACTOR  0.75

struct sect_objects
{
    struct GRid  grid;        /* the section object; objid will be NULL_OBJID
                                 if the object should not be crosshatched
                                 (it's a hole in one of the other sections) */
    IGRint       num_boundaries;  /* number of boundaries (holes) in this
                                     section */
    struct EMSobject_info *boundaries;   /* ids of the section's boundaries */
};

#define  NUM_LEVEL_INTS    (((DP_NUM_OF_LEVELS - 1) * sizeof(IGRint) * 8) + 1)

/* defines for segment_info bitmask */

#define  ONE_SEGMENT        1  /* cutting plane line has 1 segment */
#define  SEGS_NOT_PARALLEL  2  /* the end segments are not parallel;
                                  only valid if ONE_SEGMENT is not set */
#define  ORIENT_FIRSTSEG    4  /* only valid if ONE_SEGMENT is not set and
                                  and SEGS_NOT_PARALLEL is set;
                                  if this bit is set, orient the section
                                  about the first segment otherwise orient
                                  it about the last segment */

/* defines for the view arrow style */

#define  END_OF_LINE    1
#define  ABOVE_LINE     2

/* defines for the cutting plane line styles */

#define  DASH_DOT_LINESTYLE   7
#define  DASH_DASH_LINESTYLE  3

/* defines for the gagdets on the status display form */

#define  ACCEPT_BUTTON               1
#define  EXIT_BUTTON                 4
#define  FORM_MESSAGE_FIELD         10
#define  MANUAL_COORDINATE_SYS      12
#define  CROSSHATCH_TOGGLE          13
#define  VISIBLE_LINES_TOGGLE       14
#define  PROJECT_ROTATE_TOGGLE      15
#define  UPPER_DASH_DOT_LINE        16
#define  LOWER_DASH_DASH_LINE       17
#define  LEFT_ARROW                 18
#define  RIGHT_ARROW                19
#define  RIGHT_LINE_ARROW           20
#define  LEFT_LINE_ARROW            21
#define  UPPER_DASH_DASH_LINE       23
#define  LOWER_DASH_DOT_LINE        24
#define  VIEW_NAME_FIELD            25
#define  LABEL_FIELD                26
#define  UNSECTIONED_MODELS_TOGGLE  27
#define  SCALE_FIELD                31
#define  DESCRIPTION_FIELD          32
#define  SCALE_DISPLAY_TOGGLE       35
#define  ELEMENT_SELECT_TOGGLE      39
#define  LABEL_TOGGLE               40
#define  XHATCH_PARAMS_BUTTON       44
#define  RECREATE_SOLID_TOGGLE      38  /*added to take care of recreation
                                         *of solid. CR Section View Enh.
                                         */

/* defines for scale_flags below */

#define  SCALE_SPECIFIED  0x1   /* the user input a valid scale */
#define  USER_SCALE       0x2   /* the scale field contains a user specified
                                   scale */

#define  INITIAL_DVATTACH_INDEX    1
#define  FIRST_UNSECT_MODEL_INDEX  1  /* index of the first unsectioned model
                                       * if there is one */
#define  PARENT_ARRAY_INCR        10


from GRdrawview import GRget_component_id, GRget_model_matrix,
                       GRget_model_geometry, GRget_drawview_scale,
                       GRget_drawing_attachment_id;
from GRreffile  import GRselpass, GRgetenvironment;
from EMSassoc   import EMinit_associative;
from GRgraphics import GRgetprops, GRgetrang, GRdelete, GRlocate;
from GRowner    import GRadd_components;
from GRvg       import GRgetsymb, GRputsymb;
from GRcoords   import GRcvt_to_wld_coords;
from NDnode     import ASreturn_go,NDdisconnect;
from GRconnector    import GRflexconn,GRrigidconn,GRdisconn;


extern OMuword OPP_EMSasectvw_class_id;
extern OMuword OPP_GRaxhatch_class_id;
extern OMuword OPP_EMSsolid_class_id;

instance
{
    OM_S_CHANSELECT to_first_chansel;
    struct GRmd_env module_env,
                    dv_mod_env1,
                    dv_mod_env2,
                    line_mod_env;
    variable struct EMSobject_info  model_elems[1];
    variable struct EMSobject_info  parents[3];
    struct GRid     sect_view_grid,
                    cut_pln_line_grid,
                    cs_grid;
    struct IGRdisplay display_attr;
    IGRpoint        *segments;      /* the line segments comprising the
                                       cutting plane line */
    IGRpoint        firstseg_pts[2];
    IGRpoint        lastseg_pts[2]; /* only valid if there is more than
                                       one segment in the cutting plane line */
    IGRint          num_models;
    IGRint          num_parents;
    IGRint          num_segments;  /* number of segments in the cutting plane
                                      line */
    IGRint          line_style;       /* line style to be used for the cutting
                                         plane line */
    IGRint          tmp_line_style; /* if value was changed on the form,
                                       save it and only set if the the
                                       accept button is selected */
    IGRint          dvattach_index; /* index at which the drawing view
                                       attachment should be inserted into the
                                       parent array */
    IGRshort        active_layer;
    IGRboolean      segment_info;  /* informational bitmask about the cutting
                                      plane line; #defines are located above */
    IGRboolean      crosshatch_off;  /* false if the sections are to be
                                         crosshatched (using active
                                         crosshatching parameters;
                                             #defines are located above */
    IGRboolean      tmp_crosshatch_off;  /* if value was changed on the form,
                                             save it and only set if the
                                             accept button is selected */
    IGRboolean      section_only;  /* false if visible lines are to be created
                                       and displayed, true otherwise */
    IGRboolean      tmp_section_only;  /* if value was changed on the form,
                                           save it and only set if the
                                           accept button is selected */
    IGRboolean      rotate_align;  /* true if non-parallel intersections in
                                       aligned views are to be rotated, else
                                       they will be projected */
    IGRboolean      tmp_rotate_align;  /* if value was changed on the form,
                                           save it and only set if the
                                           accept button is selected */
    IGRboolean      unsectioned_models; /* true if the user wants to be prompted
                                           for elements that are not to be
                                           sectioned, false otherwise */
    IGRboolean      tmp_unsectioned_models;  /* if value was changed on the
                                                form, save it and only set if
                                                the accept button is selected */
    IGRboolean      element_selection; /* true if selecting elements
                                          individually, else all elements in
                                          drawing view are selected */
    IGRboolean      tmp_element_selection; /* if value was changed on the form,
                                              save it and only set if the
                                              accept button is selected */
    IGRboolean      coord_sys_manual;  /* true if the user is to be prompted
                                          for the section view's drawing view
                                          coordinate system origin, false if
                                          the default location is to be used */
    IGRboolean      tmp_coord_sys_manual; /* if value was changed on the form,
                                              save it and only set if the
                                              accept button is selected */
    IGRboolean      alternate_prompt;  /* if TRUE use the select handler should
                                          use the alternate prompt if the
                                          cutting plane line's end segments
                                          are parallel */
    IGRboolean      scale_display_on;  /* if TRUE display the scale of the
                                          section view immediately below the
                                          section view else don't display the
                                          scale */
    IGRboolean      tmp_scale_display_on;  /* if value was changed on the form,
                                              save it and only set if the
                                              accept button is selected */
    IGRboolean      no_label;           /* if TRUE, don't want to go into the
                                           command state to place a label,
                                           otherwise dynamically display the
                                           label for placement */
    IGRboolean      tmp_no_label;       /* if value was changed on the form,
                                           save it and only set if the
                                           accept button is selected */
    IGRshort        scale_flags;  /* indicates whether the user specified the
                                     scale; flag values defined above */
    IGRchar        *save_form_ptr;
    IGRchar         projection_angle;    /* first or third projection angle;
                                            determines the orientation of the
                                            section view */
    char            tmp_desc[80];  /* holds the description that was in the
                                      description field when the form was
                                      brought up */
    char            tmp_text_scale[80];  /* holds the scale that was in
                                            the scale field when the
                                            form was brought up */
    char            tmp_text_name[MAXPATHLEN];  /* holds the text label that
                                                   was in the label field
                                                   when the form was brought
                                                   up */
    char            tmp_name[DI_PATH_MAX];  /* holds the drawing view name
                                               that was in the name field when
                                               the form was brought up */
    IGRboolean      recreate_solid;         /* True if solid is to be recreated
                                               during modifications else false*/
    IGRboolean      tmp_recreate_solid;    /* if value was changed on the form,
                                             save it and only set if the
                                             accept button is selected */

}

action init
{
    int                 gadget_state;

    om$send(mode = OM_e_wrt_message,
            msg = message CEO_GSLOCATE.init(type, str_ptr),
            targetid = my_id);

    om$send(mode = OM_e_wrt_message,
            msg = message ECaxhatch.init(type, str_ptr),
            targetid = my_id);

    /* get the initial gadget values from the form, except for the line style
     * button which is determined initially by the projection angle
     */

    FIg_get_state(ME.CEO->status_display_form_ptr, CROSSHATCH_TOGGLE,
                  &gadget_state);
    ME.ECsectvw->crosshatch_off = ME.ECsectvw->tmp_crosshatch_off =
                                             (IGRboolean) gadget_state;

    FIg_get_state(ME.CEO->status_display_form_ptr, VISIBLE_LINES_TOGGLE,
                  &gadget_state);
    ME.ECsectvw->section_only = ME.ECsectvw->tmp_section_only =
                                               (IGRboolean) gadget_state;

    FIg_get_state(ME.CEO->status_display_form_ptr, PROJECT_ROTATE_TOGGLE,
                  &gadget_state);
    ME.ECsectvw->rotate_align = ME.ECsectvw->tmp_rotate_align =
                                               (IGRboolean) gadget_state;

    FIg_get_state(ME.CEO->status_display_form_ptr, UNSECTIONED_MODELS_TOGGLE,
                  &gadget_state);
    ME.ECsectvw->unsectioned_models = ME.ECsectvw->tmp_unsectioned_models =
                                               (IGRboolean) gadget_state;

    FIg_get_state(ME.CEO->status_display_form_ptr,RECREATE_SOLID_TOGGLE,
                  &gadget_state);
    ME.ECsectvw->recreate_solid = ME.ECsectvw->tmp_recreate_solid =
                                               (IGRboolean) gadget_state;
 
    /* The recreation option is disabled if section-only is selected.
     * - SpB CR Section View Enh.
     */
 
    if (ME.ECsectvw->section_only)
        {
       FIg_disable(ME.CEO->status_display_form_ptr, UNSECTIONED_MODELS_TOGGLE);
       FIg_disable(ME.CEO->status_display_form_ptr, RECREATE_SOLID_TOGGLE);
        }
    else
        {
       FIg_enable(ME.CEO->status_display_form_ptr, UNSECTIONED_MODELS_TOGGLE);
       FIg_enable(ME.CEO->status_display_form_ptr,RECREATE_SOLID_TOGGLE);
        }
    
    FIg_get_state(ME.CEO->status_display_form_ptr, ELEMENT_SELECT_TOGGLE,
                  &gadget_state);
    ME.ECsectvw->element_selection = ME.ECsectvw->tmp_element_selection =
                                             (IGRboolean) gadget_state;

    FIg_get_state(ME.CEO->status_display_form_ptr, MANUAL_COORDINATE_SYS,
                  &gadget_state);
    ME.ECsectvw->coord_sys_manual = ME.ECsectvw->tmp_coord_sys_manual =
                                               (IGRboolean) gadget_state;

    FIg_get_state(ME.CEO->status_display_form_ptr, SCALE_DISPLAY_TOGGLE,
                  &gadget_state);
    ME.ECsectvw->scale_display_on = ME.ECsectvw->tmp_scale_display_on =
                                              (IGRboolean) gadget_state;

    FIg_get_state(ME.CEO->status_display_form_ptr, LABEL_TOGGLE,
                  &gadget_state);
    ME.ECsectvw->no_label = ME.ECsectvw->tmp_no_label =
                                              (IGRboolean) gadget_state;

    if (ME.ECsectvw->no_label)
        FIg_disable(ME.CEO->status_display_form_ptr, LABEL_FIELD);
    else
        FIg_enable(ME.CEO->status_display_form_ptr, LABEL_FIELD);

    ME.ECsectvw->scale_flags = 0;
    gr$get_projection_angle(buffer = &ME.ECsectvw->projection_angle);

    ME.ECsectvw->line_style = ME.ECsectvw->tmp_line_style =
                          (ME.ECsectvw->projection_angle == DS_FIRST_ANGLE) ?
                           LOWER_DASH_DOT_LINE : UPPER_DASH_DOT_LINE;

    gr$get_module_env(buffer = &ME.ECsectvw->module_env);
    me->dv_id1.objid = NULL_OBJID;
    ME.ECsectvw->segments = NULL;
    ME.ECsectvw->dvattach_index = INITIAL_DVATTACH_INDEX;
}

action delete
{
    if (ME.ECsectvw->segments != NULL)
        om$dealloc(ptr = ME.ECsectvw->segments);

    om$send(mode = OM_e_wrt_message,
            msg = message CEO_GSLOCATE.delete(f_defer_flag),
            targetid = my_id);
}

/*\
Description
   Create a sectional view by finding the solid objects contained in the
   specified drawing view and calling a function that constructs sectional
   view elements give a solid and a cutting line plane.

Notes
   This function depends upon the following instance variables:
      me->line_base
      me->window_matrix
      me->dv_id1
      me->origin
\*/

action create_section_view()
{
    extern IGRboolean      MAptlnproj(), MAptalln(), MAang2vc(), MAgrotmx(),
                           MAptsxform(), BScrossp();

    IGRlong                temp_msg,
                           func_msg;
    IGRint                 index,
                           index2,
                           rc;
    IGRmatrix              *matr[1];
    IGRdouble              proj_pt[3],
                           length,
                           tparm,
                           *pt1,
                           *pt2,
                           angle[3];
    IGRpoint               *arrow_pts[4],
                           direction_vector,
                           arrow1_startpt,
                           arrow1_endpt,
                           arrow2_startpt,
                           arrow2_endpt,
                           temp_point,
                           *point_ptr,
                           *point2_ptr,
                           vec1,
                           vec2,
                           *vector1,
                           *vector2,
                           crossvector;
    struct EMS_ASsectvw_info sect_view_info;
    struct GRvg_construct  construct_list;
    struct GRobj_env       obj_env;
    struct GRid            dim_grid[2];
    struct IGRline         lines[2];
    struct GRsymbology     symbology;
    struct DMenv_param     frm_env;
    struct EMS_SVconstruct_info sv_construct_info;
    struct IGRlbsys        lbsys;
    IGRshort               direction;
    IGRboolean             sts;

    status = OM_S_SUCCESS;
    me->ret = OM_S_SUCCESS;
    dim_grid[0].osnum = dim_grid[1].osnum = OM_Gw_current_OS;
    dim_grid[0].objid = dim_grid[1].objid = NULL_OBJID;

    /* construct the associative sectional view object */

    sect_view_info.origin[0] = me->origin[0];
    sect_view_info.origin[1] = me->origin[1];
    sect_view_info.origin[2] = me->origin[2];
    BSEXTRACTPAR(&rc, BSTOLCHRDHT, sect_view_info.view_info.cht);
    sect_view_info.view_info.flags = SV_TRIMMING_REQUIRED;

    if ((ME.ECsectvw->segment_info & ONE_SEGMENT) ||
        (ME.ECsectvw->segment_info & ORIENT_FIRSTSEG))
    {
        sect_view_info.view_info.flags |= SV_FIRST_SEG_ALIGN;
    }


    /* The appropriate flags for recreation is set here
     * -SpB CR Section View Enh.
     */
 
    if (! ME.ECsectvw->section_only)
    {
       sect_view_info.view_info.flags |= SV_SHOW_VISIBLE_LINES;
       if(ME.ECsectvw->recreate_solid)
       {
          sect_view_info.view_info.flags |= SV_RECREATE_SOLID;
       }
    }

    if (! ME.ECsectvw->rotate_align)
        sect_view_info.view_info.flags |= SV_PROJ_INTERSECTIONS;

    for (index = 0; index < 3; index++)
        sect_view_info.view_info.z_vec[index] =
                                me->window_matrix[index + 8];

    /* find the directional vector (direction in which the model is being
     * viewed) by projecting the placement point onto the line defined by
     * the orientation (alignment) segment, then find the angle between the
     * view's z vector and this direction vector; this angle will be stored
     * with the section view so it will maintain its original orientation
     * no matter where the section view is subsequently moved
     */

    pt1 = proj_pt;
    pt2 = &me->line_base.event.button.x;

    if (ME.ECsectvw->segment_info & (ONE_SEGMENT | ORIENT_FIRSTSEG))
    {
        lines[0].point1 = (IGRdouble *) ME.ECsectvw->firstseg_pts[0];
        lines[0].point2 = (IGRdouble *) ME.ECsectvw->firstseg_pts[1];
    }
    else
    {
        lines[0].point1 = (IGRdouble *) ME.ECsectvw->lastseg_pts[0];
        lines[0].point2 = (IGRdouble *) ME.ECsectvw->lastseg_pts[1];
    }

    sts = MAptlnproj(&temp_msg, &me->line_base.event.button.x,
                     &lines[0], proj_pt, &tparm);

    if (! (1 & sts & temp_msg))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    for (index = 0; index < 3; index++)
        direction_vector[index] = pt1[index] - pt2[index];

    sts = MAang2vc(&temp_msg, sect_view_info.view_info.z_vec,
                   direction_vector, angle);

    if (! (1 & sts & temp_msg))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    sect_view_info.rot_angle = angle[0];

    construct_list.msg = &func_msg;
    construct_list.env_info = &ME.ECsectvw->module_env;
    construct_list.newflag = FALSE;
    construct_list.level = ME.ECsectvw->active_layer;
    construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    construct_list.geometry = NULL;
    construct_list.display = &ME.ECsectvw->display_attr;
    construct_list.name = NULL;

    /* allocating an array of struct GRid's to be passed to
     * EMconstruct_associative; all parents which do not intersect with the
     * cutting planes will be returned in this array so that these parents
     * can be disconnected as parents - the last enty in the array will have
     * NULL_OBJID as the objid; passing this information through class_attr
     * is done since there is no argument that is used to pass information
     * back from EMconstruct_associative
     */

    construct_list.class_attr = (IGRchar *) &sv_construct_info;
    sv_construct_info.flags = EMS_ALIGN_SECTION_VIEW;
    sv_construct_info.ni_parents = (struct GRid *) alloca(
                       (ME.ECsectvw->num_parents - 1) * sizeof(struct GRid));

    status = om$construct(classid = OPP_EMSasectvw_class_id,
                          p_objid = &ME.ECsectvw->sect_view_grid.objid,
                          msg = message EMSassoc.EMinit_associative(&temp_msg,
                              NULL, ME.ECsectvw->num_parents,
                              ME.ECsectvw->parents, EMS_ASsectvw,
                              sizeof (struct EMS_ASsectvw_info),
                              (IGRchar *) &sect_view_info,
                              &construct_list),
                          osnum = construct_list.env_info->md_id.osnum);

    if (status & temp_msg & 1)
    {
        if (temp_msg == EMS_I_Interrupt)
        {
            om$send (msg = message Root.delete(1),
                     senderid = NULL_OBJID,
                     targetid = ME.ECsectvw->sect_view_grid.objid,
                     targetos = construct_list.env_info->md_id.osnum);
            me->ret = OM_E_ABORT;
            goto quit;
        }
        else if (1 & temp_msg)
        {
            /* update me->origin with the origin of the constructed drawing
             * view, since it may have changed when the section view was
             * created
             */

            status = om$send(msg = message GRdrawview.GRget_model_geometry(
                                 &temp_msg, &ME.ECsectvw->dv_mod_env2, &lbsys),
                             targetid = me->dv_id2.objid,
                             targetos = me->dv_id2.osnum);

            if (! (1 & status & temp_msg))
            {
                me->ret = OM_E_ABORT;
                goto quit;
            }

            me->origin[0] = lbsys.matrix[3];
            me->origin[1] = lbsys.matrix[7];
            me->origin[2] = lbsys.matrix[11];

            ME.ECsectvw->sect_view_grid.osnum = construct_list.env_info->md_id.osnum;

            /* disconnect any model objects that were not intersected by the
             * cutting planes
             */

            if (sv_construct_info.num_ni_parents)
            {
                status = om$send (msg = message NDnode.NDdisconnect(
                                           sv_construct_info.num_ni_parents,
                                           sv_construct_info.ni_parents),
                                  senderid = NULL_OBJID,
                                  targetid = ME.ECsectvw->sect_view_grid.objid,
                                  targetos = ME.ECsectvw->sect_view_grid.osnum);

                if (! (1 & status))
                {
                    me->ret = OM_E_ABORT;
                    goto quit;
                }
            }

            /* add the cutting plane line to the drawing view; don't check
             * the return code since the cutting plane line may be a profile
             * which is rigidly owned so it can't be added as a component
             * to the drawing view - in this case the user should constrain
             * the profile to the solid model
             */

            obj_env.mod_env = ME.ECsectvw->module_env;
            obj_env.obj_id.osnum = me->cut_pln_line_grid.osnum;
            obj_env.obj_id.objid = me->cut_pln_line_grid.objid;
            index = 1;

            status = om$send (msg = message GRowner.GRadd_components
                                          ( &temp_msg,
                                            &ME.ECsectvw->module_env,
                                            &index,
                                            &obj_env,
                                            NULL,
                                            NULL),
                              senderid = NULL_OBJID,
                              targetid = me->dv_id1.objid,
                              targetos = me->dv_id1.osnum);

            matr[0] = (IGRmatrix *) ME.ECsectvw->module_env.md_env.matrix;

            status = dp$display(msg = &temp_msg,
                                osnum = construct_list.env_info->md_id.osnum,
                                mode = GRbd,
                                oids = &ME.ECsectvw->sect_view_grid,
                                num_elem = 1,
                                mtx_type = &ME.ECsectvw->module_env.md_env.matrix_type,
                                matrix = matr);

            if (! (1 & status & temp_msg))
            {
                me->ret = OM_E_ABORT;
                goto quit;
            }

            /* erase the cutting plane line since it will be redisplayed using
             * the specified line style
             */

            status = dp$display(msg = &temp_msg,
                                osnum = me->cut_pln_line_grid.osnum,
                                mode = GRbe,
                                oids = &me->cut_pln_line_grid,
                                num_elem = 1,
                                mtx_type = &ME.ECsectvw->module_env.md_env.matrix_type,
                                matrix = matr);

            if (! (1 & status & temp_msg))
            {
                me->ret = OM_E_ABORT;
                goto quit;
            }

            /* Change the line style and weight of the line selected to be
             * the cutting plane line; get the line's symbology
             * since we will want the arrows to be the same color
             * and on the same level as the selected line
             */

            status = om$send (msg = message GRvg.GRgetsymb(&temp_msg,
                                                           &symbology),
                              senderid = NULL_OBJID,
                              targetid = me->cut_pln_line_grid.objid,
                              targetos = me->cut_pln_line_grid.osnum);

            if (! (1 & status & temp_msg))
            {
                me->ret = OM_E_ABORT;
                goto quit;
            }

            symbology.display_attr.style = (ME.ECsectvw->line_style & 1) ?
                                      DASH_DASH_LINESTYLE : DASH_DOT_LINESTYLE;

            if ((ME.ECsectvw->line_style == UPPER_DASH_DOT_LINE) ||
                (ME.ECsectvw->line_style == UPPER_DASH_DASH_LINE))
            {
                symbology.display_attr.weight = 2;
            }
            else
                symbology.display_attr.weight = 0;

            status = om$send (msg = message GRvg.GRputsymb(&temp_msg,
                                                           &symbology),
                              senderid = NULL_OBJID,
                              targetid = me->cut_pln_line_grid.objid,
                              targetos = me->cut_pln_line_grid.osnum);

            if (! (1 & status & temp_msg))
            {
                me->ret = OM_E_ABORT;
                goto quit;
            }

            status = dp$display(msg = &temp_msg,
                                osnum = me->cut_pln_line_grid.osnum,
                                mode = GRbd,
                                oids = &me->cut_pln_line_grid,
                                num_elem = 1,
                                mtx_type = &ME.ECsectvw->module_env.md_env.matrix_type,
                                matrix = matr);

            if (! (1 & status & temp_msg))
            {
                me->ret = OM_E_ABORT;
                goto quit;
            }

            /* place dimension leader lines (lines with arrows at the end)
             * at the end points of the cutting plane line to indicate the
             * view direction
             */

            /* calculate the end points of the directional arrows; there are
             * two different styles of directional arrows - one style is to
             * connect to the outside point of each end segment and point
             * from there while the other style has the tip of the directional
             * arrow touching the cutting plane line near the outside points
             * of the end segments; the information necessary in both cases
             * is to get the outside points of the end segments and a
             * directional vector for the segment about which the section view
             * was oriented; using this directional vector and the point on the
             * "orient" line segment we can determine the arrow line segment
             * normal to the "orient" line segment and these segment points
             * are used to find the second directional line segment; if the
             * other end segment is not parallel to the orient line segment
             * the cross product of the first directional vector and the
             * orient line segment is found, then the cross product of the
             * other end segment and the cross product found above produces
             * a vector in the correct direction for the other end segment
             */

            dm$get_dim_param(type = DM_ENV_PARAM, p_data = &frm_env);

            /* get the begin and end points and line segments of the cutting
             * plane line
             */

            if ((ME.ECsectvw->line_style == UPPER_DASH_DOT_LINE) ||
                (ME.ECsectvw->line_style == UPPER_DASH_DASH_LINE))
            {
                if (ME.ECsectvw->segment_info & ONE_SEGMENT)
                {
                    arrow_pts[0] = (IGRpoint *) ME.ECsectvw->firstseg_pts[0];
                    arrow_pts[2] = (IGRpoint *) ME.ECsectvw->firstseg_pts[1];
                }
                else if (ME.ECsectvw->segment_info & ORIENT_FIRSTSEG)
                {
                    arrow_pts[0] = (IGRpoint *) ME.ECsectvw->firstseg_pts[0];
                    arrow_pts[2] = (IGRpoint *) ME.ECsectvw->lastseg_pts[1];
                }
                else
                {
                    arrow_pts[0] = (IGRpoint *) ME.ECsectvw->lastseg_pts[1];
                    arrow_pts[2] = (IGRpoint *) ME.ECsectvw->firstseg_pts[0];
                }
            }
            else  /* ABOVE_LINE */
            {
                /* the tips of the directional vectors are offset from the
                 * ends of the end sections
                 */

                if (ME.ECsectvw->segment_info & (ONE_SEGMENT | ORIENT_FIRSTSEG))
                {
                    lines[0].point1 = ME.ECsectvw->firstseg_pts[0];
                    lines[0].point2 = ME.ECsectvw->firstseg_pts[1];

                    if (ME.ECsectvw->segment_info & ONE_SEGMENT)
                    {
                        lines[1].point1 = ME.ECsectvw->firstseg_pts[1];
                        lines[1].point2 = ME.ECsectvw->firstseg_pts[0];
                    }
                    else
                    {
                        lines[1].point1 = ME.ECsectvw->lastseg_pts[1];
                        lines[1].point2 = ME.ECsectvw->lastseg_pts[0];
                    }
                }
                else  /* more than one cutting plane line segment */
                {
                    lines[0].point1 = ME.ECsectvw->lastseg_pts[1];
                    lines[0].point2 = ME.ECsectvw->lastseg_pts[0];
                    lines[1].point1 = ME.ECsectvw->firstseg_pts[0];
                    lines[1].point2 = ME.ECsectvw->firstseg_pts[1];
                }

                direction = 1;
                arrow_pts[1] = (IGRpoint *) arrow1_endpt;
                arrow_pts[3] = (IGRpoint *) arrow2_endpt;

                /* use a factor of the dimensioning text height to
                 * determine the offset of the arrow from the end of the line
                 */

                length = frm_env.txt_heig * ARROW_OFFSET_FACTOR;

                for (index = 0; index < 2; index++)
                {
                    sts = MAptalln(&temp_msg, &lines[index],
                                   lines[index].point1, &direction, &length,
                                   arrow_pts[(index * 2) + 1]);

                    if (! (1 & sts & temp_msg))
                    {
                        me->ret = OM_E_ABORT;
                        goto quit;
                    }
                }
            }

            /* find the remaining endpoints of the arrows; we have already
             * found the two begin points if the line_style is one of the
             * "upper" types else we have found the two end points
             */

            length = 4 * frm_env.txt_heig;

            if ((ME.ECsectvw->line_style == UPPER_DASH_DOT_LINE) ||
                (ME.ECsectvw->line_style == UPPER_DASH_DASH_LINE))
            {
                arrow_pts[1] = (IGRpoint *) arrow1_endpt;
                arrow_pts[3] = (IGRpoint *) arrow2_endpt;
                direction = (ME.ECsectvw->projection_angle == DS_FIRST_ANGLE) ?
                            -1 : 1;
            }
            else  /* ABOVE_LINE */
            {
                arrow_pts[0] = (IGRpoint *) arrow1_startpt;
                arrow_pts[2] = (IGRpoint *) arrow2_startpt;
                direction = (ME.ECsectvw->projection_angle == DS_FIRST_ANGLE) ?
                            1 : -1;
            }

            for (index = 0; index < 2; index++)
            {
                if ((ME.ECsectvw->line_style == UPPER_DASH_DOT_LINE) ||
                    (ME.ECsectvw->line_style == UPPER_DASH_DASH_LINE))
                {
                    point_ptr = arrow_pts[index * 2];
                    point2_ptr = arrow_pts[(index * 2) + 1];
                }
                else  /* ABOVE_LINE */
                {
                    point_ptr = arrow_pts[(index * 2) + 1];
                    point2_ptr = arrow_pts[index * 2];
                }

                /* if there is more than one cutting plane line segment and
                 * the end segments are not parallel and this is the last
                 * end segment, find the direction vector for the second
                 * vector
                 */

                if (index && (! (ME.ECsectvw->segment_info & ONE_SEGMENT) &&
                    (ME.ECsectvw->segment_info & SEGS_NOT_PARALLEL)))
                {
                    for (index = 0; index < 3; index++)
                    {
                        vec1[index] = ME.ECsectvw->firstseg_pts[1][index] -
                                      ME.ECsectvw->firstseg_pts[0][index];
                        vec2[index] = ME.ECsectvw->lastseg_pts[1][index] -
                                      ME.ECsectvw->lastseg_pts[0][index];
                    }

                    if (ME.ECsectvw->segment_info & ORIENT_FIRSTSEG)
                    {
                        vector1 = (IGRpoint *) vec1;
                        vector2 = (IGRpoint *) vec2;
                    }
                    else
                    {
                        vector1 = (IGRpoint *) vec2;
                        vector2 = (IGRpoint *) vec1;
                    }

                    BScrossp(&temp_msg, direction_vector, vector1, crossvector);

                    if (temp_msg != BSSUCC)
                    {
                        me->ret = OM_E_ABORT;
                        goto quit;
                    }

                    BScrossp(&temp_msg, vector2, crossvector, direction_vector);

                    if (temp_msg != BSSUCC)
                    {
                        me->ret = OM_E_ABORT;
                        goto quit;
                    }
                }

                for (index2 = 0; index2 < 3; index2++)
                    temp_point[index2] =
                      direction_vector[index2] + point_ptr[0][index2];

                lines[index].point1 = (IGRdouble *) point_ptr;
                lines[index].point2 = temp_point;

                sts = MAptalln(&temp_msg, &lines[index],
                               lines[index].point1, &direction,
                               &length, point2_ptr);

                if (! (1 & sts & temp_msg))
                {
                    me->ret = OM_E_ABORT;
                    goto quit;
                }
            }

            obj_env.mod_env = ME.ECsectvw->module_env;
            index2 = 1;

            for (index = 0; index < 4; index += 2)
            {
                /* place the directional arrows at the ends of the cutting
                 * plane line
                 */

                rc = dm$place_leader_line(geom_type = 0,
                                          attach_ele1 = &me->cut_pln_line_grid,
                                          attach_ele2 = &me->cut_pln_line_grid,
                                          attach_pt1 = arrow_pts[index + 1],
                                          attach_pt2 = arrow_pts[index],
                                          num_brkpt = 0,
                                          brkpt = NULL,
                                          plane_matrix = me->window_matrix,
                                          dim_grid = &dim_grid[index/2]);

                /* add the leaders line to the constructed drawing view so
                 * they will be deleted when the drawing view is deleted
                 */

                obj_env.obj_id.osnum = dim_grid[index/2].osnum;
                obj_env.obj_id.objid = dim_grid[index/2].objid;

                om$send(msg = message GRowner.GRadd_components
                                          ( &temp_msg,
                                            &ME.ECsectvw->module_env,
                                            &index2,
                                            &obj_env,
                                            NULL,
                                            NULL),
                        senderid = NULL_OBJID,
                        targetid = me->dv_id2.objid,
                        targetos = me->dv_id2.osnum);
            }

            if (ME.ECsectvw->crosshatch_off)
                me->ret = OM_I_STOP_SENDING;
        }
    }
    else  /* om$construct failed */
    {
        if (temp_msg == EMS_E_NoIntersection)
            me->ret = EMS_E_NoIntersection;
        else
            me->ret = OM_E_ABORT;

        /* clean up by deleting the section view's drawing view object,
         * the section view object and the view direction arrows on the ends
         * of the cutting plane line
         */

        om$send(msg = message GRgraphics.GRdelete(&temp_msg,
                                                  construct_list.env_info),
                targetid = ME.ECsectvw->sect_view_grid.objid,
                targetos = construct_list.env_info->md_id.osnum);

        om$send(msg = message GRgraphics.GRdelete(&temp_msg,
                                                  &ME.ECsectvw->module_env),
                targetid = me->dv_id2.objid,
                targetos = me->dv_id2.osnum);
    }
}

/*\
Description
   This action determines if the cutting plane line is valid.  A valid
    cutting plane line must be planar, each of its elements must be linear
    and the angle between the first section and each of the rest of the
    segments must be non-orthogonal.

Notes
   This function depends upon the following instance variables:
     me->dv_id1
     me->dv_mod_env1
     me->cut_pln_line_grid
     me->line_mod_env
\*/

action verify_cut_plane_line()
{
    extern IGRdouble  BSlenvecsq(), fabs(), BSdotp();
    extern IGRlong EFget_cut_line_segs(), EFfind_non_orthogonal_segments();
    extern IGRboolean BScrossp(), MAlenvc();

    struct IGRline  boreline,
                    end_line;
    IGRlong   om_msg,
              msg;
    IGRint    index,
              index2,
              num_seg_pts,
              invalid_segment,
              num_non_orth_segs;
    IGRpoint  vector1,
              vector2,
              crossvector,
              pt1,
              pt2,
              tmp_point;
    IGRdouble length,
              tolerance,
              dot_prod,
              distance1,
              distance2,
              *distance_ptr;
    IGRshort  properties;
    IGRboolean   rc,
                *segment_type_array;

    me->ret = EMS_S_Success;

    om_msg = om$send(msg = message GRgraphics.GRgetprops(&msg, &properties),
                     senderid = NULL_OBJID,
                     targetid = me->cut_pln_line_grid.objid,
                     targetos = me->cut_pln_line_grid.osnum);

    if (1 & om_msg & msg)
    {
        if (properties & GRIS_PLANAR)
        {
            if (ME.ECsectvw->segments)
                om$dealloc(ptr = ME.ECsectvw->segments);

            status = EFget_cut_line_segs(&msg, &me->cut_pln_line_grid,
                                         &ME.ECsectvw->line_mod_env,
                                         &ME.ECsectvw->num_segments,
                                         &ME.ECsectvw->segments);

            if (1 & status)
            {
                if ((msg == EMS_S_Success) &&
                    (ME.ECsectvw->num_segments >= 1))
                {
                    /* determine if the cutting plane line is planar to the
                     * selected view - a requirement for the line; only need
                     * to check two non-colinear segments to ensure planarity
                     * but checking them all to reduce code - usually won't
                     * have that many segments
                     */

                    BSEXTRACTPAR(&msg, BSTOLORTHOVEC, tolerance);

                    for (index2 = 0; index2 < (ME.ECsectvw->num_segments * 2);
                         index2 += 2)
                    {
                        for (index = 0; index < 3; index++)
                        {
                            vector1[index] = ME.ECsectvw->segments[index2][index] -
                                             ME.ECsectvw->segments[index2 + 1][index];
                        }

                        dot_prod = BSdotp (&msg, vector1,
                                           &me->window_matrix[8]);
                        if (msg != BSSUCC)
                        {
                            me->ret = EMS_E_Fail;
                            goto quit;
                        }

                        if (fabs(dot_prod) > tolerance)
                        {
                            me->ret = EMS_E_InvalidCase;
                            goto quit;
                        }
                    }

                    OM_BLOCK_MOVE(ME.ECsectvw->segments,
                                  ME.ECsectvw->firstseg_pts,
                                  sizeof(IGRpoint) * 2);

                    if (ME.ECsectvw->num_segments > 1)
                    {
                        OM_BLOCK_MOVE(ME.ECsectvw->segments[(ME.ECsectvw->num_segments * 2) - 2],
                                      ME.ECsectvw->lastseg_pts,
                                      sizeof(IGRpoint) * 2);

                        /* determine if the end segments are parallel */

                        for (index = 0; index < 3; index++)
                        {
                            vector1[index] = ME.ECsectvw->firstseg_pts[1][index] -
                                             ME.ECsectvw->firstseg_pts[0][index];
                            vector2[index] = ME.ECsectvw->lastseg_pts[1][index] -
                                             ME.ECsectvw->lastseg_pts[0][index];
                        }

                        BSEXTRACTPAR(&msg, BSTOLSQCOLLINVEC, tolerance);
                        BScrossp(&msg, vector1, vector2, crossvector);

                        if (msg != BSSUCC)
                        {
                            me->ret = EMS_E_Fail;
                            goto quit;
                        }

                        length = BSlenvecsq(&msg, crossvector);

                        if (msg != BSSUCC)
                        {
                            me->ret = EMS_E_Fail;
                            goto quit;
                        }

                        if (length > tolerance)
                        {
                            ME.ECsectvw->segment_info = SEGS_NOT_PARALLEL;

                            /* create a boreline from the accept point and the
                             * view's z-vector
                             */

                            boreline.point1 = pt1;
                            boreline.point2 = pt2;

                            rc = MAbrlnconstr(&msg, &me->event1.event.button.x,
                                              me->window_matrix,
                                              &boreline);

                            if (! (1 & rc & msg))
                            {
                                me->ret = OM_E_ABORT;
                                goto quit;
                            }

                            /* find which end segment the boreline is closest
                             * to
                             */

                            for (index = 0; index < 2; index++)
                            {
                                if (index)
                                {
                                    end_line.point1 = ME.ECsectvw->lastseg_pts[0];
                                    end_line.point2 = ME.ECsectvw->lastseg_pts[1];
                                    distance_ptr = &distance2;
                                }
                                else
                                {
                                    end_line.point1 = ME.ECsectvw->firstseg_pts[0];
                                    end_line.point2 = ME.ECsectvw->firstseg_pts[1];
                                    distance_ptr = &distance1;
                                }

                                rc = MA2lndis(&msg, &boreline, &end_line,
                                              distance_ptr);

                                if (! (1 & rc & msg))
                                {
                                    me->ret = OM_E_ABORT;
                                    goto quit;
                                }
                            }

                            if (distance1 > distance2)
                            {
                                /* want to orient about the last segment;
                                 * reverse the array of segment points so that
                                 * the last segment becomes the first
                                 */

                                num_seg_pts = ME.ECsectvw->num_segments * 2;

                                for (index = 0; index < ME.ECsectvw->num_segments; index++)
                                {
                                    OM_BLOCK_MOVE(ME.ECsectvw->segments[index],
                                                  tmp_point, sizeof(IGRpoint));
                                    OM_BLOCK_MOVE(ME.ECsectvw->segments[num_seg_pts - index - 1],
                                                  ME.ECsectvw->segments[index],
                                                  sizeof(IGRpoint));
                                    OM_BLOCK_MOVE(tmp_point,
                                                  ME.ECsectvw->segments[num_seg_pts - index - 1],
                                                  sizeof(IGRpoint));
                                }
                            }
                            else
                                ME.ECsectvw->segment_info |= ORIENT_FIRSTSEG;
                        }
                        else  /* segments are parallel */
                        {
                            ME.ECsectvw->segment_info = ORIENT_FIRSTSEG;
                        }

                        /* remove any line segments that are orthogonal
                         * to the alignment (first) line segment
                         */

                        segment_type_array = NULL;
                        segment_type_array = (IGRboolean *) alloca(
                                                 ME.ECsectvw->num_segments *
                                                 sizeof(IGRboolean));
                        if (! segment_type_array)
                        {
                            me->ret = OM_E_ABORT;
                            goto quit;
                        }

                        status = EFfind_non_orthogonal_segments(&msg,
                                                   ME.ECsectvw->num_segments,
                                                   ME.ECsectvw->segments,
                                                   &num_non_orth_segs,
                                                   segment_type_array,
                                                   &invalid_segment);
                        if (! (1 & status & msg))
                            me->ret = EMS_E_NoSolution;

                        if (num_non_orth_segs < ME.ECsectvw->num_segments)
                        {
                            for (index = 0, index2 = 0;
                                 index < ME.ECsectvw->num_segments; index++)
                            {
                                if (segment_type_array[index] == 0)
                                {
                                    OM_BLOCK_MOVE(ME.ECsectvw->segments[index2 + 2],
                                                  ME.ECsectvw->segments[index2],
                                                  (ME.ECsectvw->num_segments - index) *
                                                  sizeof(IGRpoint) * 2);
                                }
                                else
                                    index2 += 2;
                            }
                            ME.ECsectvw->num_segments = num_non_orth_segs;
                        }
                    }
                    else
                        ME.ECsectvw->segment_info = ONE_SEGMENT;
                }
                else if (msg == EMS_E_InvalidArg)
                    me->ret = EMS_E_NotSupported;
                else
                    me->ret = EMS_E_Fail;
            }
            else
                me->ret = EMS_E_Fail;
        }
        else
            me->ret = EMS_E_InvalidArg;
    }
    else
        me->ret = EMS_E_Fail;

    if (me->ret & 1)
    {
        /* the cutting plane line is the first parent of the section view */

        ME.ECsectvw->parents[0].grid = me->cut_pln_line_grid;
        OM_BLOCK_MOVE(&ME.ECsectvw->line_mod_env, &ME.ECsectvw->parents[0].env,
                      sizeof(struct GRmd_env));
        ME.ECsectvw->num_parents = 1;

        /* need to save the endpoints of the alignment segment
         * into the following instance data, which will be
         * needed by future actions
         */

        OM_BLOCK_MOVE(ME.ECsectvw->segments[0], me->point1, sizeof(IGRpoint));
        OM_BLOCK_MOVE(ME.ECsectvw->segments[1], me->point2, sizeof(IGRpoint));
    }
}

/*\
Description
   This action gets the geometry of the model(s) in the drawing view and
   the "aligned" cutting plane line and creates a plane using the line
   and the combined ranges of the models.  This plane is then rotated 90
   degrees about the orientation segment of the cutting plane line. This
   rectangle is then dynamically displayed in highlight to track the cursor
   while staying aligned with the orientation segment.

Notes
   This function depends upon the following instance variables:
      me->module_env
      me->firstseg_pts
      me->dv_id1
\*/

action dynamics
{
    extern IGRboolean MAptlnproj(), MAptsxform(), MAgrotmx(),
                      BScrossp(), MAptalln();
    extern IGRint     EFdyn_aligned_rectangle(), EFunion_range();
    extern void       BSscale_pts();

    IGRlong          temp_msg,
                     num_pts;
    IGRint           index;
    int              sel_flag,
                     r_pos;
    IGRdouble        tparm,
                     cut_plane_line[6],
                     *segments_ptr,
                     u_knots[4],
                     v_knots[4],
                     poles[12],
                     *pt_to_project,
                     angle[3],
                     align_matrix[16],
                     distance,
                     start_point[3],
                     drawview_scale[3],
                     scale_factor;
    IGRpoint         segment_vec,
                     plane_nrml_vec,
                     center_pt;
    GRrange          model_range,
                     total_range;
    struct IGRline   orient_line;
    struct IGRbsp_surface plane_geom;
    struct IGRdisplay disp_attr;
    IGRshort          direction;
    GRspacenum        mod_osnum,   /* current module osnum */
                      ref_osnum;   /* reference file osnum */
    IGRboolean        pl_mdl_int, rc;

    if (dynamics == 15)
    {
        rc = TRUE;

        for (index = FIRST_UNSECT_MODEL_INDEX; index < ME.ECsectvw->num_parents;
             index++)
        {
            if (index != ME.ECsectvw->dvattach_index)
            {
                /* get the range of located model objects (the parents) */

                status = om$send(msg = message GRgraphics.GRgetrang(&temp_msg,
                                    &ME.ECsectvw->parents[index].env.md_env.matrix_type,
                                    ME.ECsectvw->parents[index].env.md_env.matrix,
                                    &rc, model_range), 
                                 senderid = NULL_OBJID,
                                 targetid = ME.ECsectvw->parents[index].grid.objid,
                                 targetos = ME.ECsectvw->parents[index].grid.osnum);

                if (! (1 & status & temp_msg))
                {
                    status = OM_E_ABORT;
                    goto quit;
                }

                if (((index == ME.ECsectvw->dvattach_index + 1) &&
                     (ME.ECsectvw->dvattach_index == FIRST_UNSECT_MODEL_INDEX)) ||
                     (index == FIRST_UNSECT_MODEL_INDEX))
                    OM_BLOCK_MOVE(model_range, total_range, sizeof(GRrange));
                else
                    EFunion_ranges(model_range, total_range);
            }
        }
    }
    else
    {
        om$send(mode = OM_e_wrt_message,
                msg = message COdetail.dynamics(dynamics, sts),
                targetid = my_id);
        goto quit;
    }

    /* create one line from the cutting plane line segment(s);
     * if there is more than one segment and the first and last segments
     * are not aligned, use the start point of the orientation segment
     * as the first point of the line, and project (if necessary) the first
     * point of the other segment onto the line defined by the orientation
     * segment, then find the point along the orientation line at the distance
     * equal to the other segment's length from the projected point and use
     * this as the second point of the line; if there is more than one segment
     * and the segments are aligned use the start point of the first segment
     * and the end point of the last segment as the points of the line;
     * otherwise use the single segment as the line
     */

    if (ME.ECsectvw->segment_info & ONE_SEGMENT)
    {
        segments_ptr = (IGRdouble *) ME.ECsectvw->firstseg_pts;
    }
    else
    {
        if (ME.ECsectvw->segment_info & ORIENT_FIRSTSEG)
        {
            OM_BLOCK_MOVE(ME.ECsectvw->firstseg_pts[0], cut_plane_line,
                          sizeof(IGRdouble) * 3);
            orient_line.point1 = ME.ECsectvw->firstseg_pts[0];
            orient_line.point2 = ME.ECsectvw->firstseg_pts[1];
        }
        else
        {
            OM_BLOCK_MOVE(ME.ECsectvw->lastseg_pts[1], cut_plane_line,
                          sizeof(IGRdouble) * 3);
            orient_line.point1 = ME.ECsectvw->lastseg_pts[0];
            orient_line.point2 = ME.ECsectvw->lastseg_pts[1];
        }

        if (ME.ECsectvw->segment_info & SEGS_NOT_PARALLEL)
        {
            /* get the length of the non-orientation segment, then
             * find the point on the line defined by the orientation segment
             * that will be the start point when getting the point along
             * element which will be the second point of the line we are
             * trying to determine;  this start point is the projection of the
             * first point of the non-orientation end segment onto the
             * orientation line; also need to find in which direction the
             * point is to be found
             */

            if (ME.ECsectvw->segment_info & ORIENT_FIRSTSEG)
            {
                MA2ptdis(&temp_msg, ME.ECsectvw->lastseg_pts[0],
                         ME.ECsectvw->lastseg_pts[1], &distance);
                pt_to_project = (IGRdouble *) ME.ECsectvw->lastseg_pts[0];
                direction = 1;
            }
            else
            {
                MA2ptdis(&temp_msg, ME.ECsectvw->firstseg_pts[0],
                         ME.ECsectvw->firstseg_pts[1], &distance);
                pt_to_project = (IGRdouble *) ME.ECsectvw->firstseg_pts[1];
                direction = -1;
            }

            if (ME.ECsectvw->num_segments > 2)
            {
                MAptlnproj(&temp_msg, pt_to_project, &orient_line,
                           start_point, &tparm);
            }
            else
            {
                /* if there are only two segments, the last point of the first
                 * segment should be the same as the first point of the last
                 * segment so no projection is necessary
                 */

                OM_BLOCK_MOVE(pt_to_project, start_point,
                              sizeof(IGRdouble) * 3);
            }

            rc = MAptalln(&temp_msg, &orient_line, start_point, &direction,
                          &distance, &cut_plane_line[3]);

            if (! (1 & rc & temp_msg))
            {
                me->ret = OM_E_ABORT;
                goto quit;
            }
        }
        else
        {
            if (ME.ECsectvw->segment_info & ORIENT_FIRSTSEG)
                pt_to_project = (IGRdouble *) ME.ECsectvw->lastseg_pts[1];
            else
                pt_to_project = (IGRdouble *) ME.ECsectvw->firstseg_pts[0];

            MAptlnproj(&temp_msg, pt_to_project, &orient_line,
                       &cut_plane_line[3], &tparm);
        }
        segments_ptr = cut_plane_line;
    }

    segment_vec[0] = segments_ptr[3] - segments_ptr[0];
    segment_vec[1] = segments_ptr[4] - segments_ptr[1];
    segment_vec[2] = segments_ptr[5] - segments_ptr[2];

    BScrossp(&temp_msg, segment_vec, &me->window_matrix[8],
             plane_nrml_vec);

    plane_geom.poles = poles;
    plane_geom.u_knots = u_knots;
    plane_geom.v_knots = v_knots;

    EFconstruct_xs_plane(&temp_msg, total_range, segments_ptr,
                         plane_nrml_vec, &me->window_matrix[8], 1.0,
                         &plane_geom, &pl_mdl_int);
    if (! (1 & temp_msg))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    /* rotate the plane to be planar to the view */

    angle[0] = PI / 2;

    rc = MAgrotmx(&temp_msg, segment_vec, segments_ptr, angle,
                  align_matrix);

    if (! (1 & rc & temp_msg))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    num_pts = 4;
    MAptsxform(&temp_msg, &num_pts, align_matrix, poles, poles);

    if (! (1 & temp_msg))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    /* if the scale specified on the status display form is different than
     * the scale of the located drawing view, need to scale the poles so
     * that they are at the specified scale
     */

    FIfld_get_text(ME.CEO->status_display_form_ptr, SCALE_FIELD, 0, 0,
                   DESC_SCALE_LEN, me->text_scale, &sel_flag, &r_pos);

    if (strlen(me->text_scale))
    {
        /* get the scale of the located drawing view */

        status = om$send(msg = message GRdrawview.GRget_drawview_scale(
                                        &temp_msg, &ME.ECsectvw->dv_mod_env1,
                                        NULL, drawview_scale),
                         senderid = NULL_OBJID,
                         targetid = me->dv_id1.objid,
                         targetos = me->dv_id1.osnum);

        if (1 & status & temp_msg)
        {
            mod_osnum = ref_osnum = ME.ECsectvw->module_env.md_id.osnum;

            GRmodel_scale(&temp_msg, &mod_osnum, &ref_osnum, me->text_scale,
                          align_matrix);

            if (temp_msg & 1)
            {
                if (drawview_scale[0] != align_matrix[0])
                {
                    scale_factor = align_matrix[0] / drawview_scale[0];

                    /* scale about the center of the rectangle */

                    MAptscentroid(&temp_msg, poles, &num_pts, center_pt);

                    if (! (1 & temp_msg))
                    {
                        me->ret = OM_E_ABORT;
                        goto quit;
                    }

                    BSscale_pts(num_pts, poles, NULL, scale_factor, center_pt,
                                &temp_msg);

                    if (temp_msg != BSSUCC)
                    {
                        me->ret = OM_E_ABORT;
                        goto quit;
                    }
                }
            }
        }
    }

    /* get the alignment vector */

    BScrossp(&temp_msg, segment_vec, &me->window_matrix[8],
             plane_nrml_vec);

    /* call dynamics function */

    disp_attr.color = 1;
    disp_attr.weight = 0;
    disp_attr.style = 0;

    EFdyn_aligned_rectangle(&temp_msg, poles, &poles[9], segment_vec,
                            plane_nrml_vec, &disp_attr);
}

action status_disp
{
    int sel_flag,
        r_pos;

    status = om$send(msg = message CEO.status_disp(),
                     targetid = my_id,
                     mode = OM_e_wrt_message);

    /* getting the following strings so they can be restored on the form
     * in case the the status form is exitted (not saved); this is done here
     * instead of in the init action because the action set_defaults NULLs
     * out the following strings
     */

    FIfld_get_text(ME.CEO->status_display_form_ptr, VIEW_NAME_FIELD, 0, 0,
                   DI_PATH_MAX, (IGRuchar *) me->tmp_name, &sel_flag, &r_pos);

    FIfld_get_text(ME.CEO->status_display_form_ptr, LABEL_FIELD, 0, 0,
                   MAXPATHLEN, (IGRuchar *) me->tmp_text_name, &sel_flag,
                   &r_pos);

    FIfld_get_text(ME.CEO->status_display_form_ptr, SCALE_FIELD, 0, 0,
                   DESC_SCALE_LEN, (IGRuchar *) me->tmp_text_scale, &sel_flag,
                   &r_pos);

    FIfld_get_text(ME.CEO->status_display_form_ptr, DESCRIPTION_FIELD, 0, 0,
                   DESC_SCALE_LEN, (IGRuchar *) me->tmp_desc, &sel_flag,
                   &r_pos);

    /* display the active line style gadget on the form */

    FIg_display(ME.CEO->status_display_form_ptr, (int) ME.ECsectvw->line_style);

    /* update the icon on the cross hatching subform button */

    om$send(msg = message ECsectvw.update_xhatch_button(),
            targetid = my_id);
}


action form_notification
{
    IGRdouble  scale_matrix[16];
    IGRlong    temp_msg,
               size;
    int        sts,
               response,
               sel_flag,
               r_pos;
    GRobjid    dir_objid;
    GRspacenum dir_osnum;
    IGRuchar   text_ptr[128];
    IGRchar    scale_string[DESC_SCALE_LEN],
               sectvw_name[DI_PATH_MAX];

    if (form_label == STATUS_FORM)
    {
        FIfld_set_text(ME.CEO->status_display_form_ptr,
                       FORM_MESSAGE_FIELD, 0, 0, "", FALSE);

        switch (gadget_label)
        {
            case ACCEPT_BUTTON:
            case EXIT_BUTTON:

                om$send(msg = message CEO.erase_form_by_label(STATUS_FORM,
                                                              0, &sts),
                        targetid = my_id);

                if (gadget_label == ACCEPT_BUTTON)
                {
                    ME.ECsectvw->tmp_crosshatch_off = ME.ECsectvw->crosshatch_off;
                    ME.ECsectvw->tmp_section_only = ME.ECsectvw->section_only;
                    ME.ECsectvw->tmp_rotate_align = ME.ECsectvw->rotate_align;
                    ME.ECsectvw->tmp_unsectioned_models = ME.ECsectvw->unsectioned_models;
                    ME.ECsectvw->tmp_line_style = ME.ECsectvw->line_style;
                    ME.ECsectvw->tmp_element_selection =
                                           ME.ECsectvw->element_selection;
                    ME.ECsectvw->tmp_coord_sys_manual =
                                            ME.ECsectvw->coord_sys_manual;
                    ME.ECsectvw->tmp_scale_display_on =
                                            ME.ECsectvw->scale_display_on;
                    ME.ECsectvw->tmp_no_label = ME.ECsectvw->no_label;

                    ME.ECsectvw->tmp_recreate_solid = 
                                            ME.ECsectvw->recreate_solid;

                    /* put a form finished event on the queue so that, if
                     * currently in dynamics, it will be exitted and re-entered
                     * and will pick up any new values that affect it
                     * (i.e. scale)
                     */

                    response = EX_FORM_FINISHED;
                    size = 0;
                    status = ex$putque(msg = &temp_msg,
                                       byte = &size,
                                       response = &response,
                                       buffer = NULL);
                }
                else  /* EXIT_BUTTON - don't save changes */
                {
                    FIg_erase(ME.CEO->status_display_form_ptr,
                              (int) ME.ECsectvw->line_style);

                    ME.ECsectvw->crosshatch_off = ME.ECsectvw->tmp_crosshatch_off;
                    ME.ECsectvw->section_only = ME.ECsectvw->tmp_section_only;
                    ME.ECsectvw->rotate_align = ME.ECsectvw->tmp_rotate_align;
                    ME.ECsectvw->unsectioned_models = ME.ECsectvw->tmp_unsectioned_models;
                    ME.ECsectvw->line_style = ME.ECsectvw->tmp_line_style;
                    ME.ECsectvw->element_selection =
                                           ME.ECsectvw->tmp_element_selection;
                    ME.ECsectvw->coord_sys_manual =
                                            ME.ECsectvw->tmp_coord_sys_manual;
                    ME.ECsectvw->scale_display_on =
                                            ME.ECsectvw->tmp_scale_display_on;
                    ME.ECsectvw->no_label = ME.ECsectvw->tmp_no_label;

                    ME.ECsectvw->recreate_solid =
                                            ME.ECsectvw->tmp_recreate_solid;
                    strcpy(me->desc, ME.ECsectvw->tmp_desc);
                    strcpy(me->text_scale, ME.ECsectvw->tmp_text_scale);
                    strcpy(me->name, ME.ECsectvw->tmp_name);
                    strcpy(me->text_name, ME.ECsectvw->tmp_text_name);

                    if (me->text_scale[0] == '\0')
                        ME.ECsectvw->scale_flags &= ~USER_SCALE;

                    /* reset the gadgets back to the state they were in when
                     * the form was brought up
                     */

                    FIg_set_state(ME.CEO->status_display_form_ptr,
                                  CROSSHATCH_TOGGLE,
                                  (int) ME.ECsectvw->crosshatch_off);

                    FIg_set_state(ME.CEO->status_display_form_ptr,
                                  VISIBLE_LINES_TOGGLE,
                                  (int) ME.ECsectvw->section_only);

                    FIg_set_state(ME.CEO->status_display_form_ptr,
                                  PROJECT_ROTATE_TOGGLE,
                                  (int) ME.ECsectvw->rotate_align);

                    FIg_set_state(ME.CEO->status_display_form_ptr,
                                  UNSECTIONED_MODELS_TOGGLE,
                                  (int) ME.ECsectvw->unsectioned_models);
                    FIg_set_state(ME.CEO->status_display_form_ptr,
                                  RECREATE_SOLID_TOGGLE,
                                  (int) ME.ECsectvw->recreate_solid);
 

                    FIg_set_state(ME.CEO->status_display_form_ptr,
                                  ELEMENT_SELECT_TOGGLE,
                                  (int) ME.ECsectvw->element_selection);


                    if (ME.ECsectvw->section_only)
                    {
                        FIg_disable(ME.CEO->status_display_form_ptr,
                                    UNSECTIONED_MODELS_TOGGLE);
                        FIg_disable(ME.CEO->status_display_form_ptr,
                                    RECREATE_SOLID_TOGGLE);
                        ME.ECsectvw->recreate_solid = FALSE;
                    }
                    else
                    {
                        FIg_enable(ME.CEO->status_display_form_ptr,
                                   UNSECTIONED_MODELS_TOGGLE);
                        FIg_enable(ME.CEO->status_display_form_ptr,
                                    RECREATE_SOLID_TOGGLE);
                        ME.ECsectvw->recreate_solid = TRUE;
                    }
 

                    FIg_set_state(ME.CEO->status_display_form_ptr,
                                  MANUAL_COORDINATE_SYS,
                                  (int) ME.ECsectvw->coord_sys_manual);

                    FIg_set_state(ME.CEO->status_display_form_ptr,
                                  SCALE_DISPLAY_TOGGLE,
                                  (int) ME.ECsectvw->scale_display_on);

                    FIg_set_state(ME.CEO->status_display_form_ptr,
                                  LABEL_TOGGLE, (int) ME.ECsectvw->no_label);

                    if (ME.ECsectvw->no_label)
                    {
                        FIg_disable(ME.CEO->status_display_form_ptr,
                                    LABEL_FIELD);
                    }
                    else
                    {
                        FIg_enable(ME.CEO->status_display_form_ptr,
                                   LABEL_FIELD);
                    }

                    FIfld_set_text(ME.CEO->status_display_form_ptr,
                                   DESCRIPTION_FIELD, 0, 0, 
                                   (IGRuchar *) me->desc, FALSE);
                    FIfld_set_text(ME.CEO->status_display_form_ptr,
                                   SCALE_FIELD, 0, 0, 
                                   (IGRuchar *) me->text_scale, FALSE);
                    FIfld_set_text(ME.CEO->status_display_form_ptr,
                                   VIEW_NAME_FIELD, 0, 0,
                                   (IGRuchar *) me->name, FALSE);
                    FIfld_set_text(ME.CEO->status_display_form_ptr,
                                   LABEL_FIELD, 0, 0,
                                   (IGRuchar *) me->text_name, FALSE);
                }
                break;

            case MANUAL_COORDINATE_SYS:

                ME.ECsectvw->coord_sys_manual = (IGRboolean) value;
                break;

            case CROSSHATCH_TOGGLE:

                ME.ECsectvw->crosshatch_off = (IGRboolean) value;
                break;

            case VISIBLE_LINES_TOGGLE:

                ME.ECsectvw->section_only = (IGRboolean) value;

                /* if this toggle is set to Section View (show visible lines),
                 * the project-align toggle must be set to project since
                 * visible lines can't be shown for aligned views
                 */

                if (ME.ECsectvw->rotate_align)
                {
                    FIg_set_state(ME.CEO->status_display_form_ptr,
                                  PROJECT_ROTATE_TOGGLE, 0);
                    ME.ECsectvw->rotate_align = 0;
                }

                /* if this toggle is set to Section View (show visible lines),
                 * the unsectioned models toggle must be disabled since we
                 * we will only be dealing with sections
                 */


                if (ME.ECsectvw->section_only)
                {
                    FIg_disable(ME.CEO->status_display_form_ptr,
                                UNSECTIONED_MODELS_TOGGLE);
                    FIg_disable(ME.CEO->status_display_form_ptr,
                                    RECREATE_SOLID_TOGGLE);
                    ME.ECsectvw->recreate_solid = FALSE;
                }
                else
                {
                    FIg_enable(ME.CEO->status_display_form_ptr,
                               UNSECTIONED_MODELS_TOGGLE);
                    FIg_enable(ME.CEO->status_display_form_ptr,
                                    RECREATE_SOLID_TOGGLE);
                    ME.ECsectvw->recreate_solid = TRUE;
                }
 

                break;

            case PROJECT_ROTATE_TOGGLE:

                /* don't allow rotated (aligned) sections if visible lines
                 * (Section View toggle) is on - i.e. this toggle can only be
                 * set to Aligned if the section type toggle
                 * (VISIBLE_LINES_TOGGLE) is set to Section Only
                 */

                if ((! ME.ECsectvw->section_only) &&
                    (value == 1.0))
                {
                    FIg_set_state(ME.CEO->status_display_form_ptr,
                                  gadget_label, 0);

                    ex$message(msgnumb = EMS_I_SetScTgScOnly,
                               buff = (IGRchar *) text_ptr);

                    FIfld_set_text(ME.CEO->status_display_form_ptr,
                                   FORM_MESSAGE_FIELD, 0, 0, text_ptr, FALSE);
                }
                else
                    ME.ECsectvw->rotate_align = (IGRboolean) value;

                break;

            case UPPER_DASH_DOT_LINE:
            case LOWER_DASH_DASH_LINE:
            case UPPER_DASH_DASH_LINE:
            case LOWER_DASH_DOT_LINE:

                /* erase this line and display the other upper line */

                FIg_erase(ME.CEO->status_display_form_ptr, gadget_label);

                if (gadget_label == UPPER_DASH_DOT_LINE)
                    ME.ECsectvw->line_style = UPPER_DASH_DASH_LINE;
                else if (gadget_label == LOWER_DASH_DASH_LINE)
                    ME.ECsectvw->line_style = LOWER_DASH_DOT_LINE;
                else if (gadget_label == UPPER_DASH_DASH_LINE)
                    ME.ECsectvw->line_style = UPPER_DASH_DOT_LINE;
                else if (gadget_label == LOWER_DASH_DOT_LINE)
                    ME.ECsectvw->line_style = LOWER_DASH_DASH_LINE;

                FIg_display(ME.CEO->status_display_form_ptr,
                            ME.ECsectvw->line_style);
                break;

            case LEFT_ARROW:
            case RIGHT_ARROW:
            case RIGHT_LINE_ARROW:
            case LEFT_LINE_ARROW:

                FIg_erase(ME.CEO->status_display_form_ptr,
                          ME.ECsectvw->line_style);

                if (ME.ECsectvw->line_style == UPPER_DASH_DOT_LINE)
                    ME.ECsectvw->line_style = LOWER_DASH_DOT_LINE;
                else if (ME.ECsectvw->line_style == UPPER_DASH_DASH_LINE)
                    ME.ECsectvw->line_style = LOWER_DASH_DASH_LINE;
                else if (ME.ECsectvw->line_style == LOWER_DASH_DOT_LINE)
                    ME.ECsectvw->line_style = UPPER_DASH_DOT_LINE;
                else if (ME.ECsectvw->line_style == LOWER_DASH_DASH_LINE)
                    ME.ECsectvw->line_style = UPPER_DASH_DASH_LINE;

                FIg_display(ME.CEO->status_display_form_ptr,
                            ME.ECsectvw->line_style);
                break;

            case VIEW_NAME_FIELD:

                FIfld_get_text(ME.CEO->status_display_form_ptr,
                               VIEW_NAME_FIELD, 0, 0, DI_PATH_MAX,
                               (IGRuchar *) me->name, &sel_flag, &r_pos);

                /* check to see if the name is a duplicate and if it is,
                 * display an error message and clear the name field
                 */

                di$pwd(dirname = sectvw_name);
                di$strcat(to = sectvw_name,
                          from = me->name);

                sts = di$translate(objname = sectvw_name,
                                   p_objid = &dir_objid,
                                   p_osnum = &dir_osnum);

                if (sts == DIR_S_SUCCESS)
                {
                    ex$message(msgnumb = GR_E_DupNme,
                               buff = (IGRchar *) text_ptr);

                    FIfld_set_text(ME.CEO->status_display_form_ptr,
                                   FORM_MESSAGE_FIELD, 0, 0, text_ptr,
                                   FALSE);
                    me->name[0] = '\0';
                    FIfld_set_text(ME.CEO->status_display_form_ptr,
                                   VIEW_NAME_FIELD, 0, 0, me->name, FALSE);
                }
                break;

            case UNSECTIONED_MODELS_TOGGLE:

                ME.ECsectvw->unsectioned_models = (IGRboolean) value;
                break;

            case RECREATE_SOLID_TOGGLE:
  
                ME.ECsectvw->recreate_solid = (IGRboolean) value;
                break;

            case SCALE_FIELD:

                /* need to check and see if the scale is valid */

                FIfld_get_text(ME.CEO->status_display_form_ptr,
                               SCALE_FIELD, 0, 0, DESC_SCALE_LEN,
                               scale_string, &sel_flag, &r_pos);

                if (strlen(scale_string))
                {
                    GRmodel_scale(&temp_msg,
                                  &ME.ECsectvw->module_env.md_id.osnum,
                                  &ME.ECsectvw->module_env.md_id.osnum,
                                  scale_string, scale_matrix);

                    if (temp_msg & 1)
                    {
                        ME.ECsectvw->scale_flags |= USER_SCALE;
                        strcpy(me->text_scale, scale_string);
                    }
                    else
                    {
                        /* display a message that the scale is invalid and
                         * put the previous valid scale back in the field
                         */

                        ex$message(msgnumb = GR_E_InvScFac,
                                   buff = (IGRchar *) text_ptr);

                        FIfld_set_text(ME.CEO->status_display_form_ptr,
                                       FORM_MESSAGE_FIELD, 0, 0, text_ptr,
                                       FALSE);

                        FIfld_set_text(ME.CEO->status_display_form_ptr,
                                       SCALE_FIELD, 0, 0, 
                                       (IGRuchar *) me->text_scale, FALSE);
                    }
                }
                else
                {
                    /* no scale was specified, which indicates that the scale
                     * of the located drawing view should be used, so display
                     * that scale in the scale field and clear the bit
                     * indicating the scale is a user specified scale
                     */

                    if (me->dv_id1.objid != NULL_OBJID)
                    {
                        status = om$send(msg = message GRdrawview.GRget_drawview_scale(
                                                  &temp_msg,
                                                  &ME.ECsectvw->dv_mod_env1,
                                                  me->text_scale, NULL),
                                         targetid = me->dv_id1.objid,
                                         targetos = me->dv_id1.osnum);

                        if (1 & status & temp_msg)
                        {
                            FIfld_set_text(ME.CEO->status_display_form_ptr,
                                           SCALE_FIELD, 0, 0,
                                           (IGRuchar *) me->text_scale, FALSE);
                        }
                    }
                    ME.ECsectvw->scale_flags &= ~USER_SCALE;
                }
                break;

            case SCALE_DISPLAY_TOGGLE:

                ME.ECsectvw->scale_display_on = (IGRboolean) value;
                break;

            case ELEMENT_SELECT_TOGGLE:

                ME.ECsectvw->element_selection = (IGRboolean) value;
                break;

            case LABEL_TOGGLE:

                ME.ECsectvw->no_label = (IGRboolean) value;

                /* if the place label toggle is off, disable the label field
                 * since the field won't be used, otherwise enable the field
                 */

                if (ME.ECsectvw->no_label)
                    FIg_disable(ME.CEO->status_display_form_ptr, LABEL_FIELD);
                else
                    FIg_enable(ME.CEO->status_display_form_ptr, LABEL_FIELD);

                break;

            case XHATCH_PARAMS_BUTTON:

                /* initialize and display the form used to set the
                 * crosshatching parameters; must first erase the current
                 * form; have to set the form's pointer to be the status
                 * display form because its method expect it to be the
                 * status display form
                 */

                om$send(msg = message CEO.erase_form_by_label(STATUS_FORM,
                                                              0, &sts),
                        targetid = my_id);

                if (! (1 & status & sts))
                    goto quit;

                ME.ECsectvw->save_form_ptr = ME.CEO->status_display_form_ptr;
                ME.CEO->status_display_form_ptr = ME.CEO->forms[0].form_ptr;

                status = om$send(mode = OM_e_wrt_message,
                                 msg = message ECaxhatch.status_disp(),
                                 targetid = my_id);

                if (! (1 & status))
                    goto quit;
                break;

            default:

                break;
        }
    }
    else if (form_label == 0)  /* form to set crosshatching parameters */
    {
        /* send this action's input to the ECaxhatch.form_notification;
         * if the form is being dismissed, set up the original status display
         * form as the current status display form and display it
         */

        om$send(mode = OM_e_wrt_message,
                msg = message ECaxhatch.form_notification(form_label,
                                                         gadget_label, value,
                                                         form_ptr),
                targetid = my_id);

        if ((gadget_label == ACCEPT_BUTTON) ||
            (gadget_label == EXIT_BUTTON))
        {
            ME.CEO->status_display_form_ptr = ME.ECsectvw->save_form_ptr;

            /* update the icon on the cross hatching subform button */

            om$send(msg = message ECsectvw.update_xhatch_button(),
                    targetid = my_id);
            om$send(msg = message CEO.display_form_by_label(STATUS_FORM, &sts),
                    targetid = my_id);
        }
    }
}

/*\
Description
   This action crosshatches the section objects.  It gets the ids of all the
   sections connected to the section view then calls the function
   GRauto_nester to find any holes (boundaries) within each of the sections.
   If a hole is found, it should be one of the other sections and that section
   should be marked so that it will not be crosshatched.

Notes
   This function depends upon the following instance variables:
      me->sect_view_grid
      me->section_index
      me->window_id
\*/


action crosshatch_sections ()
{

    extern IGRlong       GRauto_nester();
    extern IGRint        GRxh_load_pattern();

    IGRlong              sts,
                         func_msg,
                         temp_msg,
			 flag=1,
                         graph_index = OM_K_MAXINT,
                         ptn_type;
    IGRint               rc,
                         index,
			 ind = 0,
			 *track_grps=NULL,
                         connect_index = OM_K_MAXINT,
                         index1,
                         index2,
                         index3,
                         index4,
			 sol_index,
                         num_entries,
                         name_size = 80,
                         desc_size = 80,
                         ret_name_size,
                         ret_desc_size,
                         num_parents,
                         parent_list_size;
    IGRuint              num_objects,
                         num_objs,
			 current_section,
 			 num_sections,
                         current_objs;
    IGRdouble            world_origin[3];
    IGRmatrix            *matr[1];
    OM_S_CHANSELECT      to_owners,to_cmpnt_chansel;
    OM_S_OBJECT_LINKAGE  *object_list1=NULL,*object_list;
    struct sect_objects  *sections;
    struct GRid          xhatch_grid,
			 *act_objs,
			 *list_ids = NULL,
                         active_cs;
    struct GRlc_info     lc_info,
                         *ret_objects;
    struct GRIOvar_def   xh_pattern_type;
    struct GRvg_construct construct_list;
    struct IGRdisplay    display_attr;
    struct EMSobject_info *parents;
    struct GRaxhatch_info xhatch_info;
    GRspacenum           cur_mod_osnum;
    GRclassid            classid;
    IGRchar              act_cs_name[80],
                         act_cs_desc[80];

    me->ret = OM_S_SUCCESS;

    /* get the objects connected to the section view object */

    status = om$make_chanselect(channame = "GRconnector.to_owners",
                                    p_chanselect = &to_owners);
    status = om$make_chanselect(channame = "GRcmpowner.to_components",
                                    p_chanselect = &to_cmpnt_chansel);
    if (! (1 & status))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    status = om$get_channel_count(osnum = ME.ECsectvw->sect_view_grid.osnum,
                                  objid = ME.ECsectvw->sect_view_grid.objid,
                                  p_chanselect = &to_cmpnt_chansel,
                                  count = &num_objects);
    if (! (1 & status))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    object_list = NULL; /* contains all objects connected to sect-vw object */
    object_list = (OM_S_OBJECT_LINKAGE *) alloca(num_objects *
                                                 sizeof(OM_S_OBJECT_LINKAGE));
    if (! object_list)
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }
    /* to store all solids */
    list_ids = (struct GRid *) alloca(num_objects * sizeof(struct GRid));
    if (! list_ids)
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    status = om$get_channel_objects(osnum = ME.ECsectvw->sect_view_grid.osnum,
                                    objid = ME.ECsectvw->sect_view_grid.objid,
                                    p_chanselect = &to_cmpnt_chansel,
                                    list = object_list,
                                    size = num_objects,
                                    count = &num_objs);
    act_objs = NULL; /* contains graphic groups */
    act_objs = (struct GRid *)alloca(num_objs * sizeof(struct GRid));
    if (! (1 & status) || !act_objs)
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

/* the graphic groups(each contains sections obtained out of one solid) 
 * are connected to the section-view object in 
 * the construct-associative method so that all sections of a particular
 * solid are available for patterning purposes
 */

 /* sort out the graphic groups & solids and disconnect the solids
  * to maintain the same order of connection to the sect-view object
  */
    for (index = 0, sol_index=0,current_objs = 0; index < num_objs; index++)
    {
        status = om$get_classid(osnum = object_list[index].osnum,
                                objid = object_list[index].S_objid,
                                p_classid = &classid);
        if (! (1 & status))
        {
            status = OM_E_ABORT;
            goto quit;
        }

        status = om$is_ancestry_valid(subclassid = classid,
                                      superclassid = OPP_EMSsolid_class_id);
        if (status == OM_I_INVANCESTRY)
        {
            act_objs[current_objs].objid = object_list[index].S_objid;
	    act_objs[current_objs].osnum = object_list[index].osnum;
            current_objs++;
        }
        else if (! (status & 1))
        {
            status = OM_E_ABORT;
            goto quit;
        }
	else
	  {
	  list_ids[sol_index].objid = object_list[index].S_objid;
	  list_ids[sol_index++].osnum = object_list[index].osnum;

          status = om$send(msg = message GRconnector.GRdisconn(&sts,
					&ME.ECsectvw->sect_view_grid),
                                targetid = object_list[index].S_objid,
                                targetos = object_list[index].osnum);
          if (! (status & 1))
            {
                me->ret = OM_E_ABORT;
                goto quit;
            }
          }

    }
    num_objs = current_objs;

    /* stores the number of sections for a solid */
    track_grps = (IGRint *)alloca (sizeof(IGRint) * num_objs);
   
/* get the sections from the graphic groups and connect to the section
 * view object
 */
    for (index = 0; index < num_objs; index++)
    {
    IGRuint num_objects=0,num_sections;
    OM_S_OBJECT_LINKAGE *aobject_list ;
    status = om$get_channel_count(osnum = act_objs[index].osnum,
                                  objid = act_objs[index].objid,
                                  p_chanselect = &to_cmpnt_chansel,
                                  count = &num_objects);
 
    aobject_list = NULL; /* stores  sections */
    aobject_list = (OM_S_OBJECT_LINKAGE *) alloca(num_objects *
                                                 sizeof(OM_S_OBJECT_LINKAGE));
    if (! aobject_list)
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }
 
    status = om$get_channel_objects(osnum = act_objs[index].osnum,
                                    objid = act_objs[index].objid,
                                    p_chanselect = &to_cmpnt_chansel, 
				    list = aobject_list,
                                    size = num_objects,
                                    count = &num_sections);
    if (! (1 & status))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }
    track_grps[index] = num_sections;

/* disconnect the graphic group  */
    status = om$send(msg = message Root.wild_disconnect(to_owners),
                                senderid = NULL_OBJID,
                                targetid = act_objs[index].objid,
                                targetos = act_objs[index].osnum);
      if (! (status & 1))
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }

/* connect the sections to the section-view object */
    for(index1 = 0; index1 < num_sections; index1++)
       {

       status = om$send (msg = message GRconnector.GRrigidconn(&sts,
                                                   &ME.ECsectvw->sect_view_grid,
                                                   (IGRlong *)&connect_index),
			       senderid = NULL_OBJID,
                               targetid = aobject_list[index1].S_objid,
                               targetos = aobject_list[index1].osnum);
      if (! (status & sts & 1))
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }
      status = om$send (msg = message GRconnector.GRflexconn(&sts,
                                                 &flag, &act_objs[index],
                                                 (IGRlong *)&connect_index,
                                                 &graph_index),
                               senderid = NULL_OBJID,
                               targetid = aobject_list[index1].S_objid,
                               targetos = aobject_list[index1].osnum);
      if (! (status & sts & 1))
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }

      }
    }

/* connect back the solids to the section view object  */
    for(index = 0; index < sol_index; index++)
      {
      status = om$send (msg = message GRconnector.GRrigidconn(&sts,
                                                   &ME.ECsectvw->sect_view_grid,
                                                   (IGRlong *)&connect_index),
                               senderid = NULL_OBJID,
                               targetid = list_ids[index].objid,
                               targetos = list_ids[index].osnum);
      if (! (status & sts & 1))
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }

      }
/* now get all the sections connected to the section-view object */
    num_objects = 0;
    status = om$get_channel_count(osnum = ME.ECsectvw->sect_view_grid.osnum,
                                  objid = ME.ECsectvw->sect_view_grid.objid,
                                  p_chanselect = &to_cmpnt_chansel,
                                  count = &num_objects);
    if (! (1 & status))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    object_list1 = NULL;
    object_list1 = (OM_S_OBJECT_LINKAGE *) alloca(num_objects *
                                                 sizeof(OM_S_OBJECT_LINKAGE));
    if (! object_list1)
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    status = om$get_channel_objects(osnum = ME.ECsectvw->sect_view_grid.osnum,
                                    objid = ME.ECsectvw->sect_view_grid.objid,
                                    p_chanselect = &to_cmpnt_chansel,
                                    list = object_list1,
                                    size = num_objects,
                                    count = &num_sections);
    if (! (1 & status))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    sections = NULL;
    sections = (struct sect_objects *) alloca(num_sections *
                                              sizeof(struct sect_objects));
    if (! sections)
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    for (index = 0, current_section = 0; index < num_sections; index++)
    {
        /* check each object on the channel since it may be a solid that
         * represents the remaining section of a sectioned object - these
         * solids should not be crosshatched
         */

        status = om$get_classid(osnum = object_list1[index].osnum,
                                objid = object_list1[index].S_objid,
                                p_classid = &classid);
        if (! (1 & status))
        {
            status = OM_E_ABORT;
            goto quit;
        }

        status = om$is_ancestry_valid(subclassid = classid,
                                      superclassid = OPP_EMSsolid_class_id);
        if (status == OM_I_INVANCESTRY)
        {
            sections[current_section].grid.objid = object_list1[index].S_objid;
            sections[current_section].grid.osnum = object_list1[index].osnum;
            sections[current_section].num_boundaries = 0;
            current_section++;
        }
        else if (! (status & 1))
        {
            status = OM_E_ABORT;
            goto quit;
        }
    }
    num_sections = current_section;

    OM_BLOCK_MOVE(&ME.ECsectvw->module_env ,&lc_info.module_info,
                  sizeof(struct GRmd_env));
    for(index1 = 0; index1 < num_sections; index1++)
       {
       /* call GRauto_nester to find any internal boundaries (holes) in each
        * section; if any are found, they should be compared to the other
        * sections since these are the only valid boundaries - if a match is
        * found that section should be marked so that it'll not be crosshatched
        */

       lc_info.located_obj.objid = sections[index1].grid.objid;
       lc_info.located_obj.osnum = sections[index1].grid.osnum;
       ret_objects = NULL;

       status = GRauto_nester(&sts, &lc_info, me->window_id,
                               &me->attributes,
                               &me->locate_eligible_thing,
		               &ret_objects, 
			       &num_entries);

       if (1 & status & sts)
       {
          /* allocate memory for the boundaries (holes) */

            if (num_entries)
            {
                sections[index1].boundaries = NULL;
                sections[index1].boundaries = (struct EMSobject_info *) 
			alloca(num_entries * sizeof(struct EMSobject_info));
                if (! sections[index1].boundaries)
                {
                    me->ret = OM_E_ABORT;
                    goto quit;
                }

                /* check to make sure each of the holes is one of the other
                 * sections, else they're invalid; the matching section's objid
                 * should be set to NULL_OBJID so that it won't be crosshatched;
                 * add the hole (internal boundaries) objects to the variable
                 * length array and set the start index of these holes in the
                 * corresponding section
                 */

                for (index2 = 0; index2 < num_entries; index2++)
                {
                    for (index3 = 0; index3 < num_sections; index3++)
                    {
                        if ((ret_objects[index2].located_obj.objid ==
                             sections[index3].grid.objid) &&
                            (ret_objects[index2].located_obj.osnum ==
                             sections[index3].grid.osnum))
                        {
                            sections[index3].grid.objid = NULL_OBJID;
                            sections[index1].boundaries[sections[index1].num_boundaries].grid.objid =
                            ret_objects[index2].located_obj.objid;
                            sections[index1].boundaries[sections[index1].num_boundaries].grid.osnum =
                            ret_objects[index2].located_obj.osnum;

                            (sections[index1].num_boundaries)++;
                            break;
                        }
                    }
                }
            }
        }

        if (ret_objects)
            om$dealloc(ptr = ret_objects);
        }

    /* create an associative crosshatch object for each of the "eligible"
     * sections
     */

    if (num_sections)
    {
        /* get the dpb values for the crosshatching parameters */

        status = gr$get_xhatch_spacing(buffer = (IGRchar *) &xhatch_info.xhatch_spacing);

        if (! (1 & status))
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }

/*
        status = gr$get_xhatch_angle(buffer = (IGRchar *) &xhatch_info.xhatch_angle);
*/
        if (! (1 & status))
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }

        ex$get_cur_mod(osnum = &cur_mod_osnum);

        status = co$cvtvar(msg = &sts,
                           alias = "COXH_PATTERN_TYPE",
                           osnum = cur_mod_osnum,
                           var = (IGRchar *) &xh_pattern_type);

        if (! (status & sts & 1))
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }

        ptn_type = (IGRlong) xh_pattern_type.contents.ivalue;

        rc = GRxh_load_pattern(ptn_type, xhatch_info.xhatch_spacing,
                               &xhatch_info.pattern_def);

        if (! (rc & 1))
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }

        xhatch_info.window_grid = me->window_id;

        construct_list.msg = &func_msg;
        construct_list.env_info = &ME.ECsectvw->module_env;
        construct_list.newflag = FALSE;
        construct_list.level = ME.ECsectvw->active_layer;
        construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        construct_list.geometry = NULL;
        construct_list.display = &ME.ECsectvw->display_attr;
        construct_list.class_attr = NULL;
        construct_list.name = NULL;

        xhatch_info.xhatch_color = ME.ECsectvw->display_attr.color;
        matr[0] = (IGRmatrix *) ME.ECsectvw->module_env.md_env.matrix;
        xhatch_grid.osnum = ME.ECsectvw->module_env.md_id.osnum;

        active_cs.osnum = ME.ECsectvw->module_env.md_id.osnum;

        status = cs$get_active_info(msg = &sts,
    			            osnum = active_cs.osnum,
			            namebuf_size = name_size,
                                    name = act_cs_name,
                                    namebytes_ret = &ret_name_size,
                                    descbuf_size = desc_size,
                                    desc = act_cs_desc,
                                    descbytes_ret = &ret_desc_size,
			            objid = &active_cs.objid);

        if (! (status & sts & 1))
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }

        world_origin[0] = 0.0;
        world_origin[1] = 0.0;
        world_origin[2] = 0.0;

        status = om$send(msg = message GRcoords.GRcvt_to_wld_coords(&sts,
						Rectangular, 1,	world_origin,
						xhatch_info.origin),
 		         targetos = active_cs.osnum,
                         targetid = active_cs.objid);

        if (! (status & sts & 1))
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }

        parent_list_size = 0;

/* num_objs stores the number of solids in the drawing view */
        for(ind = 0; ind < num_objs; ind ++)
          {
          if (ind == 0) { index4=0; num_sections = track_grps[ind];}
          else {num_sections += track_grps[ind];}
        xhatch_info.xhatch_angle = xhatch_angles[ind%6]; 
        for (; index4 < num_sections; index4++)
        {
            if (sections[index4].grid.objid != NULL_OBJID)
            {
                struct GRid id;
                num_parents = sections[index4].num_boundaries + 1;

                if (parent_list_size < num_parents)
                {
                    parents = NULL;
                    parents = (struct EMSobject_info *) alloca(num_parents *
                                              sizeof(struct EMSobject_info));
                    if (parents)
                    {
                        parents[0].grid.osnum = ME.ECsectvw->module_env.md_id.osnum;
                        OM_BLOCK_MOVE(&ME.ECsectvw->module_env,
                                      &parents[0].env, sizeof(struct GRmd_env));

                        parent_list_size = num_parents;
                    }
                    else
                    {
                        me->ret = OM_E_ABORT;
                        goto quit;
                    }
                }

                parents[0].grid.objid = sections[index4].grid.objid;

                if (sections[index4].num_boundaries)
                {
                    OM_BLOCK_MOVE(sections[index4].boundaries, &parents[1],
                                  sections[index4].num_boundaries *
                                  sizeof(struct EMSobject_info));
                }

                status = om$construct(classid = OPP_GRaxhatch_class_id,
                                      p_objid = &xhatch_grid.objid,
                                      msg = message EMSassoc.EMinit_associative(
                                                &temp_msg, NULL, num_parents,
                                                parents, GR_axhatch_elem,
                                                sizeof (struct GRaxhatch_info),
                                                (IGRchar *) &xhatch_info,
                                                &construct_list),
                                      osnum = construct_list.env_info->md_id.osnum);

                if (1 & status & temp_msg)
                {
                    dp$display(msg = &temp_msg,
                               osnum = construct_list.env_info->md_id.osnum,
                               mode = GRbd,
                               oids = &xhatch_grid,
                               num_elem = 1,
                               mtx_type = &ME.ECsectvw->module_env.md_env.matrix_type,
                               matrix = matr);
                }

            }
        }
      }
    }
}

/*\
Description
   This action locates objects subclassed from EMSsolid in the selected
drawing view and any nested reference files within the drawing view.
The located objects and their contexts will be placed in this commands
instance data for either model objects or parents, depending on the input
argument model.  If model is TRUE, ECsectvw->num_models will contain the
number of objects located and the objids and module environments of these
objects will be in ECsectvw->model_elems.  If model is FALSE,
ECsectvw->num_parents will contain the number of objects located and the
objids and module environments of these objects will be put in
ECsectvw->parents beginning at index 2 since parents index 0 is reserved
for the cutting plane line and parents index 1 is reserved for the associated
drawing view.

Notes
   This function depends upon the following instance variables:
      me->module_env
      me->dv_id1
\*/

action get_dv_solids(IGRint model)
{
    extern IGRint          EFstore_elem_act();

    IGRlong                temp_msg,
                           levels[NUM_LEVEL_INTS],
                           action_rc,
                           bytes_ret;
    IGRint                 type,
                           index,
                           which_error;
    OM_S_CLASSLIST         eligible_classes;
    GRclassid              classid;
    struct GRlc_cvl        cvl;
    struct LC_action_args  action_info;
    struct GRlc_stack      stack;
    struct GRid            ref_grid;
    struct var_list        list[2];

    struct EFloc_elems
    {
        IGRint            num_elems;          /* number of located elements */
        IGRint            num_avail_entries;  /* number of entries currently
                                                 allocated for lc_info */
        struct GRlc_info  *lc_info;           /* memory for this will be
                                                 allocated in the action
                                                 handler */
    }     action_args;

    me->ret = MSSUCC;
    action_args.num_elems = 0;

    /* find the solid objects in the reference file attached to the
     * located drawing view
     */

    status = om$send(msg = message GRdrawview.GRget_component_id(&temp_msg,
                                     GR_DV_REFFILE, 1, &ref_grid, &type),
                     targetid = me->dv_id1.objid,
                     targetos = me->dv_id1.osnum);

    if (! (1 & status & temp_msg))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    status = om$get_classid(classname = "EMSsolid",
                            p_classid = &classid);

    if (! (1 & status))
    {
        status = OM_E_ABORT;
        goto quit;
    }

    cvl.attributes.type = GR_crit_loc;
    cvl.attributes.obj_attr.classes[0] = '\0';
    cvl.attributes.obj_attr.properties = LC_DP_ONLY | LC_LC_ONLY | LC_RW;
    cvl.attributes.obj_attr.owner_action = LC_RIGID_OWNER |
                                           LC_RIGID_COMP  |
                                           LC_ASSOCIATIVE |
                                           LC_FLEX_COMP |
                                           LC_EXTERN_CONSTRAINED |
                                           LC_REF_OBJECTS;
    cvl.action_handler = EFstore_elem_act;
    action_args.num_avail_entries = 0;
    cvl.act_parms = (IGRchar *) &action_args;

    list[0].var = LEVELS;
    list[0].var_ptr = (char *)levels;
    list[0].num_bytes = sizeof(IGRint)*32;
    list[0].bytes_returned= &bytes_ret;
    list[1].var = END_PARAM;
    list[1].var_ptr = NULL;
    list[1].num_bytes = 0;
    list[1].bytes_returned = NULL;

    status = dp$inq_set_gragad(msg = &temp_msg,
                               osnum = me->window_id.osnum,
                               gragad_objid = me->window_id.objid,
                               which_error = &which_error,
                               var_list = list);

    if (! (1 & status & temp_msg))
    {
        status = OM_E_ABORT;
        goto quit;
    }

    cvl.levels = (IGRint *)levels;

    eligible_classes.w_count = 1;
    eligible_classes.w_flags = OM_CLST_subclass;
    eligible_classes.p_classes = &classid;
    cvl.classes = &eligible_classes;

    action_info.rc = &action_rc;
    action_info.stack = &stack;
    action_info.type = GR_crit_loc;
    action_info.max_entries = 1;
    action_info.select = NULL;
    cvl.locate_args = &action_info;
    cvl.r_classes = NULL;
    cvl.data = NULL;

    /* GRreffile's GRfunction method will pass on the message to the
     * nested reference files
     */

    OM_BLOCK_MOVE(&ME.ECsectvw->module_env, &cvl.module,
                  sizeof(struct GRmd_env));

    status = om$send(msg = message GRgraphics.GRlocate(&cvl, NULL),
                     targetid = ref_grid.objid,
                     targetos = ref_grid.osnum);

    if (! (1 & status & temp_msg))
    {
        status = OM_E_ABORT;
        goto quit;
    }

    if (action_args.num_elems >= 1)
    {
        if (model)
        {
            index = om$dimension_of(varray = ME.ECsectvw->model_elems);

            if (index < action_args.num_elems)
            {
                om$vla_set_dimension(varray = ME.ECsectvw->model_elems,
                                     size = action_args.num_elems);
            }

            ME.ECsectvw->num_models = action_args.num_elems;

            for (index = 0; index < action_args.num_elems; index++)
            {
                ME.ECsectvw->model_elems[index].grid = action_args.lc_info[index].located_obj;
                OM_BLOCK_MOVE(&action_args.lc_info[index].module_info,
                              &ME.ECsectvw->model_elems[index].env,
                              sizeof(struct GRmd_env));
            }

            /* only have the cutting plane line and drawing view so far */

            ME.ECsectvw->num_parents = 2;
            ME.ECsectvw->dvattach_index = INITIAL_DVATTACH_INDEX;
        }
        else  /* put the located objects in the "parents" instance data */
        {
            /* size of parents array must be two larger than the number of
             * located objects since the first entry in the array is reserved
             * for the cutting plane line and the second entry is reserved
             * for the associated drawing view
             */

            index = om$dimension_of(varray = ME.ECsectvw->parents);

            if (index < action_args.num_elems + 2)
            {
                om$vla_set_dimension(varray = ME.ECsectvw->parents,
                                     size = action_args.num_elems + 2);
            }

            ME.ECsectvw->num_parents = action_args.num_elems + 2;

            for (index = 0; index < action_args.num_elems; index++)
            {
                ME.ECsectvw->parents[index + 2].grid = action_args.lc_info[index].located_obj;
                OM_BLOCK_MOVE(&action_args.lc_info[index].module_info,
                              &ME.ECsectvw->parents[index + 2].env,
                              sizeof(struct GRmd_env));
            }
        }
    }
    else
    {
        me->ret = MSINARG;
        goto quit;
    }

    if (action_args.num_elems)
    {
        om$dealloc(ptr = action_args.lc_info);
    }
}

/*\
Description
   This action first verifies that the located objects are included in the
list of model objects in the selected drawing view.  If they are, they are
added to the list of parent objects.  If the argument "sectioned_solids" is
FALSE, the located object will be compared to the objects in the "parent" list
and if it is, it will be moved to the "unsectioned parents" part of the array.

Notes
   This function depends upon the following instance variables:
      me->num_models
      me->model_elems
\*/


action add_verified_solids (IGRint sectioned_solids)
{

    extern IGRint          GRgsget_all_objects(),
                           GRis_matrix_equal();

    struct GRobj_env       *obj_info=NULL;
    struct GRid            my_grid;
    struct EMSobject_info  unsectioned_object_info;
    IGRint                 rc,
			   ii,
			   num_objects,
                           index,
                           size;
    IGRlong                ret_msg;

    /* determine whether the located solid is in the list of model objects
     * gathered from the selected drawing view
     */

    me->ret = EMS_S_ElNotSlDrVw;
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    rc = GRgsget_all_objects(&status, &my_grid, &me->located_chansel,
                               &obj_info,&num_objects);

    if (1 & rc & status)
    {
        /* if adding a non-section parent, first check to make sure
         * the parent is not already in the list of non-section parents
         */

      for(ii = 0; ii < num_objects; ii++)
        {
        if (! sectioned_solids)
        {
            for (index = FIRST_UNSECT_MODEL_INDEX;
                 index < ME.ECsectvw->dvattach_index; index++)
            {
                if ((obj_info[ii].obj_id.objid == ME.ECsectvw->parents[index].grid.objid) &&
                    (obj_info[ii].obj_id.osnum == ME.ECsectvw->parents[index].grid.osnum) &&
                    (obj_info[ii].mod_env.md_id.objid == ME.ECsectvw->parents[index].env.md_id.objid) &&
                    (obj_info[ii].mod_env.md_id.osnum == ME.ECsectvw->parents[index].env.md_id.osnum) &&
                    (obj_info[ii].mod_env.md_env.matrix_type == ME.ECsectvw->parents[index].env.md_env.matrix_type))
                {
                    GRis_matrix_equal(&ret_msg, obj_info[ii].mod_env.md_env.matrix,
                                      ME.ECsectvw->parents[index].env.md_env.matrix);

                    if (ret_msg == MSSUCC)
                    {
                        me->ret = EMS_I_ElAlrdySel;
                        break;
                    }
                }
            }
        }

        if (me->ret != EMS_I_ElAlrdySel)
        {
            /* check to see if the selected element has already been added to
             * the list of section elements (the elements that follow the
             * drawing view attachment)
             */

            for (index = ME.ECsectvw->dvattach_index + 1;
                 index < ME.ECsectvw->num_parents; index++)
            {
                if ((obj_info[ii].obj_id.objid == ME.ECsectvw->parents[index].grid.objid) &&
                    (obj_info[ii].obj_id.osnum == ME.ECsectvw->parents[index].grid.osnum) &&
                    (obj_info[ii].mod_env.md_id.objid == ME.ECsectvw->parents[index].env.md_id.objid) &&
                    (obj_info[ii].mod_env.md_id.osnum == ME.ECsectvw->parents[index].env.md_id.osnum) &&
                    (obj_info[ii].mod_env.md_env.matrix_type == ME.ECsectvw->parents[index].env.md_env.matrix_type))
                {
                    GRis_matrix_equal(&ret_msg, obj_info[ii].mod_env.md_env.matrix,
                                      ME.ECsectvw->parents[index].env.md_env.matrix);

                    if (ret_msg == MSSUCC)
                    {
                        if (sectioned_solids)
                            me->ret = EMS_I_ElAlrdySel;
                        else
                        {
                            /* unsectioned solids are inserted between the cutting
                             * plane line segment and the drawing view attachment;
                             * must save the entry that is to be moved from a
                             * "sectioned" position to an "unsectioned" position,
                             * then move the entries starting with the current
                             * drawing view attachment entry over one position
                             * to overwrite the saved entry, then insert the saved
                             * entry into the just vacated entry
                             */

                            OM_BLOCK_MOVE(&ME.ECsectvw->parents[index],
                                          &unsectioned_object_info,
                                          sizeof(struct EMSobject_info));
                            OM_BLOCK_MOVE(&ME.ECsectvw->parents[ME.ECsectvw->dvattach_index],
                                          &ME.ECsectvw->parents[ME.ECsectvw->dvattach_index + 1],
                                          sizeof(struct EMSobject_info) *
                                            (index - ME.ECsectvw->dvattach_index));
                            OM_BLOCK_MOVE(&unsectioned_object_info,
                                          &ME.ECsectvw->parents[ME.ECsectvw->dvattach_index],
                                          sizeof(struct EMSobject_info));
                            ME.ECsectvw->dvattach_index++;
                            me->ret = MSSUCC;
                        }
                        break;
                    }
                }
            }

            if (sectioned_solids)
            {
                for (index = 0; index < ME.ECsectvw->num_models; index++)
                {
                    if ((obj_info[ii].obj_id.objid == ME.ECsectvw->model_elems[index].grid.objid) &&
                        (obj_info[ii].obj_id.osnum == ME.ECsectvw->model_elems[index].grid.osnum) &&
                        (obj_info[ii].mod_env.md_id.objid == ME.ECsectvw->model_elems[index].env.md_id.objid) &&
                        (obj_info[ii].mod_env.md_id.osnum == ME.ECsectvw->model_elems[index].env.md_id.osnum) &&
                        (obj_info[ii].mod_env.md_env.matrix_type == ME.ECsectvw->model_elems[index].env.md_env.matrix_type))
                    {
                        GRis_matrix_equal(&ret_msg, obj_info[ii].mod_env.md_env.matrix,
                                          ME.ECsectvw->model_elems[index].env.md_env.matrix);

                        if (ret_msg == MSSUCC)
                        {
                            /* set the objid of the located model element to
                             * NULL_OBJID so that if the object is located again, it
                             * won't be put in ME.ECsectvw->parents again
                             */

                            size = om$dimension_of(varray = ME.ECsectvw->parents);

                            if (size < ME.ECsectvw->num_parents + 1)
                            {
                                om$vla_set_dimension(varray = ME.ECsectvw->parents,
                                                     size = ME.ECsectvw->num_parents + 
                                                            PARENT_ARRAY_INCR);
                            }

                            ME.ECsectvw->parents[ME.ECsectvw->num_parents].grid = obj_info[ii].obj_id;
                            OM_BLOCK_MOVE(&obj_info[ii].mod_env,
                                          &ME.ECsectvw->parents[ME.ECsectvw->num_parents].env,
                                          sizeof(struct GRmd_env));
                            ME.ECsectvw->num_parents++;
                            ME.ECsectvw->model_elems[index].grid.objid = NULL_OBJID;
                            me->ret = MSSUCC;
                            break;
                        }
                    }
                }     /* for (index = 0; index < ME.ECsectvw->num_models; index++) */
            }  /* if (sectioned_solids) */
        }  /* if (me->ret != EMS_I_ElAlrdySel) */
      }  /* for each of the objects in the list */
    }
    else  /* GRgsget_simple_object failed; didn't locate any object */
    {
        if(num_objects == 0) me->ret = MSSUCC;
        me->ret = MSFAIL;
    }
  if(obj_info)
  {
    om$dealloc(ptr = obj_info);
    obj_info = NULL;
  }
}
/*\
Description
   This action finds the active crosshatching pattern, changes the symbol of
the crosshatch parameters subform button to correspond to the active pattern
and displays the subform button.

Notes
   This function depends upon the following instance variables:
      me->status_display_form_ptr
\*/

action update_xhatch_button()
{
    GRspacenum          module_osnum;
    struct GRIOvar_def  act_xh_pattern_type;
    IGRint              symbol_index;

    /* get the current pattern type and display the corresponding icon on
     * the "crosshatch subform" button
     */

    ex$get_cur_mod(osnum = &module_osnum);

    status = co$cvtvar(msg = &status,
  		       alias = "COXH_PATTERN_TYPE",
		       osnum = module_osnum,
		       var = (IGRchar *) &act_xh_pattern_type);
    if (status & 1)
    {
        switch (act_xh_pattern_type.contents.ivalue)
        {
            case GRXH_ANSI_IRON:
                symbol_index = 24;
                break;

            case GRXH_DIN_STEEL:
                symbol_index = 25;
                break;

            case GRXH_DIN_CAST_STEEL:
                symbol_index = 26;
                break;

            case GRXH_DIN_COPPER:
                symbol_index = 27;
                break;

            case GRXH_DIN_BRASS:
                symbol_index = 28;
                break;

            case GRXH_DIN_BRONZE:
                symbol_index = 29;
                break;

            case GRXH_DIN_ZINC_LEAD:
                symbol_index = 30;
                break;

            case GRXH_DIN_LIGHT_METAL:
                symbol_index = 31;
                break;

            case GRXH_DIN_SEAL_INSULAT:
                symbol_index = 32;
                break;

            case GRXH_DIN_HARD_RUBBER:
                symbol_index = 33;
                break;

            case GRXH_ANSI_PLASTIC:
                symbol_index = 34;
                break;

            case GRXH_ANSI_TITANIUM:
                symbol_index = 35;
                break;

            default:
                symbol_index = 24;  /* use ANSI_IRON symbol for default */
                break;
        }
    }
    else
        symbol_index = 24;  /* use ANSI_IRON symbol for default */

    FIg_set_symbol_index(ME.CEO->status_display_form_ptr, XHATCH_PARAMS_BUTTON,
                         symbol_index);
    FIg_activate(ME.CEO->status_display_form_ptr, XHATCH_PARAMS_BUTTON);
    FIg_display(ME.CEO->status_display_form_ptr, XHATCH_PARAMS_BUTTON);
}

/*\
Description
   This action formats the arguments of the select handler, then initializes
COB's select handler's function and argument pointers.

Notes
   This function depends upon the following instance variables:
      me->status_display_form_ptr
\*/

action setup_select_handler()
{
    extern IGRint  EFselect_end_segment();

    me->select = (char (*)()) EFselect_end_segment;
    me->select_args = (IGRchar *) &ME.ECsectvw->alternate_prompt;
    ME.ECsectvw->alternate_prompt = ME.ECsectvw->element_selection ? TRUE :
                                                                     FALSE;
}

/*\
Description
   This action sets COB's select handler function pointer to NULL so the
default select handler will now be used.

Notes
   This function depends upon the following instance variables:
\*/

action terminate_select_handler()
{
    me->select = NULL;
}

/*\
Description
   This action finds and copies the grid and module environment of the object
on the me->located_chansel channel selector into the specified instance data.

Notes
   This function depends upon the following instance variables:
me->located_chansel
\*/

action store_located_object(IGRint element)
{
    extern IGRint     GRgsget_simple_object();
    struct GRmd_env  *mod_env_ptr;
    struct GRobj_env  obj_info;
    struct GRid       my_GRid,
                      dv_attach_grid;
    IGRlong           msg;

    me->ret = MSSUCC;
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    status = GRgsget_simple_object(&msg, &my_GRid, &me->located_chansel,
                                   &obj_info);
    if (1 & status & msg)
    {
        if (element == 0)  /* store first drawing view containing models */
        {
            me->dv_id1 = obj_info.obj_id;
            mod_env_ptr = &ME.ECsectvw->dv_mod_env1;
            ME.ECsectvw->dvattach_index = INITIAL_DVATTACH_INDEX;
        }
        else if (element == 1)  /* store second drawing view */
        {
            me->dv_id2 = obj_info.obj_id;
            mod_env_ptr = &ME.ECsectvw->dv_mod_env2;

            /* for now, go ahead and put the drawing view's drawing view
             * attachment in the list of parents
             */

            status = om$send(msg = message GRdrawview.GRget_drawing_attachment_id(
                                                   &msg, &dv_attach_grid),
                             targetid = me->dv_id2.objid,
                             targetos = me->dv_id2.osnum);

            if (! (1 & status & msg))
            {
                me->ret = OM_E_ABORT;
                goto quit;
            }

            ME.ECsectvw->dvattach_index = INITIAL_DVATTACH_INDEX;
            ME.ECsectvw->parents[ME.ECsectvw->dvattach_index].grid =
                                                       dv_attach_grid;
            OM_BLOCK_MOVE(&ME.ECsectvw->dv_mod_env2,
                          &ME.ECsectvw->parents[ME.ECsectvw->dvattach_index].env,
                          sizeof(struct GRmd_env));
            ME.ECsectvw->num_parents = 2;
        }
        else if (element == 2)  /* store cutting plane line */
        {
            me->cut_pln_line_grid = obj_info.obj_id;
            mod_env_ptr = &ME.ECsectvw->line_mod_env;
        }
        else
        {
            me->ret = MSINARG;
            goto quit;
        }

        OM_BLOCK_MOVE(&obj_info.mod_env, mod_env_ptr, sizeof(struct GRmd_env));
    }
    else
        me->ret = MSFAIL;
}


/*\
Description
   This action highlights either the model objects or the parent objects
depending on the flags argument.  It will also use either regular or half-
highlight depending on how flags is set.

Notes
   This function depends upon the following instance variables:
\*/

action highlight_solids(IGRint flags)
{
    IGRmatrix      *matr[1];
    IGRlong         temp_msg;
    IGRint          index;

    if (flags & 0x1)
    {
        for (index = 0; index < ME.ECsectvw->num_models; index++)
        {
            matr[0] = (IGRmatrix *) ME.ECsectvw->model_elems[index].env.md_env.matrix;

            status = dp$display(msg = &temp_msg,
                                osnum = ME.ECsectvw->model_elems[index].grid.osnum,
                                mode = (flags & 0x2) ? GRhhd : GRhd,
                                oids = &ME.ECsectvw->model_elems[index].grid.objid,
                                num_elem = 1,
                                mtx_type = &ME.ECsectvw->model_elems[index].env.md_env.matrix_type,
                                matrix = matr);

            if (! (1 & status & temp_msg))
            {
                me->ret = OM_E_ABORT;
                goto quit;
            }
        }
    }
    else
    {
        /* display the parent solids that are to be sectioned; the first one
         * will follow the drawing view attachment element
         */

        for (index = ME.ECsectvw->dvattach_index + 1;
             index < ME.ECsectvw->num_parents; index++)
        {
            matr[0] = (IGRmatrix *) ME.ECsectvw->parents[index].env.md_env.matrix;

            status = dp$display(msg = &temp_msg,
                                osnum = ME.ECsectvw->parents[index].grid.osnum,
                                mode = (flags & 0x2) ? GRhhd : GRhd,
                                oids = &ME.ECsectvw->parents[index].grid,
                                num_elem = 1,
                                mtx_type = &ME.ECsectvw->parents[index].env.md_env.matrix_type,
                                matrix = matr);

            if (! (1 & status & temp_msg))
            {
                me->ret = OM_E_ABORT;
                goto quit;
            }
        }
    }
}


/*\
Description
   This action constructs a drawing view of class EMSdrawview to be used as
a parent of a section view.  The orientation of this drawing view will be
detemined by the selected cutting plane line.  Most of the other drawing view
parameters will determined by the first drawing view - from which the model
objects were selected.

Notes
   This function depends upon the following instance variables:
\*/

action construct_sv_drawview()
{
    extern IGRint GRconstruct_dv();

    struct GRid       my_GRid,
                      dv_attach_grid;
    IGRlong           msg;
    IGRint            rc,
                      props;
    unsigned short    properties;
    IGRchar           null_char;

    properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    gr$get_active_display(buffer = &ME.ECsectvw->display_attr);
    gr$get_active_layer(buffer = &ME.ECsectvw->active_layer);
    null_char = '\0';
    me->orientation = 0;
    me->origin[0] = me->line_base.event.button.x;
    me->origin[1] = me->line_base.event.button.y;
    me->origin[2] = me->line_base.event.button.z;

    rc = GRconstruct_dv(&msg, &ME.ECsectvw->module_env, properties,
                        &ME.ECsectvw->display_attr, ME.ECsectvw->active_layer,
                        null_char, null_char, &me->orientation, NULL,
                        "EMSdrawview", me->window_matrix,
                        &me->line_base.event.button.x,
                        me->text_scale, &me->dv_id2, NULL);
    if (! (1 & rc & msg))
    {
        me->ret = MSFAIL;
        goto quit;
    }

    /* add the constructed drawing view's drawing view attachment to the
     * parents list (array entry is reserved for it)
     */

    status = om$send(msg = message GRdrawview.GRget_drawing_attachment_id(
                                                   &msg, &dv_attach_grid),
                     targetid = me->dv_id2.objid,
                     targetos = me->dv_id2.osnum);

    if (! (1 & status & msg))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    ME.ECsectvw->parents[ME.ECsectvw->dvattach_index].grid = dv_attach_grid;
    OM_BLOCK_MOVE(&ME.ECsectvw->module_env,
                  &ME.ECsectvw->parents[ME.ECsectvw->dvattach_index].env,
                  sizeof (struct GRmd_env));
    OM_BLOCK_MOVE(&ME.ECsectvw->module_env, &ME.ECsectvw->dv_mod_env2,
                  sizeof (struct GRmd_env));

    /* put the constructed drawing view on the me->located_chansel since it
     * expected to be there by actions that will later be invoked
     */

    props = 0;
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    status = GRgsadd_object(&msg, &me->dv_id2, &ME.ECsectvw->module_env,
                            &props, &my_GRid, &me->located_chansel);

    if (! (1 & status & msg))
        me->ret = MSFAIL;
}


/*\
Description
   This action determines which state the command should go to next based on
the element selection toggle and whether the cutting plane line's end segments
are parallel.

Notes
   This function depends upon the following instance variables:
me->element_selection
me->segment_info
\*/

action selection_states()
{
    /* using #defines from EMSmsgdef.h to avoid having to create yet another
     * include file; the values returned only indicate what the next state
     * of the command should be, they are not an indication of this action's
     * success or failure (it can't fail)
     */

    if (ME.ECsectvw->element_selection)   /* individual element selection */
    {
        if (ME.ECsectvw->segment_info & SEGS_NOT_PARALLEL)
            me->ret = EMS_I_Success;
        else
            me->ret = EMS_W_Success;
    }
    else  /* selecting all elements in the drawing view */
        me->ret = EMS_S_Success;
}


/*\
Description
   This action displays a status message that indicate the current element
selection mode (all or selected elements) and also that there is a status
display form available.  There is a toggle on the status display form which
can be used to change the selection mode.

Notes
   This function depends upon the following instance variables:
me->element_selection
\*/

action display_status_message()
{
    IGRlong    status_key;
    IGRchar    status_string[128],
               tmp_string[64];

    if (ME.ECsectvw->element_selection)
        status_key = EMS_I_SelEl;
    else
        status_key = EMS_I_ElDrVw;

    ex$message(msgnumb = status_key,
               buff = status_string);

    ex$message(msgnumb = GR_I_StFmAvail,
               buff = tmp_string);

    GRstatus_display_button(1);

    strcat(status_string, tmp_string);

    ex$message(field = ERROR_FIELD,
               in_buff = status_string);
}


/*\
Description
   This action determines whether the position of the section view's
drawing view coordinate system triad is be specified by the user (manual)
or the default position it to be used (automatic).  A return value of
TRUE indicates positioning is to be manual, while a return value of
FALSE indicates automatic positioning.  There is a gadget on the status
display form that can be used to toggle this state.

Notes
   This function depends upon the following instance variables:
me->coord_sys_manual
\*/

action coord_sys_manual()
{
    if (ME.ECsectvw->coord_sys_manual)
        me->ret = TRUE;
    else
        me->ret = FALSE;
}


/*\
Description
   This action determines whether there is a drawing view description (the
description string is not null).  If there is a description, it is copied
into me->event1.event.keyin.

Notes
   This function depends upon the following instance variables:
me->desc
\*/

action get_description()
{
    int sel_flag,
        r_pos;

    FIfld_get_text(ME.CEO->status_display_form_ptr, DESCRIPTION_FIELD, 0, 0,
                   DESC_SCALE_LEN, (IGRuchar *) me->desc, &sel_flag,
                   &r_pos);

    if (strlen(me->desc) != 0)
    {
        strcpy(me->event1.event.keyin, me->desc);
        me->ret = TRUE;
    }
    else
        me->ret = FALSE;
}


/*\
Description
   This action determines whether the the drawing view scale should be
displayed or not.  

Notes
   This function depends upon the following instance variables:
me->scale_display_on
\*/

action display_scale()
{
    if (ME.ECsectvw->scale_display_on)
    {
        me->ret = TRUE;
    }
    else
        me->ret = FALSE;
}


/*\
Description
   This action determines whether the the drawing view label should be
placed or not.

Notes
   This function depends upon the following instance variables:
me->no_label
me->text_name.
\*/

action place_label()
{
    int sel_flag,
        r_pos;

    FIfld_get_text(ME.CEO->status_display_form_ptr, LABEL_FIELD, 0, 0,
                   MAXPATHLEN, (IGRuchar *) me->text_name, &sel_flag, &r_pos);

    if ((ME.ECsectvw->no_label) ||
        (! strlen(me->text_name)))
        me->ret = FALSE;
    else
        me->ret = TRUE;
}


/*\
Description
   This action determines whether a view name has been specified and if it
has, it copies the name into me->event1.event.keyin (where it is expected by
subsequent actions), TRUE is returned and the view name field is cleared.
Otherwise, FALSE is returned.


Notes
   This function depends upon the following instance variables:
me->name
\*/

action get_view_name()
{
    int sel_flag,
        r_pos;

    FIfld_get_text(ME.CEO->status_display_form_ptr, VIEW_NAME_FIELD, 0, 0,
                   DI_PATH_MAX, (IGRuchar *) me->name, &sel_flag, &r_pos);

    if (strlen(me->name))
    {
        strcpy(me->event1.event.keyin, me->name);
        me->ret = TRUE;
        me->name[0] = '\0';
        FIfld_set_text(ME.CEO->status_display_form_ptr,
                       VIEW_NAME_FIELD, 0, 0, me->name, FALSE);
    }
    else
        me->ret = FALSE;
}


/*\
Description
   This action clears out the scale field on the status display form if
is a default scale (the user has not specified a scale).

Notes
   This function depends upon the following instance variables:
me->scale_flags
\*/

action clear_default_scale()
{
    IGRuchar text_string[16];

    /* if the user did not specify the scale, clear out the scale field */

    if (! (ME.ECsectvw->scale_flags & USER_SCALE))
    {
        ex$message(msgnumb = GR_I_Clear,
                   buff = (IGRchar *) text_string);

        FIfld_set_text(ME.CEO->status_display_form_ptr, SCALE_FIELD, 0, 0,
                       text_string, FALSE);
    }
    me->dv_id1.objid = NULL_OBJID;  /* indicates we don't have a drawing view */
}


/*\
Description
   This action displays the scale of the located drawing view in the scale
field on the status display form if the user has not specified a scale.

Notes
   This function depends upon the following instance variables:
me->scale_flags
me->text_scale
\*/

action set_default_scale()
{
    if (! (ME.ECsectvw->scale_flags & USER_SCALE))
    {
        FIfld_set_text(ME.CEO->status_display_form_ptr, SCALE_FIELD, 0, 0,
                       (IGRuchar *) me->text_scale, FALSE);
    }
}


/*\
Description
   This action determines whether the user needs to be prompted to identify
models that should not be sectioned.  If the user needs prompting, TRUE is
returned, otherwise FALSE is returned.

Notes
   This function depends upon the following instance variables:
me->section_only
me->unsectioned_models
\*/

action request_unsectioned_models()
{
    if (! (ME.ECsectvw->section_only) &&
        (ME.ECsectvw->unsectioned_models))
        me->ret = TRUE;
    else
        me->ret = FALSE;
}


/*\
Description
   This action moves any parents that are between the cutting plane line and
the drawing view attachment (elements that are not to be sectioned) to the
end of the parent list (elements that are to be sectioned).

Notes
   This function depends upon the following instance variables:
me->dvattach_index
me->num_parents
me->parents
\*/

action move_unsectioned_to_sectioned()
{
    IGRint                  num_unsect_parents;
    struct EMSobject_info  *temp_buff;

    num_unsect_parents = ME.ECsectvw->dvattach_index - FIRST_UNSECT_MODEL_INDEX;

    if (num_unsect_parents)
    {
        /* unsectioned solids are inserted between the cutting plane line
         * segment and the drawing view attachment; save these solids to a
         * temporary buffer, then move the entries from the drawing
         * view attachment to the end of the array backwards to overwrite the
         * saved entries, then insert the saved entries at the end of the array
         */

        temp_buff = NULL;
        temp_buff = (struct EMSobject_info *) alloca(num_unsect_parents *
                                               sizeof(struct EMSobject_info));
        if (! temp_buff)
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }

        OM_BLOCK_MOVE(&ME.ECsectvw->parents[FIRST_UNSECT_MODEL_INDEX],temp_buff,
                      (num_unsect_parents * sizeof(struct EMSobject_info)));
        OM_BLOCK_MOVE(&ME.ECsectvw->parents[ME.ECsectvw->dvattach_index],
                      &ME.ECsectvw->parents[INITIAL_DVATTACH_INDEX],
                      sizeof(struct EMSobject_info) *
                      (ME.ECsectvw->num_parents - ME.ECsectvw->dvattach_index));
        OM_BLOCK_MOVE(temp_buff,
                      &ME.ECsectvw->parents[ME.ECsectvw->num_parents -
                              num_unsect_parents],
                      (num_unsect_parents * sizeof(struct EMSobject_info)));
        ME.ECsectvw->dvattach_index = INITIAL_DVATTACH_INDEX;
    }
}
