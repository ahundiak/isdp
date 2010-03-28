/*\
Description
   This is the command class for the input tools which generates
   a select set and places it on the input queue.

   This class has transactions files for the following commands:
      ELEMENTS INSIDE FENCE
      ELEMENTS INSIDE AND OVERLAPPING FENCE
      ELEMENTS CLIPPED INSIDE FENCE
      ELEMENTS OUTSIDE FENCE
      ELEMENTS OUTSIDE AND OVERLAPPING FENCE
      ELEMENTS CLIPPED OUTSIDE FENCE
      ELEMENTS OVERLAPPING FENCE
      ELEMENTS IN MODULE
      ELEMENTS ON LAYER
      ELEMENTS OF SYMBOLOGY
      ELEMENTS IN VIEW
      SELECT SET
      SELECT SET BY ELEMENTS

Notes
   Each action within this file uses local instance data to store
   or retrieve information.  This is not a good programming practice.
   A better approach is to allow for the local instance data to be 
   passed into the action.  Thus, when COB allows for data to passed
   into an action these methods will be converted to take any local 
   instance data that is used or modified as arguments.
   
HISTORY
   Gray Winn    05/14/87       Creation date.
   SCW          05/20/92       Added extra checking/protection in the
                               put_select_set_on_queue action.
   SCW          07/10/92       ANsi conversion
\*/

class           COgrpevent
super_class     CEO_GSLOCATE
start_state     terminate
product_name    "$SOURCE"

specification

#include "msdef.h"
#include "igrmacros.h"
#include "exmacros.h"
#include "grdpbmacros.h"
#include "grerr.h"
#include "codef.h"
#include "DIdef.h"
#include "OMindex.h"
#include "ref.h"
#include "refdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "growner.h"
#include "grgsdef.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "comiscmac.h"

instance
{
    IGRint                     layers_defined;         /* TRUE or FALSE  */
    IGRint                     prism_attr;
    IGRint                     layers_mask[DP_NUM_OF_LEVELS/32 + 1];
    IGRint                     file_no;
    IGRint                     inside_outside;
    IGRint                     prism_type;
    IGRchar                    filename[OM_K_MAXOSNAME_LEN];
    GRobjid                    save_EX_active_module;
    GRspacenum                 save_EX_active_OS_num;
    struct GRid                gs_id;
    struct GRid                sv_id;
    struct GRid                window_id;
    struct GRid                fence_id;
    struct GRmd_env            locate_env;
    struct IGRrt_prism         right_prism;
    struct IGRcv_prism         curve_prism;
    struct GRrp_action_args    rp_action_args;
    struct GRsymb_action_args  symb_action_args;
    struct GRdelete_action     delete_action_args;
    variable IGRdouble         prism_poles[];
    variable IGRdouble         prism_weights[];
    variable IGRdouble         prism_knots[];
    variable IGRdouble         prism_boundaries[];
}

implementation

#include "coimport.h"
#include "grgsdef.h"
#include "grmessage.h"
#include "grgsmacros.h"
#include "OMmacros.h"
#include "exdef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"

#define  INSIDE         1
#define  OUTSIDE        0
#define LO_COLOR        0
#define HI_COLOR        512
#define LO_STYLE        0
#define HI_STYLE        8
#define LO_WEIGHT       0
#define HI_WEIGHT       32
#define WEIGHT_DEFINED  1
#define COLOR_DEFINED   2
#define STYLE_DEFINED   4

from GRgrset      import GSend_transition, GSstart_transition, GSinit, 
                         GSobject_add, GScriteria_pass;
from GRfcset      import GSput_prism;
from GRgsmgr      import GRget_prism_size, GRget_prism;
from DPlvldir     import convert_lev_string;
from GRconnector  import GRflexconn;
from GRgraphics   import GRdisplay;
from GRvg         import GRchgstyle;

extern GRobjid       EX_active_module;
extern GRspacenum    EX_active_OS_num;
extern IGRint        LClayer();

/*\
Description
   This action stores the window id from an event into the window id 
   structure.

Notes
   This action sets up the following local instance data:
      -  me->window_id
\*/

action store_window_id
{
    IGRint num_ids, total_num_ids;
    IGRlong msg;

    *sts = MSSUCC;
    
    switch (me->event1.response) {
        case EX_DATA:
            me->window_id.objid = me->event1.event.button.objid;
            me->window_id.osnum = me->event1.event.button.osnum;
        break;
        case EX_STRING:
            dp$get_gragad_id (msg = &msg,
                              name = me->event1.event.keyin,
                              array_size = 1,
                              total_num = &total_num_ids,
                              numberofids = &num_ids,
                              found_GRids = &me->window_id);
            if (total_num_ids == 0) {
                ex$message (msgnumb = GR_E_WinNotFnd);
                *sts = MSFAIL;
            }
            else if (total_num_ids > 1) {
                ex$message (msgnumb = GR_E_AmbNme);
                *sts = MSFAIL;
            }
        break;
        default:
        break;
    }
}

/*\
Description
   This action will construct a graphcis set.

Notes
   This action sets up the following local instance data:
      -  me->gs_id
\*/
action construct_graphics_set
{
   /*
    *  Construct a graphics set.  The flag = 2 signifies to construct
    *  a graphics set that is to be used as a select set.
    */

   me->gs_id.osnum = me->ModuleInfo.md_id.osnum;
   status = gr$gsinit (msg = sts, flag = 2, p_objid = &me->gs_id.objid,
            osnum = me->ModuleInfo.md_id.osnum,
            p_chanselect = &me->located_chansel);
}

