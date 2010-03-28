/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRprism_locate

Description
   This filter performs a prism locate.

Arguments
   *msg                 IGRlong              Completion code
   *mod_env             struct GRmd_env      The module environment
   *window_id           struct GRid          Object id of the window
   *attributes          struct GRlc_locate   Locate attributes
   *classinfo           struct GRlc_classes  The locate class lists.
   prism_type           IGRint               Prism type
                                                -  GR_RIGHT_PRISM
                                                -  GR_CURVE_PRISM
   *prism               IGRchar              Pointer to prism
   prism_attr           IGRint               Flag describing the relation-
                                             ship of the graphics objects
                                             being searched for to the 
                                             prism.
                                                -  TRUE_REL
                                                -  GO_INSIDE
                                                -  GO_OUTSIDE
                                                -  GO_OVERLAP
                                                -  GO_INSIDE | GO_OVERLAP
                                                -  GO_OUTSIDE | GO_OVERLAP
   inside_outside       IGRint               If 1 search inside prism
                                             If 0 search outside prism
   *layers              IGRint               Layers
   (*action_handler)()  IGRchar              Action handler.
   *action_args         IGRchar              Action handler arguments.

Notes
   If the layers variable is NULL the layers from the window will be
   inquired.

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
     Gray Winn    11/02/86    Creation date.
     mrm          05/09/91    allow window to be NULL_OBJID
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grgsdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "lcmacros.h"

IGRint GRprism_locate (msg, mod_env, window_id, attributes, classinfo, 
                       prism_type, prism, prism_attr, inside_outside,
                       layers, action_handler, action_args)
