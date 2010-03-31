/******************************************************************************
*
* Description:
*
*    This method reports on surface of projection geometry.
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
*
* Description:
*
*  This method reports on the geometry of surface of projection objects.
*
* Completion codes return in msg argument:
*       - MSSUCC if successful
*       - MSINARG if list_size does not equal the number of report items
*       - MSFAIL (severe) if other error
*
* History:
*
*    msm        05/14/91    creation date.
*    amd        02/26/92    modified to take care of single surfaces
******************************************************************************/


class implementation EMSprjcompsf;

#include "OMmacros.h"
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
#include "EMSasnuc.h"
#include "EMSas.h"
#include "EMSasdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asmacros.h"
#include "EC_I.h"
#include "report.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#define  NBR_PARENTS               (3)
#define  NBR_EDIT_PARAMS           (2) /* no vector */

/* order of params on NDfather_father channel (objlist) */
#define  ELEMENT_INDEX             (0)
#define  HEIGHT_INDEX              (1)
#define  DIRECTION_INDEX           (2)

/* order of params in form */
#define  ELEMENT                   (0)
#define  HEIGHT                    (1)

#define  EM_EDIT_PARM_MCF         (11)
#define  EM_EDIT_PARM_FRM_TITLE   (18)


from EMSparamgm   import EMconstruct;
from EMSparamgm   import EMgetgeom;
from EMSparameter import EMis_externally_constrained;
from expression   import NDgive_value;
from expression   import NDset_value;


method GRreport(IGRlong *msg;
                struct GRmd_env *md_env;
                IGRint *list_size;
                struct GRreport_item *list; 
                struct GRreport_processor *processor )
{
  IGRint         i, buf_size=0, num_components;
  IGRint         items_in_buff;      /* Number of items buffer will hold */
  IGRint         status;
  IGRdouble axis[6];        /* projection axis */
  unsigned short  type;
  struct EMsurface_params   parms;

  IGRboolean        world = TRUE;            /* Convert to world coordinates */

  GRrange        range;                    /* Range of composite */
  struct GRid *edges=NULL;
  OM_S_CHANSELECT    to_comps;
  
  struct GRreport_item        buff[COMPSFPJ_GEOM_SF_NUM_ITEMS];
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
  if (*list_size != COMPSFPJ_GEOM_SF_NUM_ITEMS)
  {
    *list_size = COMPSFPJ_GEOM_SF_NUM_ITEMS;
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


   
   if (! (status & 1))
      goto wrapup;
   status = om$send(msg = message EMSsurface.EMget_params (msg, NULL, md_env,
                    &type, &parms),
                    p_chanselect = &to_comps, from = 0, to = 0);
   if (!(status & *msg & 1))
     goto wrapup;
   
   get_projection_axis (msg, type, &parms, axis);

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
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_CS_NAME;
            buff_ptr[i].row   = 0;
            buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_coord_sys;
            break;
          }
          case 3:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_UNIT1;
            buff_ptr[i].row   = 0;
            buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
            break;
          }
          case 4:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_UNIT2;
            buff_ptr[i].row   = 0;
            buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
            break;
          }
          case 5:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_UNIT3;
            buff_ptr[i].row   = 0;
            buff_ptr[i].col   = 0;
        buff_ptr[i].format_mask  = GR_units | GR_distance;
            break;
          }
          case 6:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_COOR1_LABEL;
        buff_ptr[i].format_mask  = GR_coord1;
            break;
          }
          case 7:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_COOR2_LABEL;
        buff_ptr[i].format_mask  = GR_coord2;
            break;
          }
          case 8:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_COOR3_LABEL;
        buff_ptr[i].format_mask  = GR_coord3;
            break;
          }
          case 9:
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

          case 10:
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
          case 11:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_KEYPTS;
            buff_ptr[i].row   = 2;
            buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = axis[0];
        buff_ptr[i].GRreport_data.point[1] = axis[1];
        buff_ptr[i].GRreport_data.point[2] = axis[2];
            break;
          }

          case 12:
          {
        buff_ptr[i].label = COMPSFPJRV_GEOM_SF_KEYPTS;
            buff_ptr[i].row   = 3;
            buff_ptr[i].col   = 0;
            buff_ptr[i].format_mask  = GR_point | GR_local;
        buff_ptr[i].GRreport_data.point[0] = axis[3];
        buff_ptr[i].GRreport_data.point[1] = axis[4];
        buff_ptr[i].GRreport_data.point[2] = axis[5];
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

int get_projection_axis(msg,type,parms,axis)
IGRlong *msg;
IGRint type;
struct EMsurface_params  *parms;
IGRdouble *axis;
{
 IGRint i;

 *msg = EMS_S_Success;

 switch(type)
 {
   case EMcylinder:
   {

    OM_BLOCK_MOVE(parms->params.cyl.base_center,axis,sizeof(IGRpoint));

    for (i=0;i<3;i++)
     axis[3+i] = parms->params.cyl.base_center[i] + 
                 parms->params.cyl.height[i];
   }
   break;

   case EMcone:
   {

    OM_BLOCK_MOVE(parms->params.cone.base_center,axis,sizeof(IGRpoint));

    for (i=0;i<3;i++)
     axis[3+i] = parms->params.cone.base_center[i] + 
                 parms->params.cone.height[i];
   }
   break;

   case EMelliptical_cylinder:
   {
    struct EMelliptical_cylinder_params *ptr;

    ptr = &parms->params.elpcyl;

    OM_BLOCK_MOVE(ptr->base_center,axis,sizeof(IGRpoint));

    for (i=0;i<3;i++)
      axis[3+i] = ptr->base_center[i] + ptr->height[i];
   }
   break;

   case EMelliptical_cone:
   {
    struct EMelliptical_cone_params *ptr;

    ptr = &parms->params.elpcone;

    OM_BLOCK_MOVE(ptr->base_center,axis,sizeof(IGRpoint));

    for (i=0;i<3;i++)
      axis[3+i] = ptr->base_center[i] + ptr->height[i];
   }
   break;

   case EMpcylinder:
   {
    struct EMpartial_cylinder_params *ptr;

    ptr = &parms->params.pcyl;

    OM_BLOCK_MOVE(ptr->base_center,axis,sizeof(IGRpoint));

    for (i=0;i<3;i++)
      axis[3+i] = ptr->base_center[i] + ptr->height[i];
   }
   break;

   case EMpcone:
   {
    struct EMpartial_cone_params *ptr;

    ptr = &parms->params.pcone;

    OM_BLOCK_MOVE(ptr->base_center,axis,sizeof(IGRpoint));

    for (i=0;i<3;i++)
      axis[3+i] = ptr->base_center[i] + ptr->height[i];
   }
   break;

  case EMproject:
  {
   struct EMproject_params *ptr;

   ptr = &parms->params.project;

   OM_BLOCK_MOVE(ptr->axis_point0,axis,sizeof(IGRpoint) * 2);
   break;
  }

  default:
  {
   *msg = EMS_E_InvalidArg;
   return(0);
  }
 }
  return OM_S_SUCCESS;
}




end implementation EMSprjcompsf;