/*\
Description
   This action will construct a fence set.  Only clip commands
   use the fence set.  Thus the fence set should have its properties
   initialized based on the command.

Notes
   This action depends upon the following local instance data:
      -  me->mytype

   This action sets up the following local instance data:
      -  me->gs_id
\*/
action construct_fence_set
{
IGRint            properties;
OM_S_CHANSELECT   chansel;

   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_owners";

   /*
    *  Construct a fence set.
    */

   me->gs_id.osnum = me->ModuleInfo.md_id.osnum;
   status = om$construct (osnum =  me->ModuleInfo.md_id.osnum,
            classname = "GRfcset", p_objid = &me->gs_id.objid);

   status = om$send (msg = message Root.connect (chansel, OM_K_MAXINT,
            my_id, OM_Gw_current_OS, me->located_chansel, OM_K_MAXINT),
            targetid = me->gs_id.objid,
            targetos = me->gs_id.osnum);

   if (me->mytype == FC_INSIDE_CLIP)
   {
      properties = GRIS_POST_PROCESSING_INSIDE | GRIS_BACKGROUND_DISPLAY;
   }else if (me->mytype == FC_OUTSIDE_CLIP)
   {
      properties = GRIS_POST_PROCESSING_OUTSIDE | GRIS_BACKGROUND_DISPLAY;
   }else
   {
      properties |= GRIS_BACKGROUND_DISPLAY;
   }   

   /*
    *  Initilaze the fence set.
    */

   status = om$send (
            msg = message GRgrset.GSinit ((IGRlong *)sts, &properties, NULL,
            NULL), targetid = me->gs_id.objid, targetos = me->gs_id.osnum);
}

/*\
Description
   This action will start a transition for the fence set or the 
   graphics set.

Notes
   This action depends upon the following local instance data:
      -  me->gs_id

   This action sets up the following local instance data:
      -  me->sv_id
\*/
action start_transition_for_graphics_set
{
IGRint   properties;

   /*
    *  Start a transition for the graphics set. 
    */
   
   properties = 0;
   status = om$send (
            msg = message GRgrset.GSstart_transition 
            ((IGRlong *)sts, &me->ModuleInfo, &properties, NULL, &me->sv_id),
            targetid = me->gs_id.objid,
            targetos = me->gs_id.osnum);
}

/*\
Description
   This action will build the locate criteria to be used by the group
   input tool.  The group input tools should inquire the locate
   criteria of the previous command.

Notes
   This action sets up the following local instance data:
      -  me->locate_rtree_thing
      -  me->locate_eligible_thing
      -  me->rtree_classids
      -  me->eligible_classids
      -  me->locate_env
      -  me->attributes,
\*/
action build_locate_criteria
{
OMuword        GRgraphics_classid;
IGRint         criteria_flag;
IGRint         i;

   /*
    *  Get the locate criteria.
    */

   status = gr$gsget_locate_criteria ( msg = sts,
            locate_env = &me->locate_env,
            criteria_flag = &criteria_flag,
            attributes = &me->attributes,
            rtree_classes = &me->locate_rtree_thing,
            eligible_classes = &me->locate_eligible_thing);

   if (!(criteria_flag & GSPUT_LOCATE_ENV))
   {
      me->locate_env = me->ModuleInfo;
   }

   if (!(criteria_flag & GSPUT_ATTRIBUTES))
   {
      strcpy (me->attributes.classes,"GRgraphics");
      me->attributes.properties = LC_LC_ONLY |
                                  LC_RW |
                                  LC_DP_ONLY |
                                  IGN_MOD_BIT |
                                  IGN_PLANAR_BIT;

      me->attributes.owner_action =  LC_RIGID_OWNER | 
                                     LC_FLEX_COMP;
   }

   if ( (!(criteria_flag & GSPUT_RTREE_CLASSES)) ||
        (!(criteria_flag & GSPUT_ELIGIBLE_CLASSES)))
   {   
      status = om$get_classid (classname = "GRgraphics",
               p_classid = &GRgraphics_classid);

      if (!(criteria_flag & GSPUT_RTREE_CLASSES))
      {
         me->locate_rtree_thing.w_count = 1;
         me->locate_rtree_thing.w_flags = OM_CLST_subclass;
      }

      if (!(criteria_flag & GSPUT_ELIGIBLE_CLASSES))
      {
         me->locate_eligible_thing.w_count = 1;
         me->locate_eligible_thing.w_flags = OM_CLST_subclass;
      }
   }

   /*
    * allocate space for and copy the rtree and eligible classids
    */
         
   if (me->locate_rtree_thing.w_count)
   {
      status = om$vla_set_dimension(varray = me->rtree_classids,
                                    size = me->locate_rtree_thing.w_count);

      if (criteria_flag & GSPUT_RTREE_CLASSES)
      {
         for (i = 0; i < (IGRint)me->locate_rtree_thing.w_count; ++i)
         {
            me->rtree_classids[i] = me->locate_rtree_thing.p_classes[i];
         }
      }
      else
      {
         me->rtree_classids[0] = GRgraphics_classid;
      }
   }

   if (me->locate_eligible_thing.w_count)
   {
      status = om$vla_set_dimension(varray = me->eligible_classids,
                                    size = me->locate_eligible_thing.w_count);

      if (criteria_flag & GSPUT_ELIGIBLE_CLASSES)
      {
         for (i = 0; i < (IGRint)me->locate_eligible_thing.w_count; ++i)
         {
            me->eligible_classids[i] = me->locate_eligible_thing.p_classes[i];
         }
      }
      else
      {
         me->eligible_classids[0] = GRgraphics_classid;
      }
   }

   me->locate_rtree_thing.p_classes = me->rtree_classids;
   me->locate_eligible_thing.p_classes = me->eligible_classids;
   me->locate_rtree = &me->locate_rtree_thing;
   me->locate_eligible = &me->locate_eligible_thing;
}

