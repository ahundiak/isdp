/* #######################    APOGEE COMPILED   ######################## */
/* 
    Name

    IGRlong CO_ni_measure_min_dist_point_to_element(msg,
                                                    events,
                                                    module_info,
                                                    distance,
                                                    units,
                                                    my_id,
                                                    my_chan_struct,
                                                    object_grid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *events[];
    struct GRmd_env      *module_info;
    IGRdouble            *distance;
    IGRchar              *units;
    GRobjid               my_id;
    OM_S_CHANSELECT      *my_chan_struct;
    struct GRid          *object_grid;
                                                                               

Abstract
    This function measures the minimum distance between a data point and an element;
    the absolute/local and apparent projection flags are used in determining the calculated
    distance.
                                                               
Arguments

    msg
        return codes

    events
       events[0] - base point 
       events[1] - accept point of locate operation

    module
        context of located object

    cob_id
        object id of calling object, or at least some object

    distance
        value of everything that we measure

    units
        returned by the function, units specify whether distance/angle
        is to be used

    p_chanselect
        pointer to a chaselect structure for located object on channel

    object_grid
        object to measure

Status returns

    om return codes

History

    xxx 00/00/00 : Genesis
    scw 12/07/89 : Added local/absolute & true/apparent checking 
    srh 03/13/90 : removed local/absolute & true/apparent checking 

*/
class implementation Root;

#include "coimport.h"
#include "codebug.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "grdpbdef.h"
#include "griodef.h"
#include "madef.h"
#include "msdef.h"
#include "godef.h"
#include "dp.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "grdpbmacros.h"

/*---------------------------------------------
 *  Externs & Imports   (made in USA) NO RICE
 *---------------------------------------------
 */
extern  IGRboolean  BSlngen();
extern  void        BSmdstptcv();
extern  IGRboolean  CO_ni_world_to_view();

from GRgraphics  import GRptproject;
from GRlinear    import GRsegfind;

/*----------------------------------------
 *  CO_ni_measure_min_dist_point_to_element
 *----------------------------------------
 */
IGRlong CO_ni_measure_min_dist_point_to_element( msg,
                                                 events,
                                                 module_info,
                                                 distance,
                                                 units,
                                                 my_id,
                                                 my_chan_struct,
                                                 object_grid )

     IGRlong              *msg;
     struct GRevent       *events[];
     struct GRmd_env      *module_info;
     IGRdouble            *distance;
     IGRchar              *units;
     GRobjid               my_id;
     OM_S_CHANSELECT      *my_chan_struct;
     struct GRid          *object_grid;
     
{
  IGRint              type,
                      num_pts = 1;
  IGRlong             status,
                      number_of_bytes,
                      bytes_received;
  IGRpoint            from_point,
                      proj_point,
                      proj_lcl_point,
                      line_point1,
                      line_point2;
  IGRdouble           t_parm,
                      dummy;
  IGRboolean          b_status,
                      absolute_flag;
  struct GRparms      proj_parms,
                      segment_parms;
  
  GRls_declare( bs_curve, pole_knot_buff );

  /* this is the fixed point */
  from_point[0] = events[0]->event.button.x;
  from_point[1] = events[0]->event.button.y;
  from_point[2] = events[0]->event.button.z;


  /* check for local/absolute flag */
  number_of_bytes = sizeof( absolute_flag );
  status = gr$get_local_abs_flag( msg    =  msg,
                                  sizbuf = &number_of_bytes,
                                  buffer = &absolute_flag,
                                  nret   = &bytes_received );
  if( absolute_flag == 0 ) /* is local mode */
  {
     segment_parms = events[1]->located_object[0].geom_parms;

     if ( my_chan_struct != NULL )
     {
        status = om$send( msg = message GRlinear.GRsegfind( 
                                              msg, 
                                             &module_info->md_env.matrix_type,
                                              module_info->md_env.matrix,
                                             &segment_parms, 
                                              line_point1,
                                              line_point2 ),
                          p_chanselect = my_chan_struct );
     }
     else
     {
        status = om$send( msg = message GRlinear.GRsegfind( 
                                              msg, 
                                             &module_info->md_env.matrix_type,
                                              module_info->md_env.matrix,
                                             &segment_parms, 
                                              line_point1,
                                              line_point2 ),
                          targetid = object_grid->objid,
                          targetos = object_grid->osnum );
     }
     if( status & *msg & 1 )
     {
        GRls_init( bs_curve, pole_knot_buff );

        b_status = BSlngen( msg, 
                            line_point1, 
                            line_point2, 
                           &bs_curve, 
                           &type );

        BSmdstptcv(&bs_curve,
                    from_point,
                   &t_parm,
                    proj_point, /* returned */
                   &dummy,
                    msg );

     }
     else /* we have a non-linear segment - perhaps a curve */
     {
        if ( my_chan_struct != NULL )
        {
           /*  send by channel  */
           status = om$send( msg = message GRgraphics.GRptproject(
                                        msg,
                                       &module_info->md_env.matrix_type,
                                        module_info->md_env.matrix,
                                        from_point,
                                        proj_point, /* returned */
                                       &proj_parms ),
                             p_chanselect = my_chan_struct );
        }
        else
        {
           /* send by object */
           status = om$send( msg = message GRgraphics.GRptproject(
                                        msg,
                                       &module_info->md_env.matrix_type,
                                        module_info->md_env.matrix,
                                        from_point,
                                        proj_point,
                                       &proj_parms ),
                             targetid = object_grid->objid,
                             targetos = object_grid->osnum );
        }
     }
  }
  else /* absolute mode */
  {

     if ( my_chan_struct != NULL )
     {
        /*  send by channel  */
        status = om$send( msg = message GRgraphics.GRptproject(
                                        msg,
                                       &module_info->md_env.matrix_type,
                                        module_info->md_env.matrix,
                                        from_point,
                                        proj_point,
                                       &proj_parms ),
                          p_chanselect = my_chan_struct );
     }
     else
     {
        /* send by object */
        status = om$send( msg = message GRgraphics.GRptproject(
                                        msg,
                                       &module_info->md_env.matrix_type,
                                        module_info->md_env.matrix,
                                        from_point,
                                        proj_point,
                                       &proj_parms ),
                          targetid = object_grid->objid,
                          targetos = object_grid->osnum );
     }
  }

  status = COcvt_pts_to_lcl_coord( msg,
                                   num_pts,
                                   proj_point,
                                   proj_lcl_point );

  status = COcvt_pts_to_lcl_coord( msg,
                                   num_pts,
                                   from_point,
                                   from_point );

  status = MA2ptdis( msg,
                     from_point,
                     proj_lcl_point,
                     distance );

  events[1]->event.button.x = proj_point[0];
  events[1]->event.button.y = proj_point[1];
  events[1]->event.button.z = proj_point[2];

  /* 
   * KLUDGE ALLERT!  ALL THE MEASUREMENT CODE NEEDS TO BE REWORKED 
   * Shelley Heard 10/8/92 
   */
  *events[4] = *events[1];

  /*
   *  we are measuring distance
   */
  strncpy( units, GRIO_DISTANCE, GRIO_MAX_ALIAS_SIZE );
  
  return( status );
}

end implementation Root;




