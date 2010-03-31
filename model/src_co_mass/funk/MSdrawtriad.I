/* ###################   APOGEE COMPILED   ################## */
class implementation super_cmd;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "igrdp.h"
#include "madef.h"
#include "dp.h"
#include "igrdef.h"
#include "godef.h"
#include "go.h"
#include "bserr.h"
#include "maoptsxfo.h"
#include "mainvmx.h"
#include "bscrossp.h"

from GRgraphics import GRdisplay,
                       GRconstruct;
from GRconnector import GRrigidconn;
from EMSmassprop import EMstore_geometry;

extern GRclassid  OPP_EMSmassprop_class_id;

/* 
 *
 * This file displays the Mass/Area Designator.
 *
 * History
 * 10/17/89 : gupta : rewritten for new mass-props
 * ??/??/87 : GK : Creation
 * 11/01/88 : pp : Added code to output the triad to database if desired
 * 06/16/93 : Sudha : Modified for BSprototype ansification
 */

void   MSdrawtriadn (msg, option, axes, sld, prop, moduleinf,
                     display_att, my_id, output_triad, construct_list,
                     massprop_id)

IGRlong	                *msg;
IGRlong	                option;
IGRdouble               *axes;
IGRdouble               sld;
IGRdouble               *prop;
struct GRmd_env	        *moduleinf;
struct IGRdisplay       *display_att;
OM_S_OBJID              my_id;
IGRboolean              output_triad;
struct GRvg_construct   *construct_list;
struct GRid             *massprop_id;

{
  struct IGRpointset	point_data;
  IGRshort              dim = 4;
  IGRlong               i;
  IGRlong               msg_loc;
  IGRlong               stat_OM;
  IGRlong               number_of_obj;
  IGRboolean            acc_prop, log_status;
  OM_S_OBJID            objid[9];
  OMuword               osnum;
  IGRdouble	            points[6], x_length, y_length, z_length, 
                        x_axis[3], y_axis[3], z_axis[3];
  IGRdouble             geom_points[9], trans_points[9];
  IGRmatrix             inverse_matrix;
  extern void           ECdisplayPointSetByBuffer0();
  enum	GRdpmode        DisplayMode;
struct GRmd_env	        moduleinfo;
struct IGRdisplay       display_attr;

#define AREA_PROPERTIES 0
#define IS ==

  moduleinfo = *moduleinf;
  display_attr = *display_att;

 point_data.num_points = 2;
 point_data.points     = points;

 DisplayMode = GRbd;
 acc_prop = FALSE;

 /* Display centroid as a heavy point */
   
 for (i=0; i<9; i++)
      objid[i] = NULL_OBJID;

 i = 1;
 osnum = construct_list->env_info->md_id.osnum;
 if (output_triad)
  {
   IGRlong num_points = 1;
   struct GRmd_env *env;

/*   osnum = construct_list->env_info->md_id.osnum;    Move it up - Ashok */

   retry:
   EFplace_line_string (NULL_OBJID, construct_list, num_points, &prop[2],
                        &objid[0], &msg_loc);

   /* if the surface is open for mass properties, the centroid can be any
      number. If the number is too large, this returns a MSFAIL, hence
      the fix below
   */

   if (! (1 & msg_loc))
    {
     msg_loc = MSSUCC;
     prop[2] = prop[3] = prop[4] = 0.0;
     goto retry;
    }


   env = construct_list->env_info;
   env->md_id.osnum = MAIDMX;
 
   /*
    * Display the point. The point has to be displayed seperately becuase
    * the control does not reach the actual display code below when the
    * surface is non-planar and area properties are being computed.
    */

   stat_OM = om$send(msg = message GRgraphics.GRdisplay (msg,
                           &env->md_env.matrix_type, env->md_env.matrix,
                           &DisplayMode, &env->md_id),
                     targetos = osnum, 
                     targetid = objid[0]);
   if (! (1 & stat_OM & *msg)) goto wrapup;
   env->md_id.osnum = osnum;
  }
 else
  {
   ECdisplayPointSetByBuffer0 (msg, display_attr, moduleinfo, my_id, i,
                               &prop[2], DisplayMode, IGRPS);
  }

 x_length = 1.0;