/*\
Description
   This action will convert the keyin into a layers mask.

Notes
   This action sets up the following local instance data:
      -  me->layers_defined
      -  me->layers_mask
\*/
action convert_keyin_to_layer_mask
{
IGRint   i;
IGRchar  string[4];
IGRshort ret_nlayers;
IGRshort layers;
GRobjid  mgr_id;

   me->layers_defined = TRUE;
   string[0] = tolower (me->event1.event.keyin[0]);
   string[1] = tolower (me->event1.event.keyin[1]);
   string[2] = tolower (me->event1.event.keyin[2]);
   string[3] = tolower (me->event1.event.keyin[3]);

   if (!strcmp ("all", me->event1.event.keyin))
   {
      for (i=0; i < DP_NUM_OF_LEVELS; i++)
      {
         me->layers_mask[i/32] |= (1<<(i % 32));
      }
   }else
   {
      status = GRget_global_mgr_id (sts, "DPLVLDIR", 
               me->ModuleInfo.md_id.osnum, &mgr_id);

      for (i=0; i < (DP_NUM_OF_LEVELS/32 + 1); i++)
      {
         me->layers_mask[i] = 0;
      }

      status = om$send (msg = message DPlvldir.convert_lev_string (
               (int *)sts, me->event1.event.keyin, &ret_nlayers, &layers,
               (IGRlong *)me->layers_mask),
               targetid = mgr_id,
               targetos = me->ModuleInfo.md_id.osnum);
   }
}

/*\
Description
   This action will perform a second pass criteria check on the
   select set.  This pass will accept elements on any level.

Notes
   This action depends upon the following local instance data:
      -  me->locate_rtree_thing
      -  me->locate_eligible_thing
      -  me->rtree_classids
      -  me->eligible_classids
      -  me->attributes
      -  me->gs_id
\*/
action second_pass_criteria_check
{
struct GRlc_classes     classinfo;

   me->locate_rtree_thing.p_classes = me->rtree_classids;
   me->locate_eligible_thing.p_classes = me->eligible_classids;
   classinfo.rtree_classes = &me->locate_rtree_thing;
   classinfo.eligible_classes = &me->locate_eligible_thing;

   status = om$send (
            msg = message GRgrset.GScriteria_pass ((IGRlong *)sts, 
                                                    &me->ModuleInfo,
            &me->attributes, &classinfo, NULL),
            targetid = me->gs_id.objid, targetos = me->gs_id.osnum);
}

/*\
Description
   This action will generate a prism using the selected view.

Notes
   This action depends upon the following local instance data:
      -  me->window_id
      -  me->gs_id
      -  me->sv_id


   This action sets up the following local instance data:
      -  me->prism_type
      -  me->right_prism
      -  me->prism_poles
      -  me->prism_attr
      -  me->rp_action_args
      -  me->layers_defined
\*/
action generate_right_prism_from_view
{
IGRshort                matrix_type;
IGRint                  two;
IGRdouble               vw_volume[6];
IGRdouble               temp_matrix[16];
IGRdouble               local_vw_volume[6];

   two = 2;
   me->layers_defined = FALSE;

   status = GRbuild_prism_helper (sts, &me->window_id, NULL, vw_volume, 
            NULL, NULL, NULL, me->right_prism.matrix, NULL,
            &me->right_prism.height);

   /*
    *  Build a matrix which will take the view volume from its current
    *  center of the view origin to the new origin the llf of the view
    *  cube.
    */

   MAidmx(sts, temp_matrix);
   temp_matrix[3] = -vw_volume[0];
   temp_matrix[7] = -vw_volume[1];
   temp_matrix[11] = -vw_volume[2];

   MAtypemx(sts, temp_matrix, &matrix_type);
   MAoptsxform (sts, &two, &matrix_type, temp_matrix, 
               vw_volume, local_vw_volume);
   
   /*
    *  Set the vla for 5 points.
    */

   status = om$vla_set_dimension(varray = me->prism_poles, size = 15);

   me->right_prism.polygon.num_points = 5;
   me->right_prism.polygon.points = (IGRdouble *)me->prism_poles;

   /*
    *  Build the polyline that repersents the clip polygon.
    *  The view volume is in view coordinates.  Thus one should
    *  be able to form a polygon using the two diagonal points.
    */

   me->prism_poles[0] = me->prism_poles[12] = local_vw_volume[0];
   me->prism_poles[1] = me->prism_poles[13] = local_vw_volume[1];
   me->prism_poles[2] = me->prism_poles[14] = 0;
   me->prism_poles[3] = local_vw_volume[0];
   me->prism_poles[4] = local_vw_volume[4];
   me->prism_poles[5] = 0;
   me->prism_poles[6] = local_vw_volume[3];
   me->prism_poles[7] = local_vw_volume[4];
   me->prism_poles[8] = 0;
   me->prism_poles[9] = local_vw_volume[3];
   me->prism_poles[10] = local_vw_volume[1];
   me->prism_poles[11] = 0;

   /*
    *  Set up arguments.
    */

   me->prism_attr = GO_INSIDE | GO_OVERLAP;
   me->inside_outside = INSIDE;
   me->rp_action_args.gs_id = me->gs_id;
   me->rp_action_args.sv_id = me->sv_id;
   me->rp_action_args.clip_flag = FALSE;
   me->rp_action_args.rp_relation = GO_INSIDE | GO_OVERLAP;
   me->prism_type = GR_RIGHT_PRISM;
}

