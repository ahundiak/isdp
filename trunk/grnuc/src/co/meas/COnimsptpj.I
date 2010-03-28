/* #######################    APOGEE COMPILED   ######################## */
 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/* 
    Name

    IGRlong CO_ni_measure_distance_to_projection(
                msg,
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
    This function measures the distance_to_projection of a circle
                                                                            
Arguments

    msg
        return codes

    events
        not used

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
    trc 03/24/87 : created

*/
class implementation Root;

#include "coimport.h"
#include "codebug.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "madef.h"
#include "msdef.h"
#include "dp.h"

from GRgraphics import GRlnproject;

/*----------------------------------------
 *  CO_ni_measure_distance_to_projection
 *----------------------------------------
 */
IGRlong CO_ni_measure_distance_to_projection(msg,
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
  IGRlong             status;         /* return code                      */
  IGRpoint            from_point;    /* center point                     */
  IGRpoint            to_point;      /* point on the edge of the circle  */
  IGRdouble           bore_points[6];  /* points to store boreline         */
  struct IGRline      bore_line;       /* boreline for apparent project    */
  IGRpoint            dummy_point;
  IGRdouble           dummy_double;
  IGRboolean          b_status;
  IGRpoint            lcl_to_point;
  IGRint              num_pts = 1;
    
  _m_debug_str( "COnimsptproj." );
  
  /*
   *  set up user's data point in an IGRpoint
   */
  from_point[0] = events[0]->event.button.x;
  from_point[1] = events[0]->event.button.y;
  from_point[2] = events[0]->event.button.z;
  
  /*
   *  set boreline for apparent project
   */
  bore_line.point1 = &( bore_points[0] );
  bore_line.point2 = &( bore_points[3] );
  
  b_status = CObrln(msg,
                    &my_id,
                    events[0],
                    &bore_line );
  /*
   *  send to the graphic object to project
   *  the accept point onto the graphic object
   *  
   *  GOAL : find the ProjectedParms for the input point
   */
  if ( my_chan_struct != NULL )
    {
      /*  send by channel  */
      status = om$send(msg = message GRgraphics.GRlnproject(msg,
                                      &module_info->md_env.matrix_type,
                                       module_info->md_env.matrix,
							    &bore_line,
							    dummy_point,
							    to_point,
							    &dummy_double,
							   (struct GRparms *) &dummy_double ),
		       p_chanselect = my_chan_struct );
    }
  else
    {
      /* send by object */
      status = om$send(msg = message GRgraphics.GRlnproject(msg,
                        &module_info->md_env.matrix_type,
                        module_info->md_env.matrix,
							    &bore_line,
							    dummy_point,
							    to_point,
							    &dummy_double,
							   (struct GRparms *) &dummy_double ),
		       targetid = object_grid->objid,
		       targetos = object_grid->osnum );
    }
  _m_debug(
	   printf( "CO_ni_measure_distance_to_projection - to_point is:\n" );
	   printf( "                x %4.2f\n", to_point[0] );
	   printf( "                y %4.2f\n", to_point[1] );
	   printf( "                z %4.2f\n", to_point[2] );
	   );
  
  /*
   *  calculate the distance between the two points.
   */

  status = COcvt_pts_to_lcl_coord(msg,
				  num_pts,
				  to_point,
				  lcl_to_point);
  status = MA2ptdis(msg,
		    from_point,
		    lcl_to_point,
		    distance);
  _m_check2p( status, *msg, "COnimsptproj - failed MA2ptdis" );
  
  /*
   *  we are measuring distance
   */
  strncpy( units, GRIO_DISTANCE, GRIO_MAX_ALIAS_SIZE );
  
  return( status );
}

end implementation Root;