 if (option IS AREA_PROPERTIES)
  {
   x_axis[0] = prop[5]; x_axis[1] = prop[6]; x_axis[2] = prop[7];
   x_length = x_axis[0] * x_axis[0] + x_axis[1] * x_axis[1] +
              x_axis[2] * x_axis[2];
   if (x_length > 0.95)	/* yes we do yave valid x axis */
    {
	 y_axis[0] = prop[8]; y_axis[1] = prop[9]; y_axis[2] = prop[10];
	 log_status = BScrossp(msg, x_axis, y_axis, z_axis);
    }
  }
 else
  {
   for(i=0; i<3; i++)
    {
	 x_axis[i] = axes[i];
	 y_axis[i] = axes[3+i];
	 z_axis[i] = axes[6+i];
    }
  }

 if (x_length < 0.95)
  {
   if (massprop_id->objid == NULL_OBJID)
    {
     stat_OM = om$construct (classid = OPP_EMSmassprop_class_id,
                             osnum   = osnum,
                             p_objid = &massprop_id->objid,
                             msg     = message GRgraphics.GRconstruct(
                                       construct_list));
     if (! (1 & stat_OM)) goto wrapup;
    
     massprop_id->osnum = osnum;
    }

   i = 0;
   stat_OM = om$send (msg = message GRconnector.GRrigidconn (msg,
                            massprop_id, &i),
                      targetid = objid[i],
                      targetos = osnum);
   if (! (1 & stat_OM & *msg)) goto wrapup;

   return;
  }

 x_length = sld;

 if (option IS AREA_PROPERTIES)	/* solid prop */
  {
   y_length = sld * prop[15]/prop[14];
   z_length = 0.0;
  }
 else
  {
   y_length = sld * prop[6] / prop[5];
   z_length = sld * prop[7] / prop[5];
  }

 /* Normalize */

 if ((y_length > x_length) && (y_length > z_length))
  {
   x_length *= (sld / y_length);
   z_length *= (sld / y_length);
   y_length  = sld;
  }
 else if ((z_length > x_length) && (z_length > y_length))
  {
   x_length *= (sld / z_length);
   y_length *= (sld / z_length);
   z_length = sld;
  }

 /* X axis */

 points[0] = prop[2]; points[1] = prop[3]; points[2] = prop[4];
 geom_points[0] = points[3] = points[0] + x_length * x_axis[0];
 geom_points[1] = points[4] = points[1] + x_length * x_axis[1];
 geom_points[2] = points[5] = points[2] + x_length * x_axis[2];

 if (output_triad)
  {
   EFplace_line_string(NULL_OBJID, construct_list, point_data.num_points,
                       point_data.points, &objid[1], &msg_loc);
  }
 else
  {
   ECdisplayPointSetByBuffer0 (msg, display_attr, moduleinfo, my_id,
                               point_data.num_points, point_data.points,
                               DisplayMode, IGRPY);
  }

 /* Y axis */

 geom_points[3] = points[3] = points[0] + y_length * y_axis[0];
 geom_points[4] = points[4] = points[1] + y_length * y_axis[1];
 geom_points[5] = points[5] = points[2] + y_length * y_axis[2];

 if (output_triad)
  {
   EFplace_line_string (NULL_OBJID, construct_list, point_data.num_points,
                        point_data.points, &objid[2], &msg_loc);
  }
 else
  {
   ECdisplayPointSetByBuffer0 (msg, display_attr, moduleinfo, my_id,
                               point_data.num_points, point_data.points,
                               DisplayMode, IGRPY);
  }
	
 /*
  Now draw lines to differentiate between x, y and z axes
  Place 0.4*sld along x axis centered at 50% of y axis
 */

 points[3] = prop[2] + 0.5*y_length*y_axis[0]; /* y center */
 points[4] = prop[3] + 0.5*y_length*y_axis[1];
 points[5] = prop[4] + 0.5*y_length*y_axis[2];
	
 points[0] = points[3] - 0.2*y_length*x_axis[0];
 points[1] = points[4] - 0.2*y_length*x_axis[1];
 points[2] = points[5] - 0.2*y_length*x_axis[2];

 points[3] += 0.2*y_length*x_axis[0];
 points[4] += 0.2*y_length*x_axis[1];
 points[5] += 0.2*y_length*x_axis[2];
	