/*\
Description
   This action will generate a right prism using the active fence.

Notes
   This action depends upon the following local instance data:
      -  me->mytype
      -  me->gs_id
      -  me->sv_id

   This action sets up the following local instance data:
      -  me->window_id
      -  me->prism_type
      -  me->right_prism
      -  me->curve_prism
      -  me->prism_poles
      -  me->prism_weights
      -  me->prism_knots
      -  me->prism_boundaries
      -  me->fence_id
      -  me->prism_attr
      -  me->rp_action_args
      -  me->layers_defined
\*/
action generate_right_prism_from_fence
{
IGRint                  add_fence;
IGRint                  env_properties;
IGRint                  poles;
IGRint                  weights;
IGRint                  knots;
IGRint                  boundaries;
IGRlong                *sts1;

   sts1 = (IGRlong *)sts;
   add_fence = FALSE;

   env_properties = 0;
   me->layers_defined = FALSE;
   me->rp_action_args.clip_flag = FALSE;
   me->rp_action_args.gs_id = me->gs_id;
   me->rp_action_args.sv_id = me->sv_id;

   /*
    *  Set up arguments based on type.
    */

   switch (me->mytype)
   {
      case FC_INSIDE:
      {
         add_fence = TRUE;
         me->prism_attr = GO_INSIDE;
         me->rp_action_args.rp_relation = GO_INSIDE;
         me->inside_outside = INSIDE;
      }
      break;

      case FC_INSIDE_OVERLAP:
      {
         add_fence = FALSE;
         me->prism_attr = GO_INSIDE | GO_OVERLAP;
         me->rp_action_args.rp_relation = GO_INSIDE | GO_OVERLAP;
         me->inside_outside = INSIDE;
      }
      break;

      case FC_INSIDE_CLIP:
      {
         add_fence = FALSE;
         me->rp_action_args.clip_flag = TRUE;
         me->prism_attr = TRUE_REL;
         me->rp_action_args.rp_relation = GO_INSIDE | GO_OVERLAP;
         me->inside_outside = INSIDE;
      }
      break;

      case FC_OUTSIDE:
      {
         add_fence = TRUE;
         me->prism_attr = GO_OUTSIDE;
         me->rp_action_args.rp_relation = GO_OUTSIDE;
         me->inside_outside = OUTSIDE;
      }
      break;

      case FC_OUTSIDE_OVERLAP:
      {
         add_fence = FALSE;
         me->prism_attr = GO_OUTSIDE | GO_OVERLAP;
         me->rp_action_args.rp_relation = GO_OUTSIDE | GO_OVERLAP;
         me->inside_outside = OUTSIDE;
      }
      break;

      case FC_OUTSIDE_CLIP:
      {
         add_fence = FALSE;
         me->rp_action_args.clip_flag = TRUE;
         me->prism_attr = TRUE_REL;
         me->rp_action_args.rp_relation = GO_OUTSIDE | GO_OVERLAP;
         me->inside_outside = OUTSIDE;
      }
      break;

      case FC_OVERLAP:
      {
         add_fence = FALSE;
         me->prism_attr = GO_OVERLAP;
         me->rp_action_args.rp_relation = GO_OVERLAP;
         me->inside_outside = INSIDE;
      }
      break;
   }

   /*
    *  Get the active fence.
    */
      
   status = gr$gsget_fence ( msg = sts1, fence_id = &me->fence_id);

   if (!(status & *sts1 & 1))
   {
      *sts1 = MSFAIL;
      return(OM_S_SUCCESS);
   }

   /* 
    *  Send a message to the fence object to get the size of the
    *  prism geometry.
    */

   status = om$send(msg = message GRgsmgr.GRget_prism_size (sts1, 
            &me->ModuleInfo, &me->prism_type, NULL, &poles, &weights,
            &knots, &boundaries),
            targetid = me->fence_id.objid,
            targetos = me->fence_id.osnum);

   if (status & *sts1 & 1)
   {
      status = om$vla_set_dimension(varray = me->prism_poles, 
               size = poles * 3);

      if (weights)
      {
         status = om$vla_set_dimension(varray = me->prism_weights, 
                  size = weights);
      }

      if (knots)
      {
         status = om$vla_set_dimension(varray = me->prism_knots,
                  size = knots);
      }

      if (boundaries)
      {
         status = om$vla_set_dimension(varray = me->prism_boundaries,
                  size = boundaries * 2);
      }

      /*
       *  Format prism.
       */

      if (me->prism_type == GR_RIGHT_PRISM)
      {
         me->right_prism.polygon.points = &me->prism_poles[0];
      }else
      {
         me->curve_prism.curve.poles = &me->prism_poles[0];

         if (weights)
         {
            me->curve_prism.curve.rational = 1;
            me->curve_prism.curve.weights = &me->prism_weights[0];
         }else
         {
            me->curve_prism.curve.rational = 0;
         }

         if (knots)
         {
            me->curve_prism.curve.num_knots = knots;
            me->curve_prism.curve.knots = &me->prism_knots[0];
         }else
         {
            me->curve_prism.curve.num_knots = 0;
         }

         if (boundaries)
         {         
            me->curve_prism.curve.num_boundaries = boundaries;
            me->curve_prism.curve.bdrys = &me->prism_boundaries[0];
         }else
         {
            me->curve_prism.curve.num_boundaries = 0;
         }
      }

      /* 
       *  Send a message to the fence object to get prism geometry.
       */

      status = om$send(
               msg = message GRgsmgr.GRget_prism (sts1, &me->ModuleInfo,
               1, (me->prism_type == GR_RIGHT_PRISM) ? (IGRchar *) &me->right_prism : 
               (IGRchar *) &me->curve_prism, &me->window_id),
               targetid = me->fence_id.objid, 
               targetos = me->fence_id.osnum);

      /*
       *  If the fence will not be added to the graphics set.
       *  then add it now.
       */

      if ((status & *sts1 & 1) && add_fence)
      {
         /*
          *  Add the fence to the graphics set.
          */

         status = om$send (
                  msg = message GRgrset.GSobject_add (sts1, &me->fence_id,
                  &me->ModuleInfo, &env_properties, NULL, NULL),
                  targetid = me->gs_id.objid,
                  targetos = me->gs_id.osnum);
      }
   }
}

/*\
Description
   This action will connect the fence object to the fence set.

Notes
   This action depends upon the following local instance data:
      -  me->gs_id
\*/
action connect_fence_to_fence_set
{
IGRlong  flag;
IGRlong  index;

   flag = 1;
   *sts = MSSUCC;
   index = OM_K_MAXINT;
   status = om$send(
            msg = message GRconnector.GRflexconn ((IGRlong *)sts, 
                                                  &flag, 
                                                  &me->gs_id,
                                                  &index, 
                                                  &index),
            targetid = me->fence_id.objid, 
            targetos = me->fence_id.osnum);
}

