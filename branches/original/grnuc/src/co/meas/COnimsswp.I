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

    IGRlong CO_ni_measure_sweep_angle(
                msg,
                Events,
                ModuleInfo,
                SweepAngle,
                Units,
                my_id,
                MyChannelStruct,
                ObjectsGrid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo;
    IGRdouble            *SweepAngle;
    IGRchar              *Units;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;
    struct GRid          *ObjectsGrid;
                                                                               

Abstract
    This function measures the sweep_angle of an element
                                                                            
Arguments

    msg
        return codes

    events
        not used

    module
        context of located object

    cob_id
        object id of calling object, or at least some object

    SweepAngle
        value of everything that we measure

    Units
        returned by the function, units specify whether distance/angle
        is to be used

    p_chanselect
        pointer to a chaselect structure for located object on channel

    ObjectsGrid
        object to measure

Status returns

    om error codes

History
    trc 03/27/87 : created

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




from GRconic    import GRgetarc;



/*----------------------------------------
 *  CO_ni_measure_sweep_angle
 *----------------------------------------
 */
IGRlong CO_ni_measure_sweep_angle(
                msg,
                Events,
                ModuleInfo,
                SweepAngle,
                Units,
                my_id,
                MyChannelStruct,
                ObjectsGrid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo;
    IGRdouble            *SweepAngle;
    IGRchar              *Units;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;
    struct GRid          *ObjectsGrid;
                                                                               
{
    IGRlong             status;         /* return code                      */
    struct IGRarc       Arc;


    _m_debug_str( "COnimssweep." );


    /*
     *     measure the element
     */
    if ( MyChannelStruct != NULL )
    {
        /*
         *  send by channel
         */
        status = om$send(
                    msg = message GRconic.GRgetarc(
                        msg,
                        &ModuleInfo->md_env.matrix_type,
                        ModuleInfo->md_env.matrix,
                        &Arc ),
                    p_chanselect = MyChannelStruct );
    }
    else
    {
        /*
         *  send by object
         */
        status = om$send(
                    msg = message GRconic.GRgetarc(
                        msg,
                        &ModuleInfo->md_env.matrix_type,
                        ModuleInfo->md_env.matrix,
                        &Arc ),
                    targetid = ObjectsGrid->objid,
                    targetos = ObjectsGrid->osnum );
    }
    _m_check2p( status, *msg, "COnimssweep - failed GRgetarc" );
    _m_debug_str( "COnimssweep - am out of GRgetarc." );


    /*
     *  get the sweep angle from the arc data structure
     */
    *SweepAngle = Arc.sweep_angle;


    /*
     *  we are measuring distance
     */
    strncpy( Units, GRIO_ANGLE, GRIO_MAX_ALIAS_SIZE );

    return( status );
}

end implementation Root;
