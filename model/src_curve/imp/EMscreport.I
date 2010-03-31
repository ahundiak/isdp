/*
* Description:
*
*    This method reports on b-spline curve geometry.
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
*  This method reports on the geometry of b-spline curve objects.
*
* Completion codes return in msg argument:
*       - MSSUCC if successful
*       - MSINARG if list_size does not equal the number of report items
*       - MSFAIL (severe) if other error
*
* History:
*
*    msm    05/10/91      creation date.
*
******************************************************************************/


class implementation GRsubbc;

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
  IGRint 	i;
  IGRint	items_in_buff;      /* Number of items buffer will hold */
  IGRint 	status;

  struct GRreport_item	buff[BSCURVE_GEOM_SF_NUM_ITEMS];
  struct GRreport_item  *buff_ptr;

  struct IGRbsp_curve *curve;	    /* B-spline geometry to report on */
  struct GRobj_info obj_info;       /* Geometry info */
  struct IGResbc element_specific;  /* B-spline attributes */

  IGRdouble startpt[3], endpt[3];   /* Start and End points of curve */

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  curve = NULL;
  				    /* See that list_size is valid */
  if (*list_size != BSCURVE_GEOM_SF_NUM_ITEMS)
  {
    *list_size = BSCURVE_GEOM_SF_NUM_ITEMS;
    *msg = MSINARG;
    goto wrapup;
  }

  if (list == NULL)                 /* Use default item buffer */
    buff_ptr = buff;

  else                              /* Used buffer passed in */
    buff_ptr = list;

  items_in_buff = *list_size;     /* Fill up entire buffer before sending */

  GRgetabsg(msg, 
	    &md_env->md_env.matrix_type,
            md_env->md_env.matrix,
	    (IGRchar **) &curve,
            i);
  
  if (!(*msg & 1))
    goto wrapup;

					/* Determine BSCURVE endpts */
  status = om$send (msg = message GRcurve.GRendpts
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
        buff_ptr[i].label = BSCURVE_GEOM_SF_ORDER;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_int;
	    buff_ptr[i].GRreport_data.ivalue = curve->order;
	    break;
          }
	  case 1:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_RATIONALITY;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_string;
            if (curve->rational)
			 strcpy (buff_ptr[i].GRreport_data.string, "YES");
            else
			 strcpy (buff_ptr[i].GRreport_data.string, "NO");
	    break;
          }
	  case 2:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_PERIODICITY;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_string;
            if (curve->periodic)
              strcpy (buff_ptr[i].GRreport_data.string, "YES");
            else
              strcpy (buff_ptr[i].GRreport_data.string, "NO");
	    break;
          }
	  case 3:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_PLANARITY;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_string;
            if (curve->planar)
              strcpy (buff_ptr[i].GRreport_data.string, "YES");
            else
              strcpy (buff_ptr[i].GRreport_data.string, "NO");
	    break;
          }
	  case 4:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_OPENCLOSED;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_string;
            if (curve->phy_closed)
              strcpy (buff_ptr[i].GRreport_data.string, "YES");
            else
              strcpy (buff_ptr[i].GRreport_data.string, "NO");
	    break;
          }
	  case 5:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_NUM_POLES;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_int;
	    buff_ptr[i].GRreport_data.ivalue = curve->num_poles;
	    break;
          }
	  case 6:
          {
            status = om$send ( msg =  message GRcurve.GRtotlength
				     (msg,
				     &md_env->md_env.matrix_type,
				      md_env->md_env.matrix,
				     &buff[i].GRreport_data.dvalue),
                   	       targetid = my_id);

	    if (!(status & *msg & 1))
	      goto wrapup;
				
        buff_ptr[i].label = BSCURVE_GEOM_SF_LENGTH;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_double | GR_distance;
	    break;
          }
	  case 7:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_CS_NAME;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_coord_sys;
	    break;
          }
	  case 8:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_UNIT1;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 9:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_UNIT2;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 10:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_UNIT3;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
	    break;
          }
	  case 11:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_COOR1_LABEL;
        buff_ptr[i].format_mask  = GR_coord1;
	    break;
          }
	  case 12:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_COOR2_LABEL;
        buff_ptr[i].format_mask  = GR_coord2;
	    break;
          }
	  case 13:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_COOR3_LABEL;
        buff_ptr[i].format_mask  = GR_coord3;
	    break;
          }
	  case 14:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = startpt[0];
        buff_ptr[i].GRreport_data.point[1] = startpt[1];
        buff_ptr[i].GRreport_data.point[2] = startpt[2];
	    break;
          }

	  case 15:
          {
        buff_ptr[i].label = BSCURVE_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 1;
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
  GRabsg_del_all();
  return(status);
}

end implementation GRsubbc;