/*\
Description
   This action will store the prism in the fence set

Notes
   This action depends upon the following local instance data:
      -  me->gs_id
      -  me->prism_type
      -  me->right_prism
      -  me->curve_prism
      -  me->prism_poles
      -  me->prism_weights
      -  me->prism_knots
      -  me->prism_boundaries
\*/
action store_right_prism_in_fence_set
{
   if (me->prism_type == GR_RIGHT_PRISM)
   {
      me->right_prism.polygon.points = &me->prism_poles[0];
   }else
   {
      me->curve_prism.curve.poles = &me->prism_poles[0];

      if (me->curve_prism.curve.rational)
      {
         me->curve_prism.curve.weights = &me->prism_weights[0];
      }

      if (me->curve_prism.curve.num_knots)
      {
         me->curve_prism.curve.knots = &me->prism_knots[0];
      }

      if (me->curve_prism.curve.num_boundaries)
      {         
         me->curve_prism.curve.bdrys = &me->prism_boundaries[0];
      }
   }

   status = om$send(
            msg = message GRfcset.GSput_prism ((IGRlong *)sts, &me->prism_type,
            (me->prism_type == GR_RIGHT_PRISM) ? 
               (IGRchar *)&me->right_prism : (IGRchar *) &me->curve_prism ),
            targetid = me->gs_id.objid, targetos = me->gs_id.osnum);
}

/*\
Description
   This action will generate the select set (i.e. all the elements 
   passing the criteria) from the prism.

Notes
   This action depends upon the following local instance data:
      -  me->locate_rtree_thing
      -  me->locate_eligible_thing
      -  me->rtree_classids
      -  me->eligible_classids
      -  me->prism_type
      -  me->right_prism
      -  me->curve_prism
      -  me->prism_poles;
      -  me->prism_weights;
      -  me->prism_knots;
      -  me->prism_boundaries;
      -  me->locate_env
      -  me->window_id
      -  me->attributes
      -  me->prism_attr
      -  me->rp_action_args
      -  me->inside_outside
\*/
action generate_select_set_from_right_prism
{
struct GRlc_classes     classinfo;

extern IGRint   GRgs_rp_action();

   /*
    *  Format the class locate information.
    */

   me->locate_rtree_thing.p_classes = me->rtree_classids;
   me->locate_eligible_thing.p_classes = me->eligible_classids;
   classinfo.rtree_classes = &me->locate_rtree_thing;
   classinfo.eligible_classes = &me->locate_eligible_thing;

   /*
    *  Format prism.
    */

   if (me->prism_type == GR_RIGHT_PRISM)
   {
      me->right_prism.polygon.points = &me->prism_poles[0];
   }else
   {
      me->curve_prism.curve.poles = &me->prism_poles[0];

      if (me->curve_prism.curve.rational)
      {
         me->curve_prism.curve.weights = &me->prism_weights[0];
      }

      if (me->curve_prism.curve.num_knots)
      {
         me->curve_prism.curve.knots = &me->prism_knots[0];
      }

      if (me->curve_prism.curve.num_boundaries)
      {         
         me->curve_prism.curve.bdrys = &me->prism_boundaries[0];
      }
   }

   /*
    *  Call the prism locate function.
    */

   status = gr$gsprism_locate ( msg = sts,
            mod_env = &me->locate_env, 
            window_id = &me->window_id,
            attributes = &me->attributes, 
            classinfo = &classinfo,
            prism_type = me->prism_type, 
            prism = (me->prism_type == GR_RIGHT_PRISM) ? 
                 (IGRchar *) &me->right_prism : (IGRchar *) &me->curve_prism,
            prism_attr = me->prism_attr, 
            inside_outside = me->inside_outside,
            layers = (me->layers_defined) ? me->layers_mask : NULL,
            action_handler = GRgs_rp_action,
            action_args = &me->rp_action_args);
}

/*\
Description
   This action will generate the select set (i.e. all the elements 
   passing the criteria) from the prism.

Notes
   This action depends upon the following local instance data:
      -  me->gs_id
      -  me->sv_id
      -  me->locate_rtree_thing
      -  me->locate_eligible_thing
      -  me->rtree_classids
      -  me->eligible_classids
      -  me->layers_defined
      -  me->locate_env
      -  me->attributes
      -  me->layers_mask
\*/
action generate_select_set_from_all_elements
{
struct GRlc_classes  classinfo;
struct GRid          gs_array[2];
struct EX_button     button;

extern int GRgs_locate_action();

   button.objid = NULL_OBJID;
   button.osnum = me->locate_env.md_id.osnum;

   /*
    *  Set action handler arguments.
    */

   gs_array[0] = me->gs_id;
   gs_array[1] = me->sv_id;

   /*
    *  Format the class locate information.
    */

   me->locate_rtree_thing.p_classes = me->rtree_classids;
   me->locate_eligible_thing.p_classes = me->eligible_classids;
   classinfo.rtree_classes = &me->locate_rtree_thing;
   classinfo.eligible_classes = &me->locate_eligible_thing;

   /*
    *  Call the all elements locate function.
    */

   if (me->layers_defined)
   {
      status = GRgsquery_all(sts, &me->locate_env, &me->attributes,
               &classinfo, me->layers_mask, &button, GRgs_locate_action,
               gs_array);
   }else
   {
      status = GRgsquery_all(sts, &me->locate_env, &me->attributes,
               &classinfo, NULL, &button, GRgs_locate_action, gs_array);
   }
}

/*\
Description
   This action will generate the select set (i.e. all the elements 
   passing the criteria) using the symbology defined passing it
   to all elements.

Notes
   This action depends upon the following local instance data:
      -  me->gs_id
      -  me->sv_id
      -  me->locate_rtree_thing
      -  me->locate_eligible_thing
      -  me->rtree_classids
      -  me->eligible_classids
      -  me->layers_defined
      -  me->locate_env
      -  me->attributes
      -  me->layers_mask
      -  me->symb_action_args
\*/
action generate_select_set_using_symbology
{
struct GRlc_classes        classinfo;
struct EX_button           button;
extern int GRgs_symb_action();

   /*
    *  Set action handler arguments.
    */

   if (me->symb_action_args.flag & (STYLE_DEFINED | WEIGHT_DEFINED |
                                    COLOR_DEFINED))
   {
      me->symb_action_args.gs_id  = me->gs_id;
      me->symb_action_args.sv_id  = me->sv_id;
   
      button.objid = NULL_OBJID;
      button.osnum = me->locate_env.md_id.osnum;

      /*
       *  Format the class locate information.
       */

      me->locate_rtree_thing.p_classes = me->rtree_classids;
      me->locate_eligible_thing.p_classes = me->eligible_classids;
      classinfo.rtree_classes = &me->locate_rtree_thing;
      classinfo.eligible_classes = &me->locate_eligible_thing;

      /*
       *  Call the all elements locate function.
       */

      if (me->layers_defined)
      {
         status = GRgsquery_all(sts, &me->locate_env, &me->attributes,
                  &classinfo, me->layers_mask, &button, GRgs_symb_action,
                  &me->symb_action_args);
      }else
      {
         status = GRgsquery_all(sts, &me->locate_env, &me->attributes,
                  &classinfo, NULL, &button, GRgs_symb_action,
                  &me->symb_action_args);
      }
   }else
   {
      *sts = MSFAIL;
   }
}

