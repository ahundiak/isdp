/******************************************************************************
*
* Description:
*
*    This method reports on surface of revolution geometry.
*
* Overrides:
*    GRreport at GRgraphics.
*
*
*     
* Abstract
*        This method may be used in the following ways:
*
*
* Method: GRreport
*
*  (O) IGRlong		 	   *msg		   Error Message
*  (I) struct GRnd_env             *md_env         Module Environment
*  (IO)IGRint                      *list_size      List size
*  (IO)struct GRreport_item        *list           Reported items buffer
*  (I) struct GRreport_processor   *processor      Report information

* Description:
*
*  This method reports on the geometry of surface of revolution objects.
*
* Completion codes return in msg argument:
*       - MSSUCC if successful
*       - MSINARG if list_size does not equal the number of report items
*       - MSFAIL (severe) if other error
*
* History:
*
*    msm	06/06/91    creation date.
*    NP         08/21/92    Modified for ANSI compliance.
*
******************************************************************************/


class implementation EMSrevol;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "gocmacros.h"
#include "grmessage.h"
#include "go.h"
#include "revieweledef.h"
#include "MDreveledef.h"
#include "emssfdef.h"
#include "EMSopt.h"    /* for EMS_OPT_CONNECTABLE */
#include "EMSommacros.h"   /* ems$get_memory   */

#define BUFFER_SIZE  400

method GRreport(IGRlong *msg; struct GRmd_env *md_env; IGRint *list_size;
                struct GRreport_item *list; 
                struct GRreport_processor *processor )
{
  IGRint 	i, buf_size=0;
  IGRint	items_in_buff;      /* Number of items buffer will hold */
  IGRint 	status;
  IGRint    last_pole;
  IGRdouble s, e, totlen;
  IGRpoint axis[2];        /* revolution axis */
  IGRdouble sweep_angle, start_angle;
  IGRdouble  static_doubles_buffer[BUFFER_SIZE], *doubles_buffer;

  unsigned short  type;

  IGRboolean	world = TRUE;	    /* Convert to world coordinates */
  IGRboolean    is_360, pos_ort;
  GRrange	range;		    /* Range of composite */
  struct GRid *edges=NULL;
  struct IGRbsp_curve   curve;
  OM_S_CHANSELECT    to_comps;
  struct IGRbsp_surface bsdef;
  
  struct GRreport_item	buff[SURFRV_GEOM_SF_NUM_ITEMS];
  struct GRreport_item  *buff_ptr;

  struct GRobj_info obj_info;       /* Geometry info */
  extern IGRboolean BSarclength();
  
  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  				    /* See that list_size is valid */
  if (*list_size != SURFRV_GEOM_SF_NUM_ITEMS)
  {
    *list_size = SURFRV_GEOM_SF_NUM_ITEMS;
    *msg = MSINARG;
    goto wrapup;
  }

  if (list == NULL)                 /* Use default item buffer */
    buff_ptr = buff;

  else                              /* Used buffer passed in */
    buff_ptr = list;

  items_in_buff = *list_size;       /* Fill up entire buffer before sending */

  
   status = om$send(msg = message EMSrevol.EMgetRevolvedFormat(msg,
                         TRUE, &md_env->md_env.matrix_type,
                         md_env->md_env.matrix, &curve, NULL, NULL,
                         NULL, NULL, NULL),
                         targetid = my_id);
   if (!(status & *msg & 1) )
       goto wrapup;

  /* Get the bs def of the surface for planarity and such.
  */
  status = om$send(msg = message EMSsubbs.EMgetbsdef(msg, &bsdef), 
                   targetid = my_id);

  if (!(status & *msg & 1))
     goto wrapup;

  ems$get_memory(rc = msg, element_size = sizeof(IGRdouble),
                 num_elements = curve.num_poles * (curve.rational ? 4:3) +
                                curve.num_knots,
                 buffer = (IGRchar *)static_doubles_buffer,
                 buffer_size = BUFFER_SIZE,
                 ptr = (IGRchar **)&doubles_buffer);

  curve.poles = doubles_buffer;
  curve.weights = curve.rational ?
                  doubles_buffer + curve.num_poles * 3 : NULL;
  curve.knots = doubles_buffer +
                curve.num_poles * (curve.rational ? 4 : 3);

  status = om$send(msg = message EMSrevol.EMgetRevolvedFormat(msg,
                         FALSE, &md_env->md_env.matrix_type,
                         md_env->md_env.matrix, &curve, (IGRdouble *)axis, 
                         &is_360, &start_angle, &sweep_angle, &pos_ort),
                         targetid = my_id);
  if (!(status & *msg & 1) )
      goto wrapup;

 /*
   * Get the total length of the curve and also set last_pole.
   */