IGRlong              *msg;
struct GRmd_env      *mod_env;
struct GRid          *window_id;
struct GRlc_locate   *attributes;
struct GRlc_classes  *classinfo;
IGRint               prism_type;
IGRchar              *prism;
IGRint               prism_attr;
IGRint               *layers;
IGRint               inside_outside;
IGRchar              (*action_handler)();
IGRchar              *action_args;
{
IGRlong                 om_msg;
IGRlong                 ret_msg;
IGRint                  size, ret_size;
IGRint                  ortho;
IGRpoint                low_point, high_point;
IGRdouble               tolerance;
IGRdouble               scale;
enum   GRlocate_types   locate_type;
struct GRlc_rp_loc      rp_loc;
struct GRlc_cp_loc      cp_loc;
struct EX_button        button;
struct var_list         var_list[3];
struct IGRrt_prism      temp_rt_prism;
struct IGRcv_prism      temp_cv_prism;

   *msg = MSSUCC;
   om_msg = MSSUCC;
   /*
    *  Generate the tolerance for the prism locate.
    */

   size = sizeof (IGRdouble);
   if (gr$get_dit_tolerance (msg = &ret_msg, sizbuf = &size, 
       buffer = &tolerance, nret = &ret_size))
   {
      if (window_id->objid == NULL_OBJID)
      {
         scale = 1.0;
         ortho = AXIS_WLD_ALIGN;
         om_msg = ret_msg = TRUE;
      }
      else
      {
         var_list[0].var = VVOL_VIEWPORT_SCALE;
         var_list[0].var_ptr = (IGRchar*)&scale;
         var_list[0].num_bytes = sizeof (IGRdouble);
         var_list[0].bytes_returned = (IGRlong *) &ret_size;

         var_list[1].var = GRAGAD_FLAGS;
         var_list[1].var_ptr = (IGRchar*)&ortho;
         var_list[1].num_bytes = sizeof (IGRint);
         var_list[1].bytes_returned = (IGRlong *) &ret_size;

         var_list[2].var = END_PARAM;
   
         om_msg = dp$inq_set_gragad(msg = &ret_msg,
                                    osnum = window_id->osnum,
				    gragad_objid = window_id->objid,
                                    which_error = &ret_size,
				    var_list = var_list);
      }
      if (om_msg & ret_msg & 1)
      {
         /*
          *  Generate an EX_button.  The GRlocate function requires
          *  an EX_button.
          */

         button.x = 0;  /* Zero out the data point. */
         button.y = 0;
         button.z = 0;
         button.window = 0;   /* Zero out the window number */
         button.objid = window_id->objid;
         button.osnum = window_id->osnum;
         button.numb = 0;
         button.clicks = 0;
         button.button_down = 0;
         
         if (prism_type == GR_RIGHT_PRISM)
         {
            locate_type = GR_rp_loc;
            rp_loc.obj_attr = *attributes;
            rp_loc.datapoint = button;
            rp_loc.tolerance = tolerance/scale;

            /*
             *  Define the right prism.
             */

            rp_loc.rt_prism = *((struct IGRrt_prism *)prism);
            rp_loc.prism_attr = prism_attr;

            /*
             *  Define the range of the right prism.
             */

            if (inside_outside)
            {
               /* 
                *  Generate the range for the elements within the
                *  right prism range.
                */

               MArpextents (&ret_msg, prism, low_point, high_point);

               /*
                *  Build update range.  llf and urb point of range.
                */
   
               rp_loc.upd_range[0] = low_point[0];
               rp_loc.upd_range[1] = low_point[1];
               rp_loc.upd_range[2] = low_point[2];
               rp_loc.upd_range[3] = high_point[0];
               rp_loc.upd_range[4] = high_point[1];
               rp_loc.upd_range[5] = high_point[2];

               if (ortho & AXIS_WLD_ALIGN)
               {
                  rp_loc.is_ortho = 1; /* Is an ortho view. */     
               }else
               {
                  rp_loc.is_ortho = 0; /* Non ortho view. */

                  /* 
                   *  Find the extents of the front face of the
                   *  right prism.  
                   */

                  temp_rt_prism = *((struct IGRrt_prism *)prism);
                  temp_rt_prism.height = 0;
                  MArpextents (&ret_msg, &temp_rt_prism, low_point, 
                               high_point);

                  /*
                   *  Build skew range.  llf and urb point of range.
                   */

                  rp_loc.skew_range[0] = low_point[0];
                  rp_loc.skew_range[1] = low_point[1];
                  rp_loc.skew_range[2] = low_point[2];
                  rp_loc.skew_range[3] = high_point[0];
                  rp_loc.skew_range[4] = high_point[1];
                  rp_loc.skew_range[5] = high_point[2];

                  /*
                   *  Build view vector.  Third row of matrix.
                   *  Note that the right prism matrix is the
                   *  transpose of the rotation matrix.
                   */

                  rp_loc.view_vector[0] = 
                     ((struct IGRrt_prism *)prism)->matrix[2];
                  rp_loc.view_vector[1] = 
                     ((struct IGRrt_prism *)prism)->matrix[6];
                  rp_loc.view_vector[2] = 
                     ((struct IGRrt_prism *)prism)->matrix[10];
               }
            }else
            {
               /* 
                *  Generate the range for the elements outside the
                *  right prism range.
                */

               rp_loc.is_ortho = 1;  /* Is an ortho view. */
   
               rp_loc.upd_range[0] = GRDGNLIMITS_MIN_D;
               rp_loc.upd_range[1] = GRDGNLIMITS_MIN_D;
               rp_loc.upd_range[2] = GRDGNLIMITS_MIN_D;
               rp_loc.upd_range[3] = GRDGNLIMITS_MAX_D;
               rp_loc.upd_range[4] = GRDGNLIMITS_MAX_D;
               rp_loc.upd_range[5] = GRDGNLIMITS_MAX_D;
            }
         }else
         {
            locate_type = GR_cv_loc;
            cp_loc.obj_attr = *attributes;
            cp_loc.datapoint = button;
            cp_loc.tolerance = tolerance/scale;

            /*
             *  Define the right prism.
             */

            cp_loc.cv_prism =  *((struct IGRcv_prism *)prism);
            cp_loc.prism_attr = prism_attr;

            /*
             *  Define the range of the right prism.
             */

            if (inside_outside)
            {
               /* 
                *  Generate the range for the elements within the
                *  right prism range.
                */

               MAcpextents (&ret_msg, prism, low_point, high_point);

               /*
                *  Build update range.  llf and urb point of range.
                */
   
               cp_loc.upd_range[0] = low_point[0];
               cp_loc.upd_range[1] = low_point[1];
               cp_loc.upd_range[2] = low_point[2];
               cp_loc.upd_range[3] = high_point[0];
               cp_loc.upd_range[4] = high_point[1];
               cp_loc.upd_range[5] = high_point[2];

               if (ortho & AXIS_WLD_ALIGN)
               {
                  cp_loc.is_ortho = 1; /* Is an ortho view. */     
               }else
               {
                  cp_loc.is_ortho = 0; /* Non ortho view. */

                  /* 
                   *  Find the extents of the front face of the
                   *  right prism.  
                   */

                  temp_cv_prism = *((struct IGRcv_prism *)prism);
                  temp_cv_prism.height = 0;

                  MAcpextents (&ret_msg, &temp_cv_prism, low_point, 
                               high_point);

                  /*
                   *  Build skew range.  llf and urb point of range.
                   */

                  cp_loc.skew_range[0] = low_point[0];
                  cp_loc.skew_range[1] = low_point[1];
                  cp_loc.skew_range[2] = low_point[2];
                  cp_loc.skew_range[3] = high_point[0];
                  cp_loc.skew_range[4] = high_point[1];
                  cp_loc.skew_range[5] = high_point[2];

                  /*
                   *  Build view vector.  Third row of matrix.
                   *  Note that the right prism matrix is the
                   *  transpose of the rotation matrix.
                   */

                  cp_loc.view_vector[0] = 
                     ((struct IGRcv_prism *)prism)->matrix[2];
                  cp_loc.view_vector[1] = 
                     ((struct IGRcv_prism *)prism)->matrix[6];
                  cp_loc.view_vector[2] = 
                     ((struct IGRcv_prism *)prism)->matrix[10];
               }
            }else
            {
               /* 
                *  Generate the range for the elements outside the
                *  right prism range.
                */

               cp_loc.is_ortho = 1;  /* Is an ortho view. */
   
               cp_loc.upd_range[0] = GRDGNLIMITS_MIN_D;
               cp_loc.upd_range[1] = GRDGNLIMITS_MIN_D;
               cp_loc.upd_range[2] = GRDGNLIMITS_MIN_D;
               cp_loc.upd_range[3] = GRDGNLIMITS_MAX_D;
               cp_loc.upd_range[4] = GRDGNLIMITS_MAX_D;
               cp_loc.upd_range[5] = GRDGNLIMITS_MAX_D;
            }
         }
         
         /*
          *  Call the GRlcquery funciton.
          */

         om_msg = lc$query (rc = &ret_msg, 
                  mod = mod_env, 
                  locate_type = &locate_type, 
                  loc_parms = 
                        (prism_type == GR_RIGHT_PRISM) ? (IGRchar *)&rp_loc 
                                                       : (IGRchar *)&cp_loc, 
                  act_handler = action_handler,
                  act_parms = action_args,
                  classptr = classinfo,
                  levels = layers);
      }
   }
   return (om_msg);
}
end implementation Root;
