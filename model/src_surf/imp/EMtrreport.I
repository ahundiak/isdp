/******************************************************************************
*
* Description:
*
*    This method reports on solid torus geometry.
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
*  This method reports on the geometry of solid torus.
*
* Completion codes return in msg argument:
*       - MSSUCC if successful
*       - MSINARG if list_size does not equal the number of report items
*       - MSFAIL (severe) if other error
*
* History:
*
*    msm	05/21/91    creation date.
*
******************************************************************************/


class implementation EMStorus;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "gocmacros.h"
#include "grmessage.h"
#include "go.h"
#include "revieweledef.h"
#include "MDreveledef.h"
#include "EMSsfparms.h"

method GRreport(IGRlong *msg; struct GRmd_env *md_env; IGRint *list_size;
                struct GRreport_item *list; 
                struct GRreport_processor *processor )
{
  IGRint 	i;
  IGRint	items_in_buff;      /* Number of items buffer will hold */
  IGRint 	status;
  IGRpoint  normal;
  unsigned short  type;
  struct EMsurface_params   parms;

  struct GRreport_item	buff[CNTRS_GEOM_SF_NUM_ITEMS];
  struct GRreport_item  *buff_ptr;

  struct GRobj_info obj_info;       /* Geometry info */
  
  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  				    /* See that list_size is valid */
  if (*list_size != CNTRS_GEOM_SF_NUM_ITEMS)
  {
    *list_size = CNTRS_GEOM_SF_NUM_ITEMS;
    *msg = MSINARG;
    goto wrapup;
  }

  if (list == NULL)                 /* Use default item buffer */
    buff_ptr = buff;

  else                              /* Used buffer passed in */
    buff_ptr = list;

  items_in_buff = *list_size;       /* Fill up entire buffer before sending */

  /*
   * Get the base, normal, major and minor radius of the torus.
   */

  status = om$send(msg = message EMSsurface.EMget_params(msg, NULL,
                         md_env, &type, &parms),
                   targetid = my_id);

  if (!(status & *msg & 1))
     goto wrapup;

  normal[0] = parms.params.torus.center[0] +
              parms.params.torus.normal[0];
  normal[1] = parms.params.torus.center[1] +
              parms.params.torus.normal[1];
  normal[2] = parms.params.torus.center[2] +
              parms.params.torus.normal[2];  

    for (i=0; i < *list_size; i++)
    {
       buff_ptr[i].desc = 0;    /* Initialize message key in case it */
                                /*  isn't used                       */
       switch(i)
       {
      case 0:
          {
        buff_ptr[i].label = CNTRS_MAJOR_TOP_RADII;
        buff_ptr[i].row   = 0;
        buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_double | GR_distance;
        buff_ptr[i].GRreport_data.dvalue = parms.params.torus.major_radius;
        break;
          }
	  case 1:
          {
        buff_ptr[i].label = CNTRS_MINOR_BOTTOM_RADII;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_double | GR_distance;
        buff_ptr[i].GRreport_data.dvalue = parms.params.torus.minor_radius;
	    break;
          }
	  case 2:
          {
        buff_ptr[i].label = CNTRS_GEOM_SF_CS_NAME;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_coord_sys;
	    break;
          }
	  case 3:
          {
        buff_ptr[i].label = CNTRS_GEOM_SF_UNIT1;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 4:
          {
        buff_ptr[i].label = CNTRS_GEOM_SF_UNIT2;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 5:
          {
        buff_ptr[i].label = CNTRS_GEOM_SF_UNIT3;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 6:
          {
        buff_ptr[i].label = CNTRS_GEOM_SF_COOR1_LABEL;
        buff_ptr[i].format_mask  = GR_coord1;
	    break;
          }
	  case 7:
          {
        buff_ptr[i].label = CNTRS_GEOM_SF_COOR2_LABEL;
        buff_ptr[i].format_mask  = GR_coord2;
	    break;
          }
	  case 8:
          {
        buff_ptr[i].label = CNTRS_GEOM_SF_COOR3_LABEL;
        buff_ptr[i].format_mask  = GR_coord3;
	    break;
          }
	  case 9:
          {
        buff_ptr[i].label = CNTRS_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = parms.params.torus.center[0];
        buff_ptr[i].GRreport_data.point[1] = parms.params.torus.center[1];
        buff_ptr[i].GRreport_data.point[2] = parms.params.torus.center[2];
	    break;
          }

	  case 10:
          {
        buff_ptr[i].label = CNTRS_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 1;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = normal[0];
        buff_ptr[i].GRreport_data.point[1] = normal[1];
        buff_ptr[i].GRreport_data.point[2] = normal[2];
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
end implementation EMStorus;
