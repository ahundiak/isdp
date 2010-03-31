/******************************************************************************
*
* Description:
*
*    This method reports on surface geometry.
*
* Overrides:
*    GRreport at GRgraphics.
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
*
* Description:
*
*  This method reports on the geometry of surface.
*
* Completion codes return in msg argument:
*       - MSSUCC if successful
*       - MSINARG if list_size does not equal the number of report items
*       - MSFAIL (severe) if other error
*
* History:
*
*    msm    06/07/91      creation date.
*    NP     08/26/92      Modified for ANSI compliance.
*
******************************************************************************/


class implementation EMSsubbs;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "gocmacros.h"
#include "grmessage.h"
#include "go.h"
#include "revieweledef.h"
#include "MDreveledef.h"

method GRreport( IGRlong *msg; struct GRmd_env *md_env; IGRint *list_size;
                 struct GRreport_item *list;
                 struct GRreport_processor *processor )
{
  IGRint 	i, num_uv;
  IGRint	items_in_buff;      /* Number of items buffer will hold */
  IGRint 	status;
  IGRdouble uv[8];
  IGRpoint  points[4];
  struct    IGRbsp_surface  *surf;

  struct GRreport_item	buff[SURF_GEOM_SF_NUM_ITEMS];
  struct GRreport_item  *buff_ptr;

  struct GRobj_info obj_info;       /* Geometry info */

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
    				    /* See that list_size is valid */
  if (*list_size != SURF_GEOM_SF_NUM_ITEMS)
  {
    *list_size = SURF_GEOM_SF_NUM_ITEMS;
    *msg = MSINARG;
    goto wrapup;
  }

  if (list == NULL)                 /* Use default item buffer */
    buff_ptr = buff;

  else                              /* Used buffer passed in */
    buff_ptr = list;

  items_in_buff = *list_size;     /* Fill up entire buffer before sending */

  /*
   * Get the geometry of the surface.
   */

  GRgetabsg(msg, &md_env->md_env.matrix_type, md_env->md_env.matrix,
            (IGRchar **)&surf, i);
  if (!(*msg & 1))
    goto wrapup;

  /*
   * Get the Corner positions of the surface.
   */

  uv[0] = 0.0;  /* Top left */
  uv[1] = 0.0;
  uv[2] = 1.0;  /* Top right */
  uv[3] = 0.0;
  uv[4] = 0.0;  /* Bottom left */
  uv[5] = 1.0;
  uv[6] = 1.0;  /* Bottom right */
  uv[7] = 1.0;
  num_uv = 8;
  status = om$send(msg = message EMSsubbs.EMptatpr(msg,
                         &md_env->md_env.matrix_type,
                         md_env->md_env.matrix,
                         uv, num_uv, (IGRdouble *)points),
                   targetid = my_id);
  if (!(status & *msg & 1))
     goto wrapup;
   
    for (i=0; i < *list_size; i++)
    {
       buff_ptr[i].desc = 0;    /* Initialize message key in case it */
                                /*  isn't used                       */

       switch(i)
       {
	  case 0:
          {
        buff_ptr[i].label = SURF_GEOM_SF_U_ORDER;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_int;
	    buff_ptr[i].GRreport_data.ivalue = surf->u_order;
	    break;
          }
	  case 1:
          {
        buff_ptr[i].label = SURF_GEOM_SF_V_ORDER;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_int;
	    buff_ptr[i].GRreport_data.ivalue = surf->v_order;
	    break;
          }
	  case 2:
          {
        buff_ptr[i].label = SURF_GEOM_SF_NUM_U_POLES;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_int;
	    buff_ptr[i].GRreport_data.ivalue = surf->u_num_poles;
	    break;
          }
	  case 3:
          {
        buff_ptr[i].label = SURF_GEOM_SF_NUM_V_POLES;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_int;
	    buff_ptr[i].GRreport_data.ivalue = surf->v_num_poles;
	    break;
          }
	  case 4:
          {
        buff_ptr[i].label = SURF_GEOM_SF_RATIONALITY;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_string;
            if (surf->rational)
			 strcpy (buff_ptr[i].GRreport_data.string, "YES");
            else
			 strcpy (buff_ptr[i].GRreport_data.string, "NO");
	    break;
          }
	  case 5:
          {
        buff_ptr[i].label = SURF_GEOM_SF_PLANARITY;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_string;
            if (surf->planar)
              strcpy (buff_ptr[i].GRreport_data.string, "YES");
            else
              strcpy (buff_ptr[i].GRreport_data.string, "NO");
	    break;
          }
	  case 6:
          {
        buff_ptr[i].label = SURF_GEOM_SF_U_OPENCLOSED;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_string;
            if (surf->u_phy_closed)
              strcpy (buff_ptr[i].GRreport_data.string, "YES");
            else
              strcpy (buff_ptr[i].GRreport_data.string, "NO");
	    break;
          }
	  case 7:
          {
        buff_ptr[i].label = SURF_GEOM_SF_V_OPENCLOSED;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_string;
            if (surf->v_phy_closed)
              strcpy (buff_ptr[i].GRreport_data.string, "YES");
            else
              strcpy (buff_ptr[i].GRreport_data.string, "NO");
	    break;
          }
	  case 8:
          {
        buff_ptr[i].label = SURF_GEOM_SF_CS_NAME;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_coord_sys;
	    break;
          }
	  case 9:
          {
        buff_ptr[i].label = SURF_GEOM_SF_UNIT1;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 10:
          {
        buff_ptr[i].label = SURF_GEOM_SF_UNIT2;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 11:
          {
        buff_ptr[i].label = SURF_GEOM_SF_UNIT3;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 12:
          {
        buff_ptr[i].label = SURF_GEOM_SF_COOR1_LABEL;
        buff_ptr[i].format_mask  = GR_coord1;
	    break;
          }
	  case 13:
          {
        buff_ptr[i].label = SURF_GEOM_SF_COOR2_LABEL;
        buff_ptr[i].format_mask  = GR_coord2;
	    break;
          }
	  case 14:
          {
        buff_ptr[i].label = SURF_GEOM_SF_COOR3_LABEL;
        buff_ptr[i].format_mask  = GR_coord3;
	    break;
          }
	  case 15:
          {
        buff_ptr[i].label = SURF_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = points[2][0];
        buff_ptr[i].GRreport_data.point[1] = points[2][1];
        buff_ptr[i].GRreport_data.point[2] = points[2][2];
	    break;
          }
	  case 16:
          {
        buff_ptr[i].label = SURF_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 1;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = points[3][0];
        buff_ptr[i].GRreport_data.point[1] = points[3][1];
        buff_ptr[i].GRreport_data.point[2] = points[3][2];
	    break;
          }
	  case 17:
          {
        buff_ptr[i].label = SURF_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 2;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = points[0][0];
        buff_ptr[i].GRreport_data.point[1] = points[0][1];
        buff_ptr[i].GRreport_data.point[2] = points[0][2];
	    break;
          }
	  case 18:
          {
        buff_ptr[i].label = SURF_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 3;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = points[1][0];
        buff_ptr[i].GRreport_data.point[1] = points[1][1];
        buff_ptr[i].GRreport_data.point[2] = points[1][2];
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

end implementation EMSsubbs;