 if (output_triad)
  {
   EFplace_line_string(NULL_OBJID, construct_list, point_data.num_points,
                       point_data.points, &objid[3], &msg_loc);
  }
 else
  {
   ECdisplayPointSetByBuffer0 (msg, display_attr, moduleinfo, my_id,
                               point_data.num_points, point_data.points,
                               DisplayMode, IGRPY);
  }
	
 /* Z axis */

 if (option != AREA_PROPERTIES)
  {
   points[0] = prop[2]; points[1] = prop[3]; points[2] = prop[4];

   geom_points[6] = points[3] = points[0] + z_length * z_axis[0];
   geom_points[7] = points[4] = points[1] + z_length * z_axis[1];
   geom_points[8] = points[5] = points[2] + z_length * z_axis[2];

   if (output_triad)
    {
     EFplace_line_string (NULL_OBJID, construct_list,
                          point_data.num_points, point_data.points,
                          &objid[4], &msg_loc);
    }
   else
    {
     ECdisplayPointSetByBuffer0 (msg, display_attr, moduleinfo, my_id,
                                point_data.num_points, point_data.points,
                                DisplayMode, IGRPY);
    }

   /*
    Now draw lines to differentiate the z axes by placing a line
    0.4*sld long along x axis centered at 50% and 70% of z axis
   */

   if (option != AREA_PROPERTIES)
    {
     points[3] = prop[2] + 0.5*z_length*z_axis[0]; /* z center */
     points[4] = prop[3] + 0.5*z_length*z_axis[1];
     points[5] = prop[4] + 0.5*z_length*z_axis[2];
	
     points[0] = points[3] - 0.2*z_length*x_axis[0];
     points[1] = points[4] - 0.2*z_length*x_axis[1];
     points[2] = points[5] - 0.2*z_length*x_axis[2];

     points[3] += 0.2*z_length*x_axis[0];
     points[4] += 0.2*z_length*x_axis[1];
     points[5] += 0.2*z_length*x_axis[2];
	
     if (output_triad)
      {
       EFplace_line_string (NULL_OBJID, construct_list,
                            point_data.num_points, point_data.points,
                            &objid[5], &msg_loc);
      }
     else
      {
       ECdisplayPointSetByBuffer0(msg, display_attr, moduleinfo, my_id,
                                point_data.num_points, point_data.points,
                                DisplayMode, IGRPY);
       }
	
     points[3] = prop[2] + 0.7*z_length*z_axis[0]; /* z center */
     points[4] = prop[3] + 0.7*z_length*z_axis[1];
     points[5] = prop[4] + 0.7*z_length*z_axis[2];
	
     points[0] = points[3] - 0.2*z_length*x_axis[0];
     points[1] = points[4] - 0.2*z_length*x_axis[1];
     points[2] = points[5] - 0.2*z_length*x_axis[2];

     points[3] += 0.2*z_length*x_axis[0];
     points[4] += 0.2*z_length*x_axis[1];
     points[5] += 0.2*z_length*x_axis[2];
	
     if (output_triad)
      {
       EFplace_line_string (NULL_OBJID, construct_list,
                            point_data.num_points, point_data.points,
                            &objid[6], &msg_loc);
      }
     else
      {
       ECdisplayPointSetByBuffer0(msg, display_attr, moduleinfo, my_id,
                                point_data.num_points, point_data.points,
                                DisplayMode, IGRPY);
      }
    }
  }
 else
  {
   geom_points[6] = 0.0; geom_points[7] = 0.0;
   geom_points[8] = 0.0;
  }

 if ((option != AREA_PROPERTIES) && (prop[13] != -5.0) &&
     (prop[19] == 0.01234))
 {
  if (output_triad)
  {
   IGRlong num_points = 1;
   struct GRmd_env *env;

/*   osnum = construct_list->env_info->md_id.osnum;    Move it up - Ashok */

   EFplace_line_string (NULL_OBJID, construct_list, num_points, &prop[16],
                        &objid[7], &msg_loc);

   /* if the surface is open for mass properties, the centroid can be any
      number. If the number is too large, this returns a MSFAIL, hence
      the fix below
   */

   if (! (1 & msg_loc))
    {
     msg_loc = MSSUCC;
     prop[16] = prop[17] = prop[18] = 0.0;
     objid[7] = NULL_OBJID;
    }


   env = construct_list->env_info;
   env->md_id.osnum = MAIDMX;
 
   /*
    * Display the point. The point has to be displayed seperately becuase
    * the control does not reach the actual display code below when the
    * surface is non-planar and area properties are being computed.
    */

   stat_OM = om$send(msg = message GRgraphics.GRdisplay (msg,
                           &env->md_env.matrix_type, env->md_env.matrix,
                           &DisplayMode, &env->md_id),
                     targetos = osnum, 
                     targetid = objid[7]);
   if (! (1 & stat_OM & *msg)) goto wrapup;
   env->md_id.osnum = osnum;
  }
 else
  {
   ECdisplayPointSetByBuffer0 (msg, display_attr, moduleinfo, my_id, i,
                               &prop[16], DisplayMode, IGRPS);
  }
 }

