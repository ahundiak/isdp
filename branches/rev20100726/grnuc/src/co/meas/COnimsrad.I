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

    IGRlong CO_ni_measure_radius(msg,
                                 events,
                                 module_info,
                                 radius,
                                 units,
                                 my_id,
                                 my_channel_struct,
                                 object_grid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *events[];
    struct GRmd_env      *module_info;
    IGRdouble            *radius;
    IGRchar              *units;
    GRobjid               my_id;
    OM_S_CHANSELECT      *my_channel_struct;
    struct GRid          *object_grid;
                                                                               

Abstract
    This function measures the radius of a circle
                                                                            
Arguments

    msg
        return codes

    events
        not used

    module
        context of located object

    cob_id
        object id of calling object, or at least some object

    radius
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

from GRconic import GRgetarc;

/*----------------------------------------
 *  CO_ni_measure_radius
 *----------------------------------------
 */
IGRlong CO_ni_measure_radius(msg,
			     events,
			     module_info,
			     radius,
			     units,
			     my_id,
			     my_channel_struct,
			     object_grid )
                                                                               
     IGRlong              *msg;
     struct GRevent       *events[];
     struct GRmd_env      *module_info;
     IGRdouble            *radius;
     IGRchar              *units;
     GRobjid               my_id;
     OM_S_CHANSELECT      *my_channel_struct;
     struct GRid          *object_grid;
     
{
  IGRlong             status;         /* return code                      */
  struct IGRarc       arc;
  IGRmatrix           local_matrix;
  IGRshort            local_matrix_type;
  
  
  _m_debug_str( "CO_ni_measure_radius." );
  
  status = COcompute_acs_lcl_matrix(msg,
				    module_info->md_env.matrix_type,
				    module_info->md_env.matrix,  
				    &local_matrix_type,
                                    local_matrix);
  /*
   *     measure the element
   */
  if ( my_channel_struct != NULL )
    {
      /*
       *  send by channel
       */
      status = om$send(msg = message GRconic.GRgetarc(msg,
						      &local_matrix_type,
						      local_matrix,
						      &arc ),
		       p_chanselect = my_channel_struct );
    }
  else
    {
      /*
       *  send by object
       */
      status = om$send(msg = message GRconic.GRgetarc(msg,
						      &local_matrix_type,
						      local_matrix,
						      &arc ),
		       targetid = object_grid->objid,
		       targetos = object_grid->osnum );
    }
  _m_check2p( status, *msg, "COnimsrad - failed GRgetarc" );
  
  
  /*
   *  get the radius from the arc data structure
   */
  *radius = arc.prim_axis;
  
  
  /*
   *  we are measuring distance
   */
  strncpy( units, GRIO_DISTANCE, GRIO_MAX_ALIAS_SIZE );
  
  return( status );



}


end implementation Root;






