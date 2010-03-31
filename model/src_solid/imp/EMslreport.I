/******************************************************************************
*
* Description:
*
*    This method reports on solid geometry.
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
*  This method reports on the geometry of solid objects.
*
* Completion codes return in msg argument:
*       - MSSUCC if successful
*       - MSINARG if list_size does not equal the number of report items
*       - MSFAIL (severe) if other error
*
* History:
*
*    msm	06/03/91    creation date.
*
******************************************************************************/


class implementation EMSsolid;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "gocmacros.h"
#include "grmessage.h"
#include "go.h"
#include "revieweledef.h"
#include "MDreveledef.h"
#include "EMSbnddef.h"

method GRreport(IGRlong *msg; struct GRmd_env *md_env; IGRint *list_size;
                struct GRreport_item *list; 
                struct GRreport_processor *processor )
{
  IGRint 	i;
  IGRint	items_in_buff;      /* Number of items buffer will hold */
  IGRint 	status;

  IGRboolean	world = TRUE;	    /* Convert to world coordinates */

  GRrange	range;		    /* Range of composite */
  
  struct GRreport_item	buff[SOLID_GEOM_SF_NUM_ITEMS];
  struct GRreport_item  *buff_ptr;

/*  struct GRobj_info obj_info;        Geometry info */


  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  				    /* See that list_size is valid */
  if (*list_size != SOLID_GEOM_SF_NUM_ITEMS)
  {
    *list_size = SOLID_GEOM_SF_NUM_ITEMS;
    *msg = MSINARG;
    goto wrapup;
  }

  if (list == NULL)                 /* Use default item buffer */
    buff_ptr = buff;

  else                              /* Used buffer passed in */
    buff_ptr = list;

  items_in_buff = *list_size;       /* Fill up entire buffer before sending */

					/* Determine range of the solid */
   status = om$send(msg = message GRowner.GRgetrang
			 (msg,
			  &md_env->md_env.matrix_type,
                           md_env->md_env.matrix,
			  &world,
			  range),
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
	    status = om$send(msg = message GRowner.GRget_number_components(
				msg,
				&buff_ptr[i].GRreport_data.ivalue),
			     targetid = my_id);

	    if (!(status & *msg & 1))
              goto wrapup;

        buff_ptr[i].label = SOLID_GEOM_SF_NUM_SURFACES;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_int;
	    break;
          }
	  case 1:
          {
        buff_ptr[i].label = SOLID_GEOM_SF_CS_NAME;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_coord_sys;
	    break;
          }
	  case 2:
          {
        buff_ptr[i].label = SOLID_GEOM_SF_UNIT1;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 3:
          {
        buff_ptr[i].label = SOLID_GEOM_SF_UNIT2;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 4:
          {
        buff_ptr[i].label = SOLID_GEOM_SF_UNIT3;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 5:
          {
        buff_ptr[i].label = SOLID_GEOM_SF_COOR1_LABEL;
        buff_ptr[i].format_mask  = GR_coord1;
	    break;
          }
	  case 6:
          {
        buff_ptr[i].label = SOLID_GEOM_SF_COOR2_LABEL;
        buff_ptr[i].format_mask  = GR_coord2;
	    break;
          }
	  case 7:
          {
        buff_ptr[i].label = SOLID_GEOM_SF_COOR3_LABEL;
        buff_ptr[i].format_mask  = GR_coord3;
	    break;
          }
	  case 8:
          {
        buff_ptr[i].label = SOLID_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = range[0];
        buff_ptr[i].GRreport_data.point[1] = range[1];
        buff_ptr[i].GRreport_data.point[2] = range[2];
	    break;
          }
	  case 9:
          {
        buff_ptr[i].label = SOLID_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 1;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = range[3];
        buff_ptr[i].GRreport_data.point[1] = range[4];
        buff_ptr[i].GRreport_data.point[2] = range[5];
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
end implementation EMSsolid;