 /*
  * If the option was to display only area properties and the surface was
  * non-planar then the control should never reach here.
  */
	
 if (massprop_id->objid != NULL_OBJID)
  {
   if (output_triad)
    {
     number_of_obj = ((option == AREA_PROPERTIES) ? 4 :  7);
     if ((option != AREA_PROPERTIES) && (prop[13] != -5.0) &&
       (prop[19] == 0.01234))
      number_of_obj = 8;
      

     for (i=0; i<number_of_obj; i++)
      {
       if (objid[i] == NULL_OBJID) continue;

       stat_OM = om$send (msg = message GRconnector.GRrigidconn (msg,
                                massprop_id, &i),
                          targetid = objid[i],
                          targetos = osnum);
       if (! (1 & stat_OM & *msg)) goto wrapup;
      }
    }
  }
 else
  {
   acc_prop = TRUE;
   number_of_obj = (option == AREA_PROPERTIES) ? 4 : 7;
   if ((option != AREA_PROPERTIES) && (prop[13] != -5.0) &&
      (prop[19] == 0.01234))
    number_of_obj = 8;

   stat_OM = om$construct (classid = OPP_EMSmassprop_class_id,
                           osnum   = osnum,
                           p_objid = &massprop_id->objid,
                           msg     = message GRgraphics.GRconstruct(
                                     construct_list));
   if (! (1 & stat_OM)) goto wrapup;
   
   massprop_id->osnum = osnum;

   for (i=0; i<number_of_obj; i++)
    {
     if (objid[i] == NULL_OBJID) continue;
     stat_OM = om$send (msg = message GRconnector.GRrigidconn (msg,
                              massprop_id, &i),
                        targetid = objid[i],
                        targetos = osnum);
     if (! (1 & stat_OM & *msg)) goto wrapup;
    }
  }

 if (output_triad)
  {
   struct GRmd_env *env;
   IGRint cnt;

   cnt = ((option == AREA_PROPERTIES) ? 4 :  7);

   env = construct_list->env_info;
   env->md_id.osnum = MAIDMX;

   /*
    * No need to display the centroid as the same would have been
    * displayed earlier
    */

   for (i=1; i<cnt; i++)
    {
     stat_OM = om$send(msg = message GRgraphics.GRdisplay(msg,
                             &env->md_env.matrix_type, env->md_env.matrix,
                             &DisplayMode, &env->md_id),
                       targetos = osnum,
                       targetid = objid[i]);
     if (! (1 & stat_OM & *msg)) goto wrapup;
    }
    env->md_id.osnum = osnum;
   }

 if (massprop_id->objid != NULL_OBJID)
  {
   if ((moduleinfo.md_env.matrix_type != MAIDMX) && (! acc_prop))
    {
     log_status = MAinvmx (msg, &dim, moduleinfo.md_env.matrix,
                       inverse_matrix);
     if (! (1 & log_status & *msg)) goto wrapup;

     i = 3;
     log_status = MAoptsxform(msg, &i, &moduleinfo.md_env.matrix_type,
                              inverse_matrix, geom_points, trans_points);
     if (! (1 & log_status & *msg)) goto wrapup;

     for (i=0; i<9; i++) geom_points[i] = trans_points[i];
    }

   stat_OM = om$send(msg = message EMSmassprop.EMstore_geometry(msg,
                           geom_points),
                     targetos = massprop_id->osnum,
                     targetid = massprop_id->objid);
   if (! (1 & stat_OM & *msg)) goto wrapup;
  }

 wrapup:
  return;
}

end implementation super_cmd;
