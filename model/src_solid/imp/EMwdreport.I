/******************************************************************************
*
* Description:
*
*    This method reports on solid wedge geometry.
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
*  This method reports on the geometry of solid wedge.
*
* Completion codes return in msg argument:
*       - MSSUCC if successful
*       - MSINARG if list_size does not equal the number of report items
*       - MSFAIL (severe) if other error
*
* History:
*
*    msm	06/05/91    creation date.
*
******************************************************************************/


class implementation EMSwedge;

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
  IGRpoint  origin, height, width, depth;
  IGRvector h, w, d;

  struct GRreport_item	buff[BLKWEDGE_GEOM_SF_NUM_ITEMS];
  struct GRreport_item  *buff_ptr;

/*  struct GRobj_info obj_info;       Geometry info */
  
  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  				    /* See that list_size is valid */
  if (*list_size != BLKWEDGE_GEOM_SF_NUM_ITEMS)
  {
    *list_size = BLKWEDGE_GEOM_SF_NUM_ITEMS;
    *msg = MSINARG;
    goto wrapup;
  }

  if (list == NULL)                 /* Use default item buffer */
    buff_ptr = buff;

  else                              /* Used buffer passed in */
    buff_ptr = list;

  items_in_buff = *list_size;       /* Fill up entire buffer before sending */

  /*
   * Get the origin, height, width and depth of solid wedge..
   */

  status = om$send(msg = message EMSwedge.EMextract_vtx_hwd(msg,
                         md_env, origin, h, w, d),
                   targetid = my_id);
  if (!(status & *msg & 1))
     goto wrapup;

  height[0] = origin[0] + h[0];
  height[1] = origin[1] + h[1];
  height[2] = origin[2] + h[2];

  width[0] = origin[0] + w[0];
  width[1] = origin[1] + w[1];
  width[2] = origin[2] + w[2];

  depth[0] = origin[0] + d[0];
  depth[1] = origin[1] + d[1];
  depth[2] = origin[2] + d[2];

    for (i=0; i < *list_size; i++)
    {
       buff_ptr[i].desc = 0;    /* Initialize message key in case it */
                                /*  isn't used                       */
       switch(i)
       {
      case 0:
          {
        buff_ptr[i].label = BLKWEDGE_GEOM_SF_CS_NAME;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_coord_sys;
	    break;
          }
	  case 1:
          {
        buff_ptr[i].label = BLKWEDGE_GEOM_SF_UNIT1;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 2:
          {
        buff_ptr[i].label = BLKWEDGE_GEOM_SF_UNIT2;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 3:
          {
        buff_ptr[i].label = BLKWEDGE_GEOM_SF_UNIT3;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 4:
          {
        buff_ptr[i].label = BLKWEDGE_GEOM_SF_COOR1_LABEL;
        buff_ptr[i].format_mask  = GR_coord1;
	    break;
          }
	  case 5:
          {
        buff_ptr[i].label = BLKWEDGE_GEOM_SF_COOR2_LABEL;
        buff_ptr[i].format_mask  = GR_coord2;
	    break;
          }
	  case 6:
          {
        buff_ptr[i].label = BLKWEDGE_GEOM_SF_COOR3_LABEL;
        buff_ptr[i].format_mask  = GR_coord3;
	    break;
          }
	  case 7:
          {
        buff_ptr[i].label = BLKWEDGE_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = origin[0];
        buff_ptr[i].GRreport_data.point[1] = origin[1];
        buff_ptr[i].GRreport_data.point[2] = origin[2];
	    break;
          }
	  case 8:
          {
        buff_ptr[i].label = BLKWEDGE_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 1;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = height[0];
        buff_ptr[i].GRreport_data.point[1] = height[1];
        buff_ptr[i].GRreport_data.point[2] = height[2];
	    break;
          }
      case 9:
          {
        buff_ptr[i].label = BLKWEDGE_GEOM_SF_KEYPTS;
        buff_ptr[i].row   = 2;
        buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = width[0];
        buff_ptr[i].GRreport_data.point[1] = width[1];
        buff_ptr[i].GRreport_data.point[2] = width[2];
        break;
          }
      case 10:
          {
        buff_ptr[i].label = BLKWEDGE_GEOM_SF_KEYPTS;
        buff_ptr[i].row   = 3;
        buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = depth[0];
        buff_ptr[i].GRreport_data.point[1] = depth[1];
        buff_ptr[i].GRreport_data.point[2] = depth[2];
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
end implementation EMSwedge;
