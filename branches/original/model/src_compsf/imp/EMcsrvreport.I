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
*  (O) IGRlong                            *msg                   Error Message
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
*    msm        05/14/91    creation date.
*/

/*
 *    srh        06/20/91    added EMreport, EMreport_defaults, and EMupdate
 *    amd        02/26/92    modified to take care of single surfaces
 *
 *  Major KLUDGE in EMreport/EMupdate methods below:
 *   NDnode parms store angles in degrees because they know nothing of 
 *   the Units of Measure (UOM) subsystem.  We have to convert them to 
 *   internal DB units (radians) since we display the values using UOM
 *   interfaces.  SRH 7/15/91
 *
 *
 */


class implementation EMSrevcompsf;

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
#include "EMSsfparms.h"
#include "EMSommacros.h"   /* ems$get_memory   */
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "EC_I.h"
#include "nddef.h"
#include "asmacros.h"
#include "ndmacros.h"
#include "OMmacros.h"

#define BUFFER_SIZE  400

/* Edit Parameter gadget nbrs */
#define  EM_EDIT_PARM_MCF         (11)
#define  EM_EDIT_PARM_FRM_TITLE   (18)

#define  NBR_ITEMS                (5)
#define  NBR_EDIT_PARMS           (4) /* no vector for now */

/* list indices */
#define  ELEMENT                  (0)
#define  AXIS_PT                  (1)
#define  START_ANGLE              (2)
#define  END_ANGLE                (3)

/* param_info indices */
#define  ELEMENT_INDEX            (0)
#define  AXIS_PT_INDEX            (1)
#define  DIRECTION_VECTOR_INDEX   (2)
#define  START_ANGLE_INDEX        (3)
#define  END_ANGLE_INDEX          (4)


from EMSrevol     import EMgetRevolvedFormat;
from EMSparamgm   import EMgetgeom;
from EMSparamgm   import EMconstruct;  
from EMSparameter import EMis_externally_constrained;
from expression   import NDgive_value;
from expression   import NDset_value;



method GRreport(IGRlong *msg; struct GRmd_env *md_env; IGRint *list_size;
                struct GRreport_item *list; 
                struct GRreport_processor *processor )
{
  IGRint         i, buf_size=0, num_components, rvinx;
  IGRint        items_in_buff;      /* Number of items buffer will hold */
  IGRint         status;
  IGRpoint axis[2];        /* revolution axis */
  IGRdouble sweep_angle, start_angle;
  IGRdouble  static_doubles_buffer[BUFFER_SIZE], *doubles_buffer;


  IGRboolean        world = TRUE;            /* Convert to world coordinates */
  IGRboolean    is_360, pos_ort;
  GRrange        range;                    /* Range of composite */
  struct GRid *edges=NULL;
  struct IGRbsp_curve   curve;
  OM_S_CHANSELECT    to_comps;
  
  struct GRreport_item        buff[COMPSFRV_GEOM_SF_NUM_ITEMS];
  struct GRreport_item  *buff_ptr;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;

  status = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

  num_components = 0;

  status = om$send(msg = message GRowner.GRget_number_components
                    (msg, &num_components),
                targetid = my_id);
  EMomerr_hndlr ( status, wrapup, "GRget_number_components");

  if(num_components==1)
   {
    status = om$send(msg = OPPmargs, p_chanselect = &to_comps);
    EMomerr_hndlr ( status, wrapup, "GRreport");   
    goto wrapup;
   }
                                      /* See that list_size is valid */
  if (*list_size != COMPSFRV_GEOM_SF_NUM_ITEMS)
  {
    *list_size = COMPSFRV_GEOM_SF_NUM_ITEMS;
    *msg = MSINARG;
    goto wrapup;
  }

  if (list == NULL)                 /* Use default item buffer */
    buff_ptr = buff;

  else                              /* Used buffer passed in */
    buff_ptr = list;

  items_in_buff = *list_size;       /* Fill up entire buffer before sending */

  
                                        /* Determine range of composite */
   status = om$send(msg = message GRgraphics.GRgetrang
                         (msg,
                          &md_env->md_env.matrix_type,
                           md_env->md_env.matrix,
                          &world,
                          range),
                    targetid = my_id);

   if (!(status & *msg & 1))
     goto wrapup;