  s = 0.0;
  e = 1.0;
  status = BSarclength(msg, &curve, &s, &e, &totlen);

  if (!(status & 1) )
      goto wrapup;
  if (*msg != 0)
      goto wrapup;
  last_pole = (curve.num_poles - 1) * 3;

    for (i=0; i < *list_size; i++)
    {
       buff_ptr[i].desc = 0;    /* Initialize message key in case it */
                                /*  isn't used                       */

       switch(i)
       {
	  case 0:
          {
        buff_ptr[i].label = SURFRV_GEOM_SF_ORDER;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_int;
	    buff_ptr[i].GRreport_data.ivalue = bsdef.u_order;
	    break;
          }
	  case 1:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_RATIONALITY;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_string;
            if (bsdef.rational)
			 strcpy (buff_ptr[i].GRreport_data.string, "YES");
            else
			 strcpy (buff_ptr[i].GRreport_data.string, "NO");
	    break;
          }
	  case 2:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_PERIODICITY;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_string;
            if (bsdef.u_periodic)
              strcpy (buff_ptr[i].GRreport_data.string, "YES");
            else
              strcpy (buff_ptr[i].GRreport_data.string, "NO");
	    break;
          }
	  case 3:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_PLANARITY;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_string;
            if (bsdef.planar)
              strcpy (buff_ptr[i].GRreport_data.string, "YES");
            else
              strcpy (buff_ptr[i].GRreport_data.string, "NO");
	    break;
          }
	  case 4:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_OPENCLOSED;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_string;
            if (curve.phy_closed)
              strcpy (buff_ptr[i].GRreport_data.string, "YES");
            else
              strcpy (buff_ptr[i].GRreport_data.string, "NO");
	    break;
          }
	  case 5:
          {
        buff_ptr[i].label = SURFRV_GEOM_SF_NUM_POLES;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_int;
	    buff_ptr[i].GRreport_data.ivalue = bsdef.u_num_poles;
	    break;
          }
	  case 6:
          {
        buff_ptr[i].label = SURFRV_GEOM_SF_LENGTH;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_double | GR_distance;
        buff_ptr[i].GRreport_data.dvalue = totlen;
	    break;
          }
	  case 7:
          {
        buff_ptr[i].label = SURFRV_GEOM_SF_CS_NAME;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_coord_sys;
	    break;
          }
	  case 8:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_UNIT1;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 9:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_UNIT2;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 10:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_UNIT3;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 11:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_COOR1_LABEL;
        buff_ptr[i].format_mask  = GR_coord1;
	    break;
          }
	  case 12:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_COOR2_LABEL;
        buff_ptr[i].format_mask  = GR_coord2;
	    break;
          }
	  case 13:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_COOR3_LABEL;
        buff_ptr[i].format_mask  = GR_coord3;
	    break;
          }
      case 14:
          {
        buff_ptr[i].label = SURFRV_GEOM_SF_START_ANGLE;
        buff_ptr[i].row   = 0;
        buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_double| GR_angle;
        buff_ptr[i].GRreport_data.dvalue = start_angle * PI/180.0;
        break;
          }
      case 15:
          {
        buff_ptr[i].label = SURFRV_GEOM_SF_SWEEP_ANGLE;
        buff_ptr[i].row   = 0;
        buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  =  GR_double | GR_angle;
        buff_ptr[i].GRreport_data.dvalue = sweep_angle * PI/180.0;;
        break;
          }
	  case 16:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = curve.poles[0];
        buff_ptr[i].GRreport_data.point[1] = curve.poles[1];
        buff_ptr[i].GRreport_data.point[2] = curve.poles[2];
	    break;
          }
	  case 17:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 1;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = curve.poles[last_pole];
        buff_ptr[i].GRreport_data.point[1] = curve.poles[last_pole + 1];
        buff_ptr[i].GRreport_data.point[2] = curve.poles[last_pole + 2];
	    break;
          }
	  case 18:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 2;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = axis[0][0];
        buff_ptr[i].GRreport_data.point[1] = axis[0][1];
        buff_ptr[i].GRreport_data.point[2] = axis[0][2];
	    break;
          }
	  case 19:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 3;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = axis[1][0];
        buff_ptr[i].GRreport_data.point[1] = axis[1][1];
        buff_ptr[i].GRreport_data.point[2] = axis[1][2];
	    break;
          }
       }

					/* See if buffer is full yet */
       if ((i+1) == items_in_buff)
       {  
	 processor->report_function(msg, 
				    processor->report_info,
				    processor->report_file,
				    &my_id,
				    items_in_buff,
				    buff_ptr);

       }
    }

wrapup:

  return(status);
}

end implementation EMSrevol;
