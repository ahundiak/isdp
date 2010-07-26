/******************************************************************************
*
* Description:
*
*    This method reports on elliptical arc geometry.
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
*  This method reports on the geometry of elliptical arc objects.
*
* Completion codes return in msg argument:
*       - MSSUCC if successful
*       - MSINARG if list_size does not equal the number of report items
*       - MSFAIL (severe) if other error
*
* History:
*
*    msm 	04/30/91    creation date.
*
******************************************************************************/


class implementation GRellarc;

#include "grimport.h"
#include "msdef.h"
#include "grmessage.h"
#include "go.h"
#include "revieweledef.h"
#include "macos.h"


method GRreport( IGRlong *msg; struct GRmd_env *md_env; IGRint *list_size;
                 struct GRreport_item *list;
                 struct GRreport_processor *processor )
{
  IGRint 	i;
  IGRint	items_in_buff;      /* Number of items buffer will hold */
  IGRint 	status;

  struct GRreport_item	buff[GRELLARC_FORM_FIXED_SIZE];
  struct GRreport_item  *buff_ptr;

  struct IGRarc arc;		    /* Arc geometry to report on */
  struct GRobj_info obj_info;       /* Geometry info */

  IGRdouble 	major_axis, minor_axis;
  IGRdouble	aspect_ratio;
  IGRdouble 	startpt[3], endpt[3]; /* Start and End points of arc */

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  
                                    /* See that list_size has valid */
  if (*list_size != GRELLARC_FORM_FIXED_SIZE)
  {
    *list_size = GRELLARC_FORM_FIXED_SIZE;
    *msg = MSINARG;
    goto wrapup;
  }

  if (list == NULL)                 /* Use default item buffer */
    buff_ptr = buff;

  else                              /* Used buffer passed in */
    buff_ptr = list;

  items_in_buff = *list_size;     /* Fill up entire buffer before sending */

  status = om$send (msg =  message GRellarc.GRgetarc
			  (msg,
			   &md_env->md_env.matrix_type,
			   md_env->md_env.matrix,
			   &arc),
		   targetid = my_id);

  if (!(status & *msg & 1))
    goto wrapup;

  if ( arc.prim_axis >= arc.sec_axis )			/* Determine axes */
  {
    major_axis = arc.prim_axis * 2;
    minor_axis = arc.sec_axis * 2;
  }
  else
  {
    major_axis = arc.sec_axis * 2;
    minor_axis = arc.prim_axis * 2;
  }

						/* Determine ELLARC endpts */
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
/*            buff_ptr[i].desc = GR_I_GRMajAxis;*/
            buff_ptr[i].label = ELL_ARC_GEOM_SF_MAJ_AXIS;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_double | GR_distance;
	    buff_ptr[i].GRreport_data.dvalue = major_axis;
	    break;
          }
	  case 1:
          {
/*            buff_ptr[i].desc = GR_I_GRMinAxis;*/
            buff_ptr[i].label = ELL_ARC_GEOM_SF_MIN_AXIS;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_double | GR_distance;
	    buff_ptr[i].GRreport_data.dvalue = minor_axis;
	    break;
          }
	  case 2:
          {
	    aspect_ratio = minor_axis / major_axis;
/*            buff_ptr[i].desc = GR_I_GRAspectRatio;*/
            buff_ptr[i].label = ELL_ARC_GEOM_SF_ASPECT_RATIO;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_double | GR_distance;
	    buff_ptr[i].GRreport_data.dvalue = aspect_ratio;
	    break;
          }
	  case 3:
          {
/*            buff_ptr[i].desc = GR_I_GRAppRotAngle;*/
            buff_ptr[i].label = ELL_ARC_GEOM_SF_APP_ROT_ANGLE;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_double | GR_distance;
	    buff_ptr[i].GRreport_data.dvalue = MAcos(msg, &aspect_ratio);
	    break;
          }
	  case 4:
          {
/*            buff_ptr[i].desc = GR_I_GRSweepAngle;*/
            buff_ptr[i].label = ELL_ARC_SWEEP_ANGLE_PERIMETER;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_double | GR_angle;
	    buff_ptr[i].GRreport_data.dvalue = arc.sweep_angle;
	    break;
          }
	  case 5:
          {					/* Determine arc length */
            status = om$send ( msg =  message GRbspline.GRtotlength
				     (msg,
				     &md_env->md_env.matrix_type,
				      md_env->md_env.matrix,
				     &buff_ptr[i].GRreport_data.dvalue),
                   	       targetid = my_id);

	    if (!(status & *msg & 1))
	      goto wrapup;
				
/*            buff_ptr[i].desc = GR_I_GRArcLength;*/
            buff_ptr[i].label = ELL_ARC_ARC_LENGTH_AREA;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_double | GR_distance;
	    break;
          }
	  case 6:
          {
/*            buff_ptr[i].desc = GRC_I_coordsys;*/
            buff_ptr[i].label = ELL_ARC_GEOM_SF_CS_NAME;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_coord_sys;
	    break;
          }
	  case 7:
          {
            buff_ptr[i].label = ELL_ARC_GEOM_SF_UNIT1;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 8:
          {
            buff_ptr[i].label = ELL_ARC_GEOM_SF_UNIT2;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 9:
          {
            buff_ptr[i].label = ELL_ARC_GEOM_SF_UNIT3;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 10:
          {
            buff_ptr[i].label = ELL_ARC_GEOM_SF_COOR1_LABEL;
            buff_ptr[i].format_mask  = GR_coord1;
	    break;
          }
	  case 11:
          {
            buff_ptr[i].label = ELL_ARC_GEOM_SF_COOR2_LABEL;
            buff_ptr[i].format_mask  = GR_coord2;
	    break;
          }
	  case 12:
          {
            buff_ptr[i].label = ELL_ARC_GEOM_SF_COOR3_LABEL;
            buff_ptr[i].format_mask  = GR_coord3;
	    break;
          }
	  case 13:
          {
/*            buff_ptr[i].desc = GR_I_GRCenter;*/
            buff_ptr[i].label = ELL_ARC_KEYPTS_ORIGIN;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
            buff_ptr[i].GRreport_data.point[0] = arc.origin[0];
            buff_ptr[i].GRreport_data.point[1] = arc.origin[1];
            buff_ptr[i].GRreport_data.point[2] = arc.origin[2];

	    break;
          }
	  case 14:
          {
/*            buff_ptr[i].desc = GR_I_GREndPt1;*/
            buff_ptr[i].label = ELL_ARC_KEYPTS_ORIGIN;
	    buff_ptr[i].row   = 1;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
            buff_ptr[i].GRreport_data.point[0] = startpt[0];
            buff_ptr[i].GRreport_data.point[1] = startpt[1];
            buff_ptr[i].GRreport_data.point[2] = startpt[2];

	    break;
          }
	  case 15:
          {
/*            buff_ptr[i].desc = GR_I_GREndPt2;*/
            buff_ptr[i].label = ELL_ARC_KEYPTS_ORIGIN;
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
end implementation GRellarc;

