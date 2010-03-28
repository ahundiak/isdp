/******************************************************************************
*
* Description:
*
*    This method reports on circular arc geometry.
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
*  This method reports on the geometry of circular arc objects.
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


class implementation GRcirarc;

#include "grimport.h"
#include "msdef.h"
#include "grmessage.h"
#include "go.h"
#include "revieweledef.h"

method GRreport( IGRlong *msg; struct GRmd_env *md_env; IGRint *list_size;
                 struct GRreport_item *list;
                 struct GRreport_processor *processor )
{
  IGRint 	i;
  IGRint	items_in_buff;      /* Number of items buffer will hold */
  IGRint 	status;

  struct GRreport_item	buff[GRCIRARC_FORM_FIXED_SIZE];
  struct GRreport_item  *buff_ptr;

  struct IGRarc arc;		    /* Arc geometry to report on */
  struct GRobj_info obj_info;       /* Geometry info */

  IGRdouble startpt[3], endpt[3];   /* Start and End points of arc */

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  				    /* See that list_size is valid */
  if (*list_size != GRCIRARC_FORM_FIXED_SIZE)
  {
    *list_size = GRCIRARC_FORM_FIXED_SIZE;
    *msg = MSINARG;
    goto wrapup;
  }

  if (list == NULL)                 /* Use default item buffer */
    buff_ptr = buff;

  else                              /* Used buffer passed in */
    buff_ptr = list;

  items_in_buff = *list_size;     /* Fill up entire buffer before sending */

  status = om$send (msg =  message GRcirarc.GRgetarc
			  (msg,
			   &md_env->md_env.matrix_type,
			   md_env->md_env.matrix,
			   &arc),
		   targetid = my_id);

  if (!(status & *msg & 1))
    goto wrapup;

					/* Determine CIRARC endpts */
  status = om$send (msg =  message GRcurve.GRendpts
			  (msg,
			   &md_env->md_env.matrix_type,
			   md_env->md_env.matrix,
			   startpt,
			   endpt),
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
/*            buff_ptr[i].desc = GR_I_GRDiam;*/
            buff_ptr[i].label = CIR_ARC_GEOM_SF_DIAMETER;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_double | GR_distance;
	    buff_ptr[i].GRreport_data.dvalue = arc.prim_axis * 2;
	    break;
          }
	  case 1:
          {
/*            buff_ptr[i].desc = GR_I_GRRadius;*/
            buff_ptr[i].label = CIR_ARC_GEOM_SF_RADIUS;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_double | GR_distance;
	    buff_ptr[i].GRreport_data.dvalue = arc.prim_axis;
	    break;
          }
	  case 2:
          {
/*            buff_ptr[i].desc = GR_I_GRSweepAngle;*/
            buff_ptr[i].label = CIR_ARC_SWEEP_ANGLE_CIRCUMFERENCE;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_double | GR_angle;
	    buff_ptr[i].GRreport_data.dvalue = arc.sweep_angle;
	    break;
          }
	  case 3:
          {
            status = om$send ( msg =  message GRbspline.GRtotlength
				     (msg,
				     &md_env->md_env.matrix_type,
				      md_env->md_env.matrix,
				     &buff[i].GRreport_data.dvalue),
                   	       targetid = my_id);

	    if (!(status & *msg & 1))
	      goto wrapup;
				
/*            buff_ptr[i].desc = GR_I_GRArcLength;*/
            buff_ptr[i].label = CIR_ARC_ARC_LENGTH_AREA;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_double | GR_distance;
	    break;
          }
	  case 4:
          {
/*            buff_ptr[i].desc = GRC_I_coordsys;*/
            buff_ptr[i].label = CIR_ARC_GEOM_SF_CS_NAME;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_coord_sys;
	    break;
          }
	  case 5:
          {
            buff_ptr[i].label = CIR_ARC_GEOM_SF_UNIT1;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 6:
          {
            buff_ptr[i].label = CIR_ARC_GEOM_SF_UNIT2;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 7:
          {
            buff_ptr[i].label = CIR_ARC_GEOM_SF_UNIT3;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 8:
          {
            buff_ptr[i].label = CIR_ARC_GEOM_SF_COOR1_LABEL;
            buff_ptr[i].format_mask  = GR_coord1;
	    break;
          }
	  case 9:
          {
            buff_ptr[i].label = CIR_ARC_GEOM_SF_COOR2_LABEL;
            buff_ptr[i].format_mask  = GR_coord2;
	    break;
          }
	  case 10:
          {
            buff_ptr[i].label = CIR_ARC_GEOM_SF_COOR3_LABEL;
            buff_ptr[i].format_mask  = GR_coord3;
	    break;
          }
	  case 11:
          {
/*            buff_ptr[i].desc = GR_I_GRCenter;*/
            buff_ptr[i].label = CIR_ARC_KEYPTS_ORIGIN;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
            buff_ptr[i].GRreport_data.point[0] = arc.origin[0];
            buff_ptr[i].GRreport_data.point[1] = arc.origin[1];
            buff_ptr[i].GRreport_data.point[2] = arc.origin[2];

	    break;
          }
	  case 12:
          {
/*            buff_ptr[i].desc = GR_I_GREndPt1;*/
            buff_ptr[i].label = CIR_ARC_KEYPTS_ORIGIN;
	    buff_ptr[i].row   = 1;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
            buff_ptr[i].GRreport_data.point[0] = startpt[0];
            buff_ptr[i].GRreport_data.point[1] = startpt[1];
            buff_ptr[i].GRreport_data.point[2] = startpt[2];

	    break;
          }

	  case 13:
          {
/*            buff_ptr[i].desc = GR_I_GREndPt2;*/
            buff_ptr[i].label = CIR_ARC_KEYPTS_ORIGIN;
	    buff_ptr[i].row   = 2;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
            buff_ptr[i].GRreport_data.point[0] = endpt[0];
            buff_ptr[i].GRreport_data.point[1] = endpt[1];
            buff_ptr[i].GRreport_data.point[2] = endpt[2];

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
end implementation GRcirarc;

