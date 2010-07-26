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

    IGRlong CO_ni_measure_area(
                msg,
                events,
                module_info,
                area,
                units,
                my_id,
                my_channel_struct,
                object_grids )
                                                                               
    IGRlong              *msg;
    struct GRevent       *events[];
    struct GRmd_env      *module_info;
    IGRdouble            *area;
    IGRchar              *units;
    GRobjid               my_id;
    OM_S_CHANSELECT      *my_channel_struct;
    struct GRid          *object_grids;
                                                                               

Abstract
    This function modifies an element
                                                                            
Arguments

    msg
        return codes

    events
        not used.

    module
        context of located object

    cob_id
        object id of calling object, or at least some object

    area
        value of everything that we measure

    units
        returned by the function, units specify whether distance/angle
        is to be used

    p_chanselect
        pointer to a chaselect structure for located object on channel

    object_grids
        object to measure

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

History
    trc 03/19/87 : created

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
from GRcurve    import GRarea;

/*----------------------------------------
 *  CO_ni_measure_area
 *----------------------------------------
 */
IGRlong CO_ni_measure_area(msg,
			   events,
			   module_info,
			   area,
			   units,
			   my_id,
			   my_channel_struct,
			   object_grids )
     
     IGRlong              *msg;
     struct GRevent       *events[];
     struct GRmd_env      *module_info;
     IGRdouble            *area;
     IGRchar              *units;
     GRobjid               my_id;
     OM_S_CHANSELECT      *my_channel_struct;
     struct GRid          *object_grids;
     
{
  IGRlong             status;         /* return code                      */
  IGRmatrix           local_matrix;
  IGRshort            local_matrix_type;
  
  
  _m_debug_str( "CO_ni_measure_area." );
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
      status = om$send(msg = message GRcurve.GRarea(msg,
						    &local_matrix_type,
						    local_matrix,
						    area ),
		       p_chanselect = my_channel_struct );
    }
  else
    {
      /*
       *  send by object
       */
      status = om$send(msg = message GRcurve.GRarea(msg,
						    &local_matrix_type,
						    local_matrix,
						    area ),
		       targetid = object_grids->objid,
		       targetos = object_grids->osnum );
    }
  _m_check2p( status, *msg, "CO_ni_measure_area - failed GRarea" );
  
  
  /*
   *  we are measuring distance
   */
  strncpy( units, GRIO_AREA, GRIO_MAX_ALIAS_SIZE );
  
  return( status );
}

end implementation Root;
