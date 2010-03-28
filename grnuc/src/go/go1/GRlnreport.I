/******************************************************************************
*
* Description:
*
*    This method reports on linear geometry.
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
*  This method reports on the geometry of linestring objects.
*
* Notes:
*  This method utilizes a stack buffer of 100 report items.  If the list_size
*  is greater than 100 elements the buffer is reused until all the items
*  have been processed.  Ex. - 100 item
*  buffer is allocated, but there are 306 items to be processed.  The buffer
*  is used a total of 4 times.
*         Pass		Items
*	  ----		-----
*	   1		0-99
*	   2		100-199
*	   3		200-299
*	   4		300-305
*  
*   At the end of each pass the contents of the buffer are dumped to the
*   report processor.  
*
* Completion codes return in msg argument:
*       - MSSUCC if successful
*       - MSINARG if list_size does not equal the number of report items
*       - MSFAIL (severe) if other error
*
* History:
*
*    mark ferguson	04/20/90    creation date.
*
******************************************************************************/


class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "grmessage.h"
#include "go.h"
#include "revieweledef.h"
/*#include "report.h"*/


method GRreport( IGRlong *msg; struct GRmd_env *md_env;
                 IGRint *list_size; struct GRreport_item *list; 
                 struct GRreport_processor *processor )
{
  IGRint 	i;
  IGRint	item_num = 0;	    /* Current item to report on */
  IGRint	items_in_buff;      /* Number of items buffer will hold */
  IGRint 	status;
  IGRint	action;	   
  IGRint	row = 0;	    /* Row of MCF to place report item */

  struct GRreport_item	buff[100];
  struct GRreport_item  *buff_ptr;

  struct IGRpolyline polyline;	    /* Polyline geometry to report on */
  struct GRobj_info obj_info;       /* Geometry info */

  IGRdouble 	points[300];	   


  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  
  polyline.num_points = 100; 	    /* Set up polyline structure */
  polyline.points = points;

  action = 2;			    /* Send default buffer in */
  status = om$send (msg =  message GRlinear.GRgetpolyline
			  (msg,
			   &md_env->md_env.matrix_type,
			   md_env->md_env.matrix,
			   &action,
			   &polyline),
		   targetid = my_id);

                                    /* See that list_size has valid */
  if (*list_size != (GRLINEAR_FORM_FIXED_SIZE + polyline.num_points))
  {
    *list_size = GRLINEAR_FORM_FIXED_SIZE + polyline.num_points;
    *msg = MSINARG;
    goto wrapup;
  }

  if (list == NULL)                 /* Use default item buffer */
  {
    buff_ptr = buff;
    items_in_buff = 100;
  }
  else                              /* Used buffer passed in */
  {
    buff_ptr = list;
    items_in_buff = *list_size;     /* Fill up entire buffer before sending */
  }

				    /* See what status of the above      */
				    /*  GRgetpolyline was and take       */
  if (!(status & *msg & 1))	    /*  appropriate action if it errored */
  {
    if (*msg == MSINARG)
    {
      /* 
       * Default buffer was not large enough.  Malloc the necessary buffer.
       */
      polyline.points = (IGRdouble *)om$malloc(size=(sizeof(IGRdouble) * 3 *
					 polyline.num_points));

      action = 1;
   
      status = om$send (msg =  message GRlinear.GRgetpolyline
                          (msg,
                           &md_env->md_env.matrix_type,
                           md_env->md_env.matrix,
                           &action,
                           &polyline),
                   targetid = my_id);

      if (!(status & *msg & 1))	
        goto wrapup;
    }
    else 
      goto wrapup;
  }

  status = om$send (msg =  message GRgraphics.GRgetobjinfo
                          (msg,
                           &obj_info),
                   targetid = my_id);

  if (!(status & *msg & 1))
    goto wrapup;


    for (i=0; i < *list_size; i++)
    {
       buff_ptr[i].desc = 0;    /* Initialize message key in case it */
                                /*  isn't used                       */

       switch(item_num)
       {
	  case 0:
          {
/*            buff_ptr[i].desc  = GR_I_GRNumVert;*/
            buff_ptr[i].label = LINEAR_GEOM_SF_NUM_VERTICES;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_int;
	    buff_ptr[i].GRreport_data.ivalue = polyline.num_points;
	    break;
          }
	  case 1:
          {
/*            buff_ptr[i].desc  = GRC_I_coordsys;*/
	    buff_ptr[i].label = LINEAR_GEOM_SF_CS_NAME;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_coord_sys;
	    break;
          }
	  case 2:
          {
            buff_ptr[i].label = LINEAR_GEOM_SF_UNIT1;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 3:
          {				
            buff_ptr[i].label = LINEAR_GEOM_SF_UNIT2;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 4:
          {
            buff_ptr[i].label = LINEAR_GEOM_SF_UNIT3;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 5:
          {
            buff_ptr[i].label = LINEAR_GEOM_SF_COOR1_LABEL;
            buff_ptr[i].format_mask  = GR_coord1;
	    break;
          }
	  case 6:
          {
            buff_ptr[i].label = LINEAR_GEOM_SF_COOR2_LABEL;
            buff_ptr[i].format_mask  = GR_coord2;
	    break;
          }
	  case 7:
          {
            buff_ptr[i].label = LINEAR_GEOM_SF_COOR3_LABEL;
            buff_ptr[i].format_mask  = GR_coord3;
	    break;
          }
	  default:			/* Build point report items */
          {
            buff_ptr[i].label = LINEAR_GEOM_SF_COORDINATES;
	    buff_ptr[i].row   = row;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_vertex | GR_local;
            buff_ptr[i].GRreport_data.point[0] = polyline.points[row*3];
            buff_ptr[i].GRreport_data.point[1] = polyline.points[row*3+1];
            buff_ptr[i].GRreport_data.point[2] = polyline.points[row*3+2];
	    row++;			/* Update row for next report item */
	    break;
          }
       }

					/* See if buffer is full yet */
					/* or all items processed */
       if (((i+1) == items_in_buff) || ((item_num + 1) >= *list_size))
       {
         if ((i+1) == items_in_buff)
	 {  
	   processor->report_function(msg, 
				      processor->report_info,
				      processor->report_file,
				      &my_id,
				      items_in_buff,
				      buff_ptr);

         }
	 else if ((item_num + 1) == *list_size) /* Last item processed */
	 {
	   processor->report_function(msg, 
				      processor->report_info,
				      processor->report_file,
				      &my_id,
				      i + 1,
				      buff_ptr);

	   break;				/* Break out of for loop */
	 }

         if ((item_num + 1) < *list_size) /* Buffer is full -- reuse */
           i = -1;			  /* Set to -1 because for loop ++ */				
       }

       item_num++;			/* Report the next item */ 
    }

wrapup:
  if (action == 1)			/* If the points were malloced, */
  {					/*  free the space.             */
    om$dealloc(ptr = polyline.points);
  }

  return(status);
}
end implementation GRlinear;