/*\
Description
   This action will send the end transition message to the graphics
   set.

Notes
   This action depends upon the following local instance data:
      -  me->gs_id
\*/
action end_transition_for_graphics_set
{
   /*
    *  Send the GSend_transition message.
    */
      
   status = om$send (msg = message GRgrset.GSend_transition ((IGRlong *)sts, 
                                                             NULL),
            targetid = me->gs_id.objid, targetos = me->gs_id.osnum);
}

/*\
Description
   This action will define the active select set as the current
   graphics set.

Notes
   This action sets up the following local instance data:
      -  me->gs_id
\*/
action define_graphics_set_from_active_select_set
{
   /*
    *  Get the active select set.
    */
      
   status = gr$gsget_select_set (msg = sts, select_set_id = &me->gs_id);
}

/*\
Description
   This action define the graphics set as the active select set.

Notes
   This action depends upon the following local instance data:
      -  me->gs_id
\*/
action define_active_select_set_from_graphics_set
{
IGRint count;

   status = gr$gsinqcount (msg = sts, count = &count, 
            object_id = &me->gs_id);

   if (count)
   {            
      /* 
       *  Define the graphics set as the active select set.
       */
               
      status = gr$gsput_select_set (msg = sts, mod_env = &me->ModuleInfo,
               select_set_id = &me->gs_id);
   }else
   {
      *sts = MSFAIL;
   }
}


/*\
Description
   This action define the graphics set as the active select set.

Notes
   This action depends upon the following local instance data:
      -  me->gs_id
\*/
action define_active_select_set_from_graphics_set_with_fence
{
IGRint count, count1;
struct GRid temp_fence;
struct GRobj_env object_env;

   status = gr$gsinqcount (msg = sts, count = &count, 
            object_id = &me->gs_id);

   /*
    *  Only add if more than one element.  The one element will be the
    *  fence it self.
    */

   if (count > 1)
   {            
      /* 
       *  Define the graphics set as the active select set.
       */
               
      status = gr$gsput_select_set (msg = sts, mod_env = &me->ModuleInfo,
               select_set_id = &me->gs_id);
   }else
   {
      /*
       * Make sure the object in the select set is the fence object.
       */

      status = gr$gsget_fence (msg = sts,
			       fence_id = &temp_fence);

      status = gr$gsget_objects ( msg = sts,
                          array = &object_env,
                          size = sizeof (object_env),
                          count = &count1,
                          object_id = &me->gs_id);

      if (temp_fence.objid == object_env.obj_id.objid
		           &&
	  temp_fence.osnum == object_env.obj_id.osnum)
      {
          *sts = MSFAIL;
      }
      else 
      {
	  status = gr$gsput_select_set (msg = sts, mod_env = &me->ModuleInfo,
               select_set_id = &me->gs_id);
      }
   }
}

/*\
Description
   This action will put the select set onto the event queue.

Notes
   This action depends upon the following local instance data:
      -  me->gs_id
      -  me->window_id
\*/
action put_select_set_on_queue
{
IGRint                  response;
IGRlong                 size;
IGRlong                *sts1;
struct GRevent          event;

   sts1 = (IGRlong *)sts;

   /* Insurance to make sure we put a valid event on the queue.
    * A bogus event will make the DPdisbyoid code choke in a big way.
    * The get_last_point is for valid OS and future expansion. scw 20-MAY-92
    */
   if( me->window_id.objid == 0 ) 
   {
      struct EX_button button;

      gr$get_last_point( buffer = &button );
      
      me->window_id.objid = NULL_OBJID;
      me->window_id.osnum = button.osnum;
   }

   /*
    *  Format response data.
    */

   co$build_button( msg = sts1,
                    objid = me->window_id.objid,
                    osnum =  me->window_id.osnum,
                    button = &event.event.button);

   event.num_id = 1;
   event.located_object[0].located_obj = me->gs_id;
   event.located_object[0].module_info = me->ModuleInfo;

   size = sizeof( struct GRevent ) - ( 2 * sizeof ( IGRlong ) );

   /*
    * Put EX_OBJID event on front of software queue
    */

   response = EX_OBJID;
   ex$putque( msg = sts1,
              response = &response,
              byte     = &size,
              buffer   = (IGRchar *)&event.event.button );
}

/*\
Description
   This action will define the colors to be used when doing a symbology
   locate given a mulitple color keyin.

Notes
   This action sets up the following local instance data:
      -  me->symb_action_args
\*/
action define_color_from_keyin
{
extern IGRint   GRcolor_conversion();

   status = GRparse_multiple_entry_keyin (me->event1.event.keyin,
            me->symb_action_args.color, GRcolor_conversion, TRUE, 
            LO_COLOR, HI_COLOR, OM_Gw_current_OS);   
   if (status & 1)
   {
      *sts = MSSUCC;
      me->symb_action_args.flag |= COLOR_DEFINED;
   }else
   {
      *sts = MSFAIL;
   }
}