   /* Instead of relying on a surface of revolution being at index 0, loop
      around untill the revolved format is found.
      SM 09/25/92.
   */
   {
    IGRboolean got_it = FALSE;
    IGRint i;

    for(i=0; i<num_components; i++)
     {  
      status = om$send(msg = message EMSrevol.EMgetRevolvedFormat(msg,
                         TRUE, &md_env->md_env.matrix_type,
                         md_env->md_env.matrix, &curve, NULL, NULL,
                         NULL, NULL, NULL),
                    p_chanselect = &to_comps,
                   from = i, to = i);
       if (!(status & *msg & 1) ) continue;
       else {got_it = TRUE; rvinx = i; break;}
     }
    if(!got_it)
     {
      *msg = MSFAIL;
      goto wrapup;      
     }
    else
     {
      status = OM_S_SUCCESS;
      *msg = MSSUCC;
     }
   }

  ems$get_memory(rc = msg, element_size = sizeof(IGRdouble),
                 num_elements = curve.num_poles * (curve.rational ? 4:3) +
                                curve.num_knots,
                 buffer = (IGRchar *)static_doubles_buffer,
                 buffer_size = BUFFER_SIZE,
                 ptr = (IGRchar **) &doubles_buffer);

  curve.poles = doubles_buffer;
  curve.weights = curve.rational ?
                  doubles_buffer + curve.num_poles * 3 : NULL;
  curve.knots = doubles_buffer +
                curve.num_poles * (curve.rational ? 4 : 3);

  status = om$send(msg = message EMSrevol.EMgetRevolvedFormat(msg,
                   FALSE, &md_env->md_env.matrix_type,
                   md_env->md_env.matrix, &curve,(IGRdouble *)axis, &is_360,
                   &start_angle, &sweep_angle, &pos_ort),
                   p_chanselect = &to_comps,
                   from = rvinx, to = rvinx);
  if (!(status & *msg & 1) )
      goto wrapup;

    for (i=0; i < *list_size; i++)
    {
       buff_ptr[i].desc = 0;    /* Initialize message key in case it */
                                /*  isn't used                       */

       switch(i)
       {
      case 0:
          {
            buff_ptr[i].GRreport_data.ivalue = 0;
            status = om$send(msg = message EMSsurface.EMgetedges(msg,
                         EMS_OPT_CONNECTABLE, &edges, &buf_size,
                         &buff_ptr[i].GRreport_data.ivalue,
                         NULL, NULL, NULL, NULL),
                   targetid = my_id);            
            
       if (!(status & *msg & 1))
              goto wrapup;

        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_NUM_UNCON_EDGES;
        buff_ptr[i].row   = 0;
        buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_int;
        break;
          }
          case 1:
          {
            status = om$get_channel_count(object = me, 
                 p_chanselect = &to_comps,
                 count = (OMuint *)&buff_ptr[i].GRreport_data.ivalue);
            if (!(status & 1))
              goto wrapup;
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_NUM_COMPONENTS;
            buff_ptr[i].row   = 0;
            buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_int;
            break;
          }
      case 2:
          {
        buff_ptr[i].label = COMPSFRV_GEOM_SF_SWEEP_ANGLE;
        buff_ptr[i].row   = 0;
        buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_double | GR_angle;
        buff_ptr[i].GRreport_data.dvalue = sweep_angle * PI/180.0;
        break;
          }
          case 3:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_CS_NAME;
            buff_ptr[i].row   = 0;
            buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_coord_sys;
            break;
          }
          case 4:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_UNIT1;
            buff_ptr[i].row   = 0;
            buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
            break;
          }
          case 5:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_UNIT2;
            buff_ptr[i].row   = 0;
            buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
            break;
          }
          case 6:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_UNIT3;
            buff_ptr[i].row   = 0;
            buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
            break;
          }
          case 7:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_COOR1_LABEL;
        buff_ptr[i].format_mask  = GR_coord1;
            break;
          }
          case 8:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_COOR2_LABEL;
        buff_ptr[i].format_mask  = GR_coord2;
            break;
          }
          case 9:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_COOR3_LABEL;
        buff_ptr[i].format_mask  = GR_coord3;
            break;
          }
          case 10:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_KEYPTS;
            buff_ptr[i].row   = 0;
            buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = range[0];
        buff_ptr[i].GRreport_data.point[1] = range[1];
        buff_ptr[i].GRreport_data.point[2] = range[2];
            break;
          }
          case 11:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_KEYPTS;
            buff_ptr[i].row   = 1;
            buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = range[3];
        buff_ptr[i].GRreport_data.point[1] = range[4];
        buff_ptr[i].GRreport_data.point[2] = range[5];
            break;
          }
          case 12:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_KEYPTS;
            buff_ptr[i].row   = 2;
            buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = axis[0][0];
        buff_ptr[i].GRreport_data.point[1] = axis[0][1];
        buff_ptr[i].GRreport_data.point[2] = axis[0][2];
            break;
          }
          case 13:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_KEYPTS;
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





end implementation EMSrevcompsf;
