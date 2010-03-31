/******************************************************************************
*
* Description:
*
*    This method reports on surface of projection geometry.
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
*  This method reports on the geometry of surface of projection.
*
* Completion codes return in msg argument:
*       - MSSUCC if successful
*       - MSINARG if list_size does not equal the number of report items
*       - MSFAIL (severe) if other error
*
* History:
*
*    msm    06/06/91      creation date.
*
******************************************************************************/


class implementation EMSproject;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "gocmacros.h"
#include "grmessage.h"
#include "go.h"
#include "revieweledef.h"
#include "MDreveledef.h"
#include "EMSsfparms.h"
#include "bsparameters.h"

method GRreport( IGRlong *msg; struct GRmd_env *md_env; IGRint *list_size;
                 struct GRreport_item *list;
                 struct GRreport_processor *processor )
{
  IGRint 	i;
  IGRint	items_in_buff;      /* Number of items buffer will hold */
  IGRint 	status, last_pole;
  IGRdouble s, e, totlen;
  unsigned short   type;
  struct EMsurface_params   parms;
  struct IGRbsp_surface bsdef;

  struct GRreport_item	buff[SURFPJ_GEOM_SF_NUM_ITEMS];
  struct GRreport_item  *buff_ptr;

  struct GRobj_info obj_info;       /* Geometry info */
  extern IGRboolean  BSarclength();

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
    				    /* See that list_size is valid */
  if (*list_size != SURFPJ_GEOM_SF_NUM_ITEMS)
  {
    *list_size = SURFPJ_GEOM_SF_NUM_ITEMS;
    *msg = MSINARG;
    goto wrapup;
  }

  if (list == NULL)                 /* Use default item buffer */
    buff_ptr = buff;

  else                              /* Used buffer passed in */
    buff_ptr = list;

  items_in_buff = *list_size;     /* Fill up entire buffer before sending */

  parms.params.project.curve.poles = NULL;
  parms.params.project.curve.knots = NULL;
  parms.params.project.curve.weights = NULL;

  /*
   * Get the generating curve and the axis points.
   */

  status = om$send(msg = message EMSsurface.EMget_params(msg, NULL,
                         md_env, &type, &parms),
                   targetid = my_id);

  if (!(status & *msg & 1))
     goto wrapup;

  /* Get the bs def of the surface for planarity and such.
  */
  status = om$send(msg = message EMSsubbs.EMgetbsdef(msg, &bsdef), 
                   targetid = my_id);

  if (!(status & *msg & 1))
     goto wrapup;

  s = 0.0;
  e = 1.0;
  status = BSarclength(msg, &parms.params.project.curve, &s, &e,
                    &totlen);

  if (!(status & 1))
     goto wrapup;
  if (*msg & 0)
     goto wrapup;

  last_pole = (parms.params.project.curve.num_poles - 1) * 3;

    for (i=0; i < *list_size; i++)
    {
       buff_ptr[i].desc = 0;    /* Initialize message key in case it */
                                /*  isn't used                       */

       switch(i)
       {
	  case 0:
          {
        buff_ptr[i].label = SURFPJ_GEOM_SF_ORDER;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_int;
	    buff_ptr[i].GRreport_data.ivalue = parms.params.project.curve.order;
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
            if (bsdef.u_phy_closed)
              strcpy (buff_ptr[i].GRreport_data.string, "YES");
            else
              strcpy (buff_ptr[i].GRreport_data.string, "NO");
	    break;
          }
	  case 5:
          {
        buff_ptr[i].label = SURFPJ_GEOM_SF_NUM_POLES;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_int;
	    buff_ptr[i].GRreport_data.ivalue = 
                         bsdef.u_num_poles;
	    break;
          }
	  case 6:
          {
        buff_ptr[i].label = SURFPJ_GEOM_SF_LENGTH;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_double | GR_distance;
        buff_ptr[i].GRreport_data.dvalue = totlen;
	    break;
          }
	  case 7:
          {
        buff_ptr[i].label = SURFPJ_GEOM_SF_CS_NAME;
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
        buff_ptr[i].label = SURFPJRV_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 0;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = 
                    parms.params.project.curve.poles[0];
        buff_ptr[i].GRreport_data.point[1] =
                    parms.params.project.curve.poles[1];
        buff_ptr[i].GRreport_data.point[2] = 
                    parms.params.project.curve.poles[2];
	    break;
          }
	  case 15:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 1;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = 
                    parms.params.project.curve.poles[last_pole];
        buff_ptr[i].GRreport_data.point[1] = 
                    parms.params.project.curve.poles[last_pole + 1];
        buff_ptr[i].GRreport_data.point[2] =
                    parms.params.project.curve.poles[last_pole + 2];
	    break;
          }
	  case 16:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 2;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = 
                    parms.params.project.axis_point0[0];
        buff_ptr[i].GRreport_data.point[1] = 
                    parms.params.project.axis_point0[1];
        buff_ptr[i].GRreport_data.point[2] =
                    parms.params.project.axis_point0[2];
	    break;
          }
	  case 17:
          {
        buff_ptr[i].label = SURFPJRV_GEOM_SF_KEYPTS;
	    buff_ptr[i].row   = 3;
	    buff_ptr[i].col   = 0;
	    buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = 
                    parms.params.project.axis_point1[0];
        buff_ptr[i].GRreport_data.point[1] = 
                    parms.params.project.axis_point1[1];
        buff_ptr[i].GRreport_data.point[2] =
                    parms.params.project.axis_point1[2];
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
    if (parms.params.project.curve.poles) om$dealloc(ptr =
                                      parms.params.project.curve.poles);
    if (parms.params.project.curve.knots) om$dealloc(ptr =
                                      parms.params.project.curve.knots);
    if (parms.params.project.curve.weights) om$dealloc(ptr =
                                      parms.params.project.curve.weights);
  return(status);
}

end implementation EMSproject;