/*\
Description
   This action will define the weights to be used when doing a symbology
   locate given a mulitple weight keyin.

Notes
   This action sets up the following local instance data:
      -  me->symb_action_args
\*/
action define_weight_from_keyin
{
extern IGRint   GRnumber_conversion();

   status = GRparse_multiple_entry_keyin (me->event1.event.keyin,
            me->symb_action_args.weight, GRnumber_conversion, FALSE,
            LO_WEIGHT, HI_WEIGHT, OM_Gw_current_OS);

   if (status & 1)
   {
      *sts = MSSUCC;
      me->symb_action_args.flag |= WEIGHT_DEFINED;
   }else
   {
      *sts = MSFAIL;
   }
}

/*\
Description
   This action will define the styles to be used when doing a symbology
   locate given a mulitple style keyin.

Notes
   This action sets up the following local instance data:
      -  me->symb_action_args
\*/
action define_style_from_keyin
{
extern IGRint   GRnumber_conversion();

   status = GRparse_multiple_entry_keyin (me->event1.event.keyin,
            me->symb_action_args.style, GRnumber_conversion, FALSE,
            LO_STYLE, HI_STYLE, OM_Gw_current_OS);

   if (status & 1)
   {
      *sts = MSSUCC;
      me->symb_action_args.flag |= STYLE_DEFINED;
   }else
   {
      *sts = MSFAIL;
   }
}

/*\
Description
   This action will clear the layer flags used within this command.

Notes
   This action sets up the following local instance data:
      -  me->layers_defined
\*/
action clear_layers_flag
{
   me->layers_defined = FALSE;
}

/*\
Description
   This action will clear the color flag used within this command

Notes
   This action sets up the following local instance data:
      -  me->symb_action_args
\*/
action clear_color_flag
{
   me->symb_action_args.flag &= (0xffffffff ^ COLOR_DEFINED);
}

/*\
Description
   This action will clear the weight flag used within this command

Notes
   This action sets up the following local instance data:
      -  me->symb_action_args
\*/
action clear_weight_flag
{
   me->symb_action_args.flag &= (0xffffffff ^ WEIGHT_DEFINED);
}
/*\
Description
   This action will clear the style flag used within this command

Notes
   This action sets up the following local instance data:
      -  me->symb_action_args
\*/
action clear_style_flag
{
   me->symb_action_args.flag &= (0xffffffff ^ STYLE_DEFINED);
}

/*\
Description
   This action will push the accept event onto the event queue.
\*/
action put_accept_event_on_queue
{
IGRint                  response;
IGRlong                 size;
IGRlong                *sts1;

   sts1 = (IGRlong *)sts;
   /*
    * Put event one on front of software queue.
    */

   size = sizeof( struct GRevent ) - ( 2 * sizeof ( IGRlong ) );
   response = me->event1.response;
   ex$putque( msg = sts1,
              response = &response,
              byte     = &size,
              buffer   = (IGRchar *)&me->event1.event.button );
}

/*\
Description
   This action will erase the highlight plane.
\*/
action clear_highlight
{
   /*
    *  Erase the highlight plane
    */

   status = dp$erase_hilite (msg = sts,
            objid = me->ModuleInfo.md_id.objid,
            osnum = me->ModuleInfo.md_id.osnum);
}

/*\
Description
   This action will empty the graphics set
\*/
action empty_graphics_set
{
   /*
    *  Empty the graphics set
    */

   status = gr$gsempty (msg = sts, p_chanselect = &me->located_chansel);
}

/*\
Description
   This action will perform any post processing.
\*/
action perform_post_processing_on_graphics_set
{
   /*
    *  Perform post processing on the graphics set
    */

   status = gr$gspost_processing ( msg = sts,
            p_chanselect = &me->located_chansel);
}


action check_for_fence
{
   /*
    *  Get the active fence.
    */
      
   status = gr$gsget_fence ( msg = sts, fence_id = &me->fence_id);

   if (!(status & *sts & 1))
   {
      *sts = MSFAIL;
      return(OM_S_SUCCESS);
   }
}

action check_file_fence_name
{
IGRint   result;
IGRchar  fname[OM_K_MAXOSNAME_LEN];
IGRchar  tname[OM_K_MAXOSNAME_LEN];
extern IGRint   file_exists();

   strcpy (me->filename, me->event1.event.keyin);
   strcpy (tname, me->event1.event.keyin);
   module_build_path (tname);
   result = file_exists (tname, 0, 0, fname);
   if (!result)
   {
      /*
       *  File exists.
       */

      *sts = MSFAIL;
   }else
   {
      *sts = MSSUCC;
   }
}

action save_current_file_as_file_fence
{
IGRchar  filename[OM_K_MAXOSNAME_LEN];
IGRchar  path[DI_PATH_MAX];
IGRchar  *s1;

   *sts = MSSUCC;

   /*
    *  Save the current file as the name of file fence.
    */
   
   status = ex$filename(name = filename, len = OM_K_MAXOSNAME_LEN);
   status = ex$save_module (ftype = EX_visible, filename = filename,
            newfilename = me->filename);

   if (status & 1)
   {
      /*
       *  Retreive the new file as an invisible file.
       */

      s1 = strrchr(me->filename, '/');
      if (s1)
      {
         s1++;
      }else
      {
         s1 = me->filename;
      }
      DIstmocpy (path, "ref", s1, 0, me->ModuleInfo.md_id.osnum);

      status = ex$retrieve_module (ftype = EX_invisible, type = EX_ACTINV,
               filename = me->filename, flag = EX_read_write, msg = (int *)sts, 
               file_no = &me->file_no, fstat = EX_old_module, 
               mount_name = path);

      if (status & *sts & 1)
      {
         ex$get_invis_info_by_index (
            index = me->file_no, mod_osnum = &me->ModuleInfo.md_id.osnum,
            mod_id = &me->ModuleInfo.md_id.objid);
      
         /*
          *  Save the following global variables.
          */

         me->save_EX_active_module = EX_active_module;
         me->save_EX_active_OS_num = EX_active_OS_num;

         /* 
          *  Set the following global variables.
          */

         EX_active_module = me->ModuleInfo.md_id.objid;
         EX_active_OS_num = me->ModuleInfo.md_id.osnum;

         /*
          * Define the locate environment as the module environment.
          */

         me->locate_env = me->ModuleInfo;
      }
      else
      {
         *sts = MSFAIL;
      }
   }
   else
   {
      *sts = MSFAIL;
   }
}

action close_file_fence
{
   /*
    *  Restore the following global variables.
    */

   EX_active_module = me->ModuleInfo.md_id.objid = me->save_EX_active_module;
   EX_active_OS_num = me->ModuleInfo.md_id.osnum = me->save_EX_active_OS_num;

   /*
    *  Close and write the file.
    */

   ex$close_module (ftype = EX_invisible, index = me->file_no,
                    flag = (1 | EX_ACTINV));
}

action delete_graphics
{
   /*
    *  Delete the fence contents.
    */
   status = gr$gsdelete ( msg = sts, p_chanselect = &me->located_chansel);
}

action set_all_layers
{
IGRint   i;

   me->layers_defined = TRUE;
   for (i=0; i < DP_NUM_OF_LEVELS; i++)
   {
      me->layers_mask[i/32] |= (1<<(i % 32));
   }
}


action set_layers_off_in_fence_view
{
IGRint            i;
IGRlong           which_error;
struct var_list   var_list[2];

    *sts = MSSUCC;
    var_list[0].var            = LEVELS;
    var_list[0].var_ptr        = (IGRchar *)me->delete_action_args.layers;
    var_list[0].num_bytes      = sizeof(IGRint) * (DP_NUM_OF_LEVELS/32 +1);
    var_list[0].bytes_returned = &which_error;
  
    var_list[1].var            = END_PARAM;
    var_list[1].var_ptr        = NULL;
    var_list[1].num_bytes      = 0;
    var_list[1].bytes_returned = NULL;

    status = dp$inq_set_gragad(msg = sts, osnum = me->window_id.osnum,
            gragad_objid = me->window_id.objid, which_error = &which_error,
            var_list = var_list);

    /*
     * Set the layers on which were off in the view.
     */

    me->layers_defined = TRUE;
    for (i=0; i < DP_NUM_OF_LEVELS; i++)
    {
        me->layers_mask[i/32] |= (1<<(i % 32));
    }
    LClayer (me->delete_action_args.layers, me->save_EX_active_module, 
             me->save_EX_active_OS_num);
}

action parse_y_or_n
{
IGRint   flag;

   GRparseyn (sts, me->event1.event.keyin, &flag);

   if (*sts & 1)
   {
      if (flag)
      {
         *sts = MSSUCC;
      }else
      {
         *sts = MSFAIL;  
      }
   }else
   {
      *sts = GR_E_INV_REQUEST;
   }   
}

/*\
Description
   This action defines an element as the active fence.
\*/
action define_fence
{
IGRlong          *sts1;
IGRuchar          style;
struct GRid       my_GRid;
struct GRid       window_id;
struct GRobj_env  obj_info;

   sts1 = (IGRlong *)sts;

   my_GRid.osnum = OM_Gw_current_OS;
   my_GRid.objid = my_id;
   window_id.osnum = me->event1.event.button.osnum;
   window_id.objid = me->event1.event.button.objid;

   status = gr$gscopy (msg = sts1, p_chanselect = &me->located_chansel);
            
   status = GRgsget_simple_object (sts1, &my_GRid, &me->located_chansel, 
            &obj_info);
   
   /* Let the fence have a different style */

   style = 4;
   status = om$send(msg = message GRvg.GRchgstyle(sts1, &style),
                    targetid = obj_info.obj_id.objid,
                    targetos = obj_info.obj_id.osnum);

   status = gr$gsput_fence (msg = sts1, mod_env = &me->ModuleInfo,
           fence_id = &obj_info.obj_id, window_id = &window_id);
}

action set_locate_criteria_on
{
    LC_criteria_on();
}

action set_locate_criteria_off
{
    LC_criteria_off();
}

/*\
Description
    This action will create a select set that will be used to delete
    elements that do not pass the proper locate criteria after a
    file fence has been done.  The criteria that will be checked is:

        - element display off
        - element locate off
        - global layers off
        - window layers off
        - global element types off

Notes
   This action depends upon the following local instance data:
      -  me->gs_id
      -  me->sv_id
      -  me->locate_rtree_thing
      -  me->locate_eligible_thing
      -  me->rtree_classids
      -  me->eligible_classids
      -  me->layers_defined
      -  me->locate_env
      -  me->attributes
      -  me->layers_mask
      -  me->delete_action_args
\*/

action generate_select_set_for_delete
{
int                        (*func_ptr)();
struct GRlc_classes        classinfo;
struct EX_button           button;
extern int GRgs_delete_action(), GRgs_delete_orphan_cells_action();
extern OMuword OPP_GRclhdr_class_id;

   /*
    *  Set action handler arguments.
    */

    me->delete_action_args.gs_id  = me->gs_id;
    me->delete_action_args.sv_id  = me->sv_id;

    button.objid = NULL_OBJID;
    button.osnum = me->locate_env.md_id.osnum;

      /*
       *  Format the class locate information.
       */

    me->locate_rtree_thing.p_classes = me->rtree_classids;
    me->locate_eligible_thing.p_classes = me->eligible_classids;
    classinfo.rtree_classes = &me->locate_rtree_thing;
    classinfo.eligible_classes = &me->locate_eligible_thing;

    /* If the eligible class is cell, call the action handler that will
     * add orphan cells to the saveset to be deleted if the cell
     * doesn't match the search criteria.  WBC - 05/22/92
     */

    if ((classinfo.eligible_classes->w_count == 1) &&
        (classinfo.eligible_classes->w_flags == OM_CLST_subclass) &&
        (classinfo.eligible_classes->p_classes[0] == OPP_GRclhdr_class_id))
        func_ptr = GRgs_delete_orphan_cells_action;
    else
        func_ptr = GRgs_delete_action;

      /*
       *  Call the all elements locate function.
       */

    status = GRgsquery_all((IGRlong *)sts, &me->locate_env, &me->attributes,
               &classinfo, me->layers_mask, &button, func_ptr,
               &me->delete_action_args);
}
